import '../../../../core/network/dio_client.dart';
import '../../../shared/data/models/actividad_model.dart';
import '../../../shared/data/models/pregunta_model.dart';

abstract class ActividadRemoteDataSource {
  Future<ActividadModel> getActividadById(String id);
  Future<List<PreguntaModel>> getPreguntasByActividad(String actividadId);
  Future<Map<String, dynamic>> submitActividad({
    required String actividadId,
    required String alumnoId,
    required Map<String, String> respuestas, // preguntaId -> respuesta
  });
}

class ActividadRemoteDataSourceImpl implements ActividadRemoteDataSource {
  final DioClient dioClient;

  ActividadRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<ActividadModel> getActividadById(String id) async {
    final response = await dioClient.get('/actividades/$id/');
    return ActividadModel.fromJson(response.data);
  }

  @override
  Future<List<PreguntaModel>> getPreguntasByActividad(String actividadId) async {
    // Las preguntas vienen incluidas en la actividad según la documentación
    final response = await dioClient.get('/actividades/$actividadId/');
    final actividad = response.data;
    final List<dynamic> preguntasData = actividad['preguntas'] ?? [];
    return preguntasData.map((json) => PreguntaModel.fromJson(json)).toList();
  }

  @override
  Future<Map<String, dynamic>> submitActividad({
    required String actividadId,
    required String alumnoId,
    required Map<String, String> respuestas,
  }) async {
    // Crear un intento y luego finalizarlo
    // Primero crear el intento
    final intentoResponse = await dioClient.post(
      '/intentos/crear/',
      data: {
        'alumno_id': alumnoId,
        'actividad_id': actividadId,
      },
    );

    final intentoId = intentoResponse.data['id'] ?? intentoResponse.data['_id'];

    // Enviar respuestas una por una
    for (final respuesta in respuestas.entries) {
      await dioClient.post(
        '/intentos/$intentoId/respuestas/',
        data: {
          'pregunta_id': respuesta.key,
          'respuesta_alumno': respuesta.value, // Cambiar de 'opcion_id' a 'respuesta_alumno'
        },
      );
    }

    // Finalizar el intento
    final response = await dioClient.post('/intentos/$intentoId/finalizar/');
    return response.data;
  }
}
