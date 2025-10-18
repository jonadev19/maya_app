import 'package:flutter/foundation.dart';
import '../../../shared/domain/entities/calificacion.dart';
import '../../domain/repositories/calificacion_admin_repository.dart';

enum CalificacionAdminState {
  initial,
  loading,
  loaded,
  error,
}

class CalificacionAdminProvider extends ChangeNotifier {
  final CalificacionAdminRepository repository;

  CalificacionAdminProvider({required this.repository});

  CalificacionAdminState _state = CalificacionAdminState.initial;
  List<Calificacion> _calificaciones = [];
  String? _errorMessage;

  CalificacionAdminState get state => _state;
  List<Calificacion> get calificaciones => _calificaciones;
  String? get errorMessage => _errorMessage;

  // Cargar todas las calificaciones
  Future<void> loadTodasCalificaciones() async {
    _state = CalificacionAdminState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await repository.getTodasCalificaciones();
    result.fold(
      (failure) {
        _state = CalificacionAdminState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (calificaciones) {
        _calificaciones = calificaciones;
        _state = CalificacionAdminState.loaded;
        notifyListeners();
      },
    );
  }

  // Cargar calificaciones por alumno
  Future<void> loadCalificacionesByAlumno(String alumnoId) async {
    _state = CalificacionAdminState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await repository.getCalificacionesByAlumno(alumnoId);
    result.fold(
      (failure) {
        _state = CalificacionAdminState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (calificaciones) {
        _calificaciones = calificaciones;
        _state = CalificacionAdminState.loaded;
        notifyListeners();
      },
    );
  }

  // Filtrar por tema
  List<Calificacion> getCalificacionesByTema(String temaNombre) {
    return _calificaciones
        .where((c) => c.temaNombre.toLowerCase().contains(temaNombre.toLowerCase()))
        .toList();
  }

  // Filtrar por alumno (nombre)
  List<Calificacion> searchByAlumno(String query) {
    final lowerQuery = query.toLowerCase();
    return _calificaciones.where((c) {
      // Asumiendo que el nombre del alumno viene en algún campo
      // Si no existe, necesitarás agregarlo al modelo
      return c.actividadTitulo.toLowerCase().contains(lowerQuery) ||
          c.temaNombre.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Calcular promedio general
  double get promedioGeneral {
    if (_calificaciones.isEmpty) return 0.0;
    final sum = _calificaciones.fold<double>(
      0.0,
      (prev, cal) => prev + cal.porcentaje,
    );
    return sum / _calificaciones.length;
  }

  // Obtener estadísticas
  Map<String, dynamic> getEstadisticas() {
    if (_calificaciones.isEmpty) {
      return {
        'total': 0,
        'aprobados': 0,
        'reprobados': 0,
        'promedio': 0.0,
      };
    }

    final aprobados = _calificaciones.where((c) => c.porcentaje >= 70).length;
    final reprobados = _calificaciones.where((c) => c.porcentaje < 70).length;

    return {
      'total': _calificaciones.length,
      'aprobados': aprobados,
      'reprobados': reprobados,
      'promedio': promedioGeneral,
    };
  }

  // Agrupar por alumno (si tenemos el campo alumnoId)
  Map<String, List<Calificacion>> groupByAlumno() {
    final Map<String, List<Calificacion>> grouped = {};
    for (var cal in _calificaciones) {
      if (!grouped.containsKey(cal.alumnoId)) {
        grouped[cal.alumnoId] = [];
      }
      grouped[cal.alumnoId]!.add(cal);
    }
    return grouped;
  }

  // Limpiar error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
