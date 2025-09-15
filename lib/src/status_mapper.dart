import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'connection_status.dart';

/// Maps raw connectivity results to smart connection statuses
class StatusMapper {
  final List<String> testServers;
   Duration unstableThreshold;
   Duration checkInterval;
  
  DateTime? _lastConnectedTime;
  bool _lastInternetCheck = false;
  int _unstableCount = 0;

  StatusMapper({
    this.testServers = const ['https://www.google.com', 'https://www.cloudflare.com'],
    this.unstableThreshold = const Duration(seconds: 3),
    this.checkInterval = const Duration(seconds: 2),
  });

  /// Converts a ConnectivityResult to a more meaningful ConnectionStatus
  Future<ConnectionStatus> mapToStatus(
    ConnectivityResult result, {
    bool isRoaming = false,
  }) async {
    // First, check if we have basic connectivity
    if (result == ConnectivityResult.none) {
      return ConnectionStatus.disconnected;
    }

    // Check internet access quality
    final hasRealInternet = await _checkInternetQuality();
    
    // Handle roaming status
    if (isRoaming && hasRealInternet) {
      return ConnectionStatus.roaming;
    }

    // Determine status based on internet quality and previous state
    return _determineQualityStatus(hasRealInternet);
  }

  Future<bool> _checkInternetQuality() async {
    try {
      // Test multiple servers for more reliable results
      final results = await Future.wait(
        testServers.map((server) => InternetConnectionChecker().hasConnection),
      );
      
      final bool hasConnection = results.any((result) => result == true);
      _updateConnectionStats(hasConnection);
      return hasConnection;
    } catch (e) {
      _updateConnectionStats(false);
      return false;
    }
  }

  void _updateConnectionStats(bool hasConnection) {
    final now = DateTime.now();
    
    if (hasConnection && !_lastInternetCheck) {
      // Connection was restored
      _lastConnectedTime = now;
    } else if (!hasConnection && _lastInternetCheck) {
      // Connection was lost
      _lastConnectedTime = null;
    }
    
    // Track unstable connection patterns
    if (hasConnection != _lastInternetCheck) {
      _unstableCount++;
    } else if (hasConnection && _unstableCount > 0) {
      _unstableCount = 0; // Reset if stable
    }
    
    _lastInternetCheck = hasConnection;
  }

  ConnectionStatus _determineQualityStatus(bool hasRealInternet) {
    if (!hasRealInternet) {
      return ConnectionStatus.disconnected;
    }

    final now = DateTime.now();
    
    // Check for recently restored connection
    if (_lastConnectedTime != null) {
      final timeSinceRestore = now.difference(_lastConnectedTime!);
      if (timeSinceRestore < unstableThreshold) {
        return ConnectionStatus.restored;
      }
    }

    // Check for unstable connection pattern
    if (_unstableCount >= 3) {
      return ConnectionStatus.unstable;
    }

    return ConnectionStatus.connected;
  }

  void addTestServer(String serverUrl) {
    if (!testServers.contains(serverUrl)) {
      testServers.add(serverUrl);
    }
  }

  void reset() {
    _lastConnectedTime = null;
    _lastInternetCheck = false;
    _unstableCount = 0;
  }
}