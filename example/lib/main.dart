import 'package:flutter/material.dart';
import 'package:connectivity_plus_wrapper/connectivity_plus_wrapper.dart';

void main() {
  // Initialize Flutter binding first
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ConnectivityWrapper connectivityWrapper;

  // Initialize ConnectivityWrapper in the constructor, after binding is initialized
  MyApp({super.key}) : connectivityWrapper = ConnectivityWrapper();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultConnectivityWrapper(
        connectivityWrapper: connectivityWrapper,
        child: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with ConnectivityAware<MyHomePage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Use didChangeDependencies instead of initState to access inherited widgets
    final wrapper = DefaultConnectivityWrapper.of(context)?.connectivityWrapper;
    if (wrapper != null) {
      initConnectivityAware(wrapper.onStatusChange);
    }
  }

  @override
  void onConnectionStatusChanged(ConnectionStatus status) {
    // Handle status changes here
    debugPrint('Connection status changed to: $status');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connectivity Example')),
      body: ConnectivityBuilder(
        builder: (context, status) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  status.isConnected ? Icons.wifi : Icons.wifi_off,
                  size: 64,
                  color: status.isConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  status.description,
                  style: const TextStyle(fontSize: 24),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}