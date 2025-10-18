import 'package:equatable/equatable.dart';

class Alumno extends Equatable {
  final int id;
  final String nombre;
  final String apellido;
  final String email;
  final int? grupoId;
  final String? grupoNombre;
  final String nivel;
  final DateTime? fechaRegistro;
  final bool activo;

  const Alumno({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    this.grupoId,
    this.grupoNombre,
    required this.nivel,
    this.fechaRegistro,
    this.activo = true,
  });

  String get nombreCompleto => '$nombre $apellido';

  @override
  List<Object?> get props => [
        id,
        nombre,
        apellido,
        email,
        grupoId,
        grupoNombre,
        nivel,
        fechaRegistro,
        activo,
      ];
}