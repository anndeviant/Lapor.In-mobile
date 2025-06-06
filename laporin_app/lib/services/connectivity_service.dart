import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';

class ConnectivityService {
  static final Logger _logger = Logger();
  static final Connectivity _connectivity = Connectivity();
  static StreamSubscription<bool>? _connectivitySubscription;

  // Check current connectivity status
  static Future<bool> hasConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      final isConnected = !result.contains(ConnectivityResult.none);
      _logger.d('Connection status: $isConnected ($result)');
      return isConnected;
    } catch (e) {
      _logger.e('Error checking connectivity: $e');
      return false;
    }
  }

  // Listen to connectivity changes
  static Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((result) {
      final isConnected = !result.contains(ConnectivityResult.none);
      _logger.d('Connectivity changed: $isConnected ($result)');
      return isConnected;
    });
  }

  // Start monitoring connectivity
  static void startMonitoring(Function(bool) onConnectivityChanged) {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = ConnectivityService.onConnectivityChanged
        .listen(onConnectivityChanged);
  }

  // Stop monitoring connectivity
  static void stopMonitoring() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }
}
