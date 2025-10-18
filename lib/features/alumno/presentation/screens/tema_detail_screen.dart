import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/tema_provider.dart';

class TemaDetailScreen extends StatefulWidget {
  final String temaId;

  const TemaDetailScreen({super.key, required this.temaId});

  @override
  State<TemaDetailScreen> createState() => _TemaDetailScreenState();
}

class _TemaDetailScreenState extends State<TemaDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TemaProvider>().loadTemaDetails(widget.temaId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<TemaProvider>(
          builder: (context, provider, _) {
            return Text(
              provider.currentTema?.nombre ?? 'Cargando...',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primaryColor,
              unselectedLabelColor: AppColors.textSecondaryColor,
              indicatorColor: AppColors.primaryColor,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
              tabs: const [
                Tab(text: 'Vocabulario'),
                Tab(text: 'Materiales'),
                Tab(text: 'Actividades'),
              ],
            ),
          ),
        ),
      ),
      body: Consumer<TemaProvider>(
        builder: (context, provider, _) {
          if (provider.state == TemaState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.state == TemaState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 60, color: AppColors.errorColor),
                  const SizedBox(height: 16),
                  Text(provider.errorMessage ?? 'Error desconocido'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.loadTemaDetails(widget.temaId);
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildVocabularioTab(provider),
              _buildMaterialesTab(provider),
              _buildActividadesTab(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVocabularioTab(TemaProvider provider) {
    if (provider.palabras.isEmpty) {
      return const Center(
        child: Text('No hay vocabulario disponible para este tema'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.palabras.length,
      itemBuilder: (context, index) {
        final palabra = provider.palabras[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (palabra.imagenUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      palabra.imagenUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: AppColors.basicLevelColor.withOpacity(0.2),
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        palabra.palabraMaya,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        palabra.traduccionEspanol.isNotEmpty
                            ? 'Significado: ${palabra.traduccionEspanol}'
                            : 'Significado: (No disponible)',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: palabra.traduccionEspanol.isEmpty
                                  ? AppColors.textSecondaryColor
                                  : null,
                            ),
                      ),
                      if (palabra.pronunciacion != null &&
                          palabra.pronunciacion!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Pronunciación: /${palabra.pronunciacion}/',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.textSecondaryColor,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (palabra.audioUrl != null)
                  IconButton(
                    icon: const Icon(Icons.volume_up),
                    color: AppColors.accentColor,
                    onPressed: () async {
                      try {
                        await _audioPlayer.play(UrlSource(palabra.audioUrl!));
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Error al reproducir audio'),
                            ),
                          );
                        }
                      }
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMaterialesTab(TemaProvider provider) {
    if (provider.materiales.isEmpty) {
      return const Center(
        child: Text('No hay materiales disponibles para este tema'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.materiales.length,
      itemBuilder: (context, index) {
        final material = provider.materiales[index];
        IconData icon;
        Color color;

        switch (material.tipo) {
          case 'audio':
            icon = Icons.headphones;
            color = AppColors.accentColor;
            break;
          case 'video':
            icon = Icons.play_circle_outline;
            color = AppColors.secondaryColor;
            break;
          case 'imagen':
            icon = Icons.image;
            color = AppColors.basicLevelColor;
            break;
          default:
            icon = Icons.description;
            color = AppColors.primaryColor;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            title: Text(material.titulo),
            subtitle: Text(
              material.contenido,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to material detail screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vista de material en desarrollo'),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildActividadesTab(TemaProvider provider) {
    if (provider.actividades.isEmpty) {
      return const Center(
        child: Text('No hay actividades disponibles para este tema'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.actividades.length,
      itemBuilder: (context, index) {
        final actividad = provider.actividades[index];
        IconData icon;

        switch (actividad.tipo) {
          case 'quiz':
            icon = Icons.quiz;
            break;
          case 'emparejamiento':
            icon = Icons.compare_arrows;
            break;
          case 'completar':
            icon = Icons.edit_note;
            break;
          case 'audio':
            icon = Icons.hearing;
            break;
          default:
            icon = Icons.assignment;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.accentColor.withOpacity(0.1),
              child: Icon(icon, color: AppColors.accentColor),
            ),
            title: Text(actividad.titulo),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(actividad.descripcion),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.timer,
                        size: 16, color: AppColors.textSecondaryColor),
                    const SizedBox(width: 4),
                    Text(
                      '${actividad.duracionMinutos} min',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.star,
                        size: 16, color: AppColors.textSecondaryColor),
                    const SizedBox(width: 4),
                    Text(
                      '${actividad.puntuacionMaxima} pts',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () {
                context.go('/alumno/actividad/${actividad.id}');
              },
              child: const Text('Iniciar'),
            ),
          ),
        );
      },
    );
  }
}
