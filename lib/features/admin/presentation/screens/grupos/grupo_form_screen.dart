import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../providers/grupo_provider.dart';
import '../../../../shared/domain/entities/grupo.dart';

class GrupoFormScreen extends StatefulWidget {
  final String? grupoId;

  const GrupoFormScreen({super.key, this.grupoId});

  @override
  State<GrupoFormScreen> createState() => _GrupoFormScreenState();
}

class _GrupoFormScreenState extends State<GrupoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  
  String _selectedNivel = 'basico';
  bool _activo = true;
  bool _isLoading = false;
  
  bool get isEditing => widget.grupoId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadGrupo();
      });
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _loadGrupo() async {
    setState(() => _isLoading = true);
    
    final provider = context.read<GrupoProvider>();
    await provider.loadGrupoById(widget.grupoId!);
    
    if (provider.currentGrupo != null) {
      final grupo = provider.currentGrupo!;
      _nombreController.text = grupo.nombre;
      _descripcionController.text = grupo.descripcion ?? '';
      _selectedNivel = grupo.nivel;
      _activo = grupo.activo;
      setState(() {});
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Grupo' : 'Nuevo Grupo'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildForm(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
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
          Icon(
            isEditing ? Icons.edit : Icons.group_add,
            size: 48,
            color: AppColors.textOnPrimary,
          ),
          const SizedBox(height: 16),
          Text(
            isEditing 
                ? 'Modificar información del grupo'
                : 'Crear un nuevo grupo de estudiantes',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textOnPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Información Básica'),
            const SizedBox(height: 16),
            
            // Nombre del grupo
            _buildTextField(
              controller: _nombreController,
              label: 'Nombre del Grupo',
              hint: 'Ej: Grupo Maya A1',
              icon: Icons.group,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre del grupo es obligatorio';
                }
                if (value.trim().length < 3) {
                  return 'El nombre debe tener al menos 3 caracteres';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 20),
            
            // Nivel
            _buildSectionTitle('Nivel de Aprendizaje'),
            const SizedBox(height: 12),
            _buildNivelSelector(),
            
            const SizedBox(height: 24),
            
            // Descripción
            _buildSectionTitle('Descripción (Opcional)'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descripcionController,
              label: 'Descripción',
              hint: 'Describe las características del grupo...',
              icon: Icons.description,
              maxLines: 3,
              isRequired: false,
            ),
            
            if (isEditing) ...[
              const SizedBox(height: 24),
              _buildSectionTitle('Estado'),
              const SizedBox(height: 12),
              _buildActiveSwitch(),
            ],
            
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryColor,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primaryColor),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorColor),
        ),
        filled: true,
        fillColor: AppColors.surfaceColor,
      ),
    );
  }

  Widget _buildNivelSelector() {
    return Column(
      children: [
        _buildNivelOption(
          'basico',
          'Básico',
          'Estudiantes que inician su aprendizaje del maya',
          Icons.looks_one,
          AppColors.basicLevelColor,
        ),
        const SizedBox(height: 12),
        _buildNivelOption(
          'intermedio',
          'Intermedio',
          'Estudiantes con conocimientos previos del maya',
          Icons.looks_two,
          AppColors.intermediateLevelColor,
        ),
        const SizedBox(height: 12),
        _buildNivelOption(
          'avanzado',
          'Avanzado',
          'Estudiantes con amplio dominio del maya',
          Icons.looks_3,
          AppColors.advancedLevelColor,
        ),
      ],
    );
  }

  Widget _buildNivelOption(
    String value,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedNivel == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedNivel = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : AppColors.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Icon(
            _activo ? Icons.check_circle : Icons.cancel,
            color: _activo ? AppColors.successColor : AppColors.errorColor,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado del Grupo',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _activo 
                      ? 'El grupo está activo y visible para los alumnos'
                      : 'El grupo está inactivo y no visible para los alumnos',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _activo,
            onChanged: (value) {
              setState(() {
                _activo = value;
              });
            },
            activeColor: AppColors.successColor,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Consumer<GrupoProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: provider.isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: provider.isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        isEditing ? 'Actualizar Grupo' : 'Crear Grupo',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: provider.isSubmitting ? null : () => context.pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondaryColor,
                  side: const BorderSide(color: AppColors.borderColor),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<GrupoProvider>();
    bool success = false;

    if (isEditing) {
      success = await provider.updateGrupo(
        id: widget.grupoId!,
        nombre: _nombreController.text.trim(),
        nivel: _selectedNivel,
        descripcion: _descripcionController.text.trim().isNotEmpty 
            ? _descripcionController.text.trim() 
            : null,
        activo: _activo,
      );
    } else {
      success = await provider.createGrupo(
        nombre: _nombreController.text.trim(),
        nivel: _selectedNivel,
        descripcion: _descripcionController.text.trim().isNotEmpty 
            ? _descripcionController.text.trim() 
            : null,
      );
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing 
                  ? 'Grupo actualizado exitosamente'
                  : 'Grupo creado exitosamente',
            ),
            backgroundColor: AppColors.successColor,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.errorMessage ?? 
              (isEditing 
                  ? 'Error al actualizar el grupo'
                  : 'Error al crear el grupo'),
            ),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }
}