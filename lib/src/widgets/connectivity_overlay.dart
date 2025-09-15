import 'dart:async';

import 'package:connectivity_plus_wrapper/src/widgets/connectivity_builder.dart';
import 'package:flutter/material.dart';
import '../connection_status.dart';
import '../connectivity_wrapper.dart';

/// A widget that shows an overlay based on connection status
class ConnectivityOverlay extends StatefulWidget {
  final ConnectivityWrapper? connectivityWrapper;
  final Widget child;
  final Duration showDuration;
  final Curve animationCurve;
  final Duration animationDuration;

  const ConnectivityOverlay({
    super.key,
    required this.child,
    this.connectivityWrapper,
    this.showDuration = const Duration(seconds: 3),
    this.animationCurve = Curves.easeInOut,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
 State<ConnectivityOverlay> createState() => _ConnectivityOverlayState();
}

class _ConnectivityOverlayState extends State<ConnectivityOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  ConnectionStatus? _currentStatus;
  OverlayEntry? _overlayEntry;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _animation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));
    
    _initConnectivity();
  }

  void _initConnectivity() {
    final wrapper = widget.connectivityWrapper ?? 
        DefaultConnectivityWrapper.of(context)?.connectivityWrapper;
    
    if (wrapper != null) {
      wrapper.onStatusChange.listen(_handleStatusChange);
    }
  }

  void _handleStatusChange(ConnectionStatus status) {
    if (status != _currentStatus) {
      _currentStatus = status;
      _showOverlayForStatus(status);
    }
  }

  void _showOverlayForStatus(ConnectionStatus status) {
    // Cancel any pending hide operation
    _hideTimer?.cancel();
    
    // Remove existing overlay
    _removeOverlay();
    
    // Don't show overlay for connected status (normal state)
    if (status == ConnectionStatus.connected) {
      return;
    }
    
    // Create and show new overlay
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: SlideTransition(
          position: _animation,
          child: _buildStatusBanner(status),
        ),
      ),
    );
    
    Overlay.of(context).insert(_overlayEntry!);
    _controller.forward();
    
    // Schedule automatic hide
    if (status != ConnectionStatus.disconnected) {
      _hideTimer = Timer(widget.showDuration, _hideOverlay);
    }
  }

  Widget _buildStatusBanner(ConnectionStatus status) {
    Color backgroundColor;
    IconData icon;
    String message;
    
    switch (status) {
      case ConnectionStatus.disconnected:
        backgroundColor = Colors.red;
        icon = Icons.wifi_off;
        message = 'No internet connection';
      case ConnectionStatus.restored:
        backgroundColor = Colors.green;
        icon = Icons.wifi;
        message = 'Connection restored';
      case ConnectionStatus.unstable:
        backgroundColor = Colors.orange;
        icon = Icons.network_check;
        message = 'Unstable connection';
      case ConnectionStatus.roaming:
        backgroundColor = Colors.blue;
        icon = Icons.network_cell;
        message = 'Roaming network';
      case ConnectionStatus.checking:
        backgroundColor = Colors.grey;
        icon = Icons.network_wifi;
        message = 'Checking connection';
      default:
        backgroundColor = Colors.transparent;
        icon = Icons.wifi;
        message = '';
    }
    
    return Material(
      elevation: 4.0,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        color: backgroundColor,
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _hideOverlay() {
    _controller.reverse().then((value) {
      _removeOverlay();
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.dispose();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}