import 'package:flutter/foundation.dart';
import '../../../shared/domain/entities/actividad.dart';
import '../../../shared/domain/entities/pregunta.dart';
import '../../domain/repositories/actividad_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

enum ActividadState { initial, loading, loaded, submitting, completed, error }

class ActividadProvider with ChangeNotifier {
  final ActividadRepository actividadRepository;
  final AuthProvider authProvider;

  ActividadProvider({
    required this.actividadRepository,
    required this.authProvider,
  });

  ActividadState _state = ActividadState.initial;
  Actividad? _actividad;
  List<Pregunta> _preguntas = [];
  Map<String, String> _respuestas = {}; // preguntaId -> opcionId
  Map<String, dynamic>? _resultado;
  String? _errorMessage;

  ActividadState get state => _state;
  Actividad? get actividad => _actividad;
  List<Pregunta> get preguntas => _preguntas;
  Map<String, String> get respuestas => _respuestas;
  Map<String, dynamic>? get resultado => _resultado;
  String? get errorMessage => _errorMessage;

  Future<void> loadActividad(String actividadId) async {
    _state = ActividadState.loading;
    _errorMessage = null;
    _respuestas = {};
    _resultado = null;
    notifyListeners();

    final actividadResult = await actividadRepository.getActividadById(actividadId);
    final preguntasResult = await actividadRepository.getPreguntasByActividad(actividadId);

    actividadResult.fold(
      (failure) {
        _state = ActividadState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (actividad) {
        _actividad = actividad;

        preguntasResult.fold(
          (failure) {
            _state = ActividadState.error;
            _errorMessage = failure.message;
            notifyListeners();
          },
          (preguntas) {
            _preguntas = preguntas;
            _state = ActividadState.loaded;
            notifyListeners();
          },
        );
      },
    );
  }

  void selectRespuesta(String preguntaId, String opcionId) {
    _respuestas[preguntaId] = opcionId;
    notifyListeners();
  }

  Future<void> submitActividad() async {
    if (_actividad == null) return;

    _state = ActividadState.submitting;
    notifyListeners();

    // Obtener el ID del alumno del usuario autenticado
    final alumnoId = authProvider.user?.id;
    if (alumnoId == null) {
      _state = ActividadState.error;
      _errorMessage = 'No se pudo obtener el ID del alumno';
      notifyListeners();
      return;
    }

    final result = await actividadRepository.submitActividad(
      actividadId: _actividad!.id,
      alumnoId: alumnoId,
      respuestas: _respuestas,
    );

    result.fold(
      (failure) {
        _state = ActividadState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (resultado) {
        _resultado = resultado;
        _state = ActividadState.completed;
        notifyListeners();
      },
    );
  }

  void reset() {
    _actividad = null;
    _preguntas = [];
    _respuestas = {};
    _resultado = null;
    _state = ActividadState.initial;
    notifyListeners();
  }
}
