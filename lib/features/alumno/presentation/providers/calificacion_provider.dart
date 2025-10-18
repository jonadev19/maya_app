import 'package:flutter/foundation.dart';
import '../../../shared/domain/entities/calificacion.dart';
import '../../domain/repositories/calificacion_repository.dart';

enum CalificacionState { initial, loading, loaded, error }

class CalificacionProvider with ChangeNotifier {
  final CalificacionRepository calificacionRepository;

  CalificacionProvider({required this.calificacionRepository});

  CalificacionState _state = CalificacionState.initial;
  List<Calificacion> _calificaciones = [];
  String? _errorMessage;

  CalificacionState get state => _state;
  List<Calificacion> get calificaciones => _calificaciones;
  String? get errorMessage => _errorMessage;

  double get promedioGeneral {
    if (_calificaciones.isEmpty) return 0.0;
    final sum = _calificaciones.fold(0.0, (sum, cal) => sum + cal.porcentaje);
    return sum / _calificaciones.length;
  }

  Future<void> loadCalificaciones() async {
    _state = CalificacionState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await calificacionRepository.getCalificacionesAlumno();

    result.fold(
      (failure) {
        _state = CalificacionState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (calificaciones) {
        _calificaciones = calificaciones;
        _state = CalificacionState.loaded;
        notifyListeners();
      },
    );
  }

  Future<void> loadCalificacionesByTema(String temaId) async {
    _state = CalificacionState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await calificacionRepository.getCalificacionesByTema(temaId);

    result.fold(
      (failure) {
        _state = CalificacionState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (calificaciones) {
        _calificaciones = calificaciones;
        _state = CalificacionState.loaded;
        notifyListeners();
      },
    );
  }
}
