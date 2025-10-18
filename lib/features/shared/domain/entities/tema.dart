import 'package:equatable/equatable.dart';

class Tema extends Equatable {
  final int id;
  final String nombre;
  final String descripcion;
  final String? imagenUrl;
  final String nivel; // 'basico', 'intermedio', 'avanzado'
  final int orden;
  final bool activo;

  const Tema({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.imagenUrl,
    required this.nivel,
    required this.orden,
    this.activo = true,
  });

  @override
  List<Object?> get props => [id, nombre, descripcion, imagenUrl, nivel, orden, activo];
}