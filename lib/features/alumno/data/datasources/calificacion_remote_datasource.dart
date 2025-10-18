import '../../../../core/network/dio_client.dart';
import '../../../shared/data/models/calificacion_model.dart';

abstract class CalificacionRemoteDataSource {
  Future<List<CalificacionModel>> getCalificacionesAlumno();
  Future<List<CalificacionModel>> getCalificacionesByTema(String temaId);
}

class CalificacionRemoteDataSourceImpl implements CalificacionRemoteDataSource {
  final DioClient dioClient;

  CalificacionRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<CalificacionModel>> getCalificacionesAlumno() async {
    // Obtener todas las calificaciones del alumno actual
    final response = await dioClient.get('/calificaciones/');
    final List<dynamic> data = response.data;
    return data.map((json) => CalificacionModel.fromJson(json)).toList();
  }

  @override
  Future<List<CalificacionModel>> getCalificacionesByTema(String temaId) async {
    final response = await dioClient.get('/calificaciones/?tema=$temaId');
    final List<dynamic> data = response.data;
    return data.map((json) => CalificacionModel.fromJson(json)).toList();
  }
}
