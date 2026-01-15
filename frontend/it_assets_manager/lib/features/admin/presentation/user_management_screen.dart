import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../utils/responsive_sizes.dart';
import '../providers/admin_provider.dart';
import '../models/admin_models.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveSize(context);
    final adminProvider = context.watch<AdminProvider>();
    final users = adminProvider.users.where((user) {
      final name = user.fullName.toLowerCase();
      final username = user.username.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || username.contains(query);
    }).toList();

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
              "User Management",
              style: TextStyle(fontSize: responsive.appBarTitleFont),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(responsive.padding),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search users...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(responsive.borderRadius),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: adminProvider.isLoading && users.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => adminProvider.fetchUsers(),
                    child: ListView.separated(
                      padding: responsive.edgeInsets,
                      itemCount: users.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return ListTile(
                          title: Text(
                            user.fullName,
                            style: TextStyle(
                              fontSize: responsive.bodyFont,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "@${user.username} • ${user.userType}",
                            style: TextStyle(fontSize: responsive.captionFont),
                          ),
                          trailing: ElevatedButton.icon(
                            onPressed: () =>
                                _showResetPasswordDialog(context, user),
                            icon: const Icon(Icons.lock_reset, size: 18),
                            label: const Text("Reset"),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context, AdminUser user) {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscureText = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Reset Password for ${user.username}"),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: passwordController,
              obscureText: obscureText,
              decoration: InputDecoration(
                labelText: "New Password",
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setDialogState(() => obscureText = !obscureText),
                ),
              ),
              validator: (v) => v!.length < 6 ? "Min 6 chars" : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final success = await context
                      .read<AdminProvider>()
                      .resetPassword(user.id, passwordController.text);
                  if (success && context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Password reset for ${user.username}"),
                      ),
                    );
                  }
                }
              },
              child: const Text("Reset"),
            ),
          ],
        ),
      ),
    );
  }
}
