import 'package:cat_zson_pro/app/core/framework/cat_framework.dart';
import 'package:cat_zson_pro/app/core/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../storage/storage_repository.dart';
import '../event/event_bus.dart';
import '../../utils/logger.dart';

/// 主题配置
class AppThemeConfig {
  final String name;
  final String displayName;
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final bool supportsDarkMode;

  const AppThemeConfig({
    required this.name,
    required this.displayName,
    required this.lightTheme,
    required this.darkTheme,
    this.supportsDarkMode = true,
  });
}

/// 主题服务
class ThemeService extends GetxService implements Initializable{
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyThemeName = 'theme_name';

  late final KeyValueStorageRepository _storage;
  final RxString currentThemeName = 'default'.obs;
  final Rx<ThemeMode> currentThemeMode = ThemeMode.system.obs;
  final Map<String, AppThemeConfig> _themes = {};

  /// 初始化主题服务
  @override
  Future<void> init() async {
    // 初始化存储
    final storageManager = StorageManager.instance;
    await storageManager.initStorage('theme_settings');
    _storage = storageManager.createKeyValueRepository(containerName: 'theme_settings');

    // 注册默认主题
    _registerDefaultThemes();
    // 读取保存的主题设置
    final savedThemeMode = _storage.readString(_keyThemeMode);
    final savedThemeName = _storage.readString(_keyThemeName);

    if (savedThemeMode != null) {
      currentThemeMode.value = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == savedThemeMode,
        orElse: () => ThemeMode.system,
      );
    }
    if (savedThemeName != null && _themes.containsKey(savedThemeName)) {
      currentThemeName.value = savedThemeName;
    }
    // 应用主题
    _applyTheme();
  }

  @override
  Future<void> dispose() {
    return Future.value();
  }

  /// 切换主题模式
  void changeThemeMode(ThemeMode mode) {
    currentThemeMode.value = mode;
    _storage.writeString(_keyThemeMode, mode.toString());
    _applyTheme();
    
    // 发送主题变化事件
    AppEventBus.instance.fire(ThemeChangedEvent(
      themeName: currentThemeName.value,
      isDark: _isDarkMode(),
    ));
  }

  /// 切换主题
  void changeTheme(String themeName) {
    if (!_themes.containsKey(themeName)) {
      logger.w('Theme not found: $themeName');
      return;
    }

    currentThemeName.value = themeName;
    _storage.writeString(_keyThemeName, themeName);
    _applyTheme();

    // 发送主题变化事件
    AppEventBus.instance.fire(ThemeChangedEvent(
      themeName: themeName,
      isDark: _isDarkMode(),
    ));
  }

  /// 切换到深色模式
  void enableDarkMode() {
    changeThemeMode(ThemeMode.dark);
  }

  /// 切换到浅色模式
  void enableLightMode() {
    changeThemeMode(ThemeMode.light);
  }

  /// 跟随系统
  void followSystem() {
    changeThemeMode(ThemeMode.system);
  }

  /// 获取当前是否为深色模式
  bool get isDarkMode => _isDarkMode();

  /// 获取可用的主题列表
  List<AppThemeConfig> get availableThemes => _themes.values.toList();

  /// 获取当前主题配置
  AppThemeConfig? get currentThemeConfig => _themes[currentThemeName.value];

  /// 注册自定义主题
  void registerTheme(AppThemeConfig themeConfig) {
    _themes[themeConfig.name] = themeConfig;
    logger.i('Registered theme: ${themeConfig.name}');
  }

  /// 移除主题
  void removeTheme(String themeName) {
    if (themeName == 'default') {
      logger.w('Cannot remove default theme');
      return;
    }

    _themes.remove(themeName);
    
    // 如果当前主题被移除，切换到默认主题
    if (currentThemeName.value == themeName) {
      changeTheme('default');
    }
  }

  // 私有方法
  void _registerDefaultThemes() {
    // 默认主题
    registerTheme(AppThemeConfig(
      name: 'default',
      displayName: 'Default',
      lightTheme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
    ));

    // 蓝色主题
    registerTheme(AppThemeConfig(
      name: 'blue',
      displayName: 'Blue',
      lightTheme: _buildLightTheme(primaryColor: Colors.blue),
      darkTheme: _buildDarkTheme(primaryColor: Colors.blue),
    ));

    // 绿色主题
    registerTheme(AppThemeConfig(
      name: 'green',
      displayName: 'Green',
      lightTheme: _buildLightTheme(primaryColor: Colors.green),
      darkTheme: _buildDarkTheme(primaryColor: Colors.green),
    ));
  }

  ThemeData _buildLightTheme({Color? primaryColor}) {
    final primary = primaryColor ?? AppColors.primary;
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ),
      
      scaffoldBackgroundColor: AppColors.backgroundLight,
      
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        centerTitle: true,
      ),
      
      cardTheme: CardTheme(
        color: AppColors.surfaceLight,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme({Color? primaryColor}) {
    final primary = primaryColor ?? AppColors.primary;
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ),
      
      scaffoldBackgroundColor: AppColors.backgroundDark,
      
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        centerTitle: true,
      ),
      
      cardTheme: CardTheme(
        color: AppColors.surfaceDark,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  bool _isDarkMode() {
    switch (currentThemeMode.value) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return Get.isPlatformDarkMode;
    }
  }

  void _applyTheme() {
    final themeConfig = _themes[currentThemeName.value];
    if (themeConfig == null) return;

    final isDark = _isDarkMode();
    final theme = isDark ? themeConfig.darkTheme : themeConfig.lightTheme;
    
    Get.changeTheme(theme);
    logger.i('Applied theme: ${themeConfig.name} (${isDark ? 'dark' : 'light'})');
  }

}
