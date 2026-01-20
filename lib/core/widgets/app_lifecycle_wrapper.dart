import 'package:flutter/material.dart';

import 'splash_screen.dart';

class AppLifecycleWrapper extends StatefulWidget {
  final Widget child;
  final bool showSplashOnResume;
  final Duration resumeSplashDuration;

  const AppLifecycleWrapper({
    super.key,
    required this.child,
    this.showSplashOnResume = false,
    this.resumeSplashDuration = const Duration(milliseconds: 1200),
  });

  @override
  State<AppLifecycleWrapper> createState() => _AppLifecycleWrapperState();
}

class _AppLifecycleWrapperState extends State<AppLifecycleWrapper>
    with WidgetsBindingObserver {
  bool _showingSplash = true;
  bool _showingResumeSplash = false;
  DateTime? _pausedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.showSplashOnResume) return;

    if (state == AppLifecycleState.paused) {
      _pausedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      // Show splash if app was in background for more than 30 seconds
      if (_pausedAt != null && !_showingSplash) {
        final pauseDuration = DateTime.now().difference(_pausedAt!);
        if (pauseDuration.inSeconds > 30) {
          setState(() {
            _showingResumeSplash = true;
          });
        }
      }
      _pausedAt = null;
    }
  }

  void _onSplashComplete() {
    setState(() {
      _showingSplash = false;
    });
  }

  void _onResumeSplashComplete() {
    setState(() {
      _showingResumeSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show initial splash
    if (_showingSplash) {
      return SplashScreen(
        onComplete: _onSplashComplete,
      );
    }

    // Show resume splash (shorter duration)
    if (_showingResumeSplash) {
      return SplashScreen(
        onComplete: _onResumeSplashComplete,
        duration: widget.resumeSplashDuration,
      );
    }

    return widget.child;
  }
}
