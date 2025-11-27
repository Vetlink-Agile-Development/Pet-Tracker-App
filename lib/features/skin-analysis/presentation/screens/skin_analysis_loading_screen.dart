import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_tracker/features/skin-analysis/presentation/providers/skin_analysis_provider.dart';
import 'package:pet_tracker/features/skin-analysis/presentation/screens/skin_analysis_result_screen.dart';

class SkinAnalysisLoadingScreen extends ConsumerStatefulWidget {
  const SkinAnalysisLoadingScreen({super.key});

  @override
  ConsumerState<SkinAnalysisLoadingScreen> createState() =>
      _SkinAnalysisLoadingScreenState();
}

class _SkinAnalysisLoadingScreenState
    extends ConsumerState<SkinAnalysisLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController rotationController;
  late AnimationController pulseController;
  late AnimationController glowController;
  late AnimationController particleController;

  bool _handledNavigation = false;

  @override
  void initState() {
    super.initState();

    // Rotación continua y suave
    rotationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    // Pulso más pronunciado
    pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
      lowerBound: 0.90,
      upperBound: 1.08,
    )..repeat(reverse: true);

    // Glow pulsante
    glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // Partículas flotantes
    particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    rotationController.dispose();
    pulseController.dispose();
    glowController.dispose();
    particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(skinAnalysisProvider, (prev, next) {
      if (_handledNavigation) return;

      if (!next.isLoading && next.prediction != null) {
        _handledNavigation = true;
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const SkinAnalysisResultScreen(),
              ),
            );
          }
        });
      }

      if (!next.isLoading && next.errorMessage != null) {
        _handledNavigation = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF051C2C),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono animado mejorado con partículas
              SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Partículas flotantes
                    ...List.generate(6, (index) {
                      final angle = (index * 60) * 3.14159 / 180;
                      return AnimatedBuilder(
                        animation: particleController,
                        builder: (_, __) {
                          final progress = (particleController.value + index / 6) % 1.0;
                          final radius = 50 + (progress * 30);
                          final opacity = (1 - progress) * 0.6;
                          
                          return Positioned(
                            left: 100 + (radius * math.cos(angle)) - 4,
                            top: 100 + (radius * math.sin(angle)) - 4,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Color(0xFF8EA4FF).withOpacity(opacity),
                                    Color(0xFF667EEA).withOpacity(0),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),

                    // Icono central con múltiples efectos
                    AnimatedBuilder(
                      animation: rotationController,
                      builder: (_, child) {
                        return Transform.rotate(
                          angle: rotationController.value * 6.28318,
                          child: child,
                        );
                      },
                      child: AnimatedBuilder(
                        animation: pulseController,
                        builder: (_, child) {
                          return Transform.scale(
                            scale: pulseController.value,
                            child: child,
                          );
                        },
                        child: AnimatedBuilder(
                          animation: glowController,
                          builder: (_, child) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                // Glow exterior animado
                                Container(
                                  width: 180 + (glowController.value * 20),
                                  height: 180 + (glowController.value * 20),
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      colors: [
                                        Color(0xFF8EA4FF).withOpacity(0.4 + glowController.value * 0.2),
                                        Color(0xFF667EEA).withOpacity(0.2 + glowController.value * 0.1),
                                        Color(0x00667EEA),
                                      ],
                                      stops: const [0.0, 0.5, 1.0],
                                    ),
                                  ),
                                ),

                                // Anillo giratorio
                                Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                      width: 2,
                                    ),
                                  ),
                                ),

                                // Card glassmorphism
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(32),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                    child: Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.10),
                                        borderRadius: BorderRadius.circular(32),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.25),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF667EEA).withOpacity(0.5),
                                            blurRadius: 60,
                                            spreadRadius: 10,
                                          ),
                                          BoxShadow(
                                            color: const Color(0xFF8EA4FF).withOpacity(0.3),
                                            blurRadius: 30,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Brillo interno
                                          Positioned(
                                            top: 10,
                                            left: 10,
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                gradient: RadialGradient(
                                                  colors: [
                                                    Colors.white.withOpacity(0.3),
                                                    Colors.white.withOpacity(0),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Icono principal
                                          const Icon(
                                            Icons.auto_awesome,
                                            size: 65,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                'Analizando imagen...',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Nuestra IA está procesando la imagen\ny detectando posibles condiciones',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 40),

              // Barra progreso
              SizedBox(
                width: 220,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: const LinearProgressIndicator(
                    backgroundColor: Color(0xFF0D3447),
                    valueColor: AlwaysStoppedAnimation(Color(0xFF8EA4FF)),
                    minHeight: 6,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                'Esto puede tomar unos segundos...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}