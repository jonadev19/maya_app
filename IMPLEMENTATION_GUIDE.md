# Maya App - Guía de Implementación

## Estado Actual del Proyecto

### ✅ Fase 1: Setup & Autenticación - COMPLETADA

Se ha implementado exitosamente la arquitectura base y el módulo de autenticación completo.

---

## Estructura del Proyecto

La aplicación sigue **Clean Architecture** con las siguientes capas:

```
lib/
├── core/
│   ├── constants/          # Constantes de la app (API, colores, strings)
│   ├── errors/             # Manejo de errores y excepciones
│   ├── network/            # Cliente HTTP con Dio
│   ├── theme/              # Tema de la aplicación
│   └── utils/              # Utilidades (router, dependency injection)
├── features/
│   ├── auth/               # Módulo de autenticación
│   │   ├── data/
│   │   │   ├── datasources/    # Remote y Local data sources
│   │   │   ├── models/         # Modelos de datos
│   │   │   └── repositories/   # Implementación de repositorios
│   │   ├── domain/
│   │   │   ├── entities/       # Entidades de dominio
│   │   │   ├── repositories/   # Interfaces de repositorios
│   │   │   └── usecases/       # Casos de uso
│   │   └── presentation/
│   │       ├── providers/      # State management con Provider
│   │       ├── screens/        # Pantallas (Login, Splash)
│   │       └── widgets/        # Widgets reutilizables
│   ├── admin/              # Módulo de administrador
│   │   └── presentation/screens/  # AdminHomeScreen
│   ├── alumno/             # Módulo de alumno
│   │   └── presentation/screens/  # AlumnoHomeScreen
│   └── shared/             # Código compartido entre módulos
└── main.dart
```

---

## Funcionalidades Implementadas

### 1. Sistema de Autenticación JWT

**Archivos clave:**
- `lib/core/network/dio_client.dart` - Cliente HTTP con interceptores para JWT
- `lib/features/auth/data/datasources/auth_remote_datasource.dart` - Comunicación con API
- `lib/features/auth/data/datasources/auth_local_datasource.dart` - Almacenamiento local seguro

**Características:**
- Login con email y password
- Almacenamiento seguro de tokens (access y refresh)
- Refresh automático de tokens cuando expiran
- Logout con limpieza de sesión
- Persistencia de sesión (auto-login)

### 2. State Management

**Archivo:** `lib/features/auth/presentation/providers/auth_provider.dart`

**Estados soportados:**
- `initial` - Estado inicial
- `loading` - Cargando
- `authenticated` - Usuario autenticado
- `unauthenticated` - Usuario no autenticado
- `error` - Error en autenticación

### 3. Navegación con Go Router

**Archivo:** `lib/core/utils/app_router.dart`

**Rutas implementadas:**
- `/` - Splash Screen (verificación inicial)
- `/login` - Pantalla de login
- `/admin` - Dashboard de administrador
- `/alumno` - Dashboard de alumno

**Características:**
- Redirección automática basada en estado de autenticación
- Redirección basada en rol de usuario (admin/alumno)
- Guards de autenticación en rutas protegidas

### 4. Pantallas Implementadas

#### Splash Screen
**Archivo:** `lib/features/auth/presentation/screens/splash_screen.dart`

- Pantalla de carga inicial
- Verifica estado de autenticación
- Redirige automáticamente según el resultado

#### Login Screen
**Archivo:** `lib/features/auth/presentation/screens/login_screen.dart`

**Características:**
- Validación de email y password
- Indicador de carga durante login
- Manejo de errores con SnackBars
- Toggle para mostrar/ocultar password
- Información de credenciales de prueba

#### Admin Home Screen
**Archivo:** `lib/features/admin/presentation/screens/admin_home_screen.dart`

**Módulos mostrados:**
- Gestión de Alumnos
- Calificaciones
- Reportes
- Grupos

#### Alumno Home Screen
**Archivo:** `lib/features/alumno/presentation/screens/alumno_home_screen.dart`

**Temas mostrados:**
- Números
- Comidas
- Objetos Cotidianos
- Animales

**Acciones rápidas:**
- Mis Calificaciones
- Mi Perfil

### 5. Tema Personalizado

**Archivo:** `lib/core/theme/app_theme.dart`

**Características:**
- Paleta de colores inspirada en cultura maya
- Tipografía con Google Fonts (Poppins)
- Material Design 3
- Componentes estilizados (Cards, Buttons, Inputs, etc.)

---

## Cómo Ejecutar la Aplicación

### Requisitos

1. Flutter SDK instalado
2. Backend de Django corriendo en `http://localhost:8000`
3. Dispositivo/Emulador Android o iOS

### Pasos

1. **Instalar dependencias:**
   ```bash
   flutter pub get
   ```

