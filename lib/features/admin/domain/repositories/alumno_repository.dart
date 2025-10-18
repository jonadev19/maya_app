import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/alumno.dart';

abstract class AlumnoRepository {
  Future<Either<Failure, List<Alumno>>> getAlumnos();
  Future<Either<Failure, Alumno>> getAlumnoById(String id);
  Future<Either<Failure, Alumno>> createAlumno({
    required String nombre,
    required String apellido,
    required String email,
    required String password,
    String? grupoId,
    required String nivel,
  });
  Future<Either<Failure, Alumno>> updateAlumno({
    required String id,
    String? nombre,
    String? apellido,
    String? email,
    String? password,
    String? grupoId,
    String? nivel,
    bool? activo,
  });
  Future<Either<Failure, void>> deleteAlumno(String id);
}
