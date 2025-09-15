# Connectivity Plus Wrapper 🌐

[![Pub Version](https://img.shields.io/pub/v/connectivity_plus_wrapper)](https://pub.dev/packages/connectivity_plus_wrapper)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.0.0-blue)](https://flutter.dev/)

**A smarter connectivity solution for Flutter that goes beyond basic connection detection**

Tired of simply knowing if a user is "connected" or "disconnected"? `connectivity_plus_wrapper` provides intelligent connection statuses, meaningful transitions, and ready-to-use widgets for superior network handling in your Flutter applications.

## 🌟 Why Choose This Package?

| Feature | `connectivity_plus` | `internet_connection_checker` | `connectivity_plus_wrapper` |
|---------|---------------------|-------------------------------|-----------------------------|
| Basic connectivity states | ✅ | ✅ | ✅ |
| **Smart statuses** (unstable, restored, roaming) | ❌ | ❌ | ✅ |
| **Connection quality assessment** | ❌ | ⚠️ Limited | ✅ Advanced |
| **Transition tracking** with timing | ❌ | ❌ | ✅ |
| **Ready-to-use widgets** | ❌ | ❌ | ✅ |
| **Customizable test servers** | ❌ | ⚠️ Limited | ✅ |
| **Connection analytics** | ❌ | ❌ | ✅ |

## 🚀 Features

### 🤖 Intelligent Connection Statuses
Go beyond basic connected/disconnected states with our smart status system:

```dart
enum ConnectionStatus {
  disconnected,    // No internet connection
  connected,       // Stable and reliable connection
  restored,        // Connection recently restored after disruption
  unstable,        // Intermittent or poor quality connection
  roaming,         // Mobile data in roaming mode
  checking,        // Quality assessment in progress
}
