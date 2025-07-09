import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sidebarx/sidebarx.dart';
import '../../core/framework/page_cache_manager.dart';
import '../../core/framework/page_lifecycle.dart';
import 'responsive_navigation.dart';

/// Cat Framework 导航控制器
class NavigationController extends GetxController {
  /// SidebarX 控制器
  late SidebarXController sidebarController;
  
  /// Scaffold Key (用于移动端抽屉)
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  
  /// 页面缓存管理器
  late PageCacheManager _pageCacheManager;
  
  /// 导航项列表
  final RxList<NavigationItem> navigationItems = <NavigationItem>[].obs;
  
  /// 当前选中索引
  final RxInt currentIndex = 0.obs;
  
  /// 当前路由
  final RxString currentRoute = ''.obs;
  
  /// 侧边栏是否展开
  final RxBool isSidebarExpanded = true.obs;
  
  /// 设备类型
  final RxBool isDesktop = false.obs;
  final RxBool isTablet = false.obs;
  final RxBool isMobile = false.obs;
  
  /// 路由历史栈 (用于返回功能)
  final RxList<String> routeHistory = <String>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    
    // 初始化页面缓存管理器
    _pageCacheManager = Get.put(PageCacheManager());
    
    // 初始化 SidebarX 控制器
    sidebarController = SidebarXController(
      selectedIndex: currentIndex.value,
      extended: isSidebarExpanded.value,
    );
    
