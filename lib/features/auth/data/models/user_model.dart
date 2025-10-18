import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.nombre,
    required super.apellido,
    required super.rol,
    required super.activo,
    super.grupoId,
    super.grupoNombre,
    super.nivel,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      rol: json['rol'] ?? '',
      activo: json['activo'] ?? true,
      grupoId: json['grupo_id'],
      grupoNombre: json['grupo_nombre'],
      nivel: json['nivel'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'apellido': apellido,
      'rol': rol,
      'activo': activo,
      'grupo_id': grupoId,
      'grupo_nombre': grupoNombre,
      'nivel': nivel,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      nombre: nombre,
      apellido: apellido,
      rol: rol,
      activo: activo,
      grupoId: grupoId,
      grupoNombre: grupoNombre,
      nivel: nivel,
    );
  }
}
