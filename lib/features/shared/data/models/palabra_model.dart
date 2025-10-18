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
    return PalabraModel(
      id: json['id'].toString(),
      temaId: json['tema_id'].toString(),
      palabraMaya: (json['palabra_maya'] as String?) ?? '',
      traduccionEspanol: (json['traduccion_espanol'] as String?) ?? '',
      pronunciacion: json['pronunciacion'] as String?,
      audioUrl: json['audio_url'] as String?,
      imagenUrl: json['imagen_url'] as String?,
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
