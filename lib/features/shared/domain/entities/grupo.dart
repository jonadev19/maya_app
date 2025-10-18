import 'package:equatable/equatable.dart';

class Grupo extends Equatable {
  final String id;
  final String nombre;
  final String nivel; // 'basico', 'intermedio', 'avanzado'
  final String? descripcion;
  final int cantidadAlumnos;
  final bool activo;

  const Grupo({
    required this.id,
    required this.nombre,
    required this.nivel,
    this.descripcion,
    this.cantidadAlumnos = 0,
    this.activo = true,
  });

  @override
  List<Object?> get props => [id, nombre, nivel, descripcion, cantidadAlumnos, activo];
}