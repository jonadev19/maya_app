import 'package:equatable/equatable.dart';

class Calificacion extends Equatable {
  final String id;
  final String alumnoId;
  final String actividadId;
  final String actividadTitulo;
  final String temaNombre;
  final int puntuacionObtenida;
  final int puntuacionMaxima;
  final DateTime fechaRealizacion;
  final int intentos;

  const Calificacion({
    required this.id,
    required this.alumnoId,
    required this.actividadId,
    required this.actividadTitulo,
    required this.temaNombre,
    required this.puntuacionObtenida,
    required this.puntuacionMaxima,
    required this.fechaRealizacion,
    this.intentos = 1,
  });

  double get porcentaje => (puntuacionObtenida / puntuacionMaxima) * 100;

  @override
  List<Object?> get props => [
        id,
        alumnoId,
        actividadId,
        actividadTitulo,
        temaNombre,
        puntuacionObtenida,
        puntuacionMaxima,
        fechaRealizacion,
        intentos,
      ];
}