import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../providers/alumno_provider.dart';

class AlumnosListScreen extends StatefulWidget {
  const AlumnosListScreen({super.key});

  @override
  State<AlumnosListScreen> createState() => _AlumnosListScreenState();
}

class _AlumnosListScreenState extends State<AlumnosListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _filtroNivel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlumnoProvider>().loadAlumnos();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Alumnos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Chip de filtro activo
          if (_filtroNivel != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  label: Text('Nivel: $_filtroNivel'),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() {
                      _filtroNivel = null;
                    });
                  },
                ),
              ),
            ),

          // Lista de alumnos
          Expanded(
            child: Consumer<AlumnoProvider>(
              builder: (context, provider, _) {
                if (provider.state == AlumnoState.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.state == AlumnoState.error) {
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 60, color: colorScheme.error),
                          const SizedBox(height: 16),
                          Text(
                            'Error al cargar alumnos',
                            style: textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.errorMessage?.contains('<!DOCTYPE html>') == true
                                ? 'Error de conexión con el servidor'
                                : provider.errorMessage ?? 'Error desconocido',
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => provider.loadAlumnos(),
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Filtrar alumnos
                var alumnos = provider.alumnos;

                if (_searchQuery.isNotEmpty) {
                  alumnos = provider.searchAlumnos(_searchQuery);
                }

                if (_filtroNivel != null) {
                  alumnos = alumnos.where((a) => a.nivel == _filtroNivel).toList();
                }

                if (alumnos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 80, color: colorScheme.onSurfaceVariant),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty || _filtroNivel != null
                              ? 'No se encontraron alumnos'
                              : 'No hay alumnos registrados',
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Agrega un nuevo alumno con el botón +',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadAlumnos(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: alumnos.length,
                    itemBuilder: (context, index) {
                      final alumno = alumnos[index];
                      final nivelColor = _getNivelColor(alumno.nivel);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            backgroundColor: nivelColor,
                            child: Text(
                              alumno.nombre[0].toUpperCase(),
                              style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            alumno.nombreCompleto,
                            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(alumno.email, style: textTheme.bodyMedium),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: nivelColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _formatNivel(alumno.nivel),
                                      style: textTheme.labelSmall?.copyWith(
                                        color: nivelColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (alumno.grupoNombre != null) ...[
                                    const SizedBox(width: 8),
                                    Chip(
                                      label: Text('Grupo ${alumno.grupoNombre}'),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                  const Spacer(),
                                  if (!alumno.activo)
                                    const Chip(
                                      label: Text('Inactivo'),
                                      backgroundColor: Colors.grey,
                                    ),
                                ],
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 8),
                                    Text('Editar'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 20, color: colorScheme.error),
                                    const SizedBox(width: 8),
                                    Text('Eliminar', style: TextStyle(color: colorScheme.error)),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                context.push('/admin/alumnos/edit/${alumno.id}');
                              } else if (value == 'delete') {
                                _showDeleteDialog(alumno.id, alumno.nombreCompleto);
                              }
                            },
                          ),
                          onTap: () {
                            context.push('/admin/alumnos/edit/${alumno.id}');
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/admin/alumnos/create');
        },
        tooltip: 'Nuevo Alumno',
        child: const Icon(Icons.person_add),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar por Nivel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String?>(
              title: const Text('Todos'),
              value: null,
              groupValue: _filtroNivel,
              onChanged: (value) {
                setState(() {
                  _filtroNivel = value;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String?>(
              title: const Text(AppStrings.nivelBasico),
              value: 'basico',
              groupValue: _filtroNivel,
              onChanged: (value) {
                setState(() {
                  _filtroNivel = value;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String?>(
              title: const Text(AppStrings.nivelIntermedio),
              value: 'intermedio',
              groupValue: _filtroNivel,
              onChanged: (value) {
                setState(() {
                  _filtroNivel = value;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String?>(
              title: const Text(AppStrings.nivelAvanzado),
              value: 'avanzado',
              groupValue: _filtroNivel,
              onChanged: (value) {
                setState(() {
                  _filtroNivel = value;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(String id, String nombre) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de eliminar al alumno $nombre?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final provider = context.read<AlumnoProvider>();
              final success = await provider.deleteAlumno(id);
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Alumno eliminado correctamente'
                        : 'Error al eliminar alumno: ${provider.errorMessage}',
                  ),
                  backgroundColor: success ? AppColors.successColor : AppColors.errorColor,
                ),
              );
            },
            child: Text(
              'Eliminar',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Color _getNivelColor(String nivel) {
    switch (nivel.toLowerCase()) {
      case 'basico':
        return AppColors.basicLevelColor;
      case 'intermedio':
        return AppColors.intermediateLevelColor;
      case 'avanzado':
        return AppColors.advancedLevelColor;
      default:
        return Colors.grey;
    }
  }

  String _formatNivel(String nivel) {
    switch (nivel.toLowerCase()) {
      case 'basico':
        return AppStrings.nivelBasico;
      case 'intermedio':
        return AppStrings.nivelIntermedio;
      case 'avanzado':
        return AppStrings.nivelAvanzado;
      default:
        return nivel;
    }
  }
}
