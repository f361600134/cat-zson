import 'package:cat_zson_pro/app/modules/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/responsive_framework.dart' as rf;
import 'package:sidebarx/sidebarx.dart';
import '../../core/navigation/responsive_navigation.dart';
import '../../routes/app_routes.dart';
import '../../utils/logger.dart';
import '../settings/settings_page.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CatNavigationController>();
    return CatResponsiveScaffold(
      title: 'Cat Framework',
      navigationItems: _navigationItems,
      config: _navigationConfig(context),
      onRouteChanged: (route) => logger.d('Route changed to: $route'),
      actions: [
        _buildSearchButton(),
        _buildNotificationButton(),
        _buildUserAvatar(context),
      ],
      body: _buildBody(controller),
      floatingActionButton: _buildFAB(),
    );
  }

  List<NavigationItem> get _navigationItems => [
    _navItem(Icons.dashboard_outlined, '仪表板', AppRoutes.dashboard),
    _navItem(Icons.analytics_outlined, '数据分析', AppRoutes.analytics),
    _navItem(Icons.inventory_2_outlined, '产品管理', AppRoutes.products),
    _navItem(Icons.people_outline, '用户管理', AppRoutes.users),
    _navItem(Icons.shopping_cart_outlined, '订单管理', AppRoutes.orders),
    _navItem(Icons.campaign_outlined, '营销中心', AppRoutes.marketing),
    _navItem(Icons.support_agent_outlined, '客户服务', AppRoutes.support),
    _navItem(Icons.settings_outlined, '系统设置', AppRoutes.settings),
  ];

  NavigationItem _navItem(IconData icon, String label, String route) =>
      NavigationItem(icon: icon, label: label, route: route);

  NavigationConfig _navigationConfig(BuildContext context) => NavigationConfig(
    extendedWidth: 280,
    collapsedWidth: 80,
    drawerWidth: 300,
    animationDuration: const Duration(milliseconds: 250),
    showToggleButton: true,
    appName: 'Cat Framework',
    logo: _buildLogo(context),
    headerBuilder: _buildHeader,
    footerBuilder: _buildFooter,
    theme: _sidebarTheme(context),
  );

  Widget _buildBody(CatNavigationController controller) => rf.MaxWidthBox(
    maxWidth: 1400,
    child: AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: Container(
        key: ValueKey(controller.currentRoute.value),
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        child: _routeWidget(controller.currentRoute.value),
      ),
    ),
  );

  Widget _routeWidget(String route) {
    return switch (route) {
      AppRoutes.dashboard => const DashboardPage(),
      AppRoutes.analytics => const AnalyticsPage(),
      AppRoutes.products => const ProductsPage(),
      AppRoutes.users => const UsersPage(),
      AppRoutes.orders => const OrdersPage(),
      AppRoutes.marketing => const MarketingPage(),
      AppRoutes.support => const SupportPage(),
      AppRoutes.settings => const SettingsPage(),
      _ => const DashboardPage(),
    };
  }

  SidebarXTheme _sidebarTheme(BuildContext context) => SidebarXTheme(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border(
        right: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.12),
        ),
      ),
    ),
    iconTheme:
    IconThemeData(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
    selectedIconTheme:
    IconThemeData(color: Theme.of(context).colorScheme.primary),
    textStyle:
    TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
    selectedTextStyle:
    TextStyle(color: Theme.of(context).colorScheme.primary),
    itemTextPadding: const EdgeInsets.only(left: 16),
    selectedItemTextPadding: const EdgeInsets.only(left: 16),
    itemDecoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
    selectedItemDecoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
      border:
      Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
    ),
    itemPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    selectedItemPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    padding: const EdgeInsets.symmetric(vertical: 8),
    hoverColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.04),
  );

  Widget _buildLogo(BuildContext context) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      gradient: LinearGradient(
        colors: [
          Theme.of(context).primaryColor,
          Theme.of(context).primaryColor.withOpacity(0.7),
        ],
      ),
    ),
    child: const Icon(Icons.pets, color: Colors.white),
  );

  Widget _buildHeader(BuildContext context, bool extended) => extended
      ? ListTile(
    leading: _buildLogo(context),
    title: const Text('Cat Framework', style: TextStyle(fontWeight: FontWeight.bold)),
    subtitle: Text('v1.0.0', style: Theme.of(context).textTheme.bodySmall),
  )
      : const SizedBox.shrink();

  Widget _buildFooter(BuildContext context, bool extended) => ListTile(
    leading: const CircleAvatar(radius: 18, child: Icon(Icons.person)),
    title: extended ? const Text('John Doe') : null,
    subtitle: extended ? const Text('john@example.com') : null,
    trailing: extended ? _userPopup(context) : null,
  );

  Widget _userPopup(BuildContext context) => PopupMenuButton<String>(
    icon: const Icon(Icons.more_vert, size: 18),
    onSelected: _handleUserAction,
    itemBuilder: (context) => const [
      PopupMenuItem(value: 'profile', child: Text('个人资料')),
      PopupMenuItem(value: 'logout', child: Text('退出登录')),
    ],
  );

  void _handleUserAction(String action) {
    switch (action) {
      case 'profile':
        Get.toNamed(AppRoutes.profile);
        break;
      case 'logout':
        Get.dialog(AlertDialog(
          title: const Text('确认退出'),
          content: const Text('您确定要退出登录吗？'),
          actions: [
            TextButton(onPressed: Get.back, child: const Text('取消')),
            ElevatedButton(onPressed: Get.back, child: const Text('确认')),
          ],
        ));
    }
  }

  Widget _buildSearchButton() => rf.ResponsiveVisibility(
    hiddenConditions: const [rf.Condition.smallerThan(name: rf.TABLET)],
    child: IconButton(icon: const Icon(Icons.search), onPressed: _showSearch),
  );

  void _showSearch() => Get.dialog(const AlertDialog(
    title: Text('搜索'),
    content: TextField(decoration: InputDecoration(hintText: '输入关键词')),
  ));

  Widget _buildNotificationButton() => IconButton(
    icon: Stack(children: [
      const Icon(Icons.notifications_outlined),
      Positioned(
        right: 0,
        top: 0,
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
        ),
      )
    ]),
    onPressed: _showNotifications,
  );

  void _showNotifications() => Get.bottomSheet(Container(
    height: 400,
    padding: const EdgeInsets.all(16),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('通知', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Spacer(),
        Center(child: Text('暂无新通知')),
      ],
    ),
  ));

  Widget _buildUserAvatar(BuildContext context) => rf.ResponsiveVisibility(
    hiddenConditions: const [rf.Condition.smallerThan(name: rf.TABLET)],
    child: Padding(
      padding: const EdgeInsets.only(right: 16),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.person, size: 20, color: Colors.white),
      ),
    ),
  );

  Widget _buildFAB() => rf.ResponsiveVisibility(
    visibleConditions: const [rf.Condition.smallerThan(name: rf.TABLET)],
    child: FloatingActionButton(
      onPressed: _showCreateDialog,
      child: const Icon(Icons.add),
    ),
  );

  void _showCreateDialog() => Get.dialog(AlertDialog(
    title: const Text('创建新项目'),
    content: const Text('请选择要创建的项目类型'),
    actions: [
      TextButton(onPressed: Get.back, child: const Text('取消')),
      ElevatedButton(onPressed: Get.back, child: const Text('创建')),
    ],
  ));
}
