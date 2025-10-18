import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/actividad.dart';
import '../../../shared/domain/entities/pregunta.dart';

abstract class ActividadRepository {
  Future<Either<Failure, Actividad>> getActividadById(String id);
  Future<Either<Failure, List<Pregunta>>> getPreguntasByActividad(String actividadId);
  Future<Either<Failure, Map<String, dynamic>>> submitActividad({
    required String actividadId,
    required Map<String, String> respuestas,
  });
}
