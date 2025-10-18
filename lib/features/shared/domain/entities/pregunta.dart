import 'package:equatable/equatable.dart';

class Pregunta extends Equatable {
  final int id;
  final int actividadId;
  final String textoPregunta;
  final String tipo; // 'opcion_multiple', 'verdadero_falso', 'completar'
  final List<OpcionRespuesta> opciones;
  final int puntos;

  const Pregunta({
    required this.id,
    required this.actividadId,
    required this.textoPregunta,
    required this.tipo,
    required this.opciones,
    required this.puntos,
  });

  @override
  List<Object?> get props => [id, actividadId, textoPregunta, tipo, opciones, puntos];
}

class OpcionRespuesta extends Equatable {
  final int id;
  final String textoOpcion;
  final bool esCorrecta;

  const OpcionRespuesta({
    required this.id,
    required this.textoOpcion,
    required this.esCorrecta,
  });

  @override
  List<Object?> get props => [id, textoOpcion, esCorrecta];
}