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
      id: json['id'].toString(),
      nombre: (json['nombre'] as String?) ?? '',
      apellido: (json['apellido'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      grupoId: json['grupo_id']?.toString(),
      grupoNombre: json['grupo_nombre'] as String?,
      nivel: _normalizeNivel((json['nivel'] as String?) ?? 'basico'),
      fechaRegistro: json['fecha_registro'] != null
          ? DateTime.parse(json['fecha_registro'] as String)
          : null,
      activo: json['activo'] as bool? ?? true,
    );
  }

  static String _normalizeNivel(String nivel) {
    final normalized = nivel.toLowerCase().trim();
    // Mapeo de variaciones comunes - normalizar a minúsculas para UI
    // Backend puede enviar: "Básico", "Intermedio", "Avanzado"
    if (normalized.contains('bas') || normalized.contains('bás')) {
      return 'basico';
    } else if (normalized.contains('inter')) {
      return 'intermedio';
    } else if (normalized.contains('avan')) {
      return 'avanzado';
    }
    return 'basico'; // Por defecto
  }

  static String _formatNivelForBackend(String nivel) {
    // Convertir de formato UI a formato backend
    // Backend valida: "Básico", "Intermedio", "Avanzado"
    switch (nivel.toLowerCase().trim()) {
      case 'basico':
      case 'básico':
        return 'Básico'; // Primera letra mayúscula, CON acento
      case 'intermedio':
        return 'Intermedio'; // Primera letra mayúscula
      case 'avanzado':
        return 'Avanzado'; // Primera letra mayúscula
      default:
        return 'Básico';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'grupo_id': grupoId,
      'grupo_nombre': grupoNombre,
      'nivel': _formatNivelForBackend(nivel),
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
