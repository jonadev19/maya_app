import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../providers/alumno_provider.dart';
import '../../providers/grupo_provider.dart';

class AlumnoFormScreen extends StatefulWidget {
  final String? alumnoId;

  const AlumnoFormScreen({super.key, this.alumnoId});

  @override
  State<AlumnoFormScreen> createState() => _AlumnoFormScreenState();
}

class _AlumnoFormScreenState extends State<AlumnoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _nivel = 'basico';
  String? _grupoId;
  bool _activo = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  bool get _isEditMode => widget.alumnoId != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Cargar grupos disponibles
      context.read<GrupoProvider>().loadGrupos();

      // Si es modo edición, cargar datos del alumno
      if (_isEditMode) {
        _loadAlumnoData();
      }
    });
  }

  Future<void> _loadAlumnoData() async {
    setState(() {
      _isLoading = true;
    });

    final provider = context.read<AlumnoProvider>();
    await provider.loadAlumnoById(widget.alumnoId!);

    if (provider.currentAlumno != null) {
      final alumno = provider.currentAlumno!;
      _nombreController.text = alumno.nombre;
      _apellidoController.text = alumno.apellido;
      _emailController.text = alumno.email;
      _nivel = _normalizeNivel(alumno.nivel);
      _grupoId = alumno.grupoId;
      _activo = alumno.activo;
    }

    setState(() {
      _isLoading = false;
    });
  }

  String _normalizeNivel(String nivel) {
    final normalized = nivel.toLowerCase().trim();
    // Mapeo de variaciones comunes
    if (normalized.contains('bas') || normalized.contains('bás')) {
      return 'basico';
    } else if (normalized.contains('inter')) {
      return 'intermedio';
    } else if (normalized.contains('avan')) {
      return 'avanzado';
    }
    return 'basico'; // Por defecto
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editar Alumno' : 'Nuevo Alumno'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Información del formulario
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Datos Personales',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Nombre
                            TextFormField(
                              controller: _nombreController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre *',
                                prefixIcon: Icon(Icons.person),
                              ),
                              textCapitalization: TextCapitalization.words,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'El nombre es requerido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Apellido
                            TextFormField(
                              controller: _apellidoController,
                              decoration: const InputDecoration(
                                labelText: 'Apellido *',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              textCapitalization: TextCapitalization.words,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'El apellido es requerido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Email
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email *',
                                prefixIcon: Icon(Icons.email),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'El email es requerido';
                                }
                                if (!value.contains('@')) {
                                  return 'Ingresa un email válido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password (solo en modo creación o si se quiere cambiar)
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: _isEditMode
                                    ? 'Nueva Contraseña (opcional)'
                                    : 'Contraseña *',
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              obscureText: _obscurePassword,
                              validator: (value) {
                                if (!_isEditMode &&
                                    (value == null || value.isEmpty)) {
                                  return 'La contraseña es requerida';
                                }
                                if (value != null &&
                                    value.isNotEmpty &&
                                    value.length < 6) {
                                  return 'La contraseña debe tener al menos 6 caracteres';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Datos académicos
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Datos Académicos',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Nivel
                            DropdownButtonFormField<String>(
                              value: _nivel,
                              decoration: const InputDecoration(
                                labelText: 'Nivel *',
                                prefixIcon: Icon(Icons.school),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'basico',
                                  child: Text(AppStrings.basico),
                                ),
                                DropdownMenuItem(
                                  value: 'intermedio',
                                  child: Text(AppStrings.intermedio),
                                ),
                                DropdownMenuItem(
                                  value: 'avanzado',
                                  child: Text(AppStrings.avanzado),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _nivel = value;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16),

                            // Grupo
                            Consumer<GrupoProvider>(
                              builder: (context, grupoProvider, _) {
                                final grupos = grupoProvider.grupos;

                                return DropdownButtonFormField<String>(
                                  value: _grupoId,
                                  decoration: const InputDecoration(
                                    labelText: 'Grupo (opcional)',
                                    prefixIcon: Icon(Icons.group),
                                  ),
                                  items: [
                                    const DropdownMenuItem(
                                      value: null,
                                      child: Text('Sin grupo'),
                                    ),
                                    ...grupos.map((grupo) {
                                      return DropdownMenuItem(
                                        value: grupo.id,
                                        child: Text(
                                          '${grupo.nombre} - ${_formatNivel(grupo.nivel)}',
                                        ),
                                      );
                                    }),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _grupoId = value;
                                    });
                                  },
                                );
                              },
                            ),

                            // Estado activo (solo en modo edición)
                            if (_isEditMode) ...[
                              const SizedBox(height: 16),
                              SwitchListTile(
                                title: const Text('Alumno Activo'),
                                subtitle: Text(
                                  _activo
                                      ? 'El alumno puede acceder al sistema'
                                      : 'El alumno no puede acceder al sistema',
                                ),
                                value: _activo,
                                onChanged: (value) {
                                  setState(() {
                                    _activo = value;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botones
                    Consumer<AlumnoProvider>(
                      builder: (context, provider, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                              onPressed:
                                  provider.isSubmitting ? null : _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                              ),
                              child: provider.isSubmitting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      _isEditMode
                                          ? 'Actualizar Alumno'
                                          : 'Crear Alumno',
                                    ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed:
                                  provider.isSubmitting ? null : () => context.pop(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                              ),
                              child: const Text('Cancelar'),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<AlumnoProvider>();
    bool success;

    if (_isEditMode) {
      // Actualizar alumno
      success = await provider.updateAlumno(
        id: widget.alumnoId!,
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.isNotEmpty
            ? _passwordController.text
            : null,
        grupoId: _grupoId,
        nivel: _nivel,
        activo: _activo,
      );
    } else {
      // Crear alumno
      success = await provider.createAlumno(
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        grupoId: _grupoId,
        nivel: _nivel,
      );
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode
                ? 'Alumno actualizado correctamente'
                : 'Alumno creado correctamente',
          ),
          backgroundColor: AppColors.successColor,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${provider.errorMessage ?? 'Error desconocido'}',
          ),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  String _formatNivel(String nivel) {
    switch (nivel.toLowerCase()) {
      case 'basico':
        return AppStrings.basico;
      case 'intermedio':
        return AppStrings.intermedio;
      case 'avanzado':
        return AppStrings.avanzado;
      default:
        return nivel;
    }
  }
}
