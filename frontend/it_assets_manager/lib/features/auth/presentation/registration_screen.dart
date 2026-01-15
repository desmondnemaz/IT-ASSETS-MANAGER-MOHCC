import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../utils/responsive_sizes.dart';
import '../providers/auth_provider.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Default user type
  String _userType = 'MOH'; // or 'NGO'
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _nationalIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      final success = await authProvider.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        nationalId: _nationalIdController.text.trim(),
        userType: _userType,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      if (success && mounted) {
        // Auto-login or redirect to login?
        // Typically redirect to login with a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registration successful! Please login."),
          ),
        );
        context.go('/login');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? "Registration failed"),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final responsive = ResponsiveSize(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Register Account",
          style: TextStyle(fontSize: responsive.appBarTitleFont),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: responsive.edgeInsets,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: responsive.pick(mobile: 400, tablet: 500, desktop: 600),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Type Selector
                  SegmentedButton<String>(
                    style: ButtonStyle(
                      textStyle: WidgetStatePropertyAll(
                        TextStyle(fontSize: responsive.bodyFont),
                      ),
                    ),
                    segments: const [
                      ButtonSegment(value: 'MOH', label: Text('MOHCC')),
                      ButtonSegment(value: 'NGO', label: Text('Partner (NGO)')),
                    ],
                    selected: {_userType},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _userType = newSelection.first;
                      });
                    },
                  ),
                  SizedBox(height: responsive.padding * 3),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstNameController,
                          style: TextStyle(fontSize: responsive.bodyFont),
                          decoration: InputDecoration(
                            labelText: "First Name",
                            contentPadding: EdgeInsets.all(responsive.padding),
                          ),
                          validator: (v) => v!.isEmpty ? "Required" : null,
                        ),
                      ),
                      SizedBox(width: responsive.padding * 2),
                      Expanded(
                        child: TextFormField(
                          controller: _lastNameController,
                          style: TextStyle(fontSize: responsive.bodyFont),
                          decoration: InputDecoration(
                            labelText: "Last Name",
                            contentPadding: EdgeInsets.all(responsive.padding),
                          ),
                          validator: (v) => v!.isEmpty ? "Required" : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.padding * 2),

                  TextFormField(
                    controller: _usernameController,
                    style: TextStyle(fontSize: responsive.bodyFont),
                    decoration: InputDecoration(
                      labelText: "Username",
                      contentPadding: EdgeInsets.all(responsive.padding),
                    ),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  SizedBox(height: responsive.padding * 2),

                  TextFormField(
                    controller: _emailController,
                    style: TextStyle(fontSize: responsive.bodyFont),
                    decoration: InputDecoration(
                      labelText: "Email",
                      contentPadding: EdgeInsets.all(responsive.padding),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v!.contains('@') ? null : "Invalid Email",
                  ),
                  SizedBox(height: responsive.padding * 2),

                  TextFormField(
                    controller: _nationalIdController,
                    style: TextStyle(fontSize: responsive.bodyFont),
                    decoration: InputDecoration(
                      labelText: "National ID",
                      contentPadding: EdgeInsets.all(responsive.padding),
                    ),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  SizedBox(height: responsive.padding * 2),

                  TextFormField(
                    controller: _passwordController,
                    style: TextStyle(fontSize: responsive.bodyFont),
                    decoration: InputDecoration(
                      labelText: "Password",
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
                    obscureText: _obscurePassword,
                    validator: (v) => v!.length < 6 ? "Min 6 chars" : null,
                  ),
                  SizedBox(height: responsive.padding * 2),

                  TextFormField(
                    controller: _confirmPasswordController,
                    style: TextStyle(fontSize: responsive.bodyFont),
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: responsive.icon * 0.8,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      contentPadding: EdgeInsets.all(responsive.padding),
                    ),
                    obscureText: _obscureConfirmPassword,
                    validator: (v) {
                      if (v != _passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: responsive.padding * 4),

                  SizedBox(
                    height: responsive.buttonFont * 3.5,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleRegister,
                      child: isLoading
                          ? SizedBox(
                              width: responsive.padding * 3,
                              height: responsive.padding * 3,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              "REGISTER",
                              style: TextStyle(fontSize: responsive.buttonFont),
                            ),
                    ),
                  ),
                  SizedBox(height: responsive.padding * 2),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text(
                      "Already have an account? Login",
                      style: TextStyle(fontSize: responsive.bodyFont),
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
