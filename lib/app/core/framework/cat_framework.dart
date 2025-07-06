import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../config/config_manager.dart';
import '../storage/storage_repository.dart';
import '../async/async_task.dart';
import '../event/event_bus.dart';
import '../i18n/translation_service.dart';
import '../theme/theme_service.dart';
import '../network/protocol_adapter.dart';
import '../ui/notification_service.dart';
import '../../utils/logger.dart';

/// 框架配置
class CatFrameworkConfig {
  final String appName;
  final List<Locale> supportedLocales;
  final Locale fallbackLocale;
  final String defaultStorageContainer;

  const CatFrameworkConfig({
    this.appName = 'Cat Framework App',
    this.supportedLocales = const [
      Locale('en', 'us'),
      Locale('zh', 'cn'),
    ],
    this.fallbackLocale = const Locale('en', 'us'),
    this.defaultStorageContainer = 'cat_framework',
  });
}

/// Cat Framework - 核心框架类
class CatFramework {
  static final CatFramework _instance = CatFramework._internal();

  factory CatFramework() => _instance;

  CatFramework._internal();

  static CatFramework get instance => _instance;

  bool _isInitialized = false;
  late CatFrameworkConfig _config;

  /// 框架是否已初始化
  bool get isInitialized => _isInitialized;

  /// 获取框架配置
  CatFrameworkConfig get config => _config;

  /// 初始化框架
  Future<void> initialize({
    CatFrameworkConfig? config,
    List<AdapterPlugin>? networkPlugins,
    Map<String, dynamic>? customConfigs,
  }) async {
    if (_isInitialized) {
      logger.w('Framework already initialized');
      return;
    }

    _config = config ?? const CatFrameworkConfig();

    logger.i('Initializing Cat Framework...');

    try {
      // 初始化GetStorage
      await _initializeStorage();
      // 注册核心服务
      await _registerCoreServices();
      // 初始化网络层
      _initializeNetwork(networkPlugins);
      // 初始化轮询服务
      await _initializePolling();
      // 初始化多语言
      await _initializeI18n();
      // 初始化主题
      await _initializeThemes();
      // 加载自定义配置
      if (customConfigs != null) {
        await _loadCustomConfigs(customConfigs);
      }
      _isInitialized = true;
      logger.d('[CatFramework] Framework initialized successfully');
    } catch (e) {
      logger.e('[CatFramework] Framework initialization failed: $e');
      rethrow;
    }
  }

  /// 创建应用
  Widget createApp({
    required Widget home,
    String? title,
    Locale? locale,
    List<GetPage>? pages,
    String? initialRoute,
    Widget Function(BuildContext, Widget?)? builder,
    GlobalKey<NavigatorState>? navigatorKey,
    GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey,
  }) {
    if (!_isInitialized) {
      throw Exception(
          '[CatFramework] Framework not initialized. Call initialize() first.');
    }
    final themeService = Get.find<ThemeService>();
    return Obx(() {
      final currentConfig = themeService.currentThemeConfig;
      final themeMode = themeService.currentThemeMode.value;
      return GetMaterialApp(
        title: title ?? _config.appName,
        home: home,

        themeMode: themeMode,
        theme: currentConfig?.lightTheme,
        darkTheme: currentConfig?.darkTheme,

        locale: locale,
        fallbackLocale: _config.fallbackLocale,
        translations: Get.isRegistered<TranslationService>() ? Get.find<TranslationService>() : null,
        getPages: pages,
        initialRoute: initialRoute,
        builder: builder,
        navigatorKey: navigatorKey,
        scaffoldMessengerKey: scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
      );
    });
  }

  /// 销毁框架
  void dispose() {
    if (!_isInitialized) return;

    AppEventBus.instance.dispose();

    // 清理轮询服务
    Get.find<PollingService>().clearAllTasks();

    // 清理配置管理器
    ConfigManager().destroyAll();

    // 清理存储管理器
    StorageManager.instance.dispose();

    _isInitialized = false;
  }

  // 私有初始化方法
  Future<void> _initializeStorage() async {
    await GetStorage.init();

    // 初始化默认存储容器
    await StorageManager.instance.initStorage(_config.defaultStorageContainer);
  }

  /// 初始化核心服务
  Future<void> _registerCoreServices() async {
    // 注册网络客户端
    Get.put<GetConnect>(GetConnect(), permanent: true);
  }

  /// 初始化网络服务
  void _initializeNetwork(List<AdapterPlugin>? plugins) {
    final protocolClient = DefaultProtocolClient(plugins: plugins);
    Get.put<IProtocolClient>(protocolClient, permanent: true);
  }

  /// 初始化异步轮训服务
  Future<void> _initializePolling() async {
    await Get.putAsync(() async => PollingService(), permanent: true);
  }

  /// 初始化多语言服务
  Future<void> _initializeI18n() async {
    final translationService = TranslationService();
    await translationService.init();
    Get.put<TranslationService>(translationService, permanent: true);
  }

  /// 初始化主题服务
  Future<void> _initializeThemes() async {
    final themeService = ThemeService();
    await themeService.init();
    Get.put<ThemeService>(themeService, permanent: true);
  }

  /// 初始化自定义配置
  /// 当前配置适用于全局配置
  Future<void> _loadCustomConfigs(Map<String, dynamic> configs) async {
    for (final entry in configs.entries) {
      logger.d('Loaded config: ${entry.key}');
    }
  }
}

///初始化方法
abstract class Initializable {
  Future<void> init();
  Future<void> dispose();
}

/// 框架便捷访问类
class Cat {
  /// 获取框架实例
  static CatFramework get framework => CatFramework.instance;

  /// 获取存储管理器
  static StorageManager get storage => StorageManager.instance;

  /// 获取配置管理器
  static ConfigManager get config => ConfigManager();

  /// 获取事件总线
  static AppEventBus get events => AppEventBus.instance;

  /// 获取轮询服务
  static PollingService? get polling {
    try {
      return Get.find<PollingService>();
    } catch (e) {
      return null;
    }
  }

  /// 获取翻译服务
  static TranslationService? get i18n {
    try {
      return Get.find<TranslationService>();
    } catch (e) {
      return null;
    }
  }

  /// 获取主题服务
  static ThemeService? get theme {
    try {
      return Get.find<ThemeService>();
    } catch (e) {
      return null;
    }
  }

  /// 获取协议客户端
  static IProtocolClient? get network {
    try {
      return Get.find<IProtocolClient>();
    } catch (e) {
      return null;
    }
  }

  /// 快捷通知方法
  static NotificationService get notify => NotificationService.instance;

}
