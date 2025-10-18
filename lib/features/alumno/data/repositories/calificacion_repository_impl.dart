import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/calificacion.dart';
import '../../domain/repositories/calificacion_repository.dart';
import '../datasources/calificacion_remote_datasource.dart';

class CalificacionRepositoryImpl implements CalificacionRepository {
  final CalificacionRemoteDataSource remoteDataSource;

  CalificacionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Calificacion>>> getCalificacionesAlumno() async {
    try {
      final calificaciones = await remoteDataSource.getCalificacionesAlumno();
      return Right(calificaciones.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Calificacion>>> getCalificacionesByTema(String temaId) async {
    try {
      final calificaciones = await remoteDataSource.getCalificacionesByTema(temaId);
      return Right(calificaciones.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
