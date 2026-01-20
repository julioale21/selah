import 'dart:math' as math;

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final Duration duration;

  const SplashScreen({
    super.key,
    required this.onComplete,
    this.duration = const Duration(milliseconds: 2500),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _particleController;

  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _logoSlideAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    // Main animation controller
    _mainController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Pulse animation for the icon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Particle animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // Fade in animation (0.0 - 0.3)
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // Scale animation (0.0 - 0.5)
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    // Logo slide up animation (0.2 - 0.6)
    _logoSlideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    // Text fade animation (0.4 - 0.7)
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    // Pulse animation
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _startAnimations() {
    _mainController.forward();
    _pulseController.repeat(reverse: true);
    _particleController.repeat();

    // Complete after duration
    Future.delayed(widget.duration + const Duration(milliseconds: 300), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    return Material(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _mainController,
          _pulseController,
          _particleController,
        ]),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF0D1117),
                        const Color(0xFF161B22),
                        const Color(0xFF1A2332),
                      ]
                    : [
                        const Color(0xFFF8F9FA),
                        const Color(0xFFE9ECEF),
                        const Color(0xFFDEE2E6),
                      ],
              ),
            ),
            child: Stack(
              children: [
                // Animated particles/orbs
                ..._buildParticles(isDark),

                // Gradient overlay orbs
                _buildGradientOrbs(isDark),

                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated logo
                      Transform.translate(
                        offset: Offset(0, _logoSlideAnimation.value),
                        child: Opacity(
                          opacity: _fadeInAnimation.value,
                          child: Transform.scale(
                            scale: _scaleAnimation.value * _pulseAnimation.value,
                            child: _buildLogo(isDark),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // App name with staggered animation
                      Opacity(
                        opacity: _textFadeAnimation.value,
                        child: _buildAppName(isDark),
                      ),

                      const SizedBox(height: 12),

                      // Tagline
                      Opacity(
                        opacity: _textFadeAnimation.value,
                        child: _buildTagline(isDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogo(bool isDark) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2D3A4F),
            const Color(0xFF1A2332),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D3A4F).withValues(alpha: 0.4),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: const Color(0xFFE8A838).withValues(alpha: 0.2),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: const Center(
        child: Text(
          '🙏',
          style: TextStyle(fontSize: 56),
        ),
      ),
    );
  }

  Widget _buildAppName(bool isDark) {
    const letters = ['S', 'e', 'l', 'a', 'h'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(letters.length, (index) {
        final delay = 0.4 + (index * 0.05);
        final letterAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: Interval(delay, delay + 0.2, curve: Curves.easeOut),
          ),
        );

        return AnimatedBuilder(
          animation: letterAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - letterAnimation.value)),
              child: Opacity(
                opacity: letterAnimation.value,
                child: Text(
                  letters[index],
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 8,
                    color: isDark ? Colors.white : const Color(0xFF1A2332),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildTagline(bool isDark) {
    return Text(
      'Tiempo de oración',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w300,
        letterSpacing: 2,
        color: isDark
            ? Colors.white.withValues(alpha: 0.6)
            : const Color(0xFF1A2332).withValues(alpha: 0.6),
      ),
    );
  }

  List<Widget> _buildParticles(bool isDark) {
    final particles = <Widget>[];
    final random = math.Random(42); // Fixed seed for consistent positions

    for (int i = 0; i < 20; i++) {
      final size = 4.0 + random.nextDouble() * 8;
      final startX = random.nextDouble();
      final startY = random.nextDouble();
      final duration = 2000 + random.nextInt(2000);

      particles.add(
        _AnimatedParticle(
          controller: _particleController,
          startX: startX,
          startY: startY,
          size: size,
          color: _getParticleColor(i, isDark),
          duration: duration,
        ),
      );
    }

    return particles;
  }

  Color _getParticleColor(int index, bool isDark) {
    final colors = [
      const Color(0xFFE8A838).withValues(alpha: 0.3), // Gold
      const Color(0xFF9B7FC7).withValues(alpha: 0.3), // Purple
      const Color(0xFF5BAE7D).withValues(alpha: 0.3), // Green
      const Color(0xFF5B9FD4).withValues(alpha: 0.3), // Blue
    ];
    return colors[index % colors.length];
  }

  Widget _buildGradientOrbs(bool isDark) {
    return Stack(
      children: [
        // Top left orb
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFE8A838).withValues(alpha: isDark ? 0.15 : 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Bottom right orb
        Positioned(
          bottom: -150,
          right: -150,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF5B9FD4).withValues(alpha: isDark ? 0.15 : 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Center subtle orb
        Positioned(
          top: MediaQuery.of(context).size.height * 0.3,
          left: MediaQuery.of(context).size.width * 0.2,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF9B7FC7).withValues(alpha: isDark ? 0.1 : 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedParticle extends StatelessWidget {
  final AnimationController controller;
  final double startX;
  final double startY;
  final double size;
  final Color color;
  final int duration;

  const _AnimatedParticle({
    required this.controller,
    required this.startX,
    required this.startY,
    required this.size,
    required this.color,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final progress = (controller.value * duration / 3000) % 1.0;
        final yOffset = progress * 100 - 50; // Float up and down
        final opacity = math.sin(progress * math.pi); // Fade in and out

        return Positioned(
          left: startX * screenSize.width,
          top: startY * screenSize.height + yOffset,
          child: Opacity(
            opacity: opacity * 0.6,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(
                    color: color,
                    blurRadius: size,
                    spreadRadius: size / 4,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
