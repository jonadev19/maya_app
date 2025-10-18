import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../providers/grupo_provider.dart';
import '../../../../shared/domain/entities/grupo.dart';

class GrupoDetailScreen extends StatefulWidget {
  final String grupoId;

  const GrupoDetailScreen({super.key, required this.grupoId});

  @override
  State<GrupoDetailScreen> createState() => _GrupoDetailScreenState();
}

class _GrupoDetailScreenState extends State<GrupoDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GrupoProvider>().loadGrupoById(widget.grupoId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Grupo'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  context.push('/admin/grupos/${widget.grupoId}/editar');
                  break;
                case 'delete':
                  _showDeleteDialog();
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
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.loadGrupoById(widget.grupoId);
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final grupo = provider.currentGrupo;
          if (grupo == null) {
            return const Center(
              child: Text('Grupo no encontrado'),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(grupo),
                _buildContent(grupo),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(Grupo grupo) {
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: nivelColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              nivelIcon,
              size: 48,
              color: AppColors.textOnPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            grupo.nombre,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textOnPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: nivelColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  grupo.nivel.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: grupo.activo 
                      ? AppColors.successColor 
                      : AppColors.errorColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  grupo.activo ? 'ACTIVO' : 'INACTIVO',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Grupo grupo) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsSection(grupo),
          const SizedBox(height: 24),
          _buildInfoSection(grupo),
          const SizedBox(height: 24),
          _buildActionsSection(grupo),
        ],
      ),
    );
  }

  Widget _buildStatsSection(Grupo grupo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estadísticas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard(
              'Alumnos',
              grupo.cantidadAlumnos.toString(),
              Icons.people,
              AppColors.primaryColor,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              'Estado',
              grupo.activo ? 'Activo' : 'Inactivo',
              grupo.activo ? Icons.check_circle : Icons.cancel,
              grupo.activo ? AppColors.successColor : AppColors.errorColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
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

  Widget _buildInfoSection(Grupo grupo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoCard(grupo),
      ],
    );
  }

  Widget _buildInfoCard(Grupo grupo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('ID', grupo.id),
          const SizedBox(height: 12),
          _buildInfoRow('Nombre', grupo.nombre),
          const SizedBox(height: 12),
          _buildInfoRow('Nivel', _getNivelDisplayName(grupo.nivel)),
          const SizedBox(height: 12),
          _buildInfoRow('Cantidad de Alumnos', grupo.cantidadAlumnos.toString()),
          if (grupo.descripcion != null && grupo.descripcion!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow('Descripción', grupo.descripcion!),
          ],
          const SizedBox(height: 12),
          _buildInfoRow(
            'Estado', 
            grupo.activo ? 'Activo' : 'Inactivo',
            textColor: grupo.activo ? AppColors.successColor : AppColors.errorColor,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? textColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: textColor ?? AppColors.textPrimaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActionsSection(Grupo grupo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push('/admin/grupos/${grupo.id}/editar');
                },
                icon: const Icon(Icons.edit),
                label: const Text('Editar Grupo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.push('/admin/grupos/${grupo.id}/alumnos');
                },
                icon: const Icon(Icons.people),
                label: const Text('Ver Alumnos'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                  side: const BorderSide(color: AppColors.primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showDeleteDialog(),
                icon: const Icon(Icons.delete),
                label: const Text('Eliminar Grupo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.errorColor,
                  side: const BorderSide(color: AppColors.errorColor),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getNivelDisplayName(String nivel) {
    switch (nivel) {
      case 'basico':
        return 'Básico';
      case 'intermedio':
        return 'Intermedio';
      case 'avanzado':
        return 'Avanzado';
      default:
        return nivel;
    }
  }

  void _showDeleteDialog() {
    final provider = context.read<GrupoProvider>();
    final grupo = provider.currentGrupo;
    
    if (grupo == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text(
          '¿Estás seguro de que deseas eliminar el grupo "${grupo.nombre}"?\n\n'
          'Esta acción no se puede deshacer.',
        ),
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
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Grupo eliminado exitosamente'),
                      backgroundColor: AppColors.successColor,
                    ),
                  );
                  context.go('/admin/grupos');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        provider.errorMessage ?? 'Error al eliminar el grupo',
                      ),
                      backgroundColor: AppColors.errorColor,
                    ),
                  );
                }
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
}