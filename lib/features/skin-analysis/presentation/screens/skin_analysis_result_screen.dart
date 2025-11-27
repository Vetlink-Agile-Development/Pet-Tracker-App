import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_tracker/features/skin-analysis/presentation/providers/skin_analysis_provider.dart';
import 'dart:math' as math;

class SkinAnalysisResultScreen extends ConsumerStatefulWidget {
  const SkinAnalysisResultScreen({super.key});

  @override
  ConsumerState<SkinAnalysisResultScreen> createState() =>
      _SkinAnalysisResultScreenState();
}

class _SkinAnalysisResultScreenState
    extends ConsumerState<SkinAnalysisResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    final prediction = ref.read(skinAnalysisProvider).prediction;

    final raw = prediction?.confidence ?? 0.0;
    final targetValue = raw.clamp(0, 100).toDouble();

    _animation = Tween<double>(
      begin: 0.0,
      end: targetValue,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getColorBasedOnPrediction(String prediction) {
    if (prediction.toLowerCase() == 'healthy') {
      return const Color(0xFF4CAF50);
    } else {
      return const Color(0xFFFF5722);
    }
  }

  IconData _getIconBasedOnPrediction(String prediction) {
    if (prediction.toLowerCase() == 'healthy') {
      return Icons.check_circle;
    } else {
      return Icons.warning;
    }
  }

  String _getChatMessage(String prediction, double confidence) {
    final predictionText =
        ref.read(skinAnalysisProvider).prediction?.translatedPrediction ??
            prediction;

    return 'El modelo detectó "$predictionText" con ${confidence.toStringAsFixed(1)}% de confianza en la piel de mi mascota. ¿Podrías ayudarme con información sobre esto?';
  }

  void _goToChat() {
    final prediction = ref.read(skinAnalysisProvider).prediction;
    if (prediction == null) return;

    final message = _getChatMessage(
      prediction.translatedPrediction,
      prediction.confidence,
    );

    ref.read(skinAnalysisProvider.notifier).reset();
    context.go('/chat', extra: {'preloadedMessage': message});
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(skinAnalysisProvider);
    final prediction = state.prediction;

    if (prediction == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No hay resultados disponibles'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      );
    }

    final color = _getColorBasedOnPrediction(prediction.prediction);
    final icon = _getIconBasedOnPrediction(prediction.prediction);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const Text(
                  'Resultados del Análisis',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF08273A),
                  ),
                ),
                const SizedBox(height: 32),

                // Animated Circular Progress
                Center(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: CircularProgressPainter(
                            progress: _animation.value / 100,
                            color: color,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  icon,
                                  size: 48,
                                  color: color,
                                ),
                                const SizedBox(height: 8),

                                Text(
                                  '${_animation.value.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                                const Text(
                                  'Confianza',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Result Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withOpacity(0.3), width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        prediction.isHealthy
                            ? '¡Buenas noticias!'
                            : 'Detección Encontrada',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        prediction.translatedPrediction,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF08273A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        prediction.isHealthy
                            ? 'La piel de tu mascota parece estar en buen estado. Continúa con los cuidados regulares.'
                            : 'Se ha detectado una posible condición. Te recomendamos consultar con un veterinario para un diagnóstico profesional.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Image preview
                if (state.selectedImage != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      state.selectedImage!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Action buttons
                if (!prediction.isHealthy) ...[
                  ElevatedButton.icon(
                    onPressed: _goToChat,
                    icon: const Icon(Icons.chat),
                    label: const Text(
                      'Consultar con IA Veterinaria',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667EEA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                OutlinedButton.icon(
                  onPressed: () {
                    ref.read(skinAnalysisProvider.notifier).reset();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text(
                    'Analizar Otra Imagen',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF667EEA),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side:
                        const BorderSide(color: Color(0xFF667EEA), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircularProgressPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    final backgroundPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    canvas.drawCircle(center, radius - 6, backgroundPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 6),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}