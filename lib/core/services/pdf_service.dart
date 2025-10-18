import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../features/shared/domain/entities/calificacion.dart';
import '../../features/shared/domain/entities/alumno.dart';

class PdfService {
  /// Genera un PDF con las calificaciones de un alumno
  static Future<pw.Document> generarReporteIndividual({
    required Alumno alumno,
    required List<Calificacion> calificaciones,
  }) async {
    final pdf = pw.Document();

    // Calcular estadísticas
    final promedio = calificaciones.isEmpty
        ? 0.0
        : calificaciones.fold<double>(0.0, (sum, c) => sum + c.porcentaje) /
            calificaciones.length;
    final aprobadas = calificaciones.where((c) => c.porcentaje >= 70).length;
    final reprobadas = calificaciones.where((c) => c.porcentaje < 70).length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Encabezado
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'REPORTE DE CALIFICACIONES',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 2),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // Información del alumno
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 1),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Información del Alumno',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                _buildInfoRow('Nombre:', alumno.nombreCompleto),
                _buildInfoRow('Email:', alumno.email),
                _buildInfoRow('Grupo:', alumno.grupoNombre ?? 'Sin grupo'),
                _buildInfoRow('Nivel:', alumno.nivel.toUpperCase()),
                _buildInfoRow(
                  'Fecha:',
                  DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // Estadísticas
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildStatBox('Actividades', '${calificaciones.length}'),
                _buildStatBox('Aprobadas', '$aprobadas'),
                _buildStatBox('Reprobadas', '$reprobadas'),
                _buildStatBox('Promedio', '${promedio.toStringAsFixed(1)}%'),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // Título de tabla
          pw.Text(
            'Detalle de Calificaciones',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 10),

          // Tabla de calificaciones
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              // Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  _buildTableCell('Tema', isHeader: true),
                  _buildTableCell('Actividad', isHeader: true),
                  _buildTableCell('Puntos', isHeader: true),
                  _buildTableCell('%', isHeader: true),
                  _buildTableCell('Estado', isHeader: true),
                  _buildTableCell('Fecha', isHeader: true),
                ],
              ),
              // Rows
              ...calificaciones.map((cal) {
                final isAprobado = cal.porcentaje >= 70;
                return pw.TableRow(
                  children: [
                    _buildTableCell(cal.temaNombre),
                    _buildTableCell(cal.actividadTitulo),
                    _buildTableCell(
                        '${cal.puntuacionObtenida}/${cal.puntuacionMaxima}'),
                    _buildTableCell('${cal.porcentaje.toStringAsFixed(1)}%'),
                    _buildTableCell(
                      isAprobado ? 'Aprobado' : 'Reprobado',
                      color: isAprobado ? PdfColors.green : PdfColors.red,
                    ),
                    _buildTableCell(
                      DateFormat('dd/MM/yyyy').format(cal.fechaRealizacion),
                    ),
                  ],
                );
              }),
            ],
          ),

          pw.SizedBox(height: 20),

          // Pie de página
          pw.Divider(),
          pw.SizedBox(height: 10),
          pw.Text(
            'Este reporte fue generado automáticamente por Maya App',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );

    return pdf;
  }

  /// Genera un PDF con las calificaciones de un grupo
  static Future<pw.Document> generarReportePorGrupo({
    required String grupoNombre,
    required String nivel,
    required Map<String, List<Calificacion>> calificacionesPorAlumno,
    required List<Alumno> alumnos,
  }) async {
    final pdf = pw.Document();

    // Calcular estadísticas del grupo
    final todasCalificaciones = calificacionesPorAlumno.values
        .expand((list) => list)
        .toList();

    final promedioGrupo = todasCalificaciones.isEmpty
        ? 0.0
        : todasCalificaciones.fold<double>(
                0.0, (sum, c) => sum + c.porcentaje) /
            todasCalificaciones.length;

    final totalAlumnos = calificacionesPorAlumno.keys.length;
    final totalActividades = todasCalificaciones.length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Encabezado
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'REPORTE DE GRUPO',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 2),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // Información del grupo
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 1),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Información del Grupo',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                _buildInfoRow('Grupo:', grupoNombre),
                _buildInfoRow('Nivel:', nivel),
                _buildInfoRow('Total Alumnos:', '$totalAlumnos'),
                _buildInfoRow(
                  'Fecha:',
                  DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // Estadísticas del grupo
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildStatBox('Alumnos', '$totalAlumnos'),
                _buildStatBox('Actividades', '$totalActividades'),
                _buildStatBox('Promedio', '${promedioGrupo.toStringAsFixed(1)}%'),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // Título
          pw.Text(
            'Calificaciones por Alumno',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 10),

          // Resumen por alumno
          ...calificacionesPorAlumno.entries.map((entry) {
            final alumnoId = entry.key;
            final calificaciones = entry.value;
            final alumno = alumnos.firstWhere((a) => a.id == alumnoId);

            final promedioAlumno = calificaciones.isEmpty
                ? 0.0
                : calificaciones.fold<double>(
                        0.0, (sum, c) => sum + c.porcentaje) /
                    calificaciones.length;

            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 16),
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        alumno.nombreCompleto,
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Promedio: ${promedioAlumno.toStringAsFixed(1)}%',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: promedioAlumno >= 70
                              ? PdfColors.green
                              : PdfColors.red,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    '${calificaciones.length} actividades completadas',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            );
          }),

          pw.SizedBox(height: 20),

          // Pie de página
          pw.Divider(),
          pw.SizedBox(height: 10),
          pw.Text(
            'Este reporte fue generado automáticamente por Maya App',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );

    return pdf;
  }

  /// Guarda el PDF en el dispositivo y lo abre
  static Future<void> guardarYAbrirPDF(
    pw.Document pdf,
    String nombreArchivo,
  ) async {
    try {
      final bytes = await pdf.save();

      // Usar el diálogo de impresión/compartir nativo
      await Printing.layoutPdf(
        onLayout: (format) async => bytes,
        name: '$nombreArchivo.pdf',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Imprime el PDF directamente
  static Future<void> imprimirPDF(pw.Document pdf) async {
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  // Helpers
  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(value),
        ],
      ),
    );
  }

  static pw.Widget _buildStatBox(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
}
