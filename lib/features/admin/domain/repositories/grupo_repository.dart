import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/grupo.dart';

abstract class GrupoRepository {
  Future<Either<Failure, List<Grupo>>> getGrupos();
  Future<Either<Failure, Grupo>> getGrupoById(String id);
  Future<Either<Failure, Grupo>> createGrupo({
    required String nombre,
    required String nivel,
    String? descripcion,
  });
  Future<Either<Failure, Grupo>> updateGrupo({
    required String id,
    String? nombre,
    String? nivel,
    String? descripcion,
    bool? activo,
  });
  Future<Either<Failure, void>> deleteGrupo(String id);
}
