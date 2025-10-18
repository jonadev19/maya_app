import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/calificacion.dart';
import '../../domain/repositories/calificacion_admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

class CalificacionAdminRepositoryImpl implements CalificacionAdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  CalificacionAdminRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Calificacion>>> getTodasCalificaciones() async {
    try {
      final calificaciones = await remoteDataSource.getTodasCalificaciones();
      return Right(calificaciones.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Calificacion>>> getCalificacionesByAlumno(
      String alumnoId) async {
    try {
      final calificaciones =
          await remoteDataSource.getCalificacionesByAlumno(alumnoId);
      return Right(calificaciones.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }
}
