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
    // Adaptarse a la nueva estructura de la API Django
    return PreguntaModel(
      id: json['id'].toString(),
      actividadId: '', // No viene en la respuesta individual
      textoPregunta: (json['texto'] as String?) ?? '', // Cambio de 'texto_pregunta' a 'texto'
      tipo: (json['tipo'] as String?) ?? 'opcion_multiple',
      opciones: _parseOpciones(json),
      puntos: json['puntos'] is String ? int.parse(json['puntos']) : (json['puntos'] as int? ?? 1),
    );
  }

  // Método helper para parsear opciones desde la nueva estructura
  static List<OpcionRespuesta> _parseOpciones(Map<String, dynamic> json) {
    final opciones = json['opciones'] as List?;
    final respuestaCorrecta = json['respuesta_correcta'] as String?;
    
    if (opciones == null) return [];
    
    // Si opciones es un array de strings, convertir a OpcionRespuesta
    if (opciones.isNotEmpty && opciones.first is String) {
      return opciones.asMap().entries.map((entry) {
        final opcion = entry.value as String;
        return OpcionRespuesta(
          id: entry.key.toString(),
          textoOpcion: opcion,
          esCorrecta: opcion == respuestaCorrecta,
        );
      }).toList();
    }
    
    // Si ya son objetos, usar el parser original
    return opciones
        .map((opcion) => OpcionRespuestaModel.fromJson(opcion))
        .toList();
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
      id: json['id'].toString(),
      textoOpcion: (json['texto_opcion'] as String?) ?? '',
      esCorrecta: (json['es_correcta'] as bool?) ?? false,
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
