/// Smart connection statuses that provide more meaningful information
/// than basic connectivity types
enum ConnectionStatus {
  /// No internet connection available
  disconnected,

  /// Stable and reliable internet connection
  connected,

  /// Connection was recently restored after being disconnected
  restored,

  /// Connection is unstable or intermittent
  unstable,

  /// Mobile data connection in roaming mode
  roaming,
  
  /// Connection type is known but quality is being assessed
  checking,
}

extension ConnectionStatusExtensions on ConnectionStatus {
  /// Returns true if there's any form of connection
  bool get isConnected => this != ConnectionStatus.disconnected;
  
  /// Returns a user-friendly description of the status
  String get description {
    switch (this) {
      case ConnectionStatus.disconnected:
        return 'No internet connection';
      case ConnectionStatus.connected:
        return 'Connected to internet';
      case ConnectionStatus.restored:
        return 'Connection restored';
      case ConnectionStatus.unstable:
        return 'Unstable connection';
      case ConnectionStatus.roaming:
        return 'Roaming network';
      case ConnectionStatus.checking:
        return 'Checking connection quality';
    }
  }
}