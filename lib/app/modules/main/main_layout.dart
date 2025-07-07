import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/responsive_framework.dart' hide Condition;
import 'package:responsive_framework/responsive_framework.dart' as rf;
import 'package:sidebarx/sidebarx.dart';
import '../../core/navigation/responsive_navigation.dart';
import '../../core/navigation/cat_navigation_controller.dart';
import '../../routes/app_routes.dart';
import '../settings/settings_page.dart';

/// 主布局页面 - Cat Framework 导航示例
class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    // 确保使用全局单例控制器
    return CatResponsiveScaffold(
      // 导航配置
      navigationItems: _buildNavigationItems(),
      config: _buildNavigationConfig(context),
      
      // 路由切换回调
      onRouteChanged: (route) {
        print('Route changed to: $route');
      },
      
      // AppBar 配置
      title: 'Cat Framework',
      centerTitle: false,
      actions: [
        // 响应式操作按钮
        ResponsiveVisibility(
          hiddenConditions: const [rf.Condition.smallerThan(name: TABLET)],
          child: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(),
          ),
        ),
        
        // 通知按钮
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                ),
              ),
            ],
          ),
          onPressed: () => _showNotifications(),
        ),
        
        // 用户头像
        ResponsiveVisibility(
          hiddenConditions: const [rf.Condition.smallerThan(name: TABLET)],
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.person, size: 20, color: Colors.white),
            ),
          ),
        ),
      ],
      
      // 主体内容
      body: _buildResponsiveBody(),
      
      // 浮动按钮（仅在移动端显示）
      floatingActionButton: ResponsiveVisibility(
        visibleConditions: const [rf.Condition.smallerThan(name: TABLET)],
        child: FloatingActionButton(
          onPressed: () => _showCreateDialog(),
          child: const Icon(Icons.add),
        ),
      ),
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
      extendedWidth: 260, // 稍微减少宽度
      collapsedWidth: 70,
      drawerWidth: 280,
      animationDuration: const Duration(milliseconds: 250),
      showToggleButton: true,
      appName: 'Cat Framework',
      logo: Container(
        width: 32, // 减小Logo尺寸
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
            ],
          ),
        ),
        child: const Icon(
          Icons.pets,
          color: Colors.white,
          size: 20, // 减小图标尺寸
        ),
      ),
      headerBuilder: (context, extended) => _buildCustomHeader(context, extended),
      footerBuilder: (context, extended) => _buildCustomFooter(context, extended),
      theme: _buildSidebarTheme(context),
    );
  }

  /// 构建自定义头部
  Widget _buildCustomHeader(BuildContext context, bool extended) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.7),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.pets,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              if (extended) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cat Framework',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        'v1.0.0',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (extended) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 1,
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建自定义底部
  Widget _buildCustomFooter(BuildContext context, bool extended) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 1,
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
          const SizedBox(height: 12),
          if (extended) ...[
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).primaryColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'John Doe',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        'john@example.com',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.more_vert,
                      size: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                    onSelected: (value) => _handleUserAction(value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'profile',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_outline, size: 16),
                            SizedBox(width: 8),
                            Text('个人资料'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.logout, size: 16),
                            SizedBox(width: 8),
                            Text('退出登录'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(
                Icons.person,
                color: Theme.of(context).primaryColor,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建侧边栏主题
  SidebarXTheme _buildSidebarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return SidebarXTheme(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: theme.dividerColor.withOpacity(0.12),
            width: 1,
          ),
        ),
      ),
      iconTheme: IconThemeData(
        color: theme.colorScheme.onSurface.withOpacity(0.7),
        size: 20, // 减小图标尺寸
      ),
      selectedIconTheme: IconThemeData(
        color: theme.colorScheme.primary,
        size: 20,
      ),
      textStyle: TextStyle(
        color: theme.colorScheme.onSurface.withOpacity(0.8),
        fontSize: 13, // 减小字体尺寸
        fontWeight: FontWeight.w500,
        overflow: TextOverflow.ellipsis, // 防止文本溢出
      ),
      selectedTextStyle: TextStyle(
        color: theme.colorScheme.primary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        overflow: TextOverflow.ellipsis,
      ),
      itemTextPadding: const EdgeInsets.only(left: 12), // 减少左边距
      selectedItemTextPadding: const EdgeInsets.only(left: 12),
      itemDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      selectedItemDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.primary.withOpacity(0.08),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      itemPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // 减少内边距
      selectedItemPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // 减少外边距
      padding: const EdgeInsets.symmetric(vertical: 6),
      hoverColor: theme.colorScheme.onSurface.withOpacity(0.04),
    );
  }

  /// 构建响应式主体内容
  Widget _buildResponsiveBody() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      constraints: const BoxConstraints(maxWidth: 1400),
      child: Builder(
        builder: (context) {
          return Obx(() {
            try {
              final controller = Get.find<CatNavigationController>();
              final currentRoute = controller.currentRoute.value;
              return _getPageForRoute(currentRoute);
            } catch (e) {
              // 如果控制器不存在，返回默认页面
              return const DashboardPage();
            }
          });
        },
      ),
    );
  }

  /// 根据路由获取页面
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

  // 事件处理方法
  void _showSearch() {
    Get.dialog(
      AlertDialog(
        title: const Text('搜索'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: '输入搜索关键词...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('搜索'),
          ),
        ],
      ),
    );
  }

  void _showNotifications() {
    Get.bottomSheet(
      Container(
        height: 400,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '通知',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Expanded(
              child: Center(
                child: Text('暂无新通知'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('创建新项目'),
        content: const Text('请选择要创建的项目类型'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  void _handleUserAction(String action) {
    switch (action) {
      case 'profile':
        Get.toNamed(AppRoutes.profile);
        break;
      case 'logout':
        Get.dialog(
          AlertDialog(
            title: const Text('确认退出'),
            content: const Text('您确定要退出登录吗？'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  // 执行登出逻辑
                },
                child: const Text('确认'),
              ),
            ],
          ),
        );
        break;
    }
  }
}

// 示例页面组件
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.dashboard,
                  size: 48,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  '仪表板',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '这是一个响应式仪表板页面，会根据屏幕大小自动调整布局。',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    try {
                      final controller = Get.find<CatNavigationController>();
                      controller.navigateTo(AppRoutes.analytics);
                    } catch (e) {
                      // 如果控制器不存在，直接导航
                      Get.toNamed(AppRoutes.analytics);
                    }
                  },
                  child: const Text('查看数据分析'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.analytics,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              '数据分析',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '数据分析页面，展示各种图表和统计信息。',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// 其他页面的简单实现
class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildSimplePage(context, '产品管理', Icons.inventory_2);
  }
}

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildSimplePage(context, '用户管理', Icons.people);
  }
}

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildSimplePage(context, '订单管理', Icons.shopping_cart);
  }
}

class MarketingPage extends StatelessWidget {
  const MarketingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildSimplePage(context, '营销中心', Icons.campaign);
  }
}

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildSimplePage(context, '客户服务', Icons.support_agent);
  }
}

Widget _buildSimplePage(BuildContext context, String title, IconData icon) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 48,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '$title页面的内容将在这里展示。',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    ),
  );
}
