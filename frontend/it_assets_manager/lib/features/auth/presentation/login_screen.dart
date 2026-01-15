import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../utils/responsive_sizes.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      if (success && mounted) {
        if (authProvider.user?.profileComplete == false) {
          context.go('/profile-complete');
        } else {
          context.go('/');
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? "Login failed"),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveSize(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: responsive.edgeInsets,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: responsive.pick(mobile: 400, tablet: 500, desktop: 600),
            ),
            child: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo or Title
                      Center(
                        child: Image.asset(
                          'assets/images/moh_logo.png',
                          height: responsive.icon * 3,
                        ),
                      ),
                      SizedBox(
                        height: responsive.padding * 3,
                      ), // 24 -> responsive
                      Text(
                        "IT Assets Manager",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                              fontSize: responsive.titleFont * 1.5,
                            ),
                      ),
                      SizedBox(height: responsive.padding), // 8 -> responsive
                      Text(
                        "Ministry of Health and Child Care",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                          fontSize: responsive.subtitleFont,
                        ),
                      ),
                      SizedBox(
                        height: responsive.padding * 6,
                      ), // 48 -> responsive
                      // Username Field
                      TextFormField(
                        controller: _usernameController,
                        style: TextStyle(fontSize: responsive.bodyFont),
                        decoration: InputDecoration(
                          labelText: "Username",
                          prefixIcon: Icon(
                            Icons.person,
                            size: responsive.icon * 0.8,
                          ),
                          contentPadding: EdgeInsets.all(responsive.padding),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "Please enter username" : null,
                      ),
                      SizedBox(height: responsive.padding * 2), // 16
                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(fontSize: responsive.bodyFont),
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: Icon(
                            Icons.lock,
                            size: responsive.icon * 0.8,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: responsive.icon * 0.8,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          contentPadding: EdgeInsets.all(responsive.padding),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "Please enter password" : null,
                      ),
                      SizedBox(height: responsive.padding * 3), // 24
                      // Login Button
                      SizedBox(
                        height: responsive.buttonFont * 3.5, // Approx 48
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _handleLogin,
                          child: auth.isLoading
                              ? SizedBox(
                                  width: responsive.padding * 3,
                                  height: responsive.padding * 3,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "LOGIN",
                                  style: TextStyle(
                                    fontSize: responsive.buttonFont,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: responsive.padding * 2),
                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: Text(
                          "Don't have an account? Register",
                          style: TextStyle(fontSize: responsive.bodyFont),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
