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
    print('Parsing calificacion JSON: $json');
    
    // La API envía 'puntaje_obtenido' y 'puntaje_total', no 'puntuacion_obtenida'/'puntuacion_maxima'
    int puntuacionObtenida = 0;
    
    // Verificar si viene con el nombre de campo correcto de la API
    if (json['puntaje_obtenido'] != null) {
      print('puntaje_obtenido type: ${json['puntaje_obtenido'].runtimeType}, value: ${json['puntaje_obtenido']}');
      if (json['puntaje_obtenido'] is String) {
        try {
          puntuacionObtenida = int.parse(json['puntaje_obtenido']);
        } catch (e) {
          print('Error parsing puntaje_obtenido as String: ${json['puntaje_obtenido']}');
          puntuacionObtenida = 0;
        }
      } else if (json['puntaje_obtenido'] is num) {
        puntuacionObtenida = (json['puntaje_obtenido'] as num).toInt();
      } else {
        print('Unexpected type for puntaje_obtenido: ${json['puntaje_obtenido'].runtimeType}');
      }
    } else if (json['puntuacion_obtenida'] != null) {
      // Fallback para el nombre anterior del campo
      if (json['puntuacion_obtenida'] is String) {
        try {
          puntuacionObtenida = int.parse(json['puntuacion_obtenida']);
        } catch (e) {
          print('Error parsing puntuacion_obtenida as String: ${json['puntuacion_obtenida']}');
          puntuacionObtenida = 0;
        }
      } else if (json['puntuacion_obtenida'] is num) {
        puntuacionObtenida = (json['puntuacion_obtenida'] as num).toInt();
      }
    }
    
    int puntuacionMaxima = 100;
    
    // Verificar si viene con el nombre de campo correcto de la API
    if (json['puntaje_total'] != null) {
      if (json['puntaje_total'] is String) {
        try {
          puntuacionMaxima = int.parse(json['puntaje_total']);
        } catch (e) {
          print('Error parsing puntaje_total as String: ${json['puntaje_total']}');
          puntuacionMaxima = 100;
        }
      } else if (json['puntaje_total'] is num) {
        puntuacionMaxima = (json['puntaje_total'] as num).toInt();
      }
    } else if (json['puntuacion_maxima'] != null) {
      // Fallback para el nombre anterior del campo
      if (json['puntuacion_maxima'] is String) {
        try {
          puntuacionMaxima = int.parse(json['puntuacion_maxima']);
        } catch (e) {
          print('Error parsing puntuacion_maxima as String: ${json['puntuacion_maxima']}');
          puntuacionMaxima = 100;
        }
      } else if (json['puntuacion_maxima'] is num) {
        puntuacionMaxima = (json['puntuacion_maxima'] as num).toInt();
      }
    }
    
    print('Parsed puntuacionObtenida: $puntuacionObtenida, puntuacionMaxima: $puntuacionMaxima');
    
    // La API también envía 'fecha_evaluacion' en lugar de 'fecha_realizacion'
    String fechaString = (json['fecha_evaluacion'] as String?) ?? (json['fecha_realizacion'] as String?) ?? DateTime.now().toIso8601String();
    
    return CalificacionModel(
      id: json['id'].toString(),
      alumnoId: json['alumno_id'].toString(),
      actividadId: json['actividad_id'].toString(),
      actividadTitulo: (json['actividad_titulo'] as String?) ?? '',
      temaNombre: (json['tema_nombre'] as String?) ?? '',
      puntuacionObtenida: puntuacionObtenida,
      puntuacionMaxima: puntuacionMaxima,
      fechaRealizacion: DateTime.parse(fechaString),
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
