import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/actividad_provider.dart';

class ActividadScreen extends StatefulWidget {
  final String actividadId;

  const ActividadScreen({super.key, required this.actividadId});

  @override
  State<ActividadScreen> createState() => _ActividadScreenState();
}

class _ActividadScreenState extends State<ActividadScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActividadProvider>().loadActividad(widget.actividadId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<ActividadProvider>(
          builder: (context, provider, _) {
            return Text(provider.actividad?.titulo ?? 'Cargando...');
          },
        ),
      ),
      body: Consumer<ActividadProvider>(
        builder: (context, provider, _) {
          if (provider.state == ActividadState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.state == ActividadState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: AppColors.errorColor),
                  const SizedBox(height: 16),
                  Text(provider.errorMessage ?? 'Error desconocido'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.loadActividad(widget.actividadId);
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (provider.state == ActividadState.completed) {
            return _buildResultadoScreen(provider);
          }

          return _buildQuizScreen(provider);
        },
      ),
    );
  }

  Widget _buildQuizScreen(ActividadProvider provider) {
    if (provider.preguntas.isEmpty) {
      return const Center(child: Text('No hay preguntas disponibles'));
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.preguntas.length,
            itemBuilder: (context, index) {
              final pregunta = provider.preguntas[index];
              final selectedOpcionId = provider.respuestas[pregunta.id];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primaryColor,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              pregunta.textoPregunta,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...pregunta.opciones.map((opcion) {
                        final isSelected = selectedOpcionId == opcion.id;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: isSelected
                                ? AppColors.primaryColor.withOpacity(0.1)
                                : null,
                          ),
                          child: RadioListTile<String>(
                            value: opcion.id,
                            groupValue: selectedOpcionId,
                            title: Text(opcion.textoOpcion),
                            onChanged: (value) {
                              if (value != null) {
                                provider.selectRespuesta(pregunta.id, value);
                              }
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: provider.respuestas.length == provider.preguntas.length
                    ? () async {
                        await provider.submitActividad();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: provider.state == ActividadState.submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Enviar Respuestas'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultadoScreen(ActividadProvider provider) {
    final resultado = provider.resultado!;
    final puntuacion = resultado['puntuacion_obtenida'] as int;
    final puntuacionMaxima = resultado['puntuacion_maxima'] as int;
    final porcentaje = (puntuacion / puntuacionMaxima * 100).round();
    final aprobado = porcentaje >= 70;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              aprobado ? Icons.check_circle : Icons.cancel,
              size: 100,
              color: aprobado ? AppColors.successColor : AppColors.errorColor,
            ),
            const SizedBox(height: 24),
            Text(
              aprobado ? '¡Felicidades!' : 'Sigue intentando',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Has obtenido $puntuacion de $puntuacionMaxima puntos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '$porcentaje%',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: aprobado ? AppColors.successColor : AppColors.errorColor,
                  ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  provider.reset();
                  context.pop();
                },
                child: const Text('Volver'),
              ),
            ),
            const SizedBox(height: 12),
            if (!aprobado)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    provider.loadActividad(widget.actividadId);
                  },
                  child: const Text('Intentar de nuevo'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
