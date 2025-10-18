import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider with ChangeNotifier {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;

  AuthProvider({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.checkAuthStatusUseCase,
  });

  AuthStatus _status = AuthStatus.initial;
  UserEntity? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserEntity? get user => _user;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAdmin => _user?.isAdministrador ?? false;
  bool get isAlumno => _user?.isAlumno ?? false;

  // Check authentication status on app start
  Future<void> checkAuthStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();

    final result = await checkAuthStatusUseCase();

    result.fold(
      (failure) {
        _status = AuthStatus.unauthenticated;
        _user = null;
        _errorMessage = null;
        notifyListeners();
      },
      (isLoggedIn) async {
        if (isLoggedIn) {
          // Get current user
          await _loadCurrentUser();
        } else {
          _status = AuthStatus.unauthenticated;
          _user = null;
          _errorMessage = null;
          notifyListeners();
        }
      },
    );
  }

  // Load current user
  Future<void> _loadCurrentUser() async {
    final result = await getCurrentUserUseCase();

    result.fold(
      (failure) {
        _status = AuthStatus.unauthenticated;
        _user = null;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (user) {
        _status = AuthStatus.authenticated;
        _user = user;
        _errorMessage = null;
        notifyListeners();
      },
    );
  }

  // Login
  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await loginUseCase(email, password);

    return result.fold(
      (failure) {
        _status = AuthStatus.error;
        _user = null;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (user) {
        _status = AuthStatus.authenticated;
        _user = user;
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }

  // Logout
  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();

    final result = await logoutUseCase();

    result.fold(
      (failure) {
        // Even if logout fails on server, clear local state
        _status = AuthStatus.unauthenticated;
        _user = null;
        _errorMessage = null;
        notifyListeners();
      },
      (_) {
        _status = AuthStatus.unauthenticated;
        _user = null;
        _errorMessage = null;
        notifyListeners();
      },
    );
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }
}
