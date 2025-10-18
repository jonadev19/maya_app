import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/tema.dart';
import '../../../shared/domain/entities/material.dart';
import '../../../shared/domain/entities/palabra.dart';
import '../../../shared/domain/entities/actividad.dart';

abstract class TemaRepository {
  Future<Either<Failure, List<Tema>>> getTemas();
  Future<Either<Failure, Tema>> getTemaById(String id);
  Future<Either<Failure, List<Material>>> getMaterialesByTema(String temaId);
  Future<Either<Failure, List<Palabra>>> getPalabrasByTema(String temaId);
  Future<Either<Failure, List<Actividad>>> getActividadesByTema(String temaId);
}
