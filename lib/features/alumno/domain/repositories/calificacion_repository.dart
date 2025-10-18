import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/calificacion.dart';

abstract class CalificacionRepository {
  Future<Either<Failure, List<Calificacion>>> getCalificacionesAlumno();
  Future<Either<Failure, List<Calificacion>>> getCalificacionesByTema(int temaId);
}
