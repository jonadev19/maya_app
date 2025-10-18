import '../../domain/entities/material.dart';

class MaterialModel extends Material {
  const MaterialModel({
    required super.id,
    required super.temaId,
    required super.titulo,
    required super.contenido,
    required super.tipo,
    super.archivoUrl,
    required super.orden,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'].toString(),
      temaId: json['tema_id'].toString(),
      titulo: (json['titulo'] as String?) ?? '',
      contenido: (json['contenido'] as String?) ?? '',
      tipo: (json['tipo'] as String?) ?? 'texto',
      archivoUrl: json['archivo_url'] as String?,
      orden: json['orden'] is String ? int.parse(json['orden']) : (json['orden'] as int? ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tema_id': temaId,
      'titulo': titulo,
      'contenido': contenido,
      'tipo': tipo,
      'archivo_url': archivoUrl,
      'orden': orden,
    };
  }

  Material toEntity() => Material(
        id: id,
        temaId: temaId,
        titulo: titulo,
        contenido: contenido,
        tipo: tipo,
        archivoUrl: archivoUrl,
        orden: orden,
      );
}
