import 'dart:async';
import 'package:get/get.dart';

/// 事件基类 - 所有事件都应该继承此类
abstract class BaseEvent {
  final DateTime timestamp;
  final String eventId;

  BaseEvent() 
    : timestamp = DateTime.now(),
      eventId = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  String toString() => 'Event(${runtimeType}, $eventId, $timestamp)';
}

/// 应用事件总线 - 全局事件通信中心
class AppEventBus {
  static final AppEventBus _instance = AppEventBus._internal();
  factory AppEventBus() => _instance;
  AppEventBus._internal();

  static AppEventBus get instance => _instance;

  final StreamController<BaseEvent> _eventController = StreamController<BaseEvent>.broadcast();

  /// 事件流
  Stream<BaseEvent> get eventStream => _eventController.stream;

  /// 发送事件
  void fire(BaseEvent event) {
    print('[EventBus] Fire event: $event');
    _eventController.add(event);
  }

  /// 监听特定类型的事件
  Stream<T> on<T extends BaseEvent>() {
    return eventStream.where((event) => event is T).cast<T>();
  }

  /// 销毁事件总线
  void dispose() {
    _eventController.close();
  }
}

/// 事件监听混入 - 为GetX控制器提供事件管理能力
mixin EventMixin on GetxController {
  final Set<StreamSubscription> _subscriptions = {};

  /// 注册事件监听，并自动管理生命周期
  void listen<T extends BaseEvent>(
    void Function(T event) onEvent, {
    void Function(Object error)? onError,
    bool Function(T event)? filter,
  }) {
    final subscription = AppEventBus.instance.on<T>().listen(
      (event) {
        print('[EventMixin] 📡 Received event: $event');
        if (filter == null || filter(event)) {
          try {
            onEvent(event);
          } catch (e) {
            print('[EventMixin] Error handling event $event: $e');
            onError?.call(e);
          }
        }
      },
      onError: onError,
    );
    _subscriptions.add(subscription);
  }

  /// 一次性监听事件
  void listenOnce<T extends BaseEvent>(
    void Function(T event) onEvent, {
    bool Function(T event)? filter,
  }) {
    late StreamSubscription subscription;
    subscription = AppEventBus.instance.on<T>().listen((event) {
      print('[EventMixin] 📡 Received event (once): $event');
      if (filter == null || filter(event)) {
        try {
          onEvent(event);
        } catch (e) {
          print('[EventMixin] Error handling one-time event $event: $e');
        }
        subscription.cancel();
        _subscriptions.remove(subscription);
      }
    });
    _subscriptions.add(subscription);
  }

  /// 发送事件的便捷方法
  void fireEvent(BaseEvent event) {
    AppEventBus.instance.fire(event);
  }

  /// 取消特定事件监听
  void cancelEventListening() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  @override
  void onClose() {
    cancelEventListening();
    super.onClose();
  }
}

/// 预定义的常用事件类型

/// 登录成功事件
class LoginSuccessEvent extends BaseEvent {
  final String userId;
  final String username;

  LoginSuccessEvent({required this.userId, required this.username});

  @override
  String toString() => 'LoginSuccessEvent(userId: $userId, username: $username)';
}

/// 登出事件
class LogoutEvent extends BaseEvent {
  final String reason;

  LogoutEvent({this.reason = 'User logout'});

  @override
  String toString() => 'LogoutEvent(reason: $reason)';
}

/// 网络状态变化事件
class NetworkStatusChangedEvent extends BaseEvent {
  final bool isConnected;
  final String connectionType;

  NetworkStatusChangedEvent({
    required this.isConnected,
    this.connectionType = 'unknown',
  });

  @override
  String toString() => 'NetworkStatusChangedEvent(connected: $isConnected, type: $connectionType)';
}

/// 主题变化事件
class ThemeChangedEvent extends BaseEvent {
  final String themeName;
  final bool isDark;

  ThemeChangedEvent({required this.themeName, required this.isDark});

  @override
  String toString() => 'ThemeChangedEvent(theme: $themeName, isDark: $isDark)';
}

/// 语言变化事件
class LanguageChangedEvent extends BaseEvent {
  final String languageCode;
  final String? countryCode;

  LanguageChangedEvent({required this.languageCode, this.countryCode});

  @override
  String toString() => 'LanguageChangedEvent(language: $languageCode, country: $countryCode)';
}

/// 数据刷新事件
class DataRefreshEvent extends BaseEvent {
  final String dataType;
  final Map<String, dynamic>? metadata;

  DataRefreshEvent({required this.dataType, this.metadata});

  @override
  String toString() => 'DataRefreshEvent(dataType: $dataType, metadata: $metadata)';
}
