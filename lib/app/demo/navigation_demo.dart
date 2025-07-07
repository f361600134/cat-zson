import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../core/navigation/responsive_navigation.dart';
import '../core/navigation/cat_navigation_controller.dart';

/// Cat Framework 导航演示页面
class NavigationDemo extends StatelessWidget {
  const NavigationDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBreakpoints(
      breakpoints: const [
        Breakpoint(start: 0, end: 450, name: MOBILE),
        Breakpoint(start: 451, end: 800, name: TABLET),
        Breakpoint(start: 801, end: 1920, name: DESKTOP),
        Breakpoint(start: 1921, end: double.infinity, name: '4K'),
      ],
      child: GetBuilder<CatNavigationController>(
        init: CatNavigationController(),
        builder: (controller) {
          return CatResponsiveScaffold(
            navigationItems: _buildDemoNavigationItems(),
            config: _buildDemoNavigationConfig(context),
            onRouteChanged: (route) {
              print('Demo Route changed to: $route');
            },
            title: 'Cat Framework Demo',
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showDemoInfo(context),
              ),
            ],
            body: _buildDemoBody(context),
          );
        },
      ),
    );
  }

  List<NavigationItem> _buildDemoNavigationItems() {
    return [
      NavigationItem(
        icon: Icons.home_outlined,
        label: '首页',
        route: '/demo/home',
      ),
      NavigationItem(
        icon: Icons.grid_view_outlined,
        label: '组件展示',
        route: '/demo/components',
      ),
      NavigationItem(
        icon: Icons.abc,
        label: '响应式布局',
        route: '/demo/responsive',
      ),
      NavigationItem(
        icon: Icons.navigation_outlined,
        label: '导航测试',
        route: '/demo/navigation',
      ),
      NavigationItem(
        icon: Icons.palette_outlined,
        label: '主题切换',
        route: '/demo/theme',
      ),
      NavigationItem(
        icon: Icons.settings_outlined,
        label: '设置',
        route: '/demo/settings',
      ),
    ];
  }

  NavigationConfig _buildDemoNavigationConfig(BuildContext context) {
    return NavigationConfig(
      extendedWidth: 260,
      collapsedWidth: 70,
      drawerWidth: 280,
      animationDuration: const Duration(milliseconds: 200),
      showToggleButton: true,
      appName: 'Cat Demo',
      logo: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: Theme.of(context).primaryColor,
        ),
        child: const Icon(
          Icons.pets,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildDemoBody(BuildContext context) {
    return MaxWidthBox(
      maxWidth: 1200,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final controller = Get.find<CatNavigationController>();
          final currentRoute = controller.currentRoute.value;
          
          return _getDemoPageForRoute(context, currentRoute);
        }),
      ),
    );
  }

  Widget _getDemoPageForRoute(BuildContext context, String route) {
    switch (route) {
      case '/demo/home':
        return _buildDemoHomePage(context);
      case '/demo/components':
        return _buildComponentsPage(context);
      case '/demo/responsive':
        return _buildResponsivePage(context);
      case '/demo/navigation':
        return _buildNavigationTestPage(context);
      default:
        return _buildDemoHomePage(context);
    }
  }

  Widget _buildDemoHomePage(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.home,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              '欢迎使用 Cat Framework',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '这是一个功能强大的 Flutter 脚手架框架，提供响应式导航、断点判断、抽屉/侧边栏模式切换等功能。',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentsPage(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.grid_view,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              '组件展示',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '展示 Cat Framework 中的各种组件和功能。',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsivePage(BuildContext context) {
    final breakpoints = ResponsiveBreakpoints.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.abc,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              '响应式布局测试',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '当前断点信息：',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('屏幕宽度: ${MediaQuery.of(context).size.width.toInt()}px'),
                  Text('屏幕高度: ${MediaQuery.of(context).size.height.toInt()}px'),
                  Text('是否移动端: ${breakpoints.isMobile}'),
                  Text('是否平板: ${breakpoints.isTablet}'),
                  Text('是否桌面端: ${breakpoints.isDesktop}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationTestPage(BuildContext context) {
    final controller = Get.find<CatNavigationController>();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.navigation,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              '导航测试',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                ElevatedButton(
                  onPressed: () => controller.toggleSidebar(),
                  child: const Text('切换侧边栏'),
                ),
                ElevatedButton(
                  onPressed: () => controller.expandSidebar(),
                  child: const Text('展开侧边栏'),
                ),
                ElevatedButton(
                  onPressed: () => controller.collapseSidebar(),
                  child: const Text('收缩侧边栏'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDemoInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cat Framework Demo'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('这是 Cat Framework 的导航系统演示。'),
            SizedBox(height: 16),
            Text('主要功能：'),
            Text('• 响应式断点判断'),
            Text('• 智能导航模式切换'),
            Text('• 桌面端固定侧边栏'),
            Text('• 平板端可收缩侧边栏'),
            Text('• 移动端抽屉导航'),
            Text('• 丰富的配置选项'),
          ],
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
}
