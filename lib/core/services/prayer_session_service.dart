import 'package:flutter/foundation.dart';

/// Service to track global prayer session state.
/// Used to prevent accidental navigation away from an active session.
class PrayerSessionService extends ChangeNotifier {
  bool _isSessionActive = false;
  int _elapsedSeconds = 0;

  bool get isSessionActive => _isSessionActive;
  int get elapsedSeconds => _elapsedSeconds;

  void startSession() {
    _isSessionActive = true;
    _elapsedSeconds = 0;
    notifyListeners();
  }

  void updateElapsedTime(int seconds) {
    _elapsedSeconds = seconds;
  }

  void endSession() {
    _isSessionActive = false;
    _elapsedSeconds = 0;
    notifyListeners();
  }
}
