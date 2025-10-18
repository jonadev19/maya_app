import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, UserEntity>> login(
    String email,
    String password,
  ) async {
    try {
      // Call remote data source to login
      final authResponse = await remoteDataSource.login(email, password);

      // Save tokens to local storage
      await localDataSource.saveTokens(
        authResponse.accessToken,
        authResponse.refreshToken,
      );

      // Save user to local storage
      await localDataSource.saveUser(authResponse.user);

      // Return user entity
      return Right(authResponse.user.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Get refresh token from local storage
      final refreshToken = await localDataSource.getRefreshToken();

      if (refreshToken != null) {
        // Call remote data source to logout
        await remoteDataSource.logout(refreshToken);
      }

      // Clear local storage
      await localDataSource.clearAll();

      return const Right(null);
    } on ServerException catch (e) {
      // Even if server logout fails, clear local storage
      await localDataSource.clearAll();
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      // Even if network fails, clear local storage
      await localDataSource.clearAll();
      return Left(NetworkFailure(e.message));
    } catch (e) {
      // Even if something fails, clear local storage
      await localDataSource.clearAll();
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      // First try to get user from local storage
      final localUser = await localDataSource.getUser();

      if (localUser != null) {
        return Right(localUser.toEntity());
      }

      // If not found locally, get from remote
      final remoteUser = await remoteDataSource.getCurrentUser();

      // Save to local storage
      await localDataSource.saveUser(remoteUser);

      return Right(remoteUser.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on UnauthorizedException catch (e) {
      // Clear local storage if unauthorized
      await localDataSource.clearAll();
      return Left(UnauthorizedFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final accessToken = await localDataSource.getAccessToken();
      final user = await localDataSource.getUser();

      return Right(accessToken != null && user != null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearSession() async {
    try {
      await localDataSource.clearAll();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
