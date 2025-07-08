import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/navigation/responsive_navigation.dart';
import '../../routes/app_routes.dart';
import '../home/home_page.dart';

/// 主布局页面 - 展示响应式框架的最佳实践
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  @override
  void initState() {
    super.initState();
    // 初始化默认路由
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<CatNavigationController>();
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

  /// 简单的header实现（彻底避免溢出问题）
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 🎯 关键：基于实际可用宽度而不是extended状态判断
          final availableWidth = constraints.maxWidth;
          final minWidthForText = 32 + 12 + 80; // 图标+间距+最小文本宽度
          final canShowText = availableWidth >= minWidthForText;
          
          return canShowText
              ? Row(
                  children: [
                    Icon(
                      Icons.pets,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Cat Framework',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Icon(
                    Icons.pets,
                    size: 24,
                  ),
                );
        },
      ),
    );
  }


  // /// 自定义头部
  // Widget _buildCustomHeader(BuildContext context, bool extended) {
  //   return LayoutBuilder(
  //     builder: (context, constraints) {
  //       final availableWidth = constraints.maxWidth;
  //
  //       // 🎯 基于实际宽度计算布局参数，而不是extended状态
  //       final padding = availableWidth > 200 ? 16.0 : 8.0;
  //       final iconSize = availableWidth > 200 ? 40.0 : 32.0;
  //       final spacing = availableWidth > 200 ? 12.0 : 8.0;
  //
  //       // 计算文本是否有足够空间显示
  //       final textSpaceNeeded = padding * 2 + iconSize + spacing + 80; // 80px最小文本宽度
  //       final canShowText = availableWidth >= textSpaceNeeded;
  //
  //       return Container(
  //         width: availableWidth,
  //         padding: EdgeInsets.all(padding),
  //         decoration: BoxDecoration(
  //           border: Border(
  //             bottom: BorderSide(
  //               color: Theme.of(context).dividerColor.withOpacity(0.1),
  //               width: 1,
  //             ),
  //           ),
  //         ),
  //         child: Row(
  //           children: [
  //             Container(
  //               width: iconSize,
  //               height: iconSize,
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(availableWidth > 200 ? 8 : 6),
  //                 gradient: LinearGradient(
  //                   colors: [
  //                     Theme.of(context).primaryColor,
  //                     Theme.of(context).primaryColor.withOpacity(0.8),
  //                   ],
  //                   begin: Alignment.topLeft,
  //                   end: Alignment.bottomRight,
  //                 ),
  //               ),
  //               child: Icon(
  //                 Icons.pets,
  //                 color: Colors.white,
  //                 size: availableWidth > 200 ? 24 : 18,
  //               ),
  //             ),
  //             if (canShowText) ...[
  //               SizedBox(width: spacing),
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       'Cat Framework',
  //                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: availableWidth > 200 ? 16 : 14,
  //                       ),
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                     Text(
  //                       'v1.0.0',
  //                       style: Theme.of(context).textTheme.bodySmall?.copyWith(
  //                         color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
  //                         fontSize: availableWidth > 200 ? 12 : 10,
  //                       ),
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }


  /// 构建主内容区
  Widget _buildMainContent() {
    var controller = Get.find<CatNavigationController>();
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