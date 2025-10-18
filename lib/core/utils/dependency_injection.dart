import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/check_auth_status_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/alumno/data/datasources/tema_remote_datasource.dart';
import '../../features/alumno/data/datasources/actividad_remote_datasource.dart';
import '../../features/alumno/data/datasources/calificacion_remote_datasource.dart';
import '../../features/alumno/data/repositories/tema_repository_impl.dart';
import '../../features/alumno/data/repositories/actividad_repository_impl.dart';
import '../../features/alumno/data/repositories/calificacion_repository_impl.dart';
import '../../features/alumno/domain/repositories/tema_repository.dart';
import '../../features/alumno/domain/repositories/actividad_repository.dart';
import '../../features/alumno/domain/repositories/calificacion_repository.dart';
import '../../features/alumno/presentation/providers/tema_provider.dart';
import '../../features/alumno/presentation/providers/actividad_provider.dart';
import '../../features/alumno/presentation/providers/calificacion_provider.dart';
import '../network/dio_client.dart';

class DependencyInjection {
  // Core
  static late DioClient dioClient;
  static late FlutterSecureStorage secureStorage;
  static late SharedPreferences sharedPreferences;

  // Auth Data Sources
  static late AuthRemoteDataSource authRemoteDataSource;
  static late AuthLocalDataSource authLocalDataSource;

  // Auth Repository
  static late AuthRepository authRepository;

  // Auth Use Cases
  static late LoginUseCase loginUseCase;
  static late LogoutUseCase logoutUseCase;
  static late GetCurrentUserUseCase getCurrentUserUseCase;
  static late CheckAuthStatusUseCase checkAuthStatusUseCase;

  // Providers
  static late AuthProvider authProvider;

  // Alumno Data Sources
  static late TemaRemoteDataSource temaRemoteDataSource;
  static late ActividadRemoteDataSource actividadRemoteDataSource;
  static late CalificacionRemoteDataSource calificacionRemoteDataSource;

  // Alumno Repositories
  static late TemaRepository temaRepository;
  static late ActividadRepository actividadRepository;
  static late CalificacionRepository calificacionRepository;

  // Alumno Providers
  static late TemaProvider temaProvider;
  static late ActividadProvider actividadProvider;
  static late CalificacionProvider calificacionProvider;

  static Future<void> init() async {
    // Core
    dioClient = DioClient();
    secureStorage = const FlutterSecureStorage();
    sharedPreferences = await SharedPreferences.getInstance();

    // Auth Data Sources
    authRemoteDataSource = AuthRemoteDataSourceImpl(
      dioClient: dioClient,
    );

    authLocalDataSource = AuthLocalDataSourceImpl(
      secureStorage: secureStorage,
      sharedPreferences: sharedPreferences,
    );

    // Auth Repository
    authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      localDataSource: authLocalDataSource,
    );

    // Auth Use Cases
    loginUseCase = LoginUseCase(repository: authRepository);
    logoutUseCase = LogoutUseCase(repository: authRepository);
    getCurrentUserUseCase = GetCurrentUserUseCase(repository: authRepository);
    checkAuthStatusUseCase = CheckAuthStatusUseCase(repository: authRepository);

    // Providers
    authProvider = AuthProvider(
      loginUseCase: loginUseCase,
      logoutUseCase: logoutUseCase,
      getCurrentUserUseCase: getCurrentUserUseCase,
      checkAuthStatusUseCase: checkAuthStatusUseCase,
    );

    // Alumno Data Sources
    temaRemoteDataSource = TemaRemoteDataSourceImpl(dioClient: dioClient);
    actividadRemoteDataSource = ActividadRemoteDataSourceImpl(dioClient: dioClient);
    calificacionRemoteDataSource = CalificacionRemoteDataSourceImpl(dioClient: dioClient);

    // Alumno Repositories
    temaRepository = TemaRepositoryImpl(remoteDataSource: temaRemoteDataSource);
    actividadRepository = ActividadRepositoryImpl(remoteDataSource: actividadRemoteDataSource);
    calificacionRepository = CalificacionRepositoryImpl(remoteDataSource: calificacionRemoteDataSource);

    // Alumno Providers
    temaProvider = TemaProvider(temaRepository: temaRepository);
    actividadProvider = ActividadProvider(actividadRepository: actividadRepository);
    calificacionProvider = CalificacionProvider(calificacionRepository: calificacionRepository);
  }
}
