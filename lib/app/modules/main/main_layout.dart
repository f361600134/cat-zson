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

  /// 构建导航配置
  NavigationConfig _buildNavigationConfig(BuildContext context) {
    return NavigationConfig(
      extendedWidth: 280,
      collapsedWidth: 72,
      drawerWidth: 300,
      animationDuration: const Duration(milliseconds: 250),
      showToggleButton: true,
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
      headerBuilder: (context, extended) =>
          _buildCustomHeader(context, extended),
      footerBuilder: (context, extended) =>
          _buildCustomFooter(context, extended),
    );
  }

  Widget _buildCustomHeader(BuildContext context, bool extended) {
    if (!extended) {
      //  Drawer 模式：仅显示图标，完全规避布局问题
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.pets, color: Colors.white, size: 24),
        ),
      );
    }

    //  Extended 模式：显示完整 header
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.pets, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cat Framework',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // /// 自定义头部
  // Widget _buildCustomHeader(BuildContext context, bool extended) {
  //   if (!extended) {
  //     return Container(
  //       padding: const EdgeInsets.all(8),
  //       alignment: Alignment.center,
  //       child: Container(
  //         width: 40,
  //         height: 40,
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(8),
  //           gradient: LinearGradient(
  //             colors: [
  //               Theme.of(context).primaryColor,
  //               Theme.of(context).primaryColor.withOpacity(0.8),
  //             ],
  //             begin: Alignment.topLeft,
  //             end: Alignment.bottomRight,
  //           ),
  //         ),
  //         child: const Icon(
  //           Icons.pets,
  //           color: Colors.white,
  //           size: 24,
  //         ),
  //       ),
  //     );
  //   }
  //
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       border: Border(
  //         bottom: BorderSide(
  //           color: Theme
  //               .of(context)
  //               .dividerColor
  //               .withOpacity(0.1),
  //           width: 1,
  //         ),
  //       ),
  //     ),
  //     child: Row(
  //       children: [
  //         Container(
  //           width: 40,
  //           height: 40,
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(8),
  //             gradient: LinearGradient(
  //               colors: [
  //                 Theme
  //                     .of(context)
  //                     .primaryColor,
  //                 Theme
  //                     .of(context)
  //                     .primaryColor
  //                     .withOpacity(0.8),
  //               ],
  //               begin: Alignment.topLeft,
  //               end: Alignment.bottomRight,
  //             ),
  //           ),
  //           child: const Icon(
  //             Icons.pets,
  //             color: Colors.white,
  //             size: 24,
  //           ),
  //         ),
  //         if (extended) ...[
  //           const SizedBox(width: 12),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   'Cat Framework',
  //                   style: Theme
  //                       .of(context)
  //                       .textTheme
  //                       .titleMedium
  //                       ?.copyWith(
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //                 Text(
  //                   'v1.0.0',
  //                   style: Theme
  //                       .of(context)
  //                       .textTheme
  //                       .bodySmall
  //                       ?.copyWith(
  //                     color: Theme
  //                         .of(context)
  //                         .colorScheme
  //                         .onSurface
  //                         .withOpacity(0.6),
  //                     overflow: TextOverflow.ellipsis,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ],
  //     ),
  //   );
  // }

  // /// 自定义底部
  // Widget _buildCustomFooter(BuildContext context, bool extended) {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       border: Border(
  //         top: BorderSide(
  //           color: Theme
  //               .of(context)
  //               .dividerColor
  //               .withOpacity(0.1),
  //           width: 1,
  //         ),
  //       ),
  //     ),
  //     child: Row(
  //       children: [
  //         CircleAvatar(
  //           radius: extended ? 20 : 16,
  //           backgroundColor: Theme
  //               .of(context)
  //               .primaryColor
  //               .withOpacity(0.1),
  //           child: Icon(
  //             Icons.person,
  //             size: extended ? 20 : 16,
  //             color: Theme
  //                 .of(context)
  //                 .primaryColor,
  //           ),
  //         ),
  //         if (extended) ...[
  //           const SizedBox(width: 12),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   '管理员',
  //                   style: Theme
  //                       .of(context)
  //                       .textTheme
  //                       .bodyMedium
  //                       ?.copyWith(
  //                     fontWeight: FontWeight.w500,
  //                   ),
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //                 Text(
  //                   'admin@example.com',
  //                   style: Theme
  //                       .of(context)
  //                       .textTheme
  //                       .bodySmall
  //                       ?.copyWith(
  //                     color: Theme
  //                         .of(context)
  //                         .colorScheme
  //                         .onSurface
  //                         .withOpacity(0.6),
  //                   ),
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               ],
  //             ),
  //           ),
  //           IconButton(
  //             icon: const Icon(Icons.logout, size: 18),
  //             onPressed: () => _handleLogout(context),
  //             tooltip: '退出登录',
  //           ),
  //         ],
  //       ],
  //     ),
  //   );
  // }

  Widget _buildCustomFooter(BuildContext context, bool extended) {
    if (!extended) {
      // Drawer 模式下，仅展示居中头像
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: CircleAvatar(
            radius: 16,
            backgroundColor:
            Theme.of(context).primaryColor.withOpacity(0.1),
            child: Icon(
              Icons.person,
              size: 16,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      );
    }

    // Extended 模式下，展示完整信息
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor:
            Theme.of(context).primaryColor.withOpacity(0.1),
            child: Icon(
              Icons.person,
              size: 20,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '管理员',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'admin@example.com',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 18),
            onPressed: () => _handleLogout(context),
            tooltip: '退出登录',
          ),
        ],
      ),
    );
  }

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
            // child: GetBuilder<CatNavigationController>(
            //   builder: (controller) {
            //     return _getPageForRoute(controller.currentRoute.value);
            //   },
            // ),
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

/// 设置页面
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme
            .of(context)
            .colorScheme
            .surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme
              .of(context)
              .dividerColor
              .withOpacity(0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.settings,
            size: 48,
            color: Theme
                .of(context)
                .primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            '系统设置',
            style: Theme
                .of(context)
                .textTheme
                .headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '在这里可以配置系统的各种设置选项。',
            style: Theme
                .of(context)
                .textTheme
                .bodyMedium,
          ),
          const SizedBox(height: 24),
          _buildSettingsList(context),
        ],
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('主题设置'),
            subtitle: const Text('配置应用外观主题'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('语言设置'),
            subtitle: const Text('切换应用显示语言'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('通知设置'),
            subtitle: const Text('管理系统通知偏好'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('安全设置'),
            subtitle: const Text('账户安全相关配置'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