    // 监听 SidebarX 选择变化
    sidebarController.addListener(_onSidebarSelectionChanged);
  }
  
  @override
  void onClose() {
    try {
      sidebarController.removeListener(_onSidebarSelectionChanged);
      sidebarController.dispose();
    } catch (e) {
      // 忽略 dispose 错误
    }
    super.onClose();
  }
  
  /// 设置导航项
  void setNavigationItems(List<NavigationItem> items) {
    navigationItems.value = items;
    // 不在这里自动导航，让外部控制首次导航
  }
  
  /// 注册页面工厂
  void registerPageFactory(
    String route, 
    Widget Function() factory, 
    {PageConfig? config}
  ) {
    _pageCacheManager.registerPageFactory(route, factory, config: config);
  }
  
  /// 批量注册页面工厂
  void registerPageFactories(Map<String, Map<String, dynamic>> factories) {
    _pageCacheManager.registerPageFactories(factories);
  }
  
  /// 获取页面（使用缓存管理）
  Widget getPageForRoute(String route) {
    return _pageCacheManager.getPage(route);
  }
  
  /// 初始化默认路由（只在需要时调用）
  void initializeDefaultRoute() {
    if (navigationItems.isNotEmpty && 
        navigationItems.first.route != null && 
        currentRoute.value.isEmpty) {
      navigateTo(navigationItems.first.route!);
    }
  }
  
  /// 更新设备类型
  void updateDeviceType({
    required bool isDesktop,
    required bool isTablet,
    required bool isMobile,
  }) {
    // 只在状态真正改变时才更新
    bool hasChanged = false;
    
    if (this.isDesktop.value != isDesktop) {
      this.isDesktop.value = isDesktop;
      hasChanged = true;
    }
    
    if (this.isTablet.value != isTablet) {
      this.isTablet.value = isTablet;
      hasChanged = true;
    }
    
    if (this.isMobile.value != isMobile) {
      this.isMobile.value = isMobile;
      hasChanged = true;
    }
    
    // 只在设备类型真正改变且是桌面端时才自动展开侧边栏
    if (hasChanged && isDesktop && !isSidebarExpanded.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        expandSidebar();
      });
    }
    // 如果变为 Mobile/Tablet 且 Sidebar 是展开状态，则自动收起
    if (hasChanged && (isMobile || isTablet) && isSidebarExpanded.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        collapseSidebar();
      });
    }
  }
  
  /// 切换侧边栏状态
  void toggleSidebar() {
    // 使用 WidgetsBinding.instance.addPostFrameCallback 确保在安全的时机执行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (isMobile.value) {
          // 移动端：打开/关闭抽屉
          if (scaffoldKey.currentState?.isDrawerOpen ?? false) {
            Get.back();
          } else {
            scaffoldKey.currentState?.openDrawer();
          }
        } else {
          // 桌面端和平板端：展开/收缩
          isSidebarExpanded.value = !isSidebarExpanded.value;
          sidebarController.setExtended(isSidebarExpanded.value);
        }
      } catch (e) {
        // 忽略切换错误
      }
    });
  }
  
  /// 展开侧边栏
  void expandSidebar() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (!isMobile.value) {
          isSidebarExpanded.value = true;
          sidebarController.setExtended(true);
        }
      } catch (e) {
        // 忽略展开错误
      }
    });
  }
  
  /// 收缩侧边栏
  void collapseSidebar() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (!isMobile.value) {
          isSidebarExpanded.value = false;
          sidebarController.setExtended(false);
        }
      } catch (e) {
        // 忽略收缩错误
      }
    });
  }
  
  /// 导航到指定路由
  void navigateTo(String route) {
    try {
      // 更新当前路由
      currentRoute.value = route;
      
      // 添加到历史记录
      if (routeHistory.isEmpty || routeHistory.last != route) {
        routeHistory.add(route);
        // 限制历史记录长度
        if (routeHistory.length > 10) {
          routeHistory.removeAt(0);
        }
      }
      
      // 查找对应的索引
      final index = navigationItems.indexWhere((item) => item.route == route);
      if (index != -1) {
        currentIndex.value = index;
        sidebarController.selectIndex(index);
      }
      
      // 不进行实际的路由跳转，只更新状态
      // 让MainLayout内部根据currentRoute.value来显示对应的页面
      
    } catch (e) {
      // 忽略导航错误
    }
  }
  
  /// 返回上一个路由
  void goBack() {
    if (routeHistory.length > 1) {
      routeHistory.removeLast(); // 移除当前路由
      final previousRoute = routeHistory.last;
      navigateTo(previousRoute);
    } else if (Get.previousRoute.isNotEmpty) {
      Get.back();
    }
  }
  
  /// 根据标签查找导航项
  NavigationItem? findItemByLabel(String label) {
    try {
      return navigationItems.firstWhere((item) => item.label == label);
    } catch (e) {
      return null;
    }
  }
  
  /// 根据路由查找导航项
  NavigationItem? findItemByRoute(String route) {
    try {
      return navigationItems.firstWhere((item) => item.route == route);
    } catch (e) {
      return null;
    }
  }
  
  /// 是否可以返回
  bool get canGoBack => routeHistory.length > 1;
  
  /// 获取当前导航项
  NavigationItem? get currentItem {
    if (currentIndex.value >= 0 && currentIndex.value < navigationItems.length) {
      return navigationItems[currentIndex.value];
    }
    return null;
  }
  
  /// SidebarX 选择变化回调
  void _onSidebarSelectionChanged() {
    try {
      final newIndex = sidebarController.selectedIndex;
      if (newIndex != currentIndex.value && 
          newIndex >= 0 && 
          newIndex < navigationItems.length) {
        final item = navigationItems[newIndex];
        if (item.route != null) {
          navigateTo(item.route!);
        }
      }
    } catch (e) {
      // 忽略选择变化的错误，可能是控制器已被销毁
    }
  }
  
  /// 刷新当前页面
  void refreshCurrentPage() {
    if (currentRoute.value.isNotEmpty) {
      _pageCacheManager.refreshCurrentPage();
    }
  }
  
  /// 刷新指定页面
  void refreshPage(String route, {bool force = false}) {
    _pageCacheManager.refreshPage(route, force: force);
  }
  
  /// 清除页面缓存
  void clearPageCache(String route) {
    _pageCacheManager.clearPage(route);
  }
  
  /// 清除所有页面缓存
  void clearAllPageCache() {
    _pageCacheManager.clearAllPages();
  }
  
  /// 获取缓存统计信息
  Map<String, dynamic> getCacheStats() {
    return _pageCacheManager.getCacheStats();
  }
  
  /// 打印缓存统计信息
  void printCacheStats() {
    _pageCacheManager.printCacheStats();
  }
  
  /// 清除导航历史
  void clearHistory() {
    routeHistory.clear();
    if (currentRoute.value.isNotEmpty) {
      routeHistory.add(currentRoute.value);
    }
  }
}

/// 导航控制器扩展方法
extension CatNavigationExtension on GetInterface {
  /// 获取导航控制器
  NavigationController? get navigation {
    try {
      return Get.find<NavigationController>();
    } catch (e) {
      return null;
    }
  }
}
