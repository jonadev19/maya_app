import '../../../../core/network/dio_client.dart';
import '../../../shared/data/models/tema_model.dart';
import '../../../shared/data/models/material_model.dart';
import '../../../shared/data/models/palabra_model.dart';
import '../../../shared/data/models/actividad_model.dart';

abstract class TemaRemoteDataSource {
  Future<List<TemaModel>> getTemas();
  Future<TemaModel> getTemaById(int id);
  Future<List<MaterialModel>> getMaterialesByTema(int temaId);
  Future<List<PalabraModel>> getPalabrasByTema(int temaId);
  Future<List<ActividadModel>> getActividadesByTema(int temaId);
}

class TemaRemoteDataSourceImpl implements TemaRemoteDataSource {
  final DioClient dioClient;

  TemaRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<TemaModel>> getTemas() async {
    final response = await dioClient.get('/temas/');
    final List<dynamic> data = response.data;
    return data.map((json) => TemaModel.fromJson(json)).toList();
  }

  @override
  Future<TemaModel> getTemaById(int id) async {
    final response = await dioClient.get('/temas/$id/');
    return TemaModel.fromJson(response.data);
  }

  @override
  Future<List<MaterialModel>> getMaterialesByTema(int temaId) async {
    final response = await dioClient.get('/temas/$temaId/materiales/');
    final List<dynamic> data = response.data;
    return data.map((json) => MaterialModel.fromJson(json)).toList();
  }

  @override
  Future<List<PalabraModel>> getPalabrasByTema(int temaId) async {
    final response = await dioClient.get('/temas/$temaId/palabras/');
    final List<dynamic> data = response.data;
    return data.map((json) => PalabraModel.fromJson(json)).toList();
  }

  @override
  Future<List<ActividadModel>> getActividadesByTema(int temaId) async {
    final response = await dioClient.get('/temas/$temaId/actividades/');
    final List<dynamic> data = response.data;
    return data.map((json) => ActividadModel.fromJson(json)).toList();
  }
}