2. **Configurar la URL de la API:**

   Edita `lib/core/constants/api_constants.dart`:
   ```dart
   // Para emulador Android
   static const String baseUrl = 'http://10.0.2.2:8000/api';

   // Para dispositivo físico (usa tu IP local)
   static const String baseUrl = 'http://192.168.1.X:8000/api';

   // Para iOS simulator
   static const String baseUrl = 'http://localhost:8000/api';
   ```

3. **Ejecutar la aplicación:**
   ```bash
   flutter run
   ```

### Credenciales de Prueba

**Administrador:**
- Email: `admin@maya.edu`
- Password: `admin123`

**Alumno:**
- Email: `juan.pech@alumno.com`
- Password: `alumno123`

---

## Flujo de Autenticación

1. **App inicia** → `SplashScreen`
2. **SplashScreen** → Llama a `AuthProvider.checkAuthStatus()`
3. **AuthProvider** verifica:
   - ¿Hay tokens guardados localmente?
   - ¿El usuario está guardado localmente?
4. **Si SÍ:**
   - Estado → `authenticated`
   - Redirige a `/admin` o `/alumno` según rol
5. **Si NO:**
   - Estado → `unauthenticated`
   - Redirige a `/login`

### Login

1. Usuario ingresa email y password
2. `AuthProvider.login()` se ejecuta
3. Llama a `LoginUseCase`
4. `AuthRepository` → `AuthRemoteDataSource.login()`
5. API retorna tokens y datos de usuario
6. `AuthLocalDataSource` guarda tokens y usuario
7. Estado → `authenticated`
8. Go Router redirige automáticamente según rol

### Logout

1. Usuario presiona botón de logout
2. `AuthProvider.logout()` se ejecuta
3. `LogoutUseCase` → `AuthRepository`
4. Llama a API para invalidar refresh token
5. `AuthLocalDataSource.clearAll()` limpia almacenamiento local
6. Estado → `unauthenticated`
7. Go Router redirige a `/login`

---

## Manejo de Errores

### Tipos de Excepciones

**Archivo:** `lib/core/errors/exceptions.dart`

- `ServerException` - Errores del servidor (500, 502, etc.)
- `NetworkException` - Problemas de conexión
- `UnauthorizedException` - Token inválido o expirado (401)
- `NotFoundException` - Recurso no encontrado (404)
- `ValidationException` - Datos inválidos (400)
- `CacheException` - Errores de almacenamiento local

### Tipos de Failures

**Archivo:** `lib/core/errors/failures.dart`

Cada excepción se convierte en un `Failure` correspondiente en la capa de dominio.

### Interceptor de Dio

El cliente Dio tiene un interceptor que:
- Agrega automáticamente el token de acceso a los headers
- Detecta errores 401 (Unauthorized)
- Intenta refrescar el token automáticamente
- Re-intenta la petición original con el nuevo token
- Si falla el refresh, limpia la sesión

---

## Dependencias Principales

```yaml
# State Management
provider: ^6.1.1

# API & Network
dio: ^5.4.0
dartz: ^0.10.1  # Para Either (manejo funcional de errores)

# Storage
shared_preferences: ^2.2.2
flutter_secure_storage: ^9.0.0

# Navigation
go_router: ^13.0.0

# UI
google_fonts: ^6.1.0

# Utils
equatable: ^2.0.5
intl: ^0.19.0
```

---

## Próximos Pasos (Fase 2 y 3)

### Fase 2: Módulo Alumno

1. **Implementar servicios de contenido:**
   - `TemasService` - Obtener temas
   - `MaterialesService` - Obtener materiales educativos
   - `VocabularioService` - Obtener palabras del vocabulario
   - `ActividadesService` - Obtener actividades/quizzes

2. **Crear pantallas:**
   - `TemaDetailScreen` - Detalle de un tema con tabs (Materiales, Vocabulario, Actividades)
   - `MaterialScreen` - Mostrar material educativo
   - `VocabularioScreen` - Lista de palabras
   - `ActividadScreen` - Realizar quiz/actividad
   - `CalificacionesScreen` - Ver calificaciones del alumno

3. **Implementar lógica de actividades:**
   - Crear intento de actividad
   - Responder preguntas
   - Finalizar actividad
   - Mostrar resultados

### Fase 3: Módulo Administrador

1. **Gestión de Alumnos (CRUD):**
   - Listar alumnos con filtros
   - Crear nuevo alumno
   - Editar alumno existente
   - Eliminar alumno

2. **Visualización de Calificaciones:**
   - Por alumno individual
   - Por grupo
   - Por tema
   - Estadísticas y gráficas

3. **Generación de Reportes PDF:**
   - Reporte individual de alumno
   - Reporte de grupo completo
   - Descarga y compartir PDF

### Fase 4: Pulido & Testing

