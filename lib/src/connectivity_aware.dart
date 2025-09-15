import 'package:flutter/material.dart';
import 'connection_status.dart';

/// A mixin that provides connectivity awareness to any class
mixin ConnectivityAware<T extends StatefulWidget> on State<T> {
  ConnectionStatus? _currentStatus;
  Stream<ConnectionStatus>? _statusStream;

  /// Get the current connection status
  ConnectionStatus? get connectionStatus => _currentStatus;

  /// Initialize connectivity awareness with a status stream
  void initConnectivityAware(Stream<ConnectionStatus> statusStream) {
    _statusStream = statusStream;
    _statusStream?.listen(_handleStatusChange);
  }

  void _handleStatusChange(ConnectionStatus status) {
    if (mounted) {
      setState(() {
        _currentStatus = status;
      });
      onConnectionStatusChanged(status);
    }
  }

  /// Override this method to handle status changes
  void onConnectionStatusChanged(ConnectionStatus status) {}

  @override
  void dispose() {
    _statusStream = null;
    super.dispose();
  }
}