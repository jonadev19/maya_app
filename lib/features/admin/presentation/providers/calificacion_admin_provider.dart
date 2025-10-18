import 'package:flutter/foundation.dart';
import '../../../shared/domain/entities/calificacion.dart';
import '../../../shared/domain/entities/alumno.dart';
import '../../domain/repositories/calificacion_admin_repository.dart';
import '../../domain/repositories/alumno_repository.dart';

enum CalificacionAdminState {
  initial,
  loading,
  loaded,
  error,
}

class CalificacionAdminProvider extends ChangeNotifier {
  final CalificacionAdminRepository repository;
  final AlumnoRepository alumnoRepository;

  CalificacionAdminProvider({
    required this.repository,
    required this.alumnoRepository,
  });

  CalificacionAdminState _state = CalificacionAdminState.initial;
  List<Calificacion> _calificaciones = [];
  Map<String, Alumno> _alumnos = {};
  String? _errorMessage;

  CalificacionAdminState get state => _state;
  List<Calificacion> get calificaciones => _calificaciones;
  Map<String, Alumno> get alumnos => _alumnos;
  String? get errorMessage => _errorMessage;

  // Cargar todas las calificaciones
  Future<void> loadTodasCalificaciones() async {
    _state = CalificacionAdminState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await repository.getTodasCalificaciones();
    await result.fold(
      (failure) {
        _state = CalificacionAdminState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (calificaciones) async {
        _calificaciones = calificaciones;
        
        // Cargar información de alumnos
        await _loadAlumnosData();
        
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
    await result.fold(
      (failure) {
        _state = CalificacionAdminState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (calificaciones) async {
        _calificaciones = calificaciones;
        
        // Cargar información de alumnos
        await _loadAlumnosData();
        
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
      final alumno = _alumnos[c.alumnoId];
      return c.actividadTitulo.toLowerCase().contains(lowerQuery) ||
          c.temaNombre.toLowerCase().contains(lowerQuery) ||
          (alumno?.nombreCompleto.toLowerCase().contains(lowerQuery) ?? false);
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

  // Cargar datos de alumnos
  Future<void> _loadAlumnosData() async {
    final alumnosIds = _calificaciones.map((c) => c.alumnoId).toSet();
    
    for (final alumnoId in alumnosIds) {
      if (!_alumnos.containsKey(alumnoId)) {
        final result = await alumnoRepository.getAlumnoById(alumnoId);
        result.fold(
          (failure) {
            // Si no se puede cargar un alumno, simplemente lo omitimos
          },
          (alumno) {
            _alumnos[alumnoId] = alumno;
          },
        );
      }
    }
  }

  // Obtener alumno por ID
  Alumno? getAlumnoById(String alumnoId) {
    return _alumnos[alumnoId];
  }

  // Limpiar error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
