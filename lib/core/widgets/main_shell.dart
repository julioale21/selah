import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../injection_container.dart';
import '../services/prayer_session_service.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({
    super.key,
    required this.navigationShell,
  });

  void _handleNavigation(BuildContext context, int index) {
    final sessionService = sl<PrayerSessionService>();

    // If session is active and trying to navigate away from prayer (index 1)
    if (sessionService.isSessionActive && navigationShell.currentIndex == 1 && index != 1) {
      _showExitSessionDialog(context, index);
    } else {
      navigationShell.goBranch(index);
    }
  }

  void _showExitSessionDialog(BuildContext context, int targetIndex) {
    final sessionService = sl<PrayerSessionService>();
    final duration = Duration(seconds: sessionService.elapsedSeconds);
    final timeString =
        '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Salir de la sesión?'),
        content: Text(
          'Has estado orando por $timeString.\nTu progreso no se guardará.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Continuar orando'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              sessionService.endSession();
              if (targetIndex == -1) {
                // Navigate to settings
                context.push('/settings');
              } else {
                navigationShell.goBranch(targetIndex);
              }
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: _ModernBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => _handleNavigation(context, index),
        onSettingsTap: () {
          final sessionService = sl<PrayerSessionService>();
          if (sessionService.isSessionActive && navigationShell.currentIndex == 1) {
            _showExitSessionDialog(context, -1); // -1 means settings
          } else {
            context.push('/settings');
          }
        },
        isDark: isDark,
        primaryColor: primaryColor,
      ),
    );
  }
}

class _ModernBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onSettingsTap;
  final bool isDark;
  final Color primaryColor;

  const _ModernBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.onSettingsTap,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      height: 72,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Main navigation bar with notch
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.4)
                        : primaryColor.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                const Color(0xFF1E1E1E).withValues(alpha: 0.95),
                                const Color(0xFF2A2A2A).withValues(alpha: 0.95),
                              ]
                            : [
                                Colors.white.withValues(alpha: 0.95),
                                const Color(0xFFF8F8F8).withValues(alpha: 0.95),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.8),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _NavItem(
                          icon: Icons.home_rounded,
                          label: 'Inicio',
                          isSelected: currentIndex == 0,
                          onTap: () => onTap(0),
                          isDark: isDark,
                          primaryColor: primaryColor,
                        ),
                        _NavItem(
                          icon: Icons.menu_book_rounded,
                          label: 'Diario',
                          isSelected: currentIndex == 2,
                          onTap: () => onTap(2),
                          isDark: isDark,
                          primaryColor: primaryColor,
                        ),
                        // Space for center button
                        const SizedBox(width: 68),
                        _NavItem(
                          icon: Icons.insights_rounded,
                          label: 'Stats',
                          isSelected: currentIndex == 3,
                          onTap: () => onTap(3),
                          isDark: isDark,
                          primaryColor: primaryColor,
                        ),
                        _NavItem(
                          icon: Icons.tune_rounded,
                          label: 'Ajustes',
                          isSelected: false,
                          onTap: onSettingsTap,
                          isDark: isDark,
                          primaryColor: primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Center floating prayer button
          Positioned(
            bottom: 10,
            child: _CenterPrayerButton(
              isSelected: currentIndex == 1,
              onTap: () => onTap(1),
              primaryColor: primaryColor,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final Color primaryColor;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isSelected
        ? widget.primaryColor
        : (widget.isDark ? Colors.white60 : Colors.black54);

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? widget.primaryColor.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 24,
                    color: color,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CenterPrayerButton extends StatefulWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final Color primaryColor;
  final bool isDark;

  const _CenterPrayerButton({
    required this.isSelected,
    required this.onTap,
    required this.primaryColor,
    required this.isDark,
  });

  @override
  State<_CenterPrayerButton> createState() => _CenterPrayerButtonState();
}

class _CenterPrayerButtonState extends State<_CenterPrayerButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _tapController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _tapAnimation;

  @override
  void initState() {
    super.initState();

    // Subtle pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Tap animation
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _tapAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _tapController]),
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (_) => _tapController.forward(),
          onTapUp: (_) {
            _tapController.reverse();
            widget.onTap();
          },
          onTapCancel: () => _tapController.reverse(),
          child: Transform.scale(
            scale: _pulseAnimation.value * _tapAnimation.value,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.primaryColor,
                    Color.lerp(widget.primaryColor, Colors.purple, 0.3)!,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.primaryColor.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: widget.primaryColor.withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 2),
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: const Center(
                  child: Text(
                    '🙏',
                    style: TextStyle(fontSize: 26),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

