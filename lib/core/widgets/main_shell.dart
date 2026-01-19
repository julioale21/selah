import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({
    super.key,
    required this.navigationShell,
  });

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
        onTap: (index) => navigationShell.goBranch(index),
        isDark: isDark,
        primaryColor: primaryColor,
      ),
    );
  }
}

class _ModernBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isDark;
  final Color primaryColor;

  const _ModernBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      height: 90,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Main navigation bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1A1A1A).withValues(alpha: 0.9)
                        : Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _NavItem(
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home_rounded,
                        label: 'Inicio',
                        isSelected: currentIndex == 0,
                        onTap: () => onTap(0),
                        isDark: isDark,
                        primaryColor: primaryColor,
                      ),
                      _NavItem(
                        icon: Icons.book_outlined,
                        activeIcon: Icons.book_rounded,
                        label: 'Diario',
                        isSelected: currentIndex == 2,
                        onTap: () => onTap(2),
                        isDark: isDark,
                        primaryColor: primaryColor,
                      ),
                      // Space for center button
                      const SizedBox(width: 80),
                      _NavItem(
                        icon: Icons.bar_chart_outlined,
                        activeIcon: Icons.bar_chart_rounded,
                        label: 'Stats',
                        isSelected: currentIndex == 3,
                        onTap: () => onTap(3),
                        isDark: isDark,
                        primaryColor: primaryColor,
                      ),
                      _NavItem(
                        icon: Icons.settings_outlined,
                        activeIcon: Icons.settings_rounded,
                        label: 'Ajustes',
                        isSelected: false,
                        onTap: () => context.push('/settings'),
                        isDark: isDark,
                        primaryColor: primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Center floating button
          Positioned(
            bottom: 25,
            child: _CenterPrayerButton(
              isSelected: currentIndex == 1,
              onTap: () => onTap(1),
              primaryColor: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final Color primaryColor;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                size: 24,
                color: isSelected
                    ? primaryColor
                    : (isDark ? Colors.white54 : Colors.black45),
              ),
            ),
            const SizedBox(height: 2),
            AutoSizeText(
              label,
              maxLines: 1,
              minFontSize: 8,
              maxFontSize: 10,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? primaryColor
                    : (isDark ? Colors.white54 : Colors.black45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterPrayerButton extends StatefulWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final Color primaryColor;

  const _CenterPrayerButton({
    required this.isSelected,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  State<_CenterPrayerButton> createState() => _CenterPrayerButtonState();
}

class _CenterPrayerButtonState extends State<_CenterPrayerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onTap,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.primaryColor,
                    widget.primaryColor.withValues(alpha: 0.7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.primaryColor.withValues(alpha: _glowAnimation.value),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                  BoxShadow(
                    color: widget.primaryColor.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Inner ring
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 2,
                      ),
                    ),
                  ),
                  // Praying hands icon
                  CustomPaint(
                    size: const Size(32, 32),
                    painter: _PrayingHandsPainter(
                      color: Colors.white,
                    ),
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

// Custom painter for praying hands icon
class _PrayingHandsPainter extends CustomPainter {
  final Color color;

  _PrayingHandsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Left hand path
    final leftHand = Path()
      ..moveTo(w * 0.5, h * 0.15)
      ..quadraticBezierTo(w * 0.25, h * 0.2, w * 0.2, h * 0.4)
      ..quadraticBezierTo(w * 0.15, h * 0.55, w * 0.25, h * 0.7)
      ..quadraticBezierTo(w * 0.35, h * 0.85, w * 0.5, h * 0.95);

    // Right hand path (mirror)
    final rightHand = Path()
      ..moveTo(w * 0.5, h * 0.15)
      ..quadraticBezierTo(w * 0.75, h * 0.2, w * 0.8, h * 0.4)
      ..quadraticBezierTo(w * 0.85, h * 0.55, w * 0.75, h * 0.7)
      ..quadraticBezierTo(w * 0.65, h * 0.85, w * 0.5, h * 0.95);

    // Combined path for fill
    final combinedPath = Path()
      ..addPath(leftHand, Offset.zero)
      ..lineTo(w * 0.5, h * 0.95)
      ..addPath(rightHand, Offset.zero);

    canvas.drawPath(combinedPath, fillPaint);
    canvas.drawPath(leftHand, paint);
    canvas.drawPath(rightHand, paint);

    // Finger lines on left hand
    canvas.drawLine(
      Offset(w * 0.28, h * 0.35),
      Offset(w * 0.35, h * 0.28),
      paint..strokeWidth = 1.5,
    );
    canvas.drawLine(
      Offset(w * 0.25, h * 0.45),
      Offset(w * 0.32, h * 0.38),
      paint,
    );

    // Finger lines on right hand (mirror)
    canvas.drawLine(
      Offset(w * 0.72, h * 0.35),
      Offset(w * 0.65, h * 0.28),
      paint,
    );
    canvas.drawLine(
      Offset(w * 0.75, h * 0.45),
      Offset(w * 0.68, h * 0.38),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
