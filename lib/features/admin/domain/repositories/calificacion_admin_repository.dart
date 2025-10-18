import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/calificacion.dart';

abstract class CalificacionAdminRepository {
  Future<Either<Failure, List<Calificacion>>> getTodasCalificaciones();
  Future<Either<Failure, List<Calificacion>>> getCalificacionesByAlumno(String alumnoId);
}
