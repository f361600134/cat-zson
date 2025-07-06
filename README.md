# 🐱 Cat Framework

> A powerful, modular Flutter framework that provides enterprise-grade architecture patterns and reusable components.

Cat Framework is a sophisticated Flutter scaffolding framework designed to accelerate development while maintaining code quality and architectural integrity. Built with inspiration from the excellent design patterns found in production applications, it provides a solid foundation for building scalable Flutter applications.

## ✨ Features

### 🏗️ **Core Architecture**
- **Modular Design**: Clean separation of concerns with well-defined modules
- **Dependency Injection**: Powered by GetX for efficient service management
- **Type Safety**: Comprehensive use of Dart generics for runtime safety
- **Event-Driven**: Decoupled communication through a robust event bus system

### 📦 **Configuration Management**
- **Multi-Source Loading**: Support for local assets and remote configurations
- **Type-Safe Configs**: Generic-based configuration with compile-time safety
- **Hot Reloading**: MD5-based cache validation for remote configs
- **Lifecycle Management**: Automatic cleanup and memory management

### 🌐 **Network Layer**
- **Protocol Adapter Pattern**: Extensible HTTP client with plugin architecture
- **Plugin System**: Logging, retry, caching, and loading plugins
- **Type-Safe APIs**: Strongly-typed request/response handling
- **Error Handling**: Comprehensive error handling and recovery mechanisms

### 💾 **Storage Repository**
- **Multiple Patterns**: Single object, list, and key-value storage repositories
- **JSON Serialization**: Built-in support for complex object serialization
- **Container Management**: Isolated storage containers for different data types
- **Type Safety**: Generic-based storage with compile-time type checking

### ⚡ **Async Task Management**
- **Polling Service**: Configurable background task execution
- **Retry Logic**: Built-in retry mechanisms with exponential backoff
- **Status Tracking**: Real-time task status monitoring
- **Resource Management**: Automatic cleanup and lifecycle management

### 🎨 **UI & Theming**
- **Dynamic Themes**: Runtime theme switching with custom color schemes
- **Dark Mode**: Built-in light/dark mode support
- **Responsive Design**: Device-adaptive UI components
- **Notification System**: Beautiful, customizable toast notifications

### 🌍 **Internationalization**
- **Multi-Language**: Support for multiple languages with easy switching
- **Type-Safe Keys**: Compile-time validation of translation keys
- **Persistent Settings**: User language preferences are automatically saved
- **RTL Support**: Right-to-left language support

### 📡 **Event System**
- **Event Bus**: Global event communication system
- **Lifecycle Management**: Automatic subscription cleanup
- **Type Safety**: Strongly-typed event definitions
- **Filtering**: Event filtering and conditional handling

## 🚀 Quick Start

### Installation

Add Cat Framework dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.7.2
  get_storage: ^2.1.1
  http: ^1.2.2
  crypto: ^3.0.6
  json_annotation: ^4.9.0
  intl: ^0.19.0
  uuid: ^4.5.1

dev_dependencies:
  build_runner: ^2.4.14
  json_serializable: ^6.9.3
```

### Basic Setup

```dart
import 'package:flutter/material.dart';
import 'app/core/framework/cat_framework.dart';
import 'app/core/network/protocol_adapter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the framework
  await CatFramework.instance.initialize(
    config: const CatFrameworkConfig(
      appName: 'My App',
      enableLogging: true,
      enableEvents: true,
      enablePolling: true,
      enableThemes: true,
      enableI18n: true,
    ),
    networkPlugins: [
      LoggingPlugin(enableDetailLog: true),
      RetryPlugin(maxRetries: 3),
      CachePlugin(),
    ],
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CatFramework.instance.createApp(
      home: HomePage(),
      title: 'My Cat App',
    );
  }
}
```

## 📖 Usage Examples

### Configuration Management

```dart
// Define your configuration model
@JsonSerializable()
class AppConfig implements IConfig {
  final int id;
  final String apiUrl;
  final bool debugMode;

  AppConfig({required this.id, required this.apiUrl, required this.debugMode});
  
  factory AppConfig.fromJson(Map<String, dynamic> json) => _$AppConfigFromJson(json);
  Map<String, dynamic> toJson() => _$AppConfigToJson(this);
}

// Load configuration
await Cat.config.load<AppConfig>(
  LoadSource.local,
  'app_config.json',
  AppConfig.fromJson,
);

// Use configuration
final config = Cat.config.getUnique<AppConfig>();
print('API URL: ${config?.apiUrl}');
```

### Event System

```dart
// Define custom events
class UserLoginEvent extends BaseEvent {
  final String userId;
  UserLoginEvent(this.userId);
}

// In your controller
class MyController extends GetxController with EventMixin {
  @override
  void onInit() {
    super.onInit();
    
    // Listen to events
    listen<UserLoginEvent>((event) {
      print('User logged in: ${event.userId}');
    });
  }
  
