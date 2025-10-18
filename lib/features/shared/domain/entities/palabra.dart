import 'package:equatable/equatable.dart';

class Palabra extends Equatable {
  final int id;
  final int temaId;
  final String palabraMaya;
  final String traduccionEspanol;
  final String? pronunciacion;
  final String? audioUrl;
  final String? imagenUrl;

  const Palabra({
    required this.id,
    required this.temaId,
    required this.palabraMaya,
    required this.traduccionEspanol,
    this.pronunciacion,
    this.audioUrl,
    this.imagenUrl,
  });

  @override
  List<Object?> get props => [
        id,
        temaId,
        palabraMaya,
        traduccionEspanol,
        pronunciacion,
        audioUrl,
        imagenUrl,
      ];
}