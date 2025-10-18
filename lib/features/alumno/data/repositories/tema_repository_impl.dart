import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/tema.dart';
import '../../../shared/domain/entities/material.dart';
import '../../../shared/domain/entities/palabra.dart';
import '../../../shared/domain/entities/actividad.dart';
import '../../domain/repositories/tema_repository.dart';
import '../datasources/tema_remote_datasource.dart';

class TemaRepositoryImpl implements TemaRepository {
  final TemaRemoteDataSource remoteDataSource;

  TemaRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Tema>>> getTemas() async {
    try {
      final temas = await remoteDataSource.getTemas();
      return Right(temas.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Tema>> getTemaById(int id) async {
    try {
      final tema = await remoteDataSource.getTemaById(id);
      return Right(tema.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Material>>> getMaterialesByTema(int temaId) async {
    try {
      final materiales = await remoteDataSource.getMaterialesByTema(temaId);
      return Right(materiales.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Palabra>>> getPalabrasByTema(int temaId) async {
    try {
      final palabras = await remoteDataSource.getPalabrasByTema(temaId);
      return Right(palabras.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Actividad>>> getActividadesByTema(int temaId) async {
    try {
      final actividades = await remoteDataSource.getActividadesByTema(temaId);
      return Right(actividades.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
