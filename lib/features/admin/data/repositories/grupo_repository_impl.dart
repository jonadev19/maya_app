import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/grupo.dart';
import '../../domain/repositories/grupo_repository.dart';
import '../datasources/admin_remote_datasource.dart';

class GrupoRepositoryImpl implements GrupoRepository {
  final AdminRemoteDataSource remoteDataSource;

  GrupoRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Grupo>>> getGrupos() async {
    try {
      final grupos = await remoteDataSource.getGrupos();
      return Right(grupos.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Grupo>> getGrupoById(String id) async {
    try {
      final grupos = await remoteDataSource.getGrupos();
      final grupo = grupos.firstWhere((g) => g.id == id);
      return Right(grupo.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Grupo>> createGrupo({
    required String nombre,
    required String nivel,
    String? descripcion,
  }) async {
    try {
      final data = {
        'nombre': nombre,
        'nivel': nivel,
        if (descripcion != null) 'descripcion': descripcion,
      };
      final grupo = await remoteDataSource.createGrupo(data);
      return Right(grupo.toEntity());
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Grupo>> updateGrupo({
    required String id,
    String? nombre,
    String? nivel,
    String? descripcion,
    bool? activo,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (nombre != null) data['nombre'] = nombre;
      if (nivel != null) data['nivel'] = nivel;
      if (descripcion != null) data['descripcion'] = descripcion;
      if (activo != null) data['activo'] = activo;

      final grupo = await remoteDataSource.updateGrupo(id, data);
      return Right(grupo.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteGrupo(String id) async {
    try {
      await remoteDataSource.deleteGrupo(id);
      return const Right(null);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }
}
