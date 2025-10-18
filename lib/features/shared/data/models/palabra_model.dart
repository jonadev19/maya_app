import '../../domain/entities/palabra.dart';

class PalabraModel extends Palabra {
  const PalabraModel({
    required super.id,
    required super.temaId,
    required super.palabraMaya,
    required super.traduccionEspanol,
    super.pronunciacion,
    super.audioUrl,
    super.imagenUrl,
  });

  factory PalabraModel.fromJson(Map<String, dynamic> json) {
    // El backend usa 'palabra_espanol', no 'traduccion_espanol'
    final traduccion = (json['palabra_espanol'] as String?) ??
        (json['palabraEspanol'] as String?) ??
        (json['traduccion_espanol'] as String?) ??
        (json['traduccionEspanol'] as String?) ??
        '';

    return PalabraModel(
      id: json['id'].toString(),
      temaId: json['tema_id']?.toString() ?? json['tema']?.toString() ?? '',
      palabraMaya: (json['palabra_maya'] as String?) ??
          (json['palabraMaya'] as String?) ??
          '',
      traduccionEspanol: traduccion,
      pronunciacion: json['pronunciacion'] as String?,
      audioUrl: json['audio_url'] as String? ?? json['audioUrl'] as String?,
      imagenUrl: json['imagen_url'] as String? ?? json['imagenUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tema_id': temaId,
      'palabra_maya': palabraMaya,
      'traduccion_espanol': traduccionEspanol,
      'pronunciacion': pronunciacion,
      'audio_url': audioUrl,
      'imagen_url': imagenUrl,
    };
  }

  Palabra toEntity() => Palabra(
        id: id,
        temaId: temaId,
        palabraMaya: palabraMaya,
        traduccionEspanol: traduccionEspanol,
        pronunciacion: pronunciacion,
        audioUrl: audioUrl,
        imagenUrl: imagenUrl,
      );
}
