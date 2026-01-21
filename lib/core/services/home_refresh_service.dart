import 'dart:async';

/// Simple service to notify the home screen when it should refresh its data
class HomeRefreshService {
  final _refreshController = StreamController<void>.broadcast();

  Stream<void> get onRefresh => _refreshController.stream;

  void triggerRefresh() {
    _refreshController.add(null);
  }

  void dispose() {
    _refreshController.close();
  }
}
