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
      id: json['id'] as int,
      temaId: json['tema_id'] as int,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      tipo: json['tipo'] as String,
      puntuacionMaxima: json['puntuacion_maxima'] as int,
      duracionMinutos: json['duracion_minutos'] as int,
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
