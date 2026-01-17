import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../utils/responsive_sizes.dart';
import '../providers/profile_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/profile_models.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ProfileProvider>().fetchProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveSize(context);
    final profileProvider = context.watch<ProfileProvider>();
    final user = context.watch<AuthProvider>().user;
    final userProfile = profileProvider.userProfile;

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
              "My Profile",
              style: TextStyle(fontSize: responsive.appBarTitleFont),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, size: responsive.appBarIcon),
            onPressed: () => context.push('/profile/edit'),
          ),
        ],
      ),
      body: profileProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: responsive.edgeInsets,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: responsive.icon * 1.5,
                          backgroundColor: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.person,
                            size: responsive.icon * 2,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      SizedBox(height: responsive.padding * 2),
                      _buildProfileCard(
                        context,
                        responsive,
                        "Account Information",
                        [
                          _buildInfoRow(
                            context,
                            responsive,
                            "First Name",
                            userProfile?.user['first_name'] ?? "",
                          ),
                          _buildInfoRow(
                            context,
                            responsive,
                            "Last Name",
                            userProfile?.user['last_name'] ?? "",
                          ),
                          _buildInfoRow(
                            context,
                            responsive,
                            "Username",
                            user?.username ?? "",
                          ),
                          _buildInfoRow(
                            context,
                            responsive,
                            "Email",
                            user?.email ?? "",
                          ),
                          _buildInfoRow(
                            context,
                            responsive,
                            "User Type",
                            user?.userType ?? "",
                          ),
                          _buildInfoRow(
                            context,
                            responsive,
                            "Admin Status",
                            (user?.isAdmin ?? false) ? "Yes" : "No",
                          ),
                        ],
                      ),
                      SizedBox(height: responsive.padding),
                      if (userProfile != null)
                        _buildProfileCard(
                          context,
                          responsive,
                          "${user?.userType} Details",
                          _buildTypeSpecificRows(
                            context,
                            responsive,
                            user?.userType,
                            userProfile.profile,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  List<Widget> _buildTypeSpecificRows(
    BuildContext context,
    ResponsiveSize responsive,
    String? userType,
    dynamic profile,
  ) {
    if (userType == 'MOH' && profile is MOHProfile) {
      return [
        _buildInfoRow(context, responsive, "Department", profile.department),
        _buildInfoRow(context, responsive, "Position", profile.position),
        _buildInfoRow(
          context,
          responsive,
          "Station",
          profile.stationName ?? "N/A",
        ),
        _buildInfoRow(
          context,
          responsive,
          "Province",
          profile.provinceName ?? "N/A",
        ),
        _buildInfoRow(
          context,
          responsive,
          "District",
          profile.districtName ?? "N/A",
        ),
      ];
    } else if (userType == 'NGO' && profile is NGOProfile) {
      return [
        _buildInfoRow(
          context,
          responsive,
          "Organization",
          profile.organizationName,
        ),
        _buildInfoRow(context, responsive, "Position", profile.position),
      ];
    }
    return [const Text("No profile data available")];
  }

  Widget _buildProfileCard(
    BuildContext context,
    ResponsiveSize responsive,
    String title,
    List<Widget> children,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(responsive.borderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(responsive.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: responsive.titleFont,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    ResponsiveSize responsive,
    String label,
    String value,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: responsive.padding / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: responsive.bodyFont,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: responsive.bodyFont,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
