import '../../domain/entities/actividad.dart';

class ActividadModel extends Actividad {
  const ActividadModel({
    required super.id,
    required super.temaId,
    required super.titulo,
    required super.descripcion,
    required super.tipo,
    required super.puntuacionMaxima,
    required super.duracionMinutos,
  });

  factory ActividadModel.fromJson(Map<String, dynamic> json) {
    return ActividadModel(
      id: json['id'].toString(),
      temaId: json['tema_id'].toString(),
      titulo: (json['titulo'] as String?) ?? '',
      descripcion: (json['descripcion'] as String?) ?? '',
      tipo: (json['tipo'] as String?) ?? 'quiz',
      puntuacionMaxima: json['puntuacion_maxima'] is String ? int.parse(json['puntuacion_maxima']) : (json['puntuacion_maxima'] as int? ?? 100),
      duracionMinutos: json['duracion_minutos'] is String ? int.parse(json['duracion_minutos']) : (json['duracion_minutos'] as int? ?? 30),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tema_id': temaId,
      'titulo': titulo,
      'descripcion': descripcion,
      'tipo': tipo,
      'puntuacion_maxima': puntuacionMaxima,
      'duracion_minutos': duracionMinutos,
    };
  }

  Actividad toEntity() => Actividad(
        id: id,
        temaId: temaId,
        titulo: titulo,
        descripcion: descripcion,
        tipo: tipo,
        puntuacionMaxima: puntuacionMaxima,
        duracionMinutos: duracionMinutos,
      );
}
