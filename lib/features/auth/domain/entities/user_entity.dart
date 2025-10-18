import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String nombre;
  final String apellido;
  final String rol; // 'administrador' o 'alumno'
  final bool activo;
  final String? grupoId;
  final String? grupoNombre;
  final String? nivel; // 'Básico', 'Intermedio', 'Avanzado' (solo para alumnos)

  const UserEntity({
    required this.id,
    required this.email,
    required this.nombre,
    required this.apellido,
    required this.rol,
    required this.activo,
    this.grupoId,
    this.grupoNombre,
    this.nivel,
  });

  String get nombreCompleto => '$nombre $apellido';

  bool get isAdministrador => rol == 'administrador';
  bool get isAlumno => rol == 'alumno';

  @override
  List<Object?> get props => [
        id,
        email,
        nombre,
        apellido,
        rol,
        activo,
        grupoId,
        grupoNombre,
        nivel,
      ];
}
