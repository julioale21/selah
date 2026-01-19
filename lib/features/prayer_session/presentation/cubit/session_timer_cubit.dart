import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum TimerStatus { initial, running, paused, finished }

class SessionTimerState extends Equatable {
  final TimerStatus status;
  final int elapsedSeconds;
  final int? targetMinutes;

  const SessionTimerState({
    this.status = TimerStatus.initial,
    this.elapsedSeconds = 0,
    this.targetMinutes,
  });

  double get progress {
    if (targetMinutes == null || targetMinutes == 0) return 0;
    return elapsedSeconds / (targetMinutes! * 60);
  }

  String get formattedTime {
    final minutes = (elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get remainingTime {
    if (targetMinutes == null) return formattedTime;
    final remaining = (targetMinutes! * 60) - elapsedSeconds;
    if (remaining <= 0) return '00:00';
    final minutes = (remaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (remaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  bool get isRunning => status == TimerStatus.running;
  bool get isPaused => status == TimerStatus.paused;
  bool get isFinished => status == TimerStatus.finished;

  SessionTimerState copyWith({
    TimerStatus? status,
    int? elapsedSeconds,
    int? targetMinutes,
  }) {
    return SessionTimerState(
      status: status ?? this.status,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      targetMinutes: targetMinutes ?? this.targetMinutes,
    );
  }

  @override
  List<Object?> get props => [status, elapsedSeconds, targetMinutes];
}

class SessionTimerCubit extends Cubit<SessionTimerState> {
  Timer? _timer;

  SessionTimerCubit() : super(const SessionTimerState());

  void setTarget(int minutes) {
    emit(state.copyWith(targetMinutes: minutes));
  }

  void start() {
    if (state.status == TimerStatus.running) return;

    emit(state.copyWith(status: TimerStatus.running));

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final newElapsed = state.elapsedSeconds + 1;

      // Check if target reached
      if (state.targetMinutes != null &&
          newElapsed >= state.targetMinutes! * 60) {
        emit(state.copyWith(
          status: TimerStatus.finished,
          elapsedSeconds: newElapsed,
        ));
        _timer?.cancel();
        return;
      }

      emit(state.copyWith(elapsedSeconds: newElapsed));
    });
  }

  void pause() {
    _timer?.cancel();
    emit(state.copyWith(status: TimerStatus.paused));
  }

  void resume() {
    if (state.status != TimerStatus.paused) return;
    start();
  }

  void toggle() {
    if (state.isRunning) {
      pause();
    } else {
      start();
    }
  }

  void reset() {
    _timer?.cancel();
    emit(const SessionTimerState());
  }

  void finish() {
    _timer?.cancel();
    emit(state.copyWith(status: TimerStatus.finished));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
