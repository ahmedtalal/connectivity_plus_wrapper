import 'package:connectivity_plus_wrapper/src/connection_status.dart';

/// Represents a transition between two connection states
class ConnectionTransition {
  final ConnectionStatus from;
  final ConnectionStatus to;
  final DateTime timestamp;
  final Duration duration;

  ConnectionTransition({
    required this.from,
    required this.to,
    DateTime? timestamp,
    this.duration = Duration.zero,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Returns true if this transition represents a restoration of connection
  bool get isRestored => 
      from == ConnectionStatus.disconnected && 
      to == ConnectionStatus.connected;

  /// Returns true if this transition represents a loss of connection
  bool get isLost => 
      from != ConnectionStatus.disconnected && 
      to == ConnectionStatus.disconnected;

  @override
  String toString() {
    return 'ConnectionTransition{from: $from, to: $to, '
           'timestamp: $timestamp, duration: $duration}';
  }
}