import 'package:flutter/foundation.dart';
import '../../../shared/domain/entities/alumno.dart';
import '../../domain/repositories/alumno_repository.dart';

enum AlumnoState {
  initial,
  loading,
  loaded,
  error,
}

class AlumnoProvider extends ChangeNotifier {
  final AlumnoRepository repository;

  AlumnoProvider({required this.repository});

  AlumnoState _state = AlumnoState.initial;
  List<Alumno> _alumnos = [];
  Alumno? _currentAlumno;
  String? _errorMessage;
  bool _isSubmitting = false;

  AlumnoState get state => _state;
  List<Alumno> get alumnos => _alumnos;
  Alumno? get currentAlumno => _currentAlumno;
  String? get errorMessage => _errorMessage;
  bool get isSubmitting => _isSubmitting;

  // Cargar todos los alumnos
  Future<void> loadAlumnos() async {
    _state = AlumnoState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await repository.getAlumnos();
    result.fold(
      (failure) {
        _state = AlumnoState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (alumnos) {
        _alumnos = alumnos;
        _state = AlumnoState.loaded;
        notifyListeners();
      },
    );
  }

  // Cargar alumno por ID
  Future<void> loadAlumnoById(String id) async {
    _state = AlumnoState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await repository.getAlumnoById(id);
    result.fold(
      (failure) {
        _state = AlumnoState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (alumno) {
        _currentAlumno = alumno;
        _state = AlumnoState.loaded;
        notifyListeners();
      },
    );
  }

  // Crear nuevo alumno
  Future<bool> createAlumno({
    required String nombre,
    required String apellido,
    required String email,
    required String password,
    String? grupoId,
    required String nivel,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final result = await repository.createAlumno(
      nombre: nombre,
      apellido: apellido,
      email: email,
      password: password,
      grupoId: grupoId,
      nivel: nivel,
    );

    _isSubmitting = false;

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (alumno) {
        _alumnos.add(alumno);
        notifyListeners();
        return true;
      },
    );
  }

  // Actualizar alumno
  Future<bool> updateAlumno({
    required String id,
    String? nombre,
    String? apellido,
    String? email,
    String? password,
    String? grupoId,
    String? nivel,
    bool? activo,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final result = await repository.updateAlumno(
      id: id,
      nombre: nombre,
      apellido: apellido,
      email: email,
      password: password,
      grupoId: grupoId,
      nivel: nivel,
      activo: activo,
    );

    _isSubmitting = false;

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (alumno) {
        final index = _alumnos.indexWhere((a) => a.id == id);
        if (index != -1) {
          _alumnos[index] = alumno;
        }
        _currentAlumno = alumno;
        notifyListeners();
        return true;
      },
    );
  }

  // Eliminar alumno
  Future<bool> deleteAlumno(String id) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final result = await repository.deleteAlumno(id);

    _isSubmitting = false;

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        _alumnos.removeWhere((a) => a.id == id);
        if (_currentAlumno?.id == id) {
          _currentAlumno = null;
        }
        notifyListeners();
        return true;
      },
    );
  }

  // Limpiar el alumno actual
  void clearCurrentAlumno() {
    _currentAlumno = null;
    notifyListeners();
  }

  // Limpiar error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Filtrar alumnos por grupo
  List<Alumno> getAlumnosByGrupo(String grupoId) {
    return _alumnos.where((a) => a.grupoId == grupoId).toList();
  }

  // Filtrar alumnos por nivel
  List<Alumno> getAlumnosByNivel(String nivel) {
    return _alumnos.where((a) => a.nivel == nivel).toList();
  }

  // Buscar alumnos por nombre
  List<Alumno> searchAlumnos(String query) {
    final lowerQuery = query.toLowerCase();
    return _alumnos.where((a) {
      return a.nombre.toLowerCase().contains(lowerQuery) ||
          a.apellido.toLowerCase().contains(lowerQuery) ||
          a.email.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
