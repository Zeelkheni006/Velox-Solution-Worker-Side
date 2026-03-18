// lib/core/providers/worker_status_provider.dart

import 'package:flutter/foundation.dart';

class WorkerStatusProvider extends ChangeNotifier {
  bool _isOnline = true;

  bool get isOnline => _isOnline;

  void setStatus(bool status) {
    _isOnline = status;
    notifyListeners();
  }

  void toggleStatus() {
    _isOnline = !_isOnline;
    notifyListeners();
  }
}