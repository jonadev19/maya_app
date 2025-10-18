import 'dart:io';

class ApiConstants {
  // Base URL - Cambia dinámicamente según la plataforma
  static String get baseUrl {
    if (Platform.isAndroid) {
      // IP especial para que el emulador de Android acceda al localhost de la máquina host
      return 'http://10.0.2.2:8000/api';
    } else if (Platform.isIOS) {
      // El simulador de iOS puede acceder directamente a localhost
      return 'http://127.0.0.1:8000/api';
    } else {
      // Fallback para otras plataformas (ej. web, desktop)
      return 'http://127.0.0.1:8000/api';
    }
  }

  // Para dispositivos físicos, usa tu IP local (debes configurarla manualmente):
  // static const String _localIp = '192.168.1.X'; // <-- REEMPLAZA ESTA IP
  // static const String baseUrl = 'http://$_localIp:8000/api';

  // Para producción:
  // static const String baseUrl = 'https://api.mayaapp.com/api';

  // Auth Endpoints
  static const String login = '/auth/login/';
  static const String logout = '/auth/logout/';
  static const String refresh = '/auth/refresh/';
  static const String me = '/auth/me/';

  // Grupos Endpoints
  static const String grupos = '/grupos/';

  // Administradores Endpoints
  static const String administradores = '/administradores/';

  // Alumnos Endpoints
  static const String alumnos = '/alumnos/';

  // Usuarios Endpoints
  static const String usuarios = '/usuarios/';

  // Temas Endpoints
  static const String temas = '/temas/';

  // Materiales Endpoints
  static const String materiales = '/materiales/';

  // Vocabulario Endpoints
  static const String vocabulario = '/vocabulario/';

  // Actividades Endpoints
  static const String actividades = '/actividades/';

  // Intentos Endpoints
  static const String intentos = '/intentos/';
  static const String crearIntento = '/intentos/crear/';

  // Calificaciones Endpoints
  static const String calificaciones = '/calificaciones/';
  static const String promedioAlumno = '/calificaciones/promedio';
  static const String promedioGrupo = '/calificaciones/promedio-grupo';
  static const String estadisticas = '/calificaciones/estadisticas';

  // Reportes Endpoints
  static const String reportes = '/reportes/';

  // Headers
  static const String contentType = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';

  // Timeouts
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds
}
