import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/services/pdf_service.dart';
import '../../../../shared/domain/entities/calificacion.dart';
import '../../providers/alumno_provider.dart';
import '../../providers/grupo_provider.dart';
import '../../providers/calificacion_admin_provider.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlumnoProvider>().loadAlumnos();
      context.read<GrupoProvider>().loadGrupos();
      context.read<CalificacionAdminProvider>().loadTodasCalificaciones();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.reportes),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Encabezado
            const Text(
              'Generar Reportes en PDF',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Selecciona el tipo de reporte que deseas generar',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Tarjeta: Reporte Individual
            _buildReportCard(
              context,
              icon: Icons.person,
              title: 'Reporte Individual',
              description: 'Genera un reporte detallado de un alumno específico',
              color: AppColors.primaryColor,
              onTap: () => _mostrarSelectorAlumno(context),
            ),

            const SizedBox(height: 16),

            // Tarjeta: Reporte por Grupo
            _buildReportCard(
              context,
              icon: Icons.group,
              title: 'Reporte por Grupo',
              description:
                  'Genera un reporte con el resumen de calificaciones de un grupo',
              color: AppColors.secondaryColor,
              onTap: () => _mostrarSelectorGrupo(context),
            ),

            const SizedBox(height: 16),

            // Tarjeta: Reporte General (opcional)
            _buildReportCard(
              context,
              icon: Icons.assessment,
              title: 'Reporte General',
              description:
                  'Genera un reporte con todas las calificaciones del sistema',
              color: AppColors.accentColor,
              onTap: () => _generarReporteGeneral(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarSelectorAlumno(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Seleccionar Alumno'),
        content: SizedBox(
          width: double.maxFinite,
          child: Consumer<AlumnoProvider>(
            builder: (context, provider, _) {
              if (provider.state == AlumnoState.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.alumnos.isEmpty) {
                return const Text('No hay alumnos registrados');
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: provider.alumnos.length,
                itemBuilder: (context, index) {
                  final alumno = provider.alumnos[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryColor,
                      child: Text(
                        alumno.nombre[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(alumno.nombreCompleto),
                    subtitle: Text(alumno.email),
                    onTap: () {
                      Navigator.pop(dialogContext);
                      _generarReporteIndividual(context, alumno.id);
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _mostrarSelectorGrupo(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Seleccionar Grupo'),
        content: SizedBox(
          width: double.maxFinite,
          child: Consumer<GrupoProvider>(
            builder: (context, provider, _) {
              if (provider.state == GrupoState.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.grupos.isEmpty) {
                return const Text('No hay grupos registrados');
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: provider.grupos.length,
                itemBuilder: (context, index) {
                  final grupo = provider.grupos[index];
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.secondaryColor,
                      child: Icon(Icons.group, color: Colors.white),
                    ),
                    title: Text(grupo.nombre),
                    subtitle: Text('Nivel: ${grupo.nivel}'),
                    trailing: Text('${grupo.cantidadAlumnos} alumnos'),
                    onTap: () {
                      Navigator.pop(dialogContext);
                      _generarReportePorGrupo(context, grupo.id);
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _generarReporteIndividual(
    BuildContext context,
    String alumnoId,
  ) async {
    if (!mounted) return;

    // Guardar referencias antes de operaciones async
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final alumnoProvider = context.read<AlumnoProvider>();
    final calificacionProvider = context.read<CalificacionAdminProvider>();

    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Obtener datos
      await calificacionProvider.loadCalificacionesByAlumno(alumnoId);

      final alumno = alumnoProvider.alumnos.firstWhere((a) => a.id == alumnoId);
      final calificaciones = calificacionProvider.calificaciones;

      // Generar PDF
      final pdf = await PdfService.generarReporteIndividual(
        alumno: alumno,
        calificaciones: calificaciones,
      );

      // Cerrar loading
      if (mounted) navigator.pop();

      // Guardar y compartir PDF
      await PdfService.guardarYAbrirPDF(
        pdf,
        'reporte_${alumno.nombre}_${alumno.apellido}',
      );

      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Reporte generado correctamente'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        navigator.pop(); // Cerrar loading
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error al generar reporte: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _generarReportePorGrupo(
    BuildContext context,
    String grupoId,
  ) async {
    if (!mounted) return;

    // Guardar referencias antes de operaciones async
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final grupoProvider = context.read<GrupoProvider>();
    final alumnoProvider = context.read<AlumnoProvider>();
    final calificacionProvider = context.read<CalificacionAdminProvider>();

    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Obtener datos
      final grupo = grupoProvider.grupos.firstWhere((g) => g.id == grupoId);
      final alumnosDelGrupo =
          alumnoProvider.alumnos.where((a) => a.grupoId == grupoId).toList();

      // Cargar todas las calificaciones
      await calificacionProvider.loadTodasCalificaciones();

      // Agrupar calificaciones por alumno
      final calificacionesPorAlumno = <String, List<Calificacion>>{};
      for (var alumno in alumnosDelGrupo) {
        final cals = calificacionProvider.calificaciones
            .where((c) => c.alumnoId == alumno.id)
            .toList();
        calificacionesPorAlumno[alumno.id] = cals;
      }

      // Generar PDF
      final pdf = await PdfService.generarReportePorGrupo(
        grupoNombre: grupo.nombre,
        nivel: grupo.nivel,
        calificacionesPorAlumno: calificacionesPorAlumno,
        alumnos: alumnosDelGrupo,
      );

      // Cerrar loading
      if (mounted) navigator.pop();

      // Guardar y compartir PDF
      await PdfService.guardarYAbrirPDF(
        pdf,
        'reporte_grupo_${grupo.nombre}',
      );

      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Reporte generado correctamente'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        navigator.pop(); // Cerrar loading
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error al generar reporte: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _generarReporteGeneral(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reporte General'),
        content: const Text(
          'Esta función generará un reporte con todas las calificaciones del sistema. '
          '¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función en desarrollo'),
                ),
              );
            },
            child: const Text('Generar'),
          ),
        ],
      ),
    );
  }
}
