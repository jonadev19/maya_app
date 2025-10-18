import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin/presentation/screens/admin_home_screen.dart';
import '../../features/alumno/presentation/screens/alumno_home_screen.dart';
import '../../features/alumno/presentation/screens/tema_detail_screen.dart';
import '../../features/alumno/presentation/screens/actividad_screen.dart';
import '../../features/alumno/presentation/screens/calificaciones_screen.dart';
import '../../features/alumno/presentation/screens/perfil_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter({required this.authProvider});

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isAuthenticated = authProvider.isAuthenticated;
      final isLoading = authProvider.status == AuthStatus.initial ||
          authProvider.status == AuthStatus.loading;

      // Show splash while checking auth status
      if (isLoading) {
        return '/';
      }

      // If not authenticated and trying to access protected routes
      if (!isAuthenticated && state.matchedLocation != '/login') {
        return '/login';
      }

      // If authenticated and on login or splash, redirect to home
      if (isAuthenticated &&
          (state.matchedLocation == '/login' || state.matchedLocation == '/')) {
        // Redirect based on role
        if (authProvider.isAdmin) {
          return '/admin';
        } else if (authProvider.isAlumno) {
          return '/alumno';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/admin',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context: context,
          state: state,
          child: const AdminHomeScreen(),
        ),
      ),
      GoRoute(
        path: '/alumno',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context: context,
          state: state,
          child: const AlumnoHomeScreen(),
        ),
        routes: [
          GoRoute(
            path: 'tema/:id',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return _buildPageWithSlideTransition(
                context: context,
                state: state,
                child: TemaDetailScreen(temaId: id),
              );
            },
          ),
          GoRoute(
            path: 'actividad/:id',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return _buildPageWithSlideTransition(
                context: context,
                state: state,
                child: ActividadScreen(actividadId: id),
              );
            },
          ),
          GoRoute(
            path: 'calificaciones',
            pageBuilder: (context, state) => _buildPageWithSlideTransition(
              context: context,
              state: state,
              child: const CalificacionesScreen(),
            ),
          ),
          GoRoute(
            path: 'perfil',
            pageBuilder: (context, state) => _buildPageWithSlideTransition(
              context: context,
              state: state,
              child: const PerfilScreen(),
            ),
          ),
        ],
      ),
    ],
  );

  // Fade transition for splash and login
  CustomTransitionPage _buildPageWithFadeTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
    );
  }

  // Slide transition for home screens
  CustomTransitionPage _buildPageWithSlideTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }
}
