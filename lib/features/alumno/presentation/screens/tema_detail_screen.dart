import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Consumer<TemaProvider>(
          builder: (context, provider, _) {
            return Text(
              provider.currentTema?.nombre ?? 'Cargando...',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            );
          },
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              indicatorColor: colorScheme.primary,
              indicatorWeight: 3,
              labelStyle: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              unselectedLabelStyle: textTheme.titleSmall,
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
                  Icon(Icons.error_outline, size: 60, color: colorScheme.error),
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
        final textTheme = Theme.of(context).textTheme;
        final colorScheme = Theme.of(context).colorScheme;

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
                          color: colorScheme.secondaryContainer,
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
                        style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        palabra.traduccionEspanol.isNotEmpty
                            ? 'Significado: ${palabra.traduccionEspanol}'
                            : 'Significado: (No disponible)',
                        style: textTheme.bodyLarge?.copyWith(
                              color: palabra.traduccionEspanol.isEmpty
                                  ? colorScheme.onSurfaceVariant
                                  : null,
                            ),
                      ),
                      if (palabra.pronunciacion != null &&
                          palabra.pronunciacion!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Pronunciación: /${palabra.pronunciacion}/',
                          style:
                              textTheme.bodySmall?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ],
                  ),
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
        final colorScheme = Theme.of(context).colorScheme;
        IconData icon;
        Color color;

        switch (material.tipo) {
          case 'audio':
            icon = Icons.headphones;
            color = colorScheme.secondary;
            break;
          case 'video':
            icon = Icons.play_circle_outline;
            color = colorScheme.primary;
            break;
          case 'imagen':
            icon = Icons.image;
            color = colorScheme.tertiary;
            break;
          default:
            icon = Icons.description;
            color = colorScheme.onSurfaceVariant;
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
              context.go('/alumno/tema/${widget.temaId}/material', extra: material);
            },
          ),
        );
      },
    );
  }

  Widget _buildActividadesTab(TemaProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
              backgroundColor: colorScheme.secondaryContainer,
              child: Icon(icon, color: colorScheme.onSecondaryContainer),
            ),
            title: Text(actividad.titulo),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(actividad.descripcion),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.timer, size: 16, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      '${actividad.duracionMinutos} min',
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.star, size: 16, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      '${actividad.puntuacionMaxima} pts',
                      style: textTheme.bodySmall,
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
