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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                          const Icon(Icons.error_outline,
                              size: 60, color: AppColors.errorColor),
                          const SizedBox(height: 16),
                          Text(
                            'Error al cargar alumnos',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
                            onPressed: () {
                              provider.loadAlumnos();
                            },
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
                  alumnos = alumnos
                      .where((a) => a.nivel == _filtroNivel)
                      .toList();
                }

                if (alumnos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.people_outline,
                            size: 80, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty || _filtroNivel != null
                              ? 'No se encontraron alumnos'
                              : 'No hay alumnos registrados',
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Agrega un nuevo alumno con el botón +',
                          textAlign: TextAlign.center,
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
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            backgroundColor: _getNivelColor(alumno.nivel),
                            child: Text(
                              alumno.nombre[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            alumno.nombreCompleto,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(alumno.email),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getNivelColor(alumno.nivel)
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _formatNivel(alumno.nivel),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _getNivelColor(alumno.nivel),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (alumno.grupoNombre != null) ...[
                                    const SizedBox(width: 8),
                                    Chip(
                                      label: Text(
                                        'Grupo ${alumno.grupoNombre}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      padding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                  const Spacer(),
                                  if (!alumno.activo)
                                    const Chip(
                                      label: Text(
                                        'Inactivo',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      backgroundColor: Colors.grey,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      padding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
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
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 20, color: AppColors.errorColor),
                                    SizedBox(width: 8),
                                    Text('Eliminar', style: TextStyle(color: AppColors.errorColor)),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/admin/alumnos/create');
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Nuevo Alumno'),
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
              Navigator.pop(context);
              final provider = context.read<AlumnoProvider>();
              final success = await provider.deleteAlumno(id);

              if (mounted) {
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
              }
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  Color _getNivelColor(String nivel) {
    switch (nivel.toLowerCase()) {
      case 'basico':
        return AppColors.nivelBasicoColor;
      case 'intermedio':
        return AppColors.nivelIntermedioColor;
      case 'avanzado':
        return AppColors.nivelAvanzadoColor;
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
