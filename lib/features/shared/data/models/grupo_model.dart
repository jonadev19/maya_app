import '../../domain/entities/grupo.dart';

class GrupoModel extends Grupo {
  const GrupoModel({
    required super.id,
    required super.nombre,
    required super.nivel,
    super.descripcion,
    super.cantidadAlumnos,
    super.activo,
  });

  factory GrupoModel.fromJson(Map<String, dynamic> json) {
    return GrupoModel(
      id: json['id'].toString(),
      nombre: (json['nombre'] as String?) ?? '',
      nivel: (json['nivel'] as String?) ?? 'basico',
      descripcion: json['descripcion'] as String?,
      cantidadAlumnos: json['cantidad_alumnos'] is String ? int.parse(json['cantidad_alumnos']) : (json['cantidad_alumnos'] as int? ?? 0),
      activo: json['activo'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'nivel': nivel,
      'descripcion': descripcion,
      'cantidad_alumnos': cantidadAlumnos,
      'activo': activo,
    };
  }

  Grupo toEntity() => Grupo(
        id: id,
        nombre: nombre,
        nivel: nivel,
        descripcion: descripcion,
        cantidadAlumnos: cantidadAlumnos,
        activo: activo,
      );
}
