import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../utils/responsive_sizes.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../profile/models/profile_models.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isSidebarOpen = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.userProfile?.profile;

    final responsive = ResponsiveSize(context);
    final isMobile = responsive.isMobile;

    String locationInfo = "";
    if (profile is MOHProfile) {
      locationInfo = profile.stationName ?? "MOH Station";
    } else if (profile is NGOProfile) {
      locationInfo = profile.organizationName;
    }

    return Scaffold(
      appBar: AppBar(
        // On Desktop/Tablet, we explicitly add the menu button to toggle sidebar
        leading: !isMobile
            ? IconButton(
                icon: Icon(Icons.menu, size: responsive.appBarIcon),
                onPressed: () {
                  setState(() {
                    _isSidebarOpen = !_isSidebarOpen;
                  });
                },
              )
            : null, // On mobile, Scaffold handles the Drawer toggle automatically
        title: Row(
          children: [
            Image.asset(
              'assets/images/moh_logo.png',
              height: responsive.appBarIcon * 1.2,
            ),
            SizedBox(width: responsive.padding / 2),
            Expanded(
              child: Text(
                isMobile ? "MOHCC Assets" : "Ministry of Health and Child Care",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: responsive.appBarTitleFont),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, size: responsive.appBarIcon),
            tooltip: "Logout",
            onPressed: () {
              context.read<AuthProvider>().logout();
              context.go('/login');
            },
          ),
        ],
      ),
      // Drawer is ONLY for mobile
      drawer: isMobile
          ? Drawer(
              width: responsive.drawerWidth,
              child: _buildDrawerContent(context, responsive, user),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.only(
          top: 2.0,
        ), // Thin gap between navbar and sidebar
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Permanent Sidebar for Tablet/Desktop (Collapsible)
            if (!isMobile && _isSidebarOpen)
              Container(
                width: responsive.drawerWidth,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: _buildDrawerContent(context, responsive, user),
              ),

            // Main Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: responsive.edgeInsets,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome, ${user?.username ?? 'User'}",
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontSize: responsive.titleFont),
                    ),
                    if (locationInfo.isNotEmpty) ...[
                      SizedBox(height: responsive.padding / 4),
                      Text(
                        locationInfo,
                        style: TextStyle(
                          fontSize: responsive.subtitleFont,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    SizedBox(height: responsive.padding / 2),
                    Text(
                      "Here is an overview of your IT assets.",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontSize: responsive.subtitleFont,
                      ),
                    ),
                    SizedBox(height: responsive.padding * 2),

                    // Stats Grid - Small Cards (2 on mobile, 3 on tablet, 4 on desktop)
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: responsive.pick(
                        mobile: 2,
                        tablet: 3,
                        desktop: 4,
                      ),
                      crossAxisSpacing: responsive.gridSpacing,
                      mainAxisSpacing: responsive.gridSpacing,
                      childAspectRatio: 1.3, // Slightly taller/squarer for info
                      children: [
                        _buildStatCard(
                          context,
                          responsive,
                          "Total Assets",
                          "12",
                          Icons.computer,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          context,
                          responsive,
                          "Pending Requests",
                          "2",
                          Icons.pending_actions,
                          Colors.orange,
                        ),
                        _buildStatCard(
                          context,
                          responsive,
                          "Faulty Items",
                          "0",
                          Icons.warning,
                          Colors.red,
                        ),
                        _buildStatCard(
                          context,
                          responsive,
                          "Assigned to Me",
                          "5",
                          Icons.assignment_ind,
                          Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    ResponsiveSize responsive,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2, // Slight elevation for small cards
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(responsive.borderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(responsive.padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: responsive.icon * 0.8),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: responsive.titleFont * 1.2,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: responsive.labelFont,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerContent(
    BuildContext context,
    ResponsiveSize responsive,
    dynamic user,
  ) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        UserAccountsDrawerHeader(
          accountName: Text(
            user?.username ?? "User",
            style: TextStyle(fontSize: responsive.bodyFont),
          ),
          accountEmail: Text(
            user?.email ?? "",
            style: TextStyle(fontSize: responsive.captionFont),
          ),
          currentAccountPicture: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: responsive.icon),
          ),
          decoration: BoxDecoration(color: Theme.of(context).primaryColor),
        ),
        ListTile(
          leading: Icon(Icons.person, size: responsive.panelIconSize),
          title: Text(
            'Profile',
            style: TextStyle(fontSize: responsive.panelItemFont),
          ),
          onTap: () => context.push('/profile'),
        ),
        ListTile(
          leading: Icon(Icons.dashboard, size: responsive.panelIconSize),
          title: Text(
            'Dashboard',
            style: TextStyle(fontSize: responsive.panelItemFont),
          ),
          onTap: () {},
          selected: true,
        ),
        ListTile(
          leading: Icon(Icons.inventory, size: responsive.panelIconSize),
          title: Text(
            'My Assets',
            style: TextStyle(fontSize: responsive.panelItemFont),
          ),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.history, size: responsive.panelIconSize),
          title: Text(
            'Request History',
            style: TextStyle(fontSize: responsive.panelItemFont),
          ),
          onTap: () {},
        ),
        if (user?.isAdmin == true) ...[
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.manage_accounts,
              size: responsive.panelIconSize,
            ),
            title: Text(
              'User Management',
              style: TextStyle(fontSize: responsive.panelItemFont),
            ),
            onTap: () => context.push('/admin/users'),
          ),
        ],
        const Divider(),
        ListTile(
          leading: Icon(Icons.settings, size: responsive.panelIconSize),
          title: Text(
            'Settings',
            style: TextStyle(fontSize: responsive.panelItemFont),
          ),
          onTap: () {},
        ),
      ],
    );
  }
}
