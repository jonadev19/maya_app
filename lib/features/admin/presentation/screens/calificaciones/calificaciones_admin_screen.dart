import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../providers/calificacion_admin_provider.dart';
import '../../providers/alumno_provider.dart';

class CalificacionesAdminScreen extends StatefulWidget {
  const CalificacionesAdminScreen({super.key});

  @override
  State<CalificacionesAdminScreen> createState() =>
      _CalificacionesAdminScreenState();
}

class _CalificacionesAdminScreenState extends State<CalificacionesAdminScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _filtroAlumno;
  String? _filtroTema;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CalificacionAdminProvider>().loadTodasCalificaciones();
      context.read<AlumnoProvider>().loadAlumnos();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calificaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Generación de PDF próximamente'),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Estadísticas
          Consumer<CalificacionAdminProvider>(
            builder: (context, provider, _) {
              if (provider.state == CalificacionAdminState.loaded) {
                final stats = provider.getEstadisticas();
                return Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.primaryColor.withOpacity(0.1),
                  child: Row(
                    children: [
                      _StatCard(
                        icon: Icons.assignment,
                        label: 'Total',
                        value: '${stats['total']}',
                        color: AppColors.infoColor,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: Icons.check_circle,
                        label: 'Aprobados',
                        value: '${stats['aprobados']}',
                        color: AppColors.successColor,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: Icons.cancel,
                        label: 'Reprobados',
                        value: '${stats['reprobados']}',
                        color: AppColors.errorColor,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: Icons.trending_up,
                        label: 'Promedio',
                        value: '${stats['promedio'].toStringAsFixed(1)}%',
                        color: AppColors.secondaryColor,
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por actividad o tema...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Chips de filtros activos
          if (_filtroAlumno != null || _filtroTema != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_filtroAlumno != null)
                    Chip(
                      label: Text('Alumno: $_filtroAlumno'),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          _filtroAlumno = null;
                        });
                        context
                            .read<CalificacionAdminProvider>()
                            .loadTodasCalificaciones();
                      },
                    ),
                  if (_filtroTema != null)
                    Chip(
                      label: Text('Tema: $_filtroTema'),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          _filtroTema = null;
                        });
                      },
                    ),
                ],
              ),
            ),

          // Lista de calificaciones
          Expanded(
            child: Consumer<CalificacionAdminProvider>(
              builder: (context, provider, _) {
                if (provider.state == CalificacionAdminState.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.state == CalificacionAdminState.error) {
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 60, color: AppColors.errorColor),
                          const SizedBox(height: 16),
                          const Text(
                            'Error al cargar calificaciones',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.errorMessage?.contains('<!DOCTYPE html>') ==
                                    true
                                ? 'Error de conexión con el servidor'
                                : provider.errorMessage ?? 'Error desconocido',
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              provider.loadTodasCalificaciones();
                            },
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Filtrar calificaciones
                var calificaciones = provider.calificaciones;

                if (_searchQuery.isNotEmpty) {
                  calificaciones = provider.searchByAlumno(_searchQuery);
                }

                if (_filtroTema != null) {
                  calificaciones = calificaciones
                      .where((c) => c.temaNombre == _filtroTema)
                      .toList();
                }

                if (calificaciones.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_outlined,
                            size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No hay calificaciones registradas'),
                        SizedBox(height: 8),
                        Text(
                          'Las calificaciones aparecerán cuando los alumnos completen actividades',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // Ordenar por fecha más reciente
                calificaciones.sort((a, b) =>
                    b.fechaRealizacion.compareTo(a.fechaRealizacion));

                return RefreshIndicator(
                  onRefresh: () => provider.loadTodasCalificaciones(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: calificaciones.length,
                    itemBuilder: (context, index) {
                      final cal = calificaciones[index];
                      final isAprobado = cal.porcentaje >= 70;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            backgroundColor: isAprobado
                                ? AppColors.successColor
                                : AppColors.errorColor,
                            child: Text(
                              '${cal.porcentaje.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          title: Text(
                            cal.actividadTitulo,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.book, size: 14),
                                  const SizedBox(width: 4),
                                  Text(cal.temaNombre),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.score, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                      '${cal.puntuacionObtenida}/${cal.puntuacionMaxima} puntos'),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.refresh, size: 14),
                                  const SizedBox(width: 4),
                                  Text('${cal.intentos} intentos'),
                                  const Spacer(),
                                  Text(
                                    DateFormat('dd/MM/yyyy')
                                        .format(cal.fechaRealizacion),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Icon(
                            isAprobado ? Icons.check_circle : Icons.cancel,
                            color: isAprobado
                                ? AppColors.successColor
                                : AppColors.errorColor,
                            size: 32,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Filtrar Calificaciones'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filtrar por Alumno',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Consumer<AlumnoProvider>(
                builder: (context, alumnoProvider, _) {
                  if (alumnoProvider.state == AlumnoState.loaded) {
                    return DropdownButtonFormField<String>(
                      value: _filtroAlumno,
                      decoration: const InputDecoration(
                        hintText: 'Seleccionar alumno',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Todos'),
                        ),
                        ...alumnoProvider.alumnos.map((alumno) {
                          return DropdownMenuItem(
                            value: alumno.id,
                            child: Text(alumno.nombreCompleto),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _filtroAlumno = value;
                        });
                        if (value != null) {
                          context
                              .read<CalificacionAdminProvider>()
                              .loadCalificacionesByAlumno(value);
                        } else {
                          context
                              .read<CalificacionAdminProvider>()
                              .loadTodasCalificaciones();
                        }
                        Navigator.pop(dialogContext);
                      },
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Filtrar por Tema',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Consumer<CalificacionAdminProvider>(
                builder: (context, provider, _) {
                  final temas = provider.calificaciones
                      .map((c) => c.temaNombre)
                      .toSet()
                      .toList();

                  return DropdownButtonFormField<String>(
                    value: _filtroTema,
                    decoration: const InputDecoration(
                      hintText: 'Seleccionar tema',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Todos'),
                      ),
                      ...temas.map((tema) {
                        return DropdownMenuItem(
                          value: tema,
                          child: Text(tema),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filtroTema = value;
                      });
                      Navigator.pop(dialogContext);
                    },
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
