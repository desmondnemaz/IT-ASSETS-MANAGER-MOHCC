import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'theme/light_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/admin/providers/admin_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initLocator();
  } catch (e) {
    debugPrint("Dependency Injection Init Failed: $e");
  }

  final authProvider = sl<AuthProvider>();
  final appRouter = AppRouter(authProvider);

  // Start checking auth status immediately
  authProvider.checkAuthStatus();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => sl<ProfileProvider>()),
        ChangeNotifierProvider(create: (_) => sl<AdminProvider>()),
      ],
      child: MyApp(router: appRouter.router),
    ),
  );
}

class MyApp extends StatelessWidget {
  final RouterConfig<Object> router;

  const MyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MOHCC IT Assets Manager',
      debugShowCheckedModeBanner: false,
      theme: mohccTheme,
      routerConfig: router,
    );
  }
}
