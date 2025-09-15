# connectivity_plus_wrapper 🌐

[![pub package](https://img.shields.io/pub/v/connectivity_plus_wrapper.svg)](https://pub.dev/packages/connectivity_plus_wrapper)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.0.0-blue)](https://flutter.dev)

**A smarter, more insightful Flutter connectivity package.** Goes beyond basic online/offline detection to provide meaningful connection statuses, quality analysis, and seamless transition handling.

Stop guessing your app's connection state. Start understanding it.

---

## 🌟 Why Choose This Package?

Most connectivity packages answer one question: *"Am I online?"* This package answers the much more important questions:

*   *"Is my connection good enough to make an API call?"* 🚀
*   *"Did the connection just come back after being lost?"* 🔄
*   *"Is the user on an unstable WiFi network?"* 📶
*   *"How long was the user offline for?"* ⏱️

### Feature Comparison

| Feature | `connectivity_plus` | `internet_connection_checker` | `connectivity_plus_wrapper` |
|:---|:---:|:---:|:---:|
| Basic Connectivity (WiFi, Mobile) | ✅ | ❌ | ✅ |
| Real Internet Access Check | ❌ | ✅ | ✅ |
| **Smart Statuses** (Unstable, Restored, Roaming) | ❌ | ❌ | ✅ |
| **Transition Tracking** (with duration) | ❌ | ❌ | ✅ |
| **Quality-Based Analysis** | ❌ | ❌ | ✅ |
| Pre-built UI Widgets | ❌ | ❌ | ✅ |
| Customizable Test Servers | ❌ | ❌ | ✅ |

---

## 💡 Getting Started

### Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  connectivity_plus_wrapper: ^1.0.0
```

### Basic Usage

Initialize the wrapper (ensure bindings are initialized first).

Listen to the stream of smart statuses.

React meaningfully in your UI.

```dart
import 'package:connectivity_plus_wrapper/connectivity_plus_wrapper.dart';

void main() {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ConnectivityWrapper connectivityWrapper;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
  }

  Future<void> _initializeConnectivity() async {
    connectivityWrapper = ConnectivityWrapper();
    await connectivityWrapper.init(); // Initialize after bindings are ready
    setState(() => _isInitialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) return const CircularProgressIndicator();

    return MaterialApp(
      home: DefaultConnectivityWrapper(
        connectivityWrapper: connectivityWrapper,
        child: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  status.description, // User-friendly description
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
```

---

## 🧠 Core Concepts & API

### Smart Statuses (ConnectionStatus)
We provide nuanced statuses that actually help you decide what to do in your app.

| Status | Description | Use Case Example |
|--------|-------------|------------------|
| disconnected | No internet access. | Disable sync buttons, show offline message. |
| connected | Stable, reliable connection. | Proceed with high-bandwidth operations. |
| restored | Internet access was just regained. | Retry failed requests, refresh data. |
| unstable | Connection is intermittent or slow. | Avoid large downloads, warn the user. |
| roaming | Connected via mobile data in roaming. | Warn about potential costs before downloading. |
| checking | Briefly shown while assessing connection quality. | Show a loading indicator. |

### Tracking Transitions (ConnectionTransition)

Understand the story behind the connection change, not just the new state.

```dart
// Listen to rich transition events
connectivityWrapper.onTransition.listen((transition) {
  debugPrint('Went from ${transition.from} to ${transition.to}');
  debugPrint('Was offline for: ${transition.duration}');

  if (transition.isRestored) {
    // Re-sync data after being offline for 2 minutes
    if (transition.duration > const Duration(minutes: 2)) {
      refreshAppData();
    }
  }
});
```

---

## 🛠️ Advanced Usage

### Custom Configuration

Tweak the package to your app's needs.

```dart
// Create a customized wrapper
final customWrapper = ConnectivityWrapper(
  testServers: [
    'https://your-api.com/health', // Ping your own server first
    'https://www.google.com',
  ],
  unstableThreshold: const Duration(seconds: 5), // How long before 'restored' becomes 'connected'
  checkInterval: const Duration(seconds: 3), // How often to check quality
);

// Add more servers later
customWrapper.addTestServers(['https://cloudflare.com']);
```

### ConnectivityAware Mixin

Make any Stateful Widget automatically react to connection changes.

```dart
class MyDataScreen extends StatefulWidget {
  const MyDataScreen({super.key});

  @override
  State<MyDataScreen> createState() => _MyDataScreenState();
}

class _MyDataScreenState extends State<MyDataScreen> with ConnectivityAware<MyDataScreen> {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final wrapper = DefaultConnectivityWrapper.of(context)!.connectivityWrapper;
    initConnectivityAware(wrapper.onStatusChange); // Initialize the mixin
  }

  @override
  void onConnectionStatusChanged(ConnectionStatus status) {
    // This method is called every time the status changes
    if (status == ConnectionStatus.restored) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Welcome back online! Data refreshed.')),
      );
      loadData(); // Reload data when connection is restored
    }
  }

  @override
  Widget build(BuildContext context) {
    // Your widget build method...
  }
}
```

### ConnectivityOverlay Widget

Add a sleek, automatic overlay that informs users about their connection status without blocking your UI.

```dart
return ConnectivityOverlay(
  child: YourAppContent(), // Your normal app scaffold
  showDuration: const Duration(seconds: 4), // How long to show non-critical statuses
);
```

![Overlay Example](https://placehold.co/600x200/EEE/31343C?text=Unstable+Connection+%25F0%259F%2594%25A8)

---

## 📚 Full API Reference

### ConnectivityWrapper

The main class to manage connectivity status.

| Method / Getter | Description |
|-----------------|-------------|
| `Future<void> init()` | Initializes the plugin. Must be called! |
| `Stream<ConnectionStatus> onStatusChange` | Stream of smart connection statuses. |
| `Stream<ConnectionTransition> onTransition` | Stream of transitions between statuses. |
| `Future<ConnectionStatus> get currentStatus` | Gets the current status (async). |
| `Future<bool> get isReallyConnected` | Checks for a real, usable internet connection. |
| `void addTestServers(List<String> urls)` | Adds custom URLs to check for internet quality. |
| `void configureTiming({...})` | Configures timing thresholds for status changes. |
| `void dispose()` | Stops all listeners and timers. |

---

## 🚀 Use Cases

- **E-commerce App**: Prevent orders from being placed with an unstable connection. Refresh the cart automatically when connection is restored.
- **Video Streaming App**: Warn users about potential buffering on unstable connections. Pause downloads if status changes to roaming.
- **News App**: Cache articles on disconnected. Retry failed image loads automatically on restored.
- **Finance App**: Block transactions or show a strong warning on any connection that isn't connected.

---

## 🤝 Contributing

We love contributions! Please feel free to open issues, suggest features, and submit pull requests. Let's make this package even better together.

1. Fork the project.
2. Create your feature branch (`git checkout -b feature/amazing-feature`).
3. Commit your changes (`git commit -m 'Add some amazing feature'`).
4. Push to the branch (`git push origin feature/amazing-feature`).
5. Open a Pull Request.

---

## 📄 License

This project is licensed under the MIT License. See the LICENSE file for details.

---

## 🙏 Acknowledgments

- Built upon the great work of the connectivity_plus and internet_connection_checker packages.
- Made with ❤️ for the Flutter community.

Questions? Feel free to open an issue on GitHub!