import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../utils/responsive_sizes.dart';
import '../providers/profile_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/profile_models.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _field1Controller;
  late TextEditingController _field2Controller;

  @override
  void initState() {
    super.initState();
    final profileProvider = context.read<ProfileProvider>();
    final user = context.read<AuthProvider>().user;
    final profile = profileProvider.userProfile?.profile;
    final userFull = profileProvider.userProfile?.user;

    _firstNameController = TextEditingController(
      text: userFull?['first_name'] ?? "",
    );
    _lastNameController = TextEditingController(
      text: userFull?['last_name'] ?? "",
    );
    _emailController = TextEditingController(text: userFull?['email'] ?? "");

    if (user?.userType == 'MOH' && profile is MOHProfile) {
      _field1Controller = TextEditingController(text: profile.department);
      _field2Controller = TextEditingController(text: profile.position);
    } else if (user?.userType == 'NGO' && profile is NGOProfile) {
      _field1Controller = TextEditingController(text: profile.organizationName);
      _field2Controller = TextEditingController(text: profile.position);
    } else {
      _field1Controller = TextEditingController();
      _field2Controller = TextEditingController();
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _field1Controller.dispose();
    _field2Controller.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = context.read<AuthProvider>().user;
      final Map<String, dynamic> accountData = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'email': _emailController.text,
      };
      final Map<String, dynamic> profileData = {};

      if (user?.userType == 'MOH') {
        profileData['department'] = _field1Controller.text;
        profileData['position'] = _field2Controller.text;
      } else {
        profileData['organization_name'] = _field1Controller.text;
        profileData['position'] = _field2Controller.text;
      }

      final success = await context
          .read<ProfileProvider>()
          .updateAccountAndProfile(
            accountData: accountData,
            profileData: profileData,
          );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile and account updated successfully!'),
          ),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveSize(context);
    final userType = context.watch<AuthProvider>().user?.userType;
    final isLoading = context.watch<ProfileProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/moh_logo.png',
              height: responsive.appBarIcon * 1.2,
            ),
            SizedBox(width: responsive.padding / 2),
            Text(
              "Edit Profile",
              style: TextStyle(fontSize: responsive.appBarTitleFont),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: responsive.edgeInsets,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Account Details",
                    style: TextStyle(
                      fontSize: responsive.titleFont,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: responsive.padding),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: "First Name"),
                    validator: (value) =>
                        value == null || value.isEmpty ? "Required" : null,
                  ),
                  SizedBox(height: responsive.padding),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: "Last Name"),
                    validator: (value) =>
                        value == null || value.isEmpty ? "Required" : null,
                  ),
                  SizedBox(height: responsive.padding),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                    validator: (value) =>
                        value == null || value.isEmpty ? "Required" : null,
                  ),
                  SizedBox(height: responsive.padding * 2),
                  Text(
                    "Profile Details",
                    style: TextStyle(
                      fontSize: responsive.titleFont,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: responsive.padding),
                  TextFormField(
                    controller: _field1Controller,
                    decoration: InputDecoration(
                      labelText: userType == 'MOH'
                          ? "Department"
                          : "Organization Name",
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? "Required" : null,
                  ),
                  SizedBox(height: responsive.padding),
                  TextFormField(
                    controller: _field2Controller,
                    decoration: const InputDecoration(labelText: "Position"),
                    validator: (value) =>
                        value == null || value.isEmpty ? "Required" : null,
                  ),
                  SizedBox(height: responsive.padding * 2),
                  ElevatedButton(
                    onPressed: isLoading ? null : _saveProfile,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            "Save Changes",
                            style: TextStyle(fontSize: responsive.buttonFont),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
