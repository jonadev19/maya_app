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
      id: json['id'] is String ? int.parse(json['id']) : json['id'] as int,
      alumnoId: json['alumno_id'] is String ? int.parse(json['alumno_id']) : json['alumno_id'] as int,
      actividadId: json['actividad_id'] is String ? int.parse(json['actividad_id']) : json['actividad_id'] as int,
      actividadTitulo: json['actividad_titulo'] as String,
      temaNombre: json['tema_nombre'] as String,
      puntuacionObtenida: json['puntuacion_obtenida'] is String ? int.parse(json['puntuacion_obtenida']) : json['puntuacion_obtenida'] as int,
      puntuacionMaxima: json['puntuacion_maxima'] is String ? int.parse(json['puntuacion_maxima']) : json['puntuacion_maxima'] as int,
      fechaRealizacion: DateTime.parse(json['fecha_realizacion'] as String),
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
