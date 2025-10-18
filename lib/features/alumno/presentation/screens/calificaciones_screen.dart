import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/calificacion_provider.dart';

class CalificacionesScreen extends StatefulWidget {
  const CalificacionesScreen({super.key});

  @override
  State<CalificacionesScreen> createState() => _CalificacionesScreenState();
}

class _CalificacionesScreenState extends State<CalificacionesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CalificacionProvider>().loadCalificaciones();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Calificaciones'),
      ),
      body: Consumer<CalificacionProvider>(
        builder: (context, provider, _) {
          if (provider.state == CalificacionState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.state == CalificacionState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: AppColors.errorColor),
                  const SizedBox(height: 16),
                  Text(provider.errorMessage ?? 'Error desconocido'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.loadCalificaciones();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (provider.calificaciones.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No tienes calificaciones aún'),
                  SizedBox(height: 8),
                  Text(
                    'Completa actividades para ver tus calificaciones aquí',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Promedio general
                Card(
                  color: AppColors.primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Icon(Icons.emoji_events, size: 50, color: Colors.white),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Promedio General',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${provider.promedioGeneral.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Historial de Calificaciones',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                // Lista de calificaciones
                ...provider.calificaciones.map((calificacion) {
                  final porcentaje = calificacion.porcentaje.round();
                  final aprobado = porcentaje >= 70;
                  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      calificacion.actividadTitulo,
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      calificacion.temaNombre,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppColors.textSecondaryColor,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '$porcentaje%',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: aprobado
                                          ? AppColors.successColor
                                          : AppColors.errorColor,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: (aprobado
                                              ? AppColors.successColor
                                              : AppColors.errorColor)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      aprobado ? 'Aprobado' : 'No aprobado',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: aprobado
                                            ? AppColors.successColor
                                            : AppColors.errorColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.score, size: 16, color: AppColors.textSecondaryColor),
                              const SizedBox(width: 4),
                              Text(
                                '${calificacion.puntuacionObtenida}/${calificacion.puntuacionMaxima} pts',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(width: 16),
                              Icon(Icons.calendar_today,
                                  size: 16, color: AppColors.textSecondaryColor),
                              const SizedBox(width: 4),
                              Text(
                                dateFormat.format(calificacion.fechaRealizacion),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
