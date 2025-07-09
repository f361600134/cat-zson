import 'package:cat_zson_pro/app/modules/navigation/responsive_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../routes/app_routes.dart';
import '../home/home_page.dart';
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
    // 初始化默认路由
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<NavigationController>();
      if (controller.currentRoute.value.isEmpty) {
        controller.navigateTo(AppRoutes.dashboard);
      }
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
          icon: const Icon(Icons.brightness_6),
          onPressed: () => _toggleTheme(),
          tooltip: '切换主题',
        ),
        IconButton(
          icon: const Icon(Icons.language),
          onPressed: () => _showLanguageDialog(context),
          tooltip: '切换语言',
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
        label: '仪表板',
        route: AppRoutes.dashboard,
      ),
      NavigationItem(
        icon: Icons.analytics_outlined,
        label: '数据分析',
        route: AppRoutes.analytics,
      ),
      NavigationItem(
        icon: Icons.inventory_2_outlined,
        label: '产品管理',
        route: AppRoutes.products,
      ),
      NavigationItem(
        icon: Icons.people_outline,
        label: '用户管理',
        route: AppRoutes.users,
      ),
      NavigationItem(
        icon: Icons.shopping_cart_outlined,
        label: '订单管理',
        route: AppRoutes.orders,
      ),
      NavigationItem(
        icon: Icons.campaign_outlined,
        label: '营销中心',
        route: AppRoutes.marketing,
      ),
      NavigationItem(
        icon: Icons.support_agent_outlined,
        label: '客户服务',
        route: AppRoutes.support,
      ),
      NavigationItem(
        icon: Icons.settings_outlined,
        label: '系统设置',
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
      // 🎯 简化：使用简单的header，避免复杂布局
      headerBuilder: (context, extended) =>
          _buildSimpleHeader(context, extended),
      // 🎯 简化：不使用footer，避免布局问题
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
    return ResponsiveRowColumn(
      layout: ResponsiveBreakpoints.of(Get.context!).smallerThan(TABLET)
          ? ResponsiveRowColumnType.COLUMN
          : ResponsiveRowColumnType.ROW,
      children: [
        ResponsiveRowColumnItem(
          rowFlex: 1,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            child: Obx(() {
              return _getPageForRoute(controller.currentRoute.value);
            }),
          ),
        ),
      ],
    );
  }

  /// 根据路由获取对应页面
  Widget _getPageForRoute(String route) {
    switch (route) {
      case AppRoutes.dashboard:
        return const DashboardPage();
      case AppRoutes.analytics:
        return const AnalyticsPage();
      case AppRoutes.products:
        return const ProductsPage();
      case AppRoutes.users:
        return const UsersPage();
      case AppRoutes.orders:
        return const OrdersPage();
      case AppRoutes.marketing:
        return const MarketingPage();
      case AppRoutes.support:
        return const SupportPage();
      case AppRoutes.settings:
        return const SettingsPage();
      default:
        return const DashboardPage();
    }
  }

  /// 切换主题
  void _toggleTheme() {
    // 实现主题切换逻辑
    debugPrint('Toggle theme');
  }

  /// 显示语言选择对话框
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('选择语言'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('中文'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('English'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
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

}