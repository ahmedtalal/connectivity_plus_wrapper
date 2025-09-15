import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'connection_status.dart';
import 'connection_transition.dart';
import 'status_mapper.dart';

/// Main class that provides smart connectivity statuses and transitions
class ConnectivityWrapper {
  final Connectivity _connectivity = Connectivity();
  final StatusMapper _statusMapper;
  final StreamController<ConnectionStatus> _statusController = 
      StreamController<ConnectionStatus>.broadcast();
  final StreamController<ConnectionTransition> _transitionController = 
      StreamController<ConnectionTransition>.broadcast();
  
  ConnectionStatus _currentStatus = ConnectionStatus.checking;
  ConnectionStatus? _previousStatus;
  DateTime? _lastStatusChange;
  Timer? _checkTimer;
  bool _isDisposed = false;

  /// Stream of connection status changes
  Stream<ConnectionStatus> get onStatusChange => _statusController.stream;

  /// Stream of connection transitions (from -> to with timing)
  Stream<ConnectionTransition> get onTransition => _transitionController.stream;

  ConnectivityWrapper({
    List<String> testServers = const ['https://www.google.com'],
    Duration unstableThreshold = const Duration(seconds: 3),
    Duration checkInterval = const Duration(seconds: 5),
  }) : _statusMapper = StatusMapper(
          testServers: testServers,
          unstableThreshold: unstableThreshold,
          checkInterval: checkInterval,
        ) {
    _init();
  }

  Future<void> _init() async {
    // Listen to basic connectivity changes
    _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
    
    // Get initial status
    final initialResult = await _connectivity.checkConnectivity();
    await _handleConnectivityChange(initialResult);
    
    // Start periodic checks for quality assessment
    _startPeriodicChecks();
  }

  Future<void> _handleConnectivityChange(ConnectivityResult result) async {
    if (_isDisposed) return;
    
    final newStatus = await _statusMapper.mapToStatus(result);
    _updateStatus(newStatus);
  }

  void _updateStatus(ConnectionStatus newStatus) {
    if (newStatus == _currentStatus) return;
    
    _previousStatus = _currentStatus;
    final now = DateTime.now();
    final duration = _lastStatusChange != null 
        ? now.difference(_lastStatusChange!) 
        : Duration.zero;
    
    // Create transition
    final transition = ConnectionTransition(
      from: _previousStatus!,
      to: newStatus,
      timestamp: now,
      duration: duration,
    );
    
    // Update state
    _currentStatus = newStatus;
    _lastStatusChange = now;
    
    // Notify listeners
    _statusController.add(newStatus);
    _transitionController.add(transition);
  }

  void _startPeriodicChecks() {
    _checkTimer = Timer.periodic(_statusMapper.checkInterval, (timer) async {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      
      final result = await _connectivity.checkConnectivity();
      await _handleConnectivityChange(result);
    });
  }

  /// Get the current connection status
  Future<ConnectionStatus> get currentStatus async {
    if (_isDisposed) throw StateError('ConnectivityWrapper is disposed');
    return _currentStatus;
  }

  /// Check if there's a real internet connection (not just network interface)
  Future<bool> get isReallyConnected async {
    if (_isDisposed) throw StateError('ConnectivityWrapper is disposed');
    
    final result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      return false;
    }
    
    return await _statusMapper.mapToStatus(result) != ConnectionStatus.disconnected;
  }

  /// Add custom test servers for internet quality checking
  void addTestServers(List<String> urls) {
    for (final url in urls) {
      _statusMapper.addTestServer(url);
    }
  }

  /// Configure timing parameters
  void configureTiming({
    Duration? unstableThreshold,
    Duration? checkInterval,
  }) {
    if (unstableThreshold != null) {
      _statusMapper.unstableThreshold = unstableThreshold;
    }
    
    if (checkInterval != null) {
      _statusMapper.checkInterval = checkInterval;
      _checkTimer?.cancel();
      _startPeriodicChecks();
    }
  }

  /// Dispose all resources
  void dispose() {
    _isDisposed = true;
    _checkTimer?.cancel();
    _statusController.close();
    _transitionController.close();
    _statusMapper.reset();
  }
}