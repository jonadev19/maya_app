import '../../../../core/network/dio_client.dart';
import '../../../shared/data/models/alumno_model.dart';
import '../../../shared/data/models/grupo_model.dart';
import '../../../shared/data/models/calificacion_model.dart';

abstract class AdminRemoteDataSource {
  Future<List<AlumnoModel>> getAlumnos();
  Future<AlumnoModel> getAlumnoById(String id);
  Future<AlumnoModel> createAlumno(Map<String, dynamic> data);
  Future<AlumnoModel> updateAlumno(String id, Map<String, dynamic> data);
  Future<void> deleteAlumno(String id);

  Future<List<GrupoModel>> getGrupos();
  Future<GrupoModel> createGrupo(Map<String, dynamic> data);
  Future<GrupoModel> updateGrupo(String id, Map<String, dynamic> data);
  Future<void> deleteGrupo(String id);

  Future<List<CalificacionModel>> getCalificacionesByAlumno(String alumnoId);
  Future<List<CalificacionModel>> getTodasCalificaciones();
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final DioClient dioClient;

  AdminRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<AlumnoModel>> getAlumnos() async {
    final response = await dioClient.get('/admin/alumnos/');
    final List<dynamic> data = response.data;
    return data.map((json) => AlumnoModel.fromJson(json)).toList();
  }

  @override
  Future<AlumnoModel> getAlumnoById(String id) async {
    final response = await dioClient.get('/admin/alumnos/$id/');
    return AlumnoModel.fromJson(response.data);
  }

  @override
  Future<AlumnoModel> createAlumno(Map<String, dynamic> data) async {
    final response = await dioClient.post('/admin/alumnos/', data: data);
    return AlumnoModel.fromJson(response.data);
  }

  @override
  Future<AlumnoModel> updateAlumno(String id, Map<String, dynamic> data) async {
    final response = await dioClient.put('/admin/alumnos/$id/', data: data);
    return AlumnoModel.fromJson(response.data);
  }

  @override
  Future<void> deleteAlumno(String id) async {
    await dioClient.delete('/admin/alumnos/$id/');
  }

  @override
  Future<List<GrupoModel>> getGrupos() async {
    final response = await dioClient.get('/admin/grupos/');
    final List<dynamic> data = response.data;
    return data.map((json) => GrupoModel.fromJson(json)).toList();
  }

  @override
  Future<GrupoModel> createGrupo(Map<String, dynamic> data) async {
    final response = await dioClient.post('/admin/grupos/', data: data);
    return GrupoModel.fromJson(response.data);
  }

  @override
  Future<GrupoModel> updateGrupo(String id, Map<String, dynamic> data) async {
    final response = await dioClient.put('/admin/grupos/$id/', data: data);
    return GrupoModel.fromJson(response.data);
  }

  @override
  Future<void> deleteGrupo(String id) async {
    await dioClient.delete('/admin/grupos/$id/');
  }

  @override
  Future<List<CalificacionModel>> getCalificacionesByAlumno(String alumnoId) async {
    final response = await dioClient.get('/admin/calificaciones/?alumno_id=$alumnoId');
    final List<dynamic> data = response.data;
    return data.map((json) => CalificacionModel.fromJson(json)).toList();
  }

  @override
  Future<List<CalificacionModel>> getTodasCalificaciones() async {
    final response = await dioClient.get('/admin/calificaciones/');
    final List<dynamic> data = response.data;
    return data.map((json) => CalificacionModel.fromJson(json)).toList();
  }
}
