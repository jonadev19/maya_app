import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/actividad.dart';
import '../../../shared/domain/entities/pregunta.dart';
import '../../domain/repositories/actividad_repository.dart';
import '../datasources/actividad_remote_datasource.dart';

class ActividadRepositoryImpl implements ActividadRepository {
  final ActividadRemoteDataSource remoteDataSource;

  ActividadRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Actividad>> getActividadById(int id) async {
    try {
      final actividad = await remoteDataSource.getActividadById(id);
      return Right(actividad.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Pregunta>>> getPreguntasByActividad(int actividadId) async {
    try {
      final preguntas = await remoteDataSource.getPreguntasByActividad(actividadId);
      return Right(preguntas.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> submitActividad({
    required int actividadId,
    required Map<int, int> respuestas,
  }) async {
    try {
      final result = await remoteDataSource.submitActividad(
        actividadId: actividadId,
        respuestas: respuestas,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
