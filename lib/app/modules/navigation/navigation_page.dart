import 'package:cat_zson_pro/app/core/framework/cat_framework.dart';
import 'package:cat_zson_pro/app/core/i18n/translation_keys.dart';
import 'package:cat_zson_pro/app/modules/home/home_page.dart';
import 'package:cat_zson_pro/app/modules/navigation/responsive_navigation.dart';
import 'package:cat_zson_pro/app/modules/support/support_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/framework/page_lifecycle.dart';
import '../../routes/app_routes.dart';
import '../dashboard/dashboard_page.dart';
import '../marketing/marketing_page.dart';
import '../orders/orders_page.dart';
import '../profile/profile_page.dart';
import '../users/users_page.dart';
import 'navigation_controller.dart';

/// 主布局页面 - 展示响应式框架的最佳实践
class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  @override
  void initState() {
    super.initState();
    // 初始化页面工厂
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePageFactories();
      final controller = Get.find<NavigationController>();
      if (controller.currentRoute.value.isEmpty) {
        controller.navigateTo(AppRoutes.dashboard);
      }
    });
  }
  
  /// 初始化页面工厂
  void _initializePageFactories() {
    final controller = Get.find<NavigationController>();
    
    // 注册页面工厂
    controller.registerPageFactories({
      AppRoutes.dashboard: {
        'factory': () => const DashboardPage(),
        'config': PageConfig.highPriority, // 仪表板高优先级
      },
      AppRoutes.analytics: {
        'factory': () => const AnalyticsPage(),
        'config': PageConfig.defaultConfig,
      },
      AppRoutes.products: {
        'factory': () => const ProductsPage(),
        'config': PageConfig.defaultConfig,
      },
      AppRoutes.users: {
        'factory': () => const UsersPage(),
        'config': PageConfig.defaultConfig,
      },
      AppRoutes.orders: {
        'factory': () => const OrdersPage(),
        'config': PageConfig.defaultConfig,
      },
      AppRoutes.marketing: {
        'factory': () => const MarketingPage(),
        'config': PageConfig.lowPriority, // 营销页面低优先级
      },
      AppRoutes.support: {
        'factory': () => const SupportPage(),
        'config': PageConfig.defaultConfig,
      },
      AppRoutes.settings: {
        'factory': () => const SettingsPage(),
        'config': PageConfig.lowPriority, // 设置页面低优先级
      },
      AppRoutes.profile: {
        'factory': () => const ProfilePage(),
        'config': PageConfig.defaultConfig,
      },
    });
  }

  @override
  Widget build(BuildContext context) {
    return CatResponsiveScaffold(
      navigationItems: _buildNavigationItems(),
      config: _buildNavigationConfig(context),
      onRouteChanged: (route) {
        debugPrint('Route changed to: $route');
      },
      title: 'Cat Framework',
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => _refreshCurrentPage(),
          tooltip: '刷新当前页面',
        ),
        IconButton(
          icon: const Icon(Icons.brightness_6),
          onPressed: () => _showThemeSelector(context),
          tooltip: '切换主题',
        ),
        IconButton(
          icon: const Icon(Icons.language),
          onPressed: () => _showLanguageSelector(context),
          tooltip: '切换语言',
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) => _handleMenuAction(context, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'cache_stats',
              child: ListTile(
                leading: Icon(Icons.analytics),
                title: Text('缓存统计'),
                dense: true,
              ),
            ),
            const PopupMenuItem(
              value: 'clear_cache',
              child: ListTile(
                leading: Icon(Icons.clear_all),
                title: Text('清除缓存'),
                dense: true,
              ),
            ),
          ],
        ),
      ],
      body: _buildMainContent(),
    );
  }

  /// 构建导航项
  List<NavigationItem> _buildNavigationItems() {
    return [
      NavigationItem(
        icon: Icons.dashboard_outlined,
        label: TranslationKeys.dashboard,
        route: AppRoutes.dashboard,
      ),
      NavigationItem(
        icon: Icons.analytics_outlined,
        label: TranslationKeys.dataAnalysis,
        route: AppRoutes.analytics,
      ),
      NavigationItem(
        icon: Icons.inventory_2_outlined,
        label: TranslationKeys.productManagement,
        route: AppRoutes.products,
      ),
      NavigationItem(
        icon: Icons.people_outline,
        label: TranslationKeys.userManagement,
        route: AppRoutes.users,
      ),
      NavigationItem(
        icon: Icons.shopping_cart_outlined,
        label: TranslationKeys.orderManagement,
        route: AppRoutes.orders,
      ),
      NavigationItem(
        icon: Icons.campaign_outlined,
        label: TranslationKeys.marketingCenter,
        route: AppRoutes.marketing,
      ),
      NavigationItem(
        icon: Icons.support_agent_outlined,
        label: TranslationKeys.customerService,
        route: AppRoutes.support,
      ),
      NavigationItem(
        icon: Icons.settings_outlined,
        label: TranslationKeys.systemSettings,
        route: AppRoutes.settings,
      ),
    ];
  }

  /// 构建导航配置（简化版：移除复杂自定义内容）
  NavigationConfig _buildNavigationConfig(BuildContext context) {
    return NavigationConfig(
      extendedWidth: 280,
      collapsedWidth: 72,
      drawerWidth: 300,
      animationDuration: const Duration(milliseconds: 250),
      showToggleButton: false,
      // 不显示侧边栏内的toggle按钮，统一用AppBar的menu
      appName: 'Cat Framework',
      logo: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [
              Theme
                  .of(context)
                  .primaryColor,
              Theme
                  .of(context)
                  .primaryColor
                  .withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Icon(
          Icons.pets,
          color: Colors.white,
          size: 24,
        ),
      ),
      // 简化：使用简单的header，避免复杂布局
      headerBuilder: (context, extended) =>
          _buildSimpleHeader(context, extended),
      // 简化：不使用footer，避免布局问题
      footerBuilder: null,
    );
  }

  /// 优雅的header实现（使用FittedBox自动缩放，零硬编码）
  Widget _buildSimpleHeader(BuildContext context, bool extended) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: extended
          ? FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.pets, size: 32,),
                  const SizedBox(width: 12),
                  Text(
                    'Cat Framework',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : Center(child: Icon(Icons.pets,size: 24,)),
    );
  }


  /// 构建主内容区
  Widget _buildMainContent() {
    var controller = Get.find<NavigationController>();
    
    // 判断是否为Mobile端
    final isMobile = ResponsiveBreakpoints.of(context).smallerThan(TABLET);
    
    if (isMobile) {
      // Mobile端：使用简单的Container，让内容自然滚动
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        child: Obx(() {
          return controller.getPageForRoute(controller.currentRoute.value);
        }),
      );
    } else {
      // Tablet/Desktop端：使用ResponsiveRowColumn
      return ResponsiveRowColumn(
        layout: ResponsiveRowColumnType.ROW,
        children: [
          ResponsiveRowColumnItem(
            rowFlex: 1,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              child: Obx(() {
                return controller.getPageForRoute(controller.currentRoute.value);
              }),
            ),
          ),
        ],
      );
    }
  }

  /// 刷新当前页面
  void _refreshCurrentPage() {
    final controller = Get.find<NavigationController>();
    controller.refreshCurrentPage();
    Cat.notify.showSuccess(message: "页面已刷新");
  }
  
  /// 处理菜单操作
  void _handleMenuAction(BuildContext context, String action) {
    final controller = Get.find<NavigationController>();
    
    switch (action) {
      case 'cache_stats':
        _showCacheStats(context, controller);
        break;
      case 'clear_cache':
        _showClearCacheDialog(context, controller);
        break;
    }
  }
  
  /// 显示缓存统计信息
  void _showCacheStats(BuildContext context, NavigationController controller) {
    final stats = controller.getCacheStats();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('缓存统计'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('总缓存数量: ${stats['totalCached']}'),
              Text('最大缓存数量: ${stats['maxCacheSize']}'),
              Text('当前路由: ${stats['currentRoute']}'),
              const SizedBox(height: 16),
              const Text('页面详情:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...((stats['pages'] as Map<String, dynamic>).entries.map((entry) {
                final pageInfo = entry.value as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${entry.key}:', style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text('  优先级: ${pageInfo['priority']}'),
                      Text('  空闲时间: ${(pageInfo['idleTime'] / 1000).toStringAsFixed(1)}s'),
                      Text('  已过期: ${pageInfo['isExpired']}'),
                    ],
                  ),
                );
              }).toList()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
  
  /// 显示清除缓存对话框
  void _showClearCacheDialog(BuildContext context, NavigationController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清除所有页面缓存吗？这将重新加载所有页面数据。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.clearAllPageCache();
              Cat.notify.showSuccess(message: "缓存已清除");
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 处理退出登录
  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('确认退出'),
            content: const Text('确定要退出登录吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // 实现退出登录逻辑
                },
                child: const Text('确定'),
              ),
            ],
          ),
    );
  }

  void _showThemeSelector(BuildContext context) {
    final themeService = Cat.theme;
    if (themeService == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Light Mode'),
              leading: const Icon(Icons.light_mode),
              onTap: () {
                themeService.enableLightMode();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Dark Mode'),
              leading: const Icon(Icons.dark_mode),
              onTap: () {
                themeService.enableDarkMode();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Follow System'),
              leading: const Icon(Icons.settings_system_daydream),
              onTap: () {
                themeService.followSystem();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    final translationService = Cat.i18n;
    if (translationService == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: translationService.languages.entries.map((entry) {
            return ListTile(
              title: Text(entry.key),
              onTap: () {
                translationService.changeLocale(
                  entry.value.languageCode,
                  entry.value.countryCode,
                );
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

}