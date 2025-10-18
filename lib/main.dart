import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_router.dart';
import 'core/utils/dependency_injection.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await DependencyInjection.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: DependencyInjection.authProvider,
        ),
        ChangeNotifierProvider.value(
          value: DependencyInjection.temaProvider,
        ),
        ChangeNotifierProvider.value(
          value: DependencyInjection.actividadProvider,
        ),
        ChangeNotifierProvider.value(
          value: DependencyInjection.calificacionProvider,
        ),
      ],
      child: Consumer(
        builder: (context, AuthProvider authProvider, child) {
          final appRouter = AppRouter(authProvider: authProvider);

          return MaterialApp.router(
            title: 'Maya App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: appRouter.router,
          );
        },
      ),
    );
  }
}
