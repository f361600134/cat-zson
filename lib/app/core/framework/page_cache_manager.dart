import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'page_lifecycle.dart';

/// 缓存页面信息
class CachedPageInfo {
  final Widget page;
  final PageConfig config;
  final DateTime createdAt;
  DateTime lastAccessedAt;
  
  CachedPageInfo({
    required this.page,
    required this.config,
    required this.createdAt,
  }) : lastAccessedAt = createdAt;
  
  /// 更新访问时间
  void updateAccess() {
    lastAccessedAt = DateTime.now();
  }
  
  /// 是否已过期
  bool get isExpired {
    if (!config.keepAlive || config.maxIdleTime <= 0) return false;
    final now = DateTime.now();
    return now.difference(lastAccessedAt).inMilliseconds > config.maxIdleTime;
  }
  
  /// 空闲时间（毫秒）
  int get idleTime => DateTime.now().difference(lastAccessedAt).inMilliseconds;
}

/// 页面缓存管理器
class PageCacheManager extends GetxController {
  /// 页面缓存
  final Map<String, CachedPageInfo> _pageCache = {};
  
  /// 页面配置
  final Map<String, PageConfig> _pageConfigs = {};
  
  /// 页面工厂函数
  final Map<String, Widget Function()> _pageFactories = {};
  
  /// 当前显示的页面路由
  final RxString _currentRoute = ''.obs;
  
  /// 最大缓存数量
  static const int _maxCacheSize = 10;
  
  /// 定时清理定时器
  Timer? _cleanupTimer;
  
  @override
  void onInit() {
    super.onInit();
    // 启动定时清理（每2分钟检查一次）
    _startCleanupTimer();
  }
  
  @override
  void onClose() {
    _cleanupTimer?.cancel();
    _disposeAllPages();
    super.onClose();
  }
  
  /// 注册页面工厂
  void registerPageFactory(
    String route, 
    Widget Function() factory, 
    {PageConfig? config}
  ) {
    _pageFactories[route] = factory;
    _pageConfigs[route] = config ?? PageConfig.defaultConfig;
  }
  
  /// 批量注册页面工厂
  void registerPageFactories(Map<String, Map<String, dynamic>> factories) {
    factories.forEach((route, info) {
      final factory = info['factory'] as Widget Function();
      final config = info['config'] as PageConfig? ?? PageConfig.defaultConfig;
      registerPageFactory(route, factory, config: config);
    });
  }
  
  /// 获取页面
  Widget getPage(String route) {
    final config = _pageConfigs[route] ?? PageConfig.defaultConfig;
    
    // 如果不需要保活，直接创建新实例
    if (!config.keepAlive) {
      return _createPage(route);
    }
    
    // 检查缓存
    final cachedInfo = _pageCache[route];
    if (cachedInfo != null && !cachedInfo.isExpired) {
      cachedInfo.updateAccess();
      _handlePageShow(route, cachedInfo.page);
      return cachedInfo.page;
    }
    
    // 缓存不存在或已过期，创建新页面
    final newPage = _createPage(route);
    _cachePage(route, newPage, config);
    _handlePageShow(route, newPage);
    
    return newPage;
  }
  
  /// 创建页面
  Widget _createPage(String route) {
    final factory = _pageFactories[route];
    if (factory == null) {
      debugPrint('PageCacheManager: No factory found for route: $route');
      return Container(
        child: Center(
          child: Text('Page not found: $route'),
        ),
      );
    }
    
    try {
      return factory();
    } catch (e) {
      debugPrint('PageCacheManager: Error creating page for route $route: $e');
      return Container(
        child: Center(
          child: Text('Error loading page: $route'),
        ),
      );
    }
  }
  
  /// 缓存页面
  void _cachePage(String route, Widget page, PageConfig config) {
    // 检查缓存大小，如果超过限制则清理
    if (_pageCache.length >= _maxCacheSize) {
      _performLRUCleanup();
    }
    
    final info = CachedPageInfo(
      page: page,
      config: config,
      createdAt: DateTime.now(),
    );
    
    _pageCache[route] = info;
    debugPrint('PageCacheManager: Cached page for route: $route');
  }
  
