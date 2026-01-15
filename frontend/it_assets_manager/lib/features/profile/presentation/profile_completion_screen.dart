import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/profile_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/location_models.dart';
import '../../../../utils/responsive_sizes.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _departmentController =
      TextEditingController(); // Used for MOH Dept or NGO Org Name
  final _positionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load provinces only if needed (MOH)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user?.userType == 'MOH') {
        context.read<ProfileProvider>().loadProvinces();
      }
    });
  }

  @override
  void dispose() {
    _departmentController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final profileProvider = context.read<ProfileProvider>();
      final authProvider = context.read<AuthProvider>();
      final userType = authProvider.user?.userType;

      bool success = false;
      if (userType == 'MOH') {
        success = await profileProvider.submitMOHProfile(
          _departmentController.text.trim(),
          _positionController.text.trim(),
        );
      } else if (userType == 'NGO') {
        success = await profileProvider.submitNGOProfile(
          _departmentController.text
              .trim(), // Using dept controller for Org Name
          _positionController.text.trim(),
        );
      }

      if (success && mounted) {
        authProvider.markProfileComplete();
        context.go('/');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(profileProvider.errorMessage ?? "Submission failed"),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isMOH = user?.userType == 'MOH';
    final responsive = ResponsiveSize(context);

    // Lazy load provinces if user becomes MOH
    final provider = context.watch<ProfileProvider>();
    if (isMOH && provider.provinces.isEmpty && !provider.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ProfileProvider>().loadProvinces();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Complete Your Profile",
          style: TextStyle(fontSize: responsive.appBarTitleFont),
        ),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          if (isMOH && provider.isLoading && provider.provinces.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: SingleChildScrollView(
              padding: responsive.edgeInsets,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: responsive.pick(
                    mobile: 400,
                    tablet: 600,
                    desktop: 800,
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        isMOH
                            ? "Please provide your department details and location."
                            : "Please provide your organization details.",
                        style: TextStyle(
                          fontSize: responsive.bodyFont,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: responsive.padding * 3),

                      // Department or Organization Name
                      TextFormField(
                        controller: _departmentController,
                        style: TextStyle(fontSize: responsive.bodyFont),
                        decoration: InputDecoration(
                          labelText: isMOH ? "Department" : "Organization Name",
                          contentPadding: EdgeInsets.all(responsive.padding),
                        ),
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),
                      SizedBox(height: responsive.padding * 2),

                      // Position
                      TextFormField(
                        controller: _positionController,
                        style: TextStyle(fontSize: responsive.bodyFont),
                        decoration: InputDecoration(
                          labelText: "Position",
                          contentPadding: EdgeInsets.all(responsive.padding),
                        ),
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),
                      SizedBox(height: responsive.padding * 3),

                      if (isMOH) ...[
                        const Divider(),
                        SizedBox(height: responsive.padding * 3),

                        // Station Type
                        DropdownButtonFormField<String>(
                          initialValue: provider.selectedStationType,
                          style: TextStyle(
                            fontSize: responsive.bodyFont,
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: "Office / Facility Type",
                            contentPadding: EdgeInsets.all(responsive.padding),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'HQ',
                              child: Text(
                                "Headquarters",
                                style: TextStyle(fontSize: responsive.bodyFont),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'PO',
                              child: Text(
                                "Provincial Office",
                                style: TextStyle(fontSize: responsive.bodyFont),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'DO',
                              child: Text(
                                "District Office",
                                style: TextStyle(fontSize: responsive.bodyFont),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'FC',
                              child: Text(
                                "Health Facility",
                                style: TextStyle(fontSize: responsive.bodyFont),
                              ),
                            ),
                          ],
                          onChanged: provider.setStationType,
                          validator: (v) => v == null ? "Required" : null,
                        ),
                        SizedBox(height: responsive.padding * 2),

                        // Province (Visible if type selected)
                        if (provider.selectedStationType != null)
                          DropdownButtonFormField<Province>(
                            initialValue: provider.selectedProvince,
                            style: TextStyle(
                              fontSize: responsive.bodyFont,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              labelText: "Province",
                              contentPadding: EdgeInsets.all(
                                responsive.padding,
                              ),
                            ),
                            items: provider.provinces.map((p) {
                              return DropdownMenuItem(
                                value: p,
                                child: Text(
                                  p.name,
                                  style: TextStyle(
                                    fontSize: responsive.bodyFont,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: provider.setSelectedProvince,
                            validator: (v) => v == null ? "Required" : null,
                          ),
                        SizedBox(height: responsive.padding * 2),

                        // District (Visible if Type is DO or FC)
                        if ([
                              'DO',
                              'FC',
                            ].contains(provider.selectedStationType) &&
                            provider.selectedProvince != null)
                          DropdownButtonFormField<District>(
                            initialValue: provider.selectedDistrict,
                            style: TextStyle(
                              fontSize: responsive.bodyFont,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              labelText: "District",
                              contentPadding: EdgeInsets.all(
                                responsive.padding,
                              ),
                            ),
                            items: provider.districts.map((d) {
                              return DropdownMenuItem(
                                value: d,
                                child: Text(
                                  d.name,
                                  style: TextStyle(
                                    fontSize: responsive.bodyFont,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: provider.setSelectedDistrict,
                            validator: (v) => v == null ? "Required" : null,
                          ),
                        SizedBox(height: responsive.padding * 2),

                        // Station
                        if (provider.selectedStationType != null &&
                            (provider.selectedStationType == 'HQ' &&
                                    provider.selectedProvince != null ||
                                provider.selectedStationType == 'PO' &&
                                    provider.selectedProvince != null ||
                                [
                                      'DO',
                                      'FC',
                                    ].contains(provider.selectedStationType) &&
                                    provider.selectedDistrict != null))
                          DropdownButtonFormField<Station>(
                            initialValue: provider.selectedStation,
                            style: TextStyle(
                              fontSize: responsive.bodyFont,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              labelText: "Select Station",
                              contentPadding: EdgeInsets.all(
                                responsive.padding,
                              ),
                            ),
                            items: provider.stations.map((s) {
                              return DropdownMenuItem(
                                value: s,
                                child: Text(
                                  s.name,
                                  style: TextStyle(
                                    fontSize: responsive.bodyFont,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: provider.setSelectedStation,
                            validator: (v) => v == null ? "Required" : null,
                          ),
                      ],

                      SizedBox(height: responsive.padding * 4),

                      SizedBox(
                        height: responsive.buttonFont * 3.5,
                        child: ElevatedButton(
                          onPressed: provider.isLoading ? null : _handleSubmit,
                          child: provider.isLoading
                              ? SizedBox(
                                  width: responsive.padding * 3,
                                  height: responsive.padding * 3,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  "SAVE PROFILE",
                                  style: TextStyle(
                                    fontSize: responsive.buttonFont,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: responsive.padding * 2),
                      TextButton(
                        onPressed: provider.isLoading
                            ? null
                            : () async {
                                final auth = context.read<AuthProvider>();
                                await auth.logout();
                                if (context.mounted) {
                                  context.go('/login');
                                }
                              },
                        child: Text(
                          "LOGOUT & CANCEL",
                          style: TextStyle(
                            fontSize: responsive.buttonFont,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
