import '../../../../core/network/dio_client.dart';
import '../../../shared/data/models/tema_model.dart';
import '../../../shared/data/models/material_model.dart';
import '../../../shared/data/models/palabra_model.dart';
import '../../../shared/data/models/actividad_model.dart';

abstract class TemaRemoteDataSource {
  Future<List<TemaModel>> getTemas();
  Future<TemaModel> getTemaById(String id);
  Future<List<MaterialModel>> getMaterialesByTema(String temaId);
  Future<List<PalabraModel>> getPalabrasByTema(String temaId);
  Future<List<ActividadModel>> getActividadesByTema(String temaId);
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
  Future<TemaModel> getTemaById(String id) async {
    final response = await dioClient.get('/temas/$id/');
    return TemaModel.fromJson(response.data);
  }

  @override
  Future<List<MaterialModel>> getMaterialesByTema(String temaId) async {
    final response = await dioClient.get('/materiales/?tema_id=$temaId');
    final List<dynamic> data = response.data;
    return data.map((json) => MaterialModel.fromJson(json)).toList();
  }

  @override
  Future<List<PalabraModel>> getPalabrasByTema(String temaId) async {
    final response = await dioClient.get('/vocabulario/?tema_id=$temaId');
    final List<dynamic> data = response.data;
    return data.map((json) => PalabraModel.fromJson(json)).toList();
  }

  @override
  Future<List<ActividadModel>> getActividadesByTema(String temaId) async {
    final response = await dioClient.get('/actividades/?tema_id=$temaId');
    final List<dynamic> data = response.data;
    return data.map((json) => ActividadModel.fromJson(json)).toList();
  }
}
