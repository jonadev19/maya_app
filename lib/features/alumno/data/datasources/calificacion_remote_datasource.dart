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
    
    print('Response status: ${response.statusCode}');
    print('Response data: ${response.data}');
    print('Response data type: ${response.data.runtimeType}');
    
    // Verificar si la respuesta tiene la estructura esperada
    dynamic data = response.data;
    
    // Si la respuesta está envuelta en un objeto, extraer la lista
    if (data is Map<String, dynamic>) {
      if (data.containsKey('results')) {
        data = data['results'];
      } else if (data.containsKey('data')) {
        data = data['data'];
      } else if (data.containsKey('calificaciones')) {
        data = data['calificaciones'];
      }
    }
    
    if (data is! List) {
      print('Error: Expected List but got ${data.runtimeType}');
      return [];
    }
    
    final List<dynamic> calificacionesList = data;
    print('Number of calificaciones found: ${calificacionesList.length}');
    
    return calificacionesList.map((json) {
      print('Processing calificacion: $json');
      return CalificacionModel.fromJson(json);
    }).toList();
  }

  @override
  Future<List<CalificacionModel>> getCalificacionesByTema(String temaId) async {
    final response = await dioClient.get('/calificaciones/?tema=$temaId');
    final List<dynamic> data = response.data;
    return data.map((json) => CalificacionModel.fromJson(json)).toList();
  }
}
