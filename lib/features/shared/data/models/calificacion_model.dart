import '../../domain/entities/calificacion.dart';

class CalificacionModel extends Calificacion {
  const CalificacionModel({
    required super.id,
    required super.alumnoId,
    required super.actividadId,
    required super.actividadTitulo,
    required super.temaNombre,
    required super.puntuacionObtenida,
    required super.puntuacionMaxima,
    required super.fechaRealizacion,
    super.intentos,
  });

  factory CalificacionModel.fromJson(Map<String, dynamic> json) {
    return CalificacionModel(
      id: json['id'].toString(),
      alumnoId: json['alumno_id'].toString(),
      actividadId: json['actividad_id'].toString(),
      actividadTitulo: (json['actividad_titulo'] as String?) ?? '',
      temaNombre: (json['tema_nombre'] as String?) ?? '',
      puntuacionObtenida: json['puntuacion_obtenida'] is String ? int.parse(json['puntuacion_obtenida']) : (json['puntuacion_obtenida'] as int? ?? 0),
      puntuacionMaxima: json['puntuacion_maxima'] is String ? int.parse(json['puntuacion_maxima']) : (json['puntuacion_maxima'] as int? ?? 100),
      fechaRealizacion: DateTime.parse((json['fecha_realizacion'] as String?) ?? DateTime.now().toIso8601String()),
      intentos: json['intentos'] is String ? int.parse(json['intentos']) : (json['intentos'] as int? ?? 1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'alumno_id': alumnoId,
      'actividad_id': actividadId,
      'actividad_titulo': actividadTitulo,
      'tema_nombre': temaNombre,
      'puntuacion_obtenida': puntuacionObtenida,
      'puntuacion_maxima': puntuacionMaxima,
      'fecha_realizacion': fechaRealizacion.toIso8601String(),
      'intentos': intentos,
    };
  }

  Calificacion toEntity() => Calificacion(
        id: id,
        alumnoId: alumnoId,
        actividadId: actividadId,
        actividadTitulo: actividadTitulo,
        temaNombre: temaNombre,
        puntuacionObtenida: puntuacionObtenida,
        puntuacionMaxima: puntuacionMaxima,
        fechaRealizacion: fechaRealizacion,
        intentos: intentos,
      );
}