  void loginUser() {
    // Fire events
    fireEvent(UserLoginEvent('user123'));
  }
}
```

### Storage Repository

```dart
// Define your data model
@JsonSerializable()
class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});
  
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

// Create repository
final userRepo = Cat.storage.createSingleRepository<User>(
  containerName: 'users',
  key: 'current_user',
);

// Store data
userRepo.write(
  item: User(id: '1', name: 'John', email: 'john@example.com'),
  toJson: (user) => user.toJson(),
);

// Read data
final user = userRepo.read(fromJson: User.fromJson);
```

### Polling Tasks

```dart
// Add polling task
Cat.polling?.addTask(
  config: const TaskConfig(
    taskId: 'sync_data',
    interval: Duration(seconds: 30),
    maxRetries: 3,
    timeout: Duration(seconds: 10),
  ),
  getStatus: (taskId) async {
    final response = await api.checkSyncStatus();
    return response.status;
  },
  isCompleted: (status) => status == 'completed',
  onUpdate: (taskId, status) {
    print('Sync status: $status');
  },
  onError: (taskId, error) {
    print('Sync error: $error');
  },
);
```

### Theme Management

```dart
// Switch themes
Cat.theme?.changeTheme('blue');
Cat.theme?.enableDarkMode();
Cat.theme?.followSystem();

// Register custom theme
Cat.theme?.registerTheme(AppThemeConfig(
  name: 'custom',
  displayName: 'Custom Theme',
  lightTheme: myLightTheme,
  darkTheme: myDarkTheme,
));
```

### Notifications

```dart
// Show notifications
Cat.notify.showSuccess(message: 'Operation completed!');
Cat.notify.showError(message: 'Something went wrong');
Cat.notify.showWarning(message: 'Please check your input');

// Custom notification
Cat.notify.show(NotificationConfig(
  title: 'Custom Title',
  message: 'Custom message',
  type: NotificationType.info,
  duration: Duration(seconds: 5),
  onTap: () => print('Notification tapped'),
  actionText: 'Action',
  onAction: () => print('Action pressed'),
));
```

## 🏗️ Architecture Overview

```
Cat Framework
├── Core Layer
│   ├── Configuration Management
│   ├── Event Bus System
│   ├── Storage Repository
│   ├── Network Protocol Adapter
│   ├── Async Task Management
│   └── Framework Initialization
├── Service Layer
│   ├── Theme Service
│   ├── Translation Service
│   ├── Notification Service
│   └── Polling Service
├── UI Layer
│   ├── Responsive Widgets
│   ├── Theme-Aware Components
│   └── Notification System
└── Utility Layer
    ├── Type-Safe Extensions
    ├── Helper Functions
    └── Constants
```

## 🎯 Design Principles

### 1. **Type Safety First**
- Extensive use of Dart generics
- Compile-time error prevention
- Runtime type validation

### 2. **Separation of Concerns**
- Clear module boundaries
- Single responsibility principle
- Loose coupling between components

### 3. **Lifecycle Management**
- Automatic resource cleanup
- Memory leak prevention
- Proper disposal patterns

### 4. **Plugin Architecture**
- Extensible design patterns
- Hot-swappable components
- Custom plugin development

### 5. **Developer Experience**
- Intuitive APIs
- Comprehensive error messages
- Rich debugging information

## 📚 Framework Components

### Core Components
- **ConfigManager**: Type-safe configuration management
- **EventBus**: Decoupled event communication
- **StorageRepository**: Generic data persistence
- **ProtocolAdapter**: Network request abstraction
- **PollingService**: Background task management

### Service Components
- **ThemeService**: Dynamic theme management
- **TranslationService**: Internationalization support
- **NotificationService**: User feedback system

### Utility Components
- **Cat**: Framework convenience accessor
- **Toast**: Quick notification methods
- **TranslationKeys**: Type-safe translation constants

## 🔧 Configuration Options

### Framework Configuration

```dart
const CatFrameworkConfig(
  appName: 'My App',
  enableLogging: true,           // Enable console logging
  enableEvents: true,            // Enable event bus system
  enablePolling: true,           // Enable polling service
  enableThemes: true,            // Enable theme management
  enableI18n: true,              // Enable internationalization
  supportedLocales: [            // Supported languages
    Locale('en', 'us'),
    Locale('zh', 'cn'),
    Locale('ja', 'jp'),
  ],
  fallbackLocale: Locale('en', 'us'),
  defaultStorageContainer: 'app_data',
);
```

## 🤝 Contributing

We welcome contributions! Here's how you can help:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- Inspired by excellent design patterns from production Flutter applications
- Built with ❤️ using Flutter and GetX
- Special thanks to the Flutter community for their amazing work

---

**Made with 🐱 by the Cat Framework Team**
