import 'package:flutter/material.dart';
import '../../../shared/domain/entities/material.dart' as entities;
import '../../../../core/constants/app_colors.dart';

class MaterialDetailScreen extends StatelessWidget {
  final entities.Material material;

  const MaterialDetailScreen({
    super.key,
    required this.material,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          material.titulo,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textOnPrimary,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildContent(),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTypeChip(),
          const SizedBox(height: 16),
          Text(
            material.titulo,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textOnPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Orden: ${material.orden}',
              style: const TextStyle(
                color: AppColors.textOnSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip() {
    IconData icon;
    String label;
    Color backgroundColor;

    switch (material.tipo) {
      case 'audio':
        icon = Icons.headphones;
        label = 'Audio';
        backgroundColor = AppColors.infoColor;
        break;
      case 'video':
        icon = Icons.play_circle_filled;
        label = 'Video';
        backgroundColor = AppColors.successColor;
        break;
      case 'imagen':
        icon = Icons.image;
        label = 'Imagen';
        backgroundColor = AppColors.warningColor;
        break;
      default:
        icon = Icons.description;
        label = 'Texto';
        backgroundColor = AppColors.accentColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (material.archivoUrl != null) ...[
            _buildMediaSection(),
            const SizedBox(height: 24),
          ],
          _buildTextContent(),
        ],
      ),
    );
  }

  Widget _buildMediaSection() {
    if (material.archivoUrl == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLightColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _buildMediaWidget(),
      ),
    );
  }

  Widget _buildMediaWidget() {
    switch (material.tipo) {
      case 'imagen':
        return Image.network(
          material.archivoUrl!,
          fit: BoxFit.cover,
          height: 200,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: AppColors.borderColor,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 48, color: AppColors.textSecondaryColor),
                  SizedBox(height: 8),
                  Text('Error al cargar imagen', style: TextStyle(color: AppColors.textSecondaryColor)),
                ],
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              color: AppColors.borderColor,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              ),
            );
          },
        );
      case 'video':
        return Container(
          height: 200,
          color: AppColors.primaryDark,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle_filled, size: 64, color: AppColors.secondaryColor),
              SizedBox(height: 8),
              Text(
                'Reproductor de video\n(Funcionalidad próximamente)',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textOnPrimary),
              ),
            ],
          ),
        );
      case 'audio':
        return Container(
          height: 120,
          color: AppColors.primaryLight,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.headphones, size: 48, color: AppColors.textOnPrimary),
              SizedBox(height: 8),
              Text(
                'Reproductor de audio\n(Funcionalidad próximamente)',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textOnPrimary),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTextContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLightColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.article,
                color: AppColors.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Contenido',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            material.contenido.isNotEmpty 
                ? material.contenido 
                : 'No hay contenido de texto disponible para este material.',
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: material.contenido.isNotEmpty 
                  ? AppColors.textPrimaryColor 
                  : AppColors.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}