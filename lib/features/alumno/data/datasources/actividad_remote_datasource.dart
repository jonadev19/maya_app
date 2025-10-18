import '../../../../core/network/dio_client.dart';
import '../../../shared/data/models/actividad_model.dart';
import '../../../shared/data/models/pregunta_model.dart';

abstract class ActividadRemoteDataSource {
  Future<ActividadModel> getActividadById(String id);
  Future<List<PreguntaModel>> getPreguntasByActividad(String actividadId);
  Future<Map<String, dynamic>> submitActividad({
    required String actividadId,
    required Map<String, String> respuestas, // preguntaId -> opcionId
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
    // Usar la ruta correcta del backend
    final response = await dioClient.get('/actividades/$actividadId/preguntas/');
    final List<dynamic> data = response.data;
    return data.map((json) => PreguntaModel.fromJson(json)).toList();
  }

  @override
  Future<Map<String, dynamic>> submitActividad({
    required String actividadId,
    required Map<String, String> respuestas,
  }) async {
    // Crear un intento y luego finalizarlo
    // Primero crear el intento
    final intentoResponse = await dioClient.post(
      '/intentos/crear/',
      data: {
        'actividad_id': actividadId,
      },
    );

    final intentoId = intentoResponse.data['id'] ?? intentoResponse.data['_id'];

    // Enviar respuestas
    await dioClient.post(
      '/intentos/$intentoId/respuestas/',
      data: {
        'respuestas': respuestas.entries
            .map((e) => {'pregunta_id': e.key, 'opcion_id': e.value})
            .toList(),
      },
    );

    // Finalizar el intento
    final response = await dioClient.post('/intentos/$intentoId/finalizar/');
    return response.data;
  }
}
