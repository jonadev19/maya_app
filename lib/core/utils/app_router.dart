import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin/presentation/screens/admin_home_screen.dart';
import '../../features/admin/presentation/screens/alumnos/alumnos_list_screen.dart';
import '../../features/admin/presentation/screens/alumnos/alumno_form_screen.dart';
import '../../features/admin/presentation/screens/grupos/grupos_list_screen.dart';
import '../../features/admin/presentation/screens/grupos/grupo_form_screen.dart';
import '../../features/admin/presentation/screens/grupos/grupo_detail_screen.dart';
import '../../features/admin/presentation/screens/grupos/grupo_alumnos_screen.dart';
import '../../features/admin/presentation/screens/calificaciones/calificaciones_admin_screen.dart';
import '../../features/admin/presentation/screens/reportes/reportes_screen.dart';
import '../../features/alumno/presentation/screens/alumno_home_screen.dart';
import '../../features/alumno/presentation/screens/tema_detail_screen.dart';
import '../../features/alumno/presentation/screens/material_detail_screen.dart';
import '../../features/alumno/presentation/screens/actividad_screen.dart';
import '../../features/alumno/presentation/screens/calificaciones_screen.dart';
import '../../features/alumno/presentation/screens/perfil_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/shared/domain/entities/material.dart' as entities;

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
        routes: [
          GoRoute(
            path: 'alumnos',
            pageBuilder: (context, state) => _buildPageWithSlideTransition(
              context: context,
              state: state,
              child: const AlumnosListScreen(),
            ),
            routes: [
              GoRoute(
                path: 'create',
                pageBuilder: (context, state) => _buildPageWithSlideTransition(
                  context: context,
                  state: state,
                  child: const AlumnoFormScreen(),
                ),
              ),
              GoRoute(
                path: 'edit/:id',
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return _buildPageWithSlideTransition(
                    context: context,
                    state: state,
                    child: AlumnoFormScreen(alumnoId: id),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'grupos',
            pageBuilder: (context, state) => _buildPageWithSlideTransition(
              context: context,
              state: state,
              child: const GruposListScreen(),
            ),
            routes: [
              GoRoute(
                path: 'nuevo',
                pageBuilder: (context, state) => _buildPageWithSlideTransition(
                  context: context,
                  state: state,
                  child: const GrupoFormScreen(),
                ),
              ),
              GoRoute(
                path: ':id',
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return _buildPageWithSlideTransition(
                    context: context,
                    state: state,
                    child: GrupoDetailScreen(grupoId: id),
                  );
                },
              ),
              GoRoute(
                path: ':id/editar',
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return _buildPageWithSlideTransition(
                    context: context,
                    state: state,
                    child: GrupoFormScreen(grupoId: id),
                  );
                },
              ),
              GoRoute(
                path: ':id/alumnos',
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return _buildPageWithSlideTransition(
                    context: context,
                    state: state,
                    child: GrupoAlumnosScreen(grupoId: id),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'calificaciones',
            pageBuilder: (context, state) => _buildPageWithSlideTransition(
              context: context,
              state: state,
              child: const CalificacionesAdminScreen(),
            ),
          ),
          GoRoute(
            path: 'reportes',
            pageBuilder: (context, state) => _buildPageWithSlideTransition(
              context: context,
              state: state,
              child: const ReportesScreen(),
            ),
          ),
        ],
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
            routes: [
              GoRoute(
                path: 'material',
                pageBuilder: (context, state) {
                  final materialData = state.extra as entities.Material?;
                  if (materialData == null) {
                    return _buildPageWithSlideTransition(
                      context: context,
                      state: state,
                      child: const Scaffold(
                        body: Center(
                          child: Text('Error: Material no encontrado'),
                        ),
                      ),
                    );
                  }
                  return _buildPageWithSlideTransition(
                    context: context,
                    state: state,
                    child: MaterialDetailScreen(material: materialData),
                  );
                },
              ),
            ],
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
