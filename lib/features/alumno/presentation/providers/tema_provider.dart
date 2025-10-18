import 'package:flutter/foundation.dart';
import '../../../shared/domain/entities/tema.dart';
import '../../../shared/domain/entities/material.dart';
import '../../../shared/domain/entities/palabra.dart';
import '../../../shared/domain/entities/actividad.dart';
import '../../domain/repositories/tema_repository.dart';

enum TemaState { initial, loading, loaded, error }

class TemaProvider with ChangeNotifier {
  final TemaRepository temaRepository;

  TemaProvider({required this.temaRepository});

  TemaState _state = TemaState.initial;
  List<Tema> _temas = [];
  Tema? _currentTema;
  List<Material> _materiales = [];
  List<Palabra> _palabras = [];
  List<Actividad> _actividades = [];
  String? _errorMessage;

  TemaState get state => _state;
  List<Tema> get temas => _temas;
  Tema? get currentTema => _currentTema;
  List<Material> get materiales => _materiales;
  List<Palabra> get palabras => _palabras;
  List<Actividad> get actividades => _actividades;
  String? get errorMessage => _errorMessage;

  Future<void> loadTemas() async {
    _state = TemaState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await temaRepository.getTemas();

    result.fold(
      (failure) {
        _state = TemaState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (temas) {
        _temas = temas;
        _state = TemaState.loaded;
        notifyListeners();
      },
    );
  }

  Future<void> loadTemaDetails(int temaId) async {
    _state = TemaState.loading;
    _errorMessage = null;
    notifyListeners();

    final temaResult = await temaRepository.getTemaById(temaId);
    final materialesResult = await temaRepository.getMaterialesByTema(temaId);
    final palabrasResult = await temaRepository.getPalabrasByTema(temaId);
    final actividadesResult = await temaRepository.getActividadesByTema(temaId);

    temaResult.fold(
      (failure) {
        _state = TemaState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (tema) {
        _currentTema = tema;

        materialesResult.fold(
          (failure) {},
          (materiales) => _materiales = materiales,
        );

        palabrasResult.fold(
          (failure) {},
          (palabras) => _palabras = palabras,
        );

        actividadesResult.fold(
          (failure) {},
          (actividades) => _actividades = actividades,
        );

        _state = TemaState.loaded;
        notifyListeners();
      },
    );
  }

  void clearCurrentTema() {
    _currentTema = null;
    _materiales = [];
    _palabras = [];
    _actividades = [];
    notifyListeners();
  }
}
