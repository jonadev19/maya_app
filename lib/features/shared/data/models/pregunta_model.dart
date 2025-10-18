import '../../domain/entities/pregunta.dart';

class PreguntaModel extends Pregunta {
  const PreguntaModel({
    required super.id,
    required super.actividadId,
    required super.textoPregunta,
    required super.tipo,
    required super.opciones,
    required super.puntos,
  });

  factory PreguntaModel.fromJson(Map<String, dynamic> json) {
    return PreguntaModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'] as int,
      actividadId: json['actividad_id'] is String ? int.parse(json['actividad_id']) : json['actividad_id'] as int,
      textoPregunta: json['texto_pregunta'] as String,
      tipo: json['tipo'] as String,
      opciones: (json['opciones'] as List)
          .map((opcion) => OpcionRespuestaModel.fromJson(opcion))
          .toList(),
      puntos: json['puntos'] is String ? int.parse(json['puntos']) : json['puntos'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'actividad_id': actividadId,
      'texto_pregunta': textoPregunta,
      'tipo': tipo,
      'opciones': opciones
          .map((opcion) => OpcionRespuestaModel(
                id: opcion.id,
                textoOpcion: opcion.textoOpcion,
                esCorrecta: opcion.esCorrecta,
              ).toJson())
          .toList(),
      'puntos': puntos,
    };
  }

  Pregunta toEntity() => Pregunta(
        id: id,
        actividadId: actividadId,
        textoPregunta: textoPregunta,
        tipo: tipo,
        opciones: opciones,
        puntos: puntos,
      );
}

class OpcionRespuestaModel extends OpcionRespuesta {
  const OpcionRespuestaModel({
    required super.id,
    required super.textoOpcion,
    required super.esCorrecta,
  });

  factory OpcionRespuestaModel.fromJson(Map<String, dynamic> json) {
    return OpcionRespuestaModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'] as int,
      textoOpcion: json['texto_opcion'] as String,
      esCorrecta: json['es_correcta'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'texto_opcion': textoOpcion,
      'es_correcta': esCorrecta,
    };
  }
}