  /// 处理页面显示
  void _handlePageShow(String route, Widget page) {
    final previousRoute = _currentRoute.value;
    _currentRoute.value = route;
    
    // 处理上一个页面的隐藏
    if (previousRoute.isNotEmpty && previousRoute != route) {
      _handlePageHide(previousRoute);
    }
    
    // 处理当前页面的显示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        // 由于Widget本身无法直接调用生命周期方法，
        // 我们通过通知机制或在页面内部处理
        debugPrint('PageCacheManager: Page $route is now showing');
        
        // 自动刷新数据的逻辑将在页面内部的onPageDidShow中处理
        final config = _pageConfigs[route] ?? PageConfig.defaultConfig;
        if (config.autoRefreshOnShow) {
          debugPrint('PageCacheManager: Auto refresh enabled for $route');
        }
      } catch (e) {
        debugPrint('PageCacheManager: Error handling page show for $route: $e');
      }
    });
  }
  
  /// 处理页面隐藏
  void _handlePageHide(String route) {
    final cachedInfo = _pageCache[route];
    if (cachedInfo != null) {
      try {
        debugPrint('PageCacheManager: Page $route is now hidden');
      } catch (e) {
        debugPrint('PageCacheManager: Error handling page hide for $route: $e');
      }
    }
  }
  
  /// LRU清理策略
  void _performLRUCleanup() {
    if (_pageCache.isEmpty) return;
    
    // 按最后访问时间和优先级排序
    final entries = _pageCache.entries.toList();
    entries.sort((a, b) {
      // 首先按优先级排序（低优先级先被清理）
      final priorityCompare = a.value.config.cachePriority.compareTo(b.value.config.cachePriority);
      if (priorityCompare != 0) return priorityCompare;
      
      // 相同优先级按访问时间排序（最久未访问的先被清理）
      return a.value.lastAccessedAt.compareTo(b.value.lastAccessedAt);
    });
    
    // 清理最低优先级的页面
    final toRemove = entries.first;
    _removePage(toRemove.key);
    
    debugPrint('PageCacheManager: LRU cleanup removed page: ${toRemove.key}');
  }
  
  /// 移除页面
  void _removePage(String route) {
    final cachedInfo = _pageCache.remove(route);
    if (cachedInfo != null) {
      try {
        debugPrint('PageCacheManager: Disposing page $route');
      } catch (e) {
        debugPrint('PageCacheManager: Error disposing page $route: $e');
      }
    }
  }
  
  /// 启动定时清理
  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      _performScheduledCleanup();
    });
  }
  
  /// 执行定时清理
  void _performScheduledCleanup() {
    final expiredRoutes = <String>[];
    
    _pageCache.forEach((route, info) {
      if (info.isExpired) {
        expiredRoutes.add(route);
      }
    });
    
    for (final route in expiredRoutes) {
      _removePage(route);
      debugPrint('PageCacheManager: Expired cleanup removed page: $route');
    }
  }
  
  /// 手动清理页面
  void clearPage(String route) {
    _removePage(route);
  }
  
  /// 清理所有页面
  void clearAllPages() {
    final routes = _pageCache.keys.toList();
    for (final route in routes) {
      _removePage(route);
    }
  }
  
  /// 强制刷新页面
  Future<void> refreshPage(String route, {bool force = false}) async {
    final cachedInfo = _pageCache[route];
    if (cachedInfo != null) {
      debugPrint('PageCacheManager: Refreshing page $route (force: $force)');
      // 刷新逻辑将由页面内部处理
    }
  }
  
  /// 刷新当前页面
  Future<void> refreshCurrentPage({bool force = false}) async {
    if (_currentRoute.value.isNotEmpty) {
      await refreshPage(_currentRoute.value, force: force);
    }
  }
  
  /// 销毁所有页面
  void _disposeAllPages() {
    final routes = _pageCache.keys.toList();
    for (final route in routes) {
      _removePage(route);
    }
  }
  
  /// 获取缓存统计信息
  Map<String, dynamic> getCacheStats() {
    final stats = <String, dynamic>{
      'totalCached': _pageCache.length,
      'maxCacheSize': _maxCacheSize,
      'currentRoute': _currentRoute.value,
      'pages': <String, Map<String, dynamic>>{},
    };
    
    _pageCache.forEach((route, info) {
      stats['pages'][route] = {
        'createdAt': info.createdAt.toIso8601String(),
        'lastAccessedAt': info.lastAccessedAt.toIso8601String(),
        'idleTime': info.idleTime,
        'isExpired': info.isExpired,
        'priority': info.config.cachePriority,
        'keepAlive': info.config.keepAlive,
      };
    });
    
    return stats;
  }
  
  /// 打印缓存统计信息
  void printCacheStats() {
    final stats = getCacheStats();
    debugPrint('PageCacheManager Stats: ${stats.toString()}');
  }
}

/// 扩展方法
extension PageCacheManagerExtension on GetInterface {
  /// 获取页面缓存管理器
  PageCacheManager get pageCache => Get.find<PageCacheManager>();
}
