import 'package:equatable/equatable.dart';

class Material extends Equatable {
  final String id;
  final String temaId;
  final String titulo;
  final String contenido;
  final String tipo; // 'texto', 'audio', 'video', 'imagen'
  final String? archivoUrl;
  final int orden;

  const Material({
    required this.id,
    required this.temaId,
    required this.titulo,
    required this.contenido,
    required this.tipo,
    this.archivoUrl,
    required this.orden,
  });

  @override
  List<Object?> get props => [id, temaId, titulo, contenido, tipo, archivoUrl, orden];
}