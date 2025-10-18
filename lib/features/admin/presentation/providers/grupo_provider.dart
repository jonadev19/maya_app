import 'package:flutter/foundation.dart';
import '../../../shared/domain/entities/grupo.dart';
import '../../domain/repositories/grupo_repository.dart';
import '../../domain/repositories/alumno_repository.dart';

enum GrupoState {
  initial,
  loading,
  loaded,
  error,
}

class GrupoProvider extends ChangeNotifier {
  final GrupoRepository repository;
  final AlumnoRepository alumnoRepository;

  GrupoProvider({
    required this.repository,
    required this.alumnoRepository,
  });

  GrupoState _state = GrupoState.initial;
  List<Grupo> _grupos = [];
  Grupo? _currentGrupo;
  String? _errorMessage;
  bool _isSubmitting = false;

  GrupoState get state => _state;
  List<Grupo> get grupos => _grupos;
  Grupo? get currentGrupo => _currentGrupo;
  String? get errorMessage => _errorMessage;
  bool get isSubmitting => _isSubmitting;

  // Cargar todos los grupos
  Future<void> loadGrupos() async {
    _state = GrupoState.loading;
    _errorMessage = null;
    notifyListeners();

    // Cargar grupos y alumnos en paralelo
    final gruposResult = await repository.getGrupos();
    final alumnosResult = await alumnoRepository.getAlumnos();

    gruposResult.fold(
      (failure) {
        _state = GrupoState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (grupos) {
        alumnosResult.fold(
          (failure) {
            // Si falla obtener alumnos, usar grupos sin contador
            _grupos = grupos;
            _state = GrupoState.loaded;
            notifyListeners();
          },
          (alumnos) {
            // Calcular cantidad de alumnos por grupo
            _grupos = grupos.map((grupo) {
              final cantidadAlumnos = alumnos.where((alumno) => 
                alumno.grupoId == grupo.id && alumno.activo
              ).length;
              
              return Grupo(
                id: grupo.id,
                nombre: grupo.nombre,
                nivel: grupo.nivel,
                descripcion: grupo.descripcion,
                cantidadAlumnos: cantidadAlumnos,
                activo: grupo.activo,
              );
            }).toList();
            
            _state = GrupoState.loaded;
            notifyListeners();
          },
        );
      },
    );
  }

  // Cargar grupo por ID
  Future<void> loadGrupoById(String id) async {
    _state = GrupoState.loading;
    _errorMessage = null;
    notifyListeners();

    // Cargar grupo y alumnos para calcular cantidad
    final grupoResult = await repository.getGrupoById(id);
    final alumnosResult = await alumnoRepository.getAlumnos();

    grupoResult.fold(
      (failure) {
        _state = GrupoState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (grupo) {
        alumnosResult.fold(
          (failure) {
            // Si falla obtener alumnos, usar grupo sin contador actualizado
            _currentGrupo = grupo;
            _state = GrupoState.loaded;
            notifyListeners();
          },
          (alumnos) {
            // Calcular cantidad de alumnos en este grupo
            final cantidadAlumnos = alumnos.where((alumno) => 
              alumno.grupoId == grupo.id && alumno.activo
            ).length;
            
            _currentGrupo = Grupo(
              id: grupo.id,
              nombre: grupo.nombre,
              nivel: grupo.nivel,
              descripcion: grupo.descripcion,
              cantidadAlumnos: cantidadAlumnos,
              activo: grupo.activo,
            );
            
            _state = GrupoState.loaded;
            notifyListeners();
          },
        );
      },
    );
  }

  // Crear nuevo grupo
  Future<bool> createGrupo({
    required String nombre,
    required String nivel,
    String? descripcion,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final result = await repository.createGrupo(
      nombre: nombre,
      nivel: nivel,
      descripcion: descripcion,
    );

    _isSubmitting = false;

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (grupo) {
        _grupos.add(grupo);
        notifyListeners();
        return true;
      },
    );
  }

  // Actualizar grupo
  Future<bool> updateGrupo({
    required String id,
    String? nombre,
    String? nivel,
    String? descripcion,
    bool? activo,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final result = await repository.updateGrupo(
      id: id,
      nombre: nombre,
      nivel: nivel,
      descripcion: descripcion,
      activo: activo,
    );

    _isSubmitting = false;

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (grupo) {
        final index = _grupos.indexWhere((g) => g.id == id);
        if (index != -1) {
          _grupos[index] = grupo;
        }
        _currentGrupo = grupo;
        notifyListeners();
        return true;
      },
    );
  }

  // Eliminar grupo
  Future<bool> deleteGrupo(String id) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final result = await repository.deleteGrupo(id);

    _isSubmitting = false;

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        _grupos.removeWhere((g) => g.id == id);
        if (_currentGrupo?.id == id) {
          _currentGrupo = null;
        }
        notifyListeners();
        return true;
      },
    );
  }

  // Limpiar el grupo actual
  void clearCurrentGrupo() {
    _currentGrupo = null;
    notifyListeners();
  }

  // Limpiar error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Filtrar grupos por nivel
  List<Grupo> getGruposByNivel(String nivel) {
    return _grupos.where((g) => g.nivel == nivel).toList();
  }

  // Buscar grupos por nombre
  List<Grupo> searchGrupos(String query) {
    final lowerQuery = query.toLowerCase();
    return _grupos.where((g) {
      return g.nombre.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