1. Agregar audio para pronunciación de palabras
2. Mejorar UI/UX con animaciones
3. Agregar caché offline para materiales
4. Testing (unit, widget, integration)
5. Manejo robusto de errores
6. Documentación completa

---

## Estructura de Código Recomendada para Nuevas Features

### 1. Crear Entidad de Dominio

```dart
// lib/features/shared/domain/entities/tema_entity.dart
class TemaEntity extends Equatable {
  final String id;
  final String nombre;
  final String descripcion;
  // ...
}
```

### 2. Crear Modelo de Datos

```dart
// lib/features/shared/data/models/tema_model.dart
class TemaModel extends TemaEntity {
  factory TemaModel.fromJson(Map<String, dynamic> json) { }
  Map<String, dynamic> toJson() { }
}
```

### 3. Crear Data Source

```dart
// lib/features/shared/data/datasources/temas_remote_datasource.dart
abstract class TemasRemoteDataSource {
  Future<List<TemaModel>> getTemas();
}

class TemasRemoteDataSourceImpl implements TemasRemoteDataSource {
  final DioClient dioClient;
  // Implementación...
}
```

### 4. Crear Repository

```dart
// lib/features/shared/domain/repositories/temas_repository.dart
abstract class TemasRepository {
  Future<Either<Failure, List<TemaEntity>>> getTemas();
}

// lib/features/shared/data/repositories/temas_repository_impl.dart
class TemasRepositoryImpl implements TemasRepository {
  // Implementación...
}
```

### 5. Crear Use Case

```dart
// lib/features/shared/domain/usecases/get_temas_usecase.dart
class GetTemasUseCase {
  final TemasRepository repository;

  Future<Either<Failure, List<TemaEntity>>> call() async {
    return await repository.getTemas();
  }
}
```

### 6. Crear Provider

```dart
// lib/features/shared/presentation/providers/temas_provider.dart
class TemasProvider with ChangeNotifier {
  final GetTemasUseCase getTemasUseCase;

  List<TemaEntity> _temas = [];
  bool _isLoading = false;

  Future<void> loadTemas() async {
    _isLoading = true;
    notifyListeners();

    final result = await getTemasUseCase();

    result.fold(
      (failure) { /* manejar error */ },
      (temas) {
        _temas = temas;
        _isLoading = false;
        notifyListeners();
      },
    );
  }
}
```

### 7. Registrar en Dependency Injection

```dart
// lib/core/utils/dependency_injection.dart
static late TemasRepository temasRepository;
static late GetTemasUseCase getTemasUseCase;
static late TemasProvider temasProvider;

// En init():
temasRepository = TemasRepositoryImpl(...);
getTemasUseCase = GetTemasUseCase(repository: temasRepository);
temasProvider = TemasProvider(getTemasUseCase: getTemasUseCase);
```

### 8. Usar en Screen

```dart
// En main.dart, agregar provider:
ChangeNotifierProvider.value(
  value: DependencyInjection.temasProvider,
),

// En la pantalla:
final temasProvider = context.watch<TemasProvider>();
```

---

## Convenciones de Código

### Naming

- **Archivos:** `snake_case.dart`
- **Clases:** `PascalCase`
- **Variables/Funciones:** `camelCase`
- **Constantes:** `camelCase` o `SCREAMING_SNAKE_CASE`
- **Widgets privados:** Prefix con `_`

### Organización

- Un archivo por clase (excepto widgets pequeños relacionados)
- Imports agrupados: Flutter → Packages → Proyecto
- Ordenar métodos: Lifecycle → Public → Private → Build

### Comentarios

- Comentar lógica compleja
- Documentar funciones públicas importantes
- No comentar código obvio

---

## Notas Importantes

1. **API Backend:** Asegúrate de que el backend Django esté corriendo antes de iniciar la app.

2. **Configuración de Red:**
   - Android Emulator: `10.0.2.2:8000`
   - iOS Simulator: `localhost:8000`
   - Dispositivo físico: Usar IP de tu máquina en la red local

3. **Tokens JWT:**
   - Los tokens se almacenan de forma segura con `flutter_secure_storage`
   - El refresh automático está implementado en `DioClient`
   - Los tokens se limpian automáticamente en logout o error 401

4. **Testing:**
   - Usa las credenciales de prueba proporcionadas
   - Puedes crear más usuarios desde el admin de Django

5. **Hot Reload:**
   - Funciona perfectamente para cambios de UI
   - Si cambias providers o dependency injection, reinicia la app

---

## Contacto y Soporte

Para preguntas o problemas durante el desarrollo, consulta:
- `API_ENDPOINTS.md` - Documentación completa de la API
- Este documento - Guía de implementación
- Código fuente - Comentarios inline en archivos clave

---

**Última actualización:** 2025-10-17
**Versión:** 1.0.0
**Estado:** Fase 1 Completada ✅
