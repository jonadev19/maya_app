import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../shared/domain/entities/alumno.dart';
import '../../domain/repositories/alumno_repository.dart';
import '../datasources/admin_remote_datasource.dart';

class AlumnoRepositoryImpl implements AlumnoRepository {
  final AdminRemoteDataSource remoteDataSource;

  AlumnoRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Alumno>>> getAlumnos() async {
    try {
      final alumnos = await remoteDataSource.getAlumnos();
      return Right(alumnos.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Alumno>> getAlumnoById(String id) async {
    try {
      final alumno = await remoteDataSource.getAlumnoById(id);
      return Right(alumno.toEntity());
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
  Future<Either<Failure, Alumno>> createAlumno({
    required String nombre,
    required String apellido,
    required String email,
    required String password,
    String? grupoId,
    required String nivel,
  }) async {
    try {
      final data = {
        'nombre': nombre,
        'apellido': apellido,
        'email': email,
        'password': password,
        if (grupoId != null) 'grupo_id': grupoId,
        'nivel': _formatNivelForBackend(nivel),
      };
      final alumno = await remoteDataSource.createAlumno(data);
      return Right(alumno.toEntity());
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

  String _formatNivelForBackend(String nivel) {
    // Convertir de formato UI a formato backend
    // Backend valida: "Básico", "Intermedio", "Avanzado"
    switch (nivel.toLowerCase().trim()) {
      case 'basico':
      case 'básico':
        return 'Básico'; // Primera letra mayúscula, CON acento
      case 'intermedio':
        return 'Intermedio'; // Primera letra mayúscula
      case 'avanzado':
        return 'Avanzado'; // Primera letra mayúscula
      default:
        return 'Básico';
    }
  }

  @override
  Future<Either<Failure, Alumno>> updateAlumno({
    required String id,
    String? nombre,
    String? apellido,
    String? email,
    String? password,
    String? grupoId,
    String? nivel,
    bool? activo,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (nombre != null) data['nombre'] = nombre;
      if (apellido != null) data['apellido'] = apellido;
      if (email != null) data['email'] = email;
      if (password != null) data['password'] = password;
      if (grupoId != null) data['grupo_id'] = grupoId;
      if (nivel != null) data['nivel'] = _formatNivelForBackend(nivel);
      if (activo != null) data['activo'] = activo;

      final alumno = await remoteDataSource.updateAlumno(id, data);
      return Right(alumno.toEntity());
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
  Future<Either<Failure, void>> deleteAlumno(String id) async {
    try {
      await remoteDataSource.deleteAlumno(id);
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
