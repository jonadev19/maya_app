import '../../domain/entities/alumno.dart';

class AlumnoModel extends Alumno {
  const AlumnoModel({
    required super.id,
    required super.nombre,
    required super.apellido,
    required super.email,
    super.grupoId,
    super.grupoNombre,
    required super.nivel,
    super.fechaRegistro,
    super.activo,
  });

  factory AlumnoModel.fromJson(Map<String, dynamic> json) {
    return AlumnoModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      email: json['email'] as String,
      grupoId: json['grupo_id'] as int?,
      grupoNombre: json['grupo_nombre'] as String?,
      nivel: json['nivel'] as String,
      fechaRegistro: json['fecha_registro'] != null
          ? DateTime.parse(json['fecha_registro'] as String)
          : null,
      activo: json['activo'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'grupo_id': grupoId,
      'grupo_nombre': grupoNombre,
      'nivel': nivel,
      'fecha_registro': fechaRegistro?.toIso8601String(),
      'activo': activo,
    };
  }

  Alumno toEntity() => Alumno(
        id: id,
        nombre: nombre,
        apellido: apellido,
        email: email,
        grupoId: grupoId,
        grupoNombre: grupoNombre,
        nivel: nivel,
        fechaRegistro: fechaRegistro,
        activo: activo,
      );
}
