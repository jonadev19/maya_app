import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../providers/grupo_provider.dart';
import '../../providers/alumno_provider.dart';
import '../../../../shared/domain/entities/alumno.dart';
import '../../../../shared/domain/entities/grupo.dart';

class GrupoAlumnosScreen extends StatefulWidget {
  final String grupoId;

  const GrupoAlumnosScreen({super.key, required this.grupoId});

  @override
  State<GrupoAlumnosScreen> createState() => _GrupoAlumnosScreenState();
}

class _GrupoAlumnosScreenState extends State<GrupoAlumnosScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showOnlyActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final grupoProvider = context.read<GrupoProvider>();
    final alumnoProvider = context.read<AlumnoProvider>();
    
    // Cargar grupo y alumnos
    await grupoProvider.loadGrupoById(widget.grupoId);
    await alumnoProvider.loadAlumnos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<GrupoProvider>(
          builder: (context, provider, _) {
            final grupo = provider.currentGrupo;
            return Text(grupo != null ? 'Alumnos - ${grupo.nombre}' : 'Alumnos del Grupo');
          },
        ),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: Consumer2<GrupoProvider, AlumnoProvider>(
        builder: (context, grupoProvider, alumnoProvider, _) {
          if (grupoProvider.state == GrupoState.loading || 
              alumnoProvider.state == AlumnoState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (grupoProvider.state == GrupoState.error) {
            return _buildErrorState('Error al cargar el grupo: ${grupoProvider.errorMessage}');
          }

          if (alumnoProvider.state == AlumnoState.error) {
            return _buildErrorState('Error al cargar alumnos: ${alumnoProvider.errorMessage}');
          }

          final grupo = grupoProvider.currentGrupo;
          if (grupo == null) {
            return _buildErrorState('Grupo no encontrado');
          }

          final alumnos = _getFilteredAlumnos(alumnoProvider.alumnos, grupo);

          return Column(
            children: [
              _buildHeader(grupo, alumnos),
              _buildSearchAndFilters(),
              Expanded(
                child: alumnos.isEmpty
                    ? _buildEmptyState(grupo)
                    : _buildAlumnosList(alumnos),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: AppColors.errorColor),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: AppColors.errorColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Grupo grupo, List<Alumno> alumnos) {
    final alumnosActivos = alumnos.where((a) => a.activo).length;
    final alumnosInactivos = alumnos.where((a) => !a.activo).length;

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

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: nivelColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(nivelIcon, color: AppColors.textOnPrimary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      grupo.nombre,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Nivel ${grupo.nivel.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatChip('Total', alumnos.length.toString(), Icons.people),
              const SizedBox(width: 12),
              _buildStatChip('Activos', alumnosActivos.toString(), Icons.check_circle),
              const SizedBox(width: 12),
              _buildStatChip('Inactivos', alumnosInactivos.toString(), Icons.cancel),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.textOnPrimary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textOnPrimary, size: 16),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textOnPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textOnPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
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
              hintText: 'Buscar alumnos...',
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
              fillColor: AppColors.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Filter toggle
          Row(
            children: [
              const Text(
                'Filtros:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondaryColor,
                ),
              ),
              const SizedBox(width: 16),
              FilterChip(
                label: const Text('Solo activos'),
                selected: _showOnlyActive,
                onSelected: (selected) {
                  setState(() {
                    _showOnlyActive = selected;
                  });
                },
                selectedColor: AppColors.primaryColor.withOpacity(0.2),
                checkmarkColor: AppColors.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Grupo grupo) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: AppColors.textSecondaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || !_showOnlyActive
                ? 'No se encontraron alumnos'
                : 'No hay alumnos en este grupo',
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || !_showOnlyActive
                ? 'Intenta con otros filtros'
                : 'Los alumnos se asignan desde la gestión de alumnos',
            style: const TextStyle(
              color: AppColors.textTertiaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isEmpty && _showOnlyActive) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.push('/admin/alumnos');
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Ir a Gestión de Alumnos'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAlumnosList(List<Alumno> alumnos) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: alumnos.length,
      itemBuilder: (context, index) {
        final alumno = alumnos[index];
        return _buildAlumnoCard(alumno);
      },
    );
  }

  Widget _buildAlumnoCard(Alumno alumno) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          context.push('/admin/alumnos/edit/${alumno.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primaryColor,
                child: Text(
                  '${alumno.nombre.isNotEmpty ? alumno.nombre[0] : ''}${alumno.apellido.isNotEmpty ? alumno.apellido[0] : ''}',
                  style: const TextStyle(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${alumno.nombre} ${alumno.apellido}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alumno.email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildInfoChip(
                          'Nivel ${alumno.nivel.toUpperCase()}',
                          _getNivelColor(alumno.nivel),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusChip(alumno.activo),
                      ],
                    ),
                  ],
                ),
              ),
              // Flecha
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool activo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: activo 
            ? AppColors.successColor.withOpacity(0.1)
            : AppColors.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            activo ? Icons.check_circle : Icons.cancel,
            size: 10,
            color: activo ? AppColors.successColor : AppColors.errorColor,
          ),
          const SizedBox(width: 4),
          Text(
            activo ? 'Activo' : 'Inactivo',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: activo ? AppColors.successColor : AppColors.errorColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getNivelColor(String nivel) {
    switch (nivel) {
      case 'basico':
        return AppColors.basicLevelColor;
      case 'intermedio':
        return AppColors.intermediateLevelColor;
      case 'avanzado':
        return AppColors.advancedLevelColor;
      default:
        return AppColors.textSecondaryColor;
    }
  }

  List<Alumno> _getFilteredAlumnos(List<Alumno> alumnos, Grupo grupo) {
    var filtered = alumnos.where((alumno) => alumno.grupoId == grupo.id).toList();

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((alumno) {
        final fullName = '${alumno.nombre} ${alumno.apellido}'.toLowerCase();
        final email = alumno.email.toLowerCase();
        final query = _searchQuery.toLowerCase();
        
        return fullName.contains(query) || email.contains(query);
      }).toList();
    }

    // Filter by active status
    if (_showOnlyActive) {
      filtered = filtered.where((alumno) => alumno.activo).toList();
    }

    // Sort by name
    filtered.sort((a, b) {
      final nameA = '${a.nombre} ${a.apellido}';
      final nameB = '${b.nombre} ${b.apellido}';
      return nameA.compareTo(nameB);
    });

    return filtered;
  }
}