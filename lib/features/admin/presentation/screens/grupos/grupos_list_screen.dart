import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../providers/grupo_provider.dart';
import '../../../../shared/domain/entities/grupo.dart';

class GruposListScreen extends StatefulWidget {
  const GruposListScreen({super.key});

  @override
  State<GruposListScreen> createState() => _GruposListScreenState();
}

class _GruposListScreenState extends State<GruposListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedNivel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GrupoProvider>().loadGrupos();
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
        title: const Text('Gestión de Grupos'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/admin/grupos/nuevo');
            },
          ),
        ],
      ),
      body: Consumer<GrupoProvider>(
        builder: (context, provider, _) {
          if (provider.state == GrupoState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.state == GrupoState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: AppColors.errorColor),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage ?? 'Error desconocido',
                    style: const TextStyle(color: AppColors.errorColor),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadGrupos(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final grupos = _getFilteredGrupos(provider.grupos);

          return Column(
            children: [
              _buildSearchAndFilter(),
              _buildStatsCards(provider.grupos),
              Expanded(
                child: grupos.isEmpty
                    ? _buildEmptyState()
                    : _buildGruposList(grupos, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Buscar grupos...',
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
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Todos', null),
                const SizedBox(width: 8),
                _buildFilterChip('Básico', 'basico'),
                const SizedBox(width: 8),
                _buildFilterChip('Intermedio', 'intermedio'),
                const SizedBox(width: 8),
                _buildFilterChip('Avanzado', 'avanzado'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? nivel) {
    final isSelected = _selectedNivel == nivel;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.textOnPrimary : AppColors.primaryColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedNivel = selected ? nivel : null;
        });
      },
      selectedColor: AppColors.secondaryColor,
      backgroundColor: Colors.white,
      checkmarkColor: AppColors.textOnPrimary,
    );
  }

  Widget _buildStatsCards(List<Grupo> grupos) {
    final totalGrupos = grupos.length;
    final gruposActivos = grupos.where((g) => g.activo).length;
    final totalAlumnos = grupos.fold(0, (sum, g) => sum + g.cantidadAlumnos);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStatCard('Total Grupos', totalGrupos.toString(), Icons.group),
          const SizedBox(width: 12),
          _buildStatCard('Activos', gruposActivos.toString(), Icons.check_circle),
          const SizedBox(width: 12),
          _buildStatCard('Alumnos', totalAlumnos.toString(), Icons.people),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLightColor,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryColor, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryColor,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_outlined,
            size: 80,
            color: AppColors.textSecondaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedNivel != null
                ? 'No se encontraron grupos'
                : 'No hay grupos registrados',
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedNivel != null
                ? 'Intenta con otros filtros'
                : 'Crea el primer grupo para comenzar',
            style: const TextStyle(
              color: AppColors.textTertiaryColor,
            ),
          ),
          if (_searchQuery.isEmpty && _selectedNivel == null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.push('/admin/grupos/nuevo');
              },
              icon: const Icon(Icons.add),
              label: const Text('Crear Grupo'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGruposList(List<Grupo> grupos, GrupoProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: grupos.length,
      itemBuilder: (context, index) {
        final grupo = grupos[index];
        return _buildGrupoCard(grupo, provider);
      },
    );
  }

  Widget _buildGrupoCard(Grupo grupo, GrupoProvider provider) {
    Color nivelColor;
    IconData nivelIcon;
    
    switch (grupo.nivel) {
      case 'basico':
        nivelColor = AppColors.basicLevelColor;
        nivelIcon = Icons.looks_one;
        break;
      case 'intermedio':
        nivelColor = AppColors.intermediateLevelColor;
        nivelIcon = Icons.looks_two;
        break;
      case 'avanzado':
        nivelColor = AppColors.advancedLevelColor;
        nivelIcon = Icons.looks_3;
        break;
      default:
        nivelColor = AppColors.textSecondaryColor;
        nivelIcon = Icons.help_outline;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          context.push('/admin/grupos/${grupo.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: nivelColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(nivelIcon, color: nivelColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          grupo.nombre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: nivelColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                grupo.nivel.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (!grupo.activo)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.errorColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'INACTIVO',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          context.push('/admin/grupos/${grupo.id}/editar');
                          break;
                        case 'delete':
                          _showDeleteDialog(grupo, provider);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: AppColors.errorColor),
                            SizedBox(width: 8),
                            Text('Eliminar', style: TextStyle(color: AppColors.errorColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (grupo.descripcion != null && grupo.descripcion!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  grupo.descripcion!,
                  style: const TextStyle(
                    color: AppColors.textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 16,
                    color: AppColors.textSecondaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${grupo.cantidadAlumnos} alumno${grupo.cantidadAlumnos != 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: AppColors.textSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: grupo.activo 
                          ? AppColors.successColor.withOpacity(0.1)
                          : AppColors.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          grupo.activo ? Icons.check_circle : Icons.cancel,
                          size: 12,
                          color: grupo.activo 
                              ? AppColors.successColor 
                              : AppColors.errorColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          grupo.activo ? 'Activo' : 'Inactivo',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: grupo.activo 
                                ? AppColors.successColor 
                                : AppColors.errorColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(Grupo grupo, GrupoProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar el grupo "${grupo.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              final success = await provider.deleteGrupo(grupo.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success 
                          ? 'Grupo eliminado exitosamente'
                          : provider.errorMessage ?? 'Error al eliminar el grupo',
                    ),
                    backgroundColor: success 
                        ? AppColors.successColor 
                        : AppColors.errorColor,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorColor,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  List<Grupo> _getFilteredGrupos(List<Grupo> grupos) {
    var filtered = grupos;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((grupo) {
        return grupo.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (grupo.descripcion?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    // Filter by nivel
    if (_selectedNivel != null) {
      filtered = filtered.where((grupo) => grupo.nivel == _selectedNivel).toList();
    }

    return filtered;
  }
}