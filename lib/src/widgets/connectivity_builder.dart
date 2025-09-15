import 'package:flutter/material.dart';
import '../connection_status.dart';
import '../connectivity_wrapper.dart';

/// A widget that rebuilds itself based on connection status
class ConnectivityBuilder extends StatelessWidget {
  final Widget Function(BuildContext, ConnectionStatus) builder;
  final ConnectivityWrapper? connectivityWrapper;
  final Widget? loadingWidget;
  final ConnectionStatus? initialData;

  const ConnectivityBuilder({
    super.key,
    required this.builder,
    this.connectivityWrapper,
    this.loadingWidget,
    this.initialData,
  });

  @override
  Widget build(BuildContext context) {
    final wrapper = connectivityWrapper ?? 
        DefaultConnectivityWrapper.of(context)?.connectivityWrapper;
    
    if (wrapper == null) {
      throw FlutterError('ConnectivityBuilder must be used with a ConnectivityWrapper. '
          'Either provide one directly or place a DefaultConnectivityWrapper above in the widget tree.');
    }

    return StreamBuilder<ConnectionStatus>(
      initialData: initialData ?? ConnectionStatus.checking,
      stream: wrapper.onStatusChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && loadingWidget != null) {
          return loadingWidget!;
        }
        
        final status = snapshot.data ?? ConnectionStatus.checking;
        return builder(context, status);
      },
    );
  }
}

/// Provides a default ConnectivityWrapper to the widget tree
class DefaultConnectivityWrapper extends InheritedWidget {
  final ConnectivityWrapper connectivityWrapper;

  const DefaultConnectivityWrapper({
    super.key,
    required this.connectivityWrapper,
    required super.child,
  });

  static DefaultConnectivityWrapper? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DefaultConnectivityWrapper>();
  }

  @override
  bool updateShouldNotify(DefaultConnectivityWrapper oldWidget) {
    return connectivityWrapper != oldWidget.connectivityWrapper;
  }
}