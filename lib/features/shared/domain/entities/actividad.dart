import 'package:equatable/equatable.dart';

class Actividad extends Equatable {
  final String id;
  final String temaId;
  final String titulo;
  final String descripcion;
  final String tipo; // 'quiz', 'emparejamiento', 'completar', 'audio'
  final int puntuacionMaxima;
  final int duracionMinutos;

  const Actividad({
    required this.id,
    required this.temaId,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    required this.puntuacionMaxima,
    required this.duracionMinutos,
  });

  @override
  List<Object?> get props => [
        id,
        temaId,
        titulo,
        descripcion,
        tipo,
        puntuacionMaxima,
        duracionMinutos,
      ];
}