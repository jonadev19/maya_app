import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/tema_provider.dart';

class AlumnoHomeScreen extends StatefulWidget {
  const AlumnoHomeScreen({super.key});

  @override
  State<AlumnoHomeScreen> createState() => _AlumnoHomeScreenState();
}

class _AlumnoHomeScreenState extends State<AlumnoHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TemaProvider>().loadTemas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
            },
            tooltip: AppStrings.logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.accentColor,
                      child: Text(
                        user?.nombre.substring(0, 1).toUpperCase() ?? 'A',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textLightColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${AppStrings.welcome}, ${user?.nombre ?? ''}!',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${user?.grupoNombre ?? 'N/A'} - ${user?.nivel ?? 'N/A'}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textSecondaryColor,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Temas Section
            Text(
              AppStrings.temas,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Consumer<TemaProvider>(
              builder: (context, temaProvider, _) {
                if (temaProvider.state == TemaState.loading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (temaProvider.state == TemaState.error) {
                  return Center(
                    child: Column(
                      children: [
                        Text(temaProvider.errorMessage ?? 'Error al cargar temas'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => temaProvider.loadTemas(),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (temaProvider.temas.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No hay temas disponibles'),
                    ),
                  );
                }

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: temaProvider.temas.length,
                  itemBuilder: (context, index) {
                    final tema = temaProvider.temas[index];
                    IconData icon;
                    Color color;

                    // Assign icons based on tema name
                    if (tema.nombre.toLowerCase().contains('número')) {
                      icon = Icons.numbers;
                      color = AppColors.basicLevelColor;
                    } else if (tema.nombre.toLowerCase().contains('comida')) {
                      icon = Icons.restaurant;
                      color = AppColors.intermediateLevelColor;
                    } else if (tema.nombre.toLowerCase().contains('objeto')) {
                      icon = Icons.home_outlined;
                      color = AppColors.advancedLevelColor;
                    } else if (tema.nombre.toLowerCase().contains('animal')) {
                      icon = Icons.pets;
                      color = AppColors.secondaryColor;
                    } else {
                      icon = Icons.school;
                      color = AppColors.accentColor;
                    }

                    return _TemaCard(
                      icon: icon,
                      title: tema.nombre,
                      color: color,
                      onTap: () {
                        context.push('/alumno/tema/${tema.id}');
                      },
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            // Quick Actions
            Text(
              'Acciones Rápidas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _ActionCard(
              icon: Icons.grade,
              title: AppStrings.misCalificaciones,
              onTap: () {
                context.push('/alumno/calificaciones');
              },
            ),
            const SizedBox(height: 12),
            _ActionCard(
              icon: Icons.person,
              title: AppStrings.miPerfil,
              onTap: () {
                context.push('/alumno/perfil');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TemaCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _TemaCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.primaryColor,
          ),
        ),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
