import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/actividad.dart';
import '../../../shared/domain/entities/pregunta.dart';

abstract class ActividadRepository {
  Future<Either<Failure, Actividad>> getActividadById(int id);
  Future<Either<Failure, List<Pregunta>>> getPreguntasByActividad(int actividadId);
  Future<Either<Failure, Map<String, dynamic>>> submitActividad({
    required int actividadId,
    required Map<int, int> respuestas,
  });
}
