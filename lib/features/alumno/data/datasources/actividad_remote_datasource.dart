import '../../../../core/network/dio_client.dart';
import '../../../shared/data/models/actividad_model.dart';
import '../../../shared/data/models/pregunta_model.dart';

abstract class ActividadRemoteDataSource {
  Future<ActividadModel> getActividadById(int id);
  Future<List<PreguntaModel>> getPreguntasByActividad(int actividadId);
  Future<Map<String, dynamic>> submitActividad({
    required int actividadId,
    required Map<int, int> respuestas, // preguntaId -> opcionId
  });
}

class ActividadRemoteDataSourceImpl implements ActividadRemoteDataSource {
  final DioClient dioClient;

  ActividadRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<ActividadModel> getActividadById(int id) async {
    final response = await dioClient.get('/actividades/$id/');
    return ActividadModel.fromJson(response.data);
  }

  @override
  Future<List<PreguntaModel>> getPreguntasByActividad(int actividadId) async {
    final response = await dioClient.get('/actividades/$actividadId/preguntas/');
    final List<dynamic> data = response.data;
    return data.map((json) => PreguntaModel.fromJson(json)).toList();
  }

  @override
  Future<Map<String, dynamic>> submitActividad({
    required int actividadId,
    required Map<int, int> respuestas,
  }) async {
    final response = await dioClient.post(
      '/actividades/$actividadId/submit/',
      data: {
        'respuestas': respuestas.entries
            .map((e) => {'pregunta_id': e.key, 'opcion_id': e.value})
            .toList(),
      },
    );
    return response.data;
  }
}
