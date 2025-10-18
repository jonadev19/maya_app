import '../../domain/entities/tema.dart';

class TemaModel extends Tema {
  const TemaModel({
    required super.id,
    required super.nombre,
    required super.descripcion,
    super.imagenUrl,
    required super.nivel,
    required super.orden,
    super.activo,
  });

  factory TemaModel.fromJson(Map<String, dynamic> json) {
    return TemaModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      imagenUrl: json['imagen_url'] as String?,
      nivel: json['nivel'] as String,
      orden: json['orden'] is String ? int.parse(json['orden']) : json['orden'] as int,
      activo: json['activo'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'imagen_url': imagenUrl,
      'nivel': nivel,
      'orden': orden,
      'activo': activo,
    };
  }

  Tema toEntity() => Tema(
        id: id,
        nombre: nombre,
        descripcion: descripcion,
        imagenUrl: imagenUrl,
        nivel: nivel,
        orden: orden,
        activo: activo,
      );
}
