import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:sidebarx/sidebarx.dart';
import 'cat_navigation_controller.dart';
export 'cat_navigation_controller.dart';
export 'navigation_config.dart';

/// 响应式导航脚手架 - Cat Framework 核心导航组件
class CatResponsiveScaffold extends StatefulWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final List<NavigationItem> navigationItems;
  final NavigationConfig? config;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool? centerTitle;
  final double? elevation;
  
  /// 路由切换回调
  final void Function(String route)? onRouteChanged;
  
  const CatResponsiveScaffold({
    super.key,
    required this.body,
    required this.navigationItems,
    this.appBar,
    this.config,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.title,
    this.actions,
    this.leading,
    this.centerTitle,
    this.elevation,
    this.onRouteChanged,
  }) ;

  @override
  State<CatResponsiveScaffold> createState() => _CatResponsiveScaffoldState();
}

class _CatResponsiveScaffoldState extends State<CatResponsiveScaffold> {
  CatNavigationController? _controller;
  bool _isInitialized = false;
  String _currentBreakpoint = '';

  @override
  void initState() {
    super.initState();
    _initializeControllerAsync();
  }
  
  @override
  void dispose() {
    // 不要在这里处理控制器的销毁，让 GetX 自动管理
    super.dispose();
  }
  
  Future<void> _initializeControllerAsync() async {
    // 尝试查找现有的控制器，如果没有则创建新的
    _controller = Get.find<CatNavigationController>();

    // 等待到下一个事件循环
    await Future.delayed(Duration.zero);
    
    if (!mounted || _controller == null) return;
    
    // 安全地初始化导航项
    if (_controller!.navigationItems.isEmpty && widget.navigationItems.isNotEmpty) {
      _controller!.setNavigationItems(widget.navigationItems);
      
      // 如果当前路由为空，初始化默认路由
      if (_controller!.currentRoute.value.isEmpty) {
        _controller!.initializeDefaultRoute();
      }
    }
    
    // 标记为已初始化
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // 安全地检查断点变化
    if (_isInitialized && _controller != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkBreakpointChanges();
      });
    }
  }
  
  void _checkBreakpointChanges() {
    if (!mounted || _controller == null) return;
    
    final breakpoints = ResponsiveBreakpoints.of(context);
    final isDesktop = breakpoints.largerThan(TABLET);
    final isTablet = breakpoints.equals(TABLET);
    final isMobile = breakpoints.isMobile;
    
    String newBreakpoint = '';
    if (isDesktop) {
      newBreakpoint = 'desktop';
    } else if (isTablet) {
      newBreakpoint = 'tablet';
    } else {
      newBreakpoint = 'mobile';
    }
    
    // 只在断点真正改变时更新
    if (_currentBreakpoint != newBreakpoint) {
      _currentBreakpoint = newBreakpoint;
      _controller!.updateDeviceType(
        isDesktop: isDesktop,
        isTablet: isTablet,
        isMobile: isMobile,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 如果还没有初始化完成，显示loading
    if (!_isInitialized || _controller == null) {
      return Scaffold(
        appBar: widget.title != null ? AppBar(title: Text(widget.title!)) : null,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // 获取配置
    final navConfig = widget.config ?? NavigationConfig();
    
    // 判断设备类型（仅读取，不更新状态）
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final isTablet = ResponsiveBreakpoints.of(context).equals(TABLET);
    
    // 构建不同布局
    if (isDesktop) {
      return _buildDesktopLayout(context, _controller!, navConfig);
    } else if (isTablet) {
      return _buildTabletLayout(context, _controller!, navConfig);
    } else {
      return _buildMobileLayout(context, _controller!, navConfig);
    }
  }
  
  /// 桌面端布局 - 固定侧边栏
  Widget _buildDesktopLayout(
    BuildContext context,
    CatNavigationController controller,
    NavigationConfig config,
  ) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Row(
        children: [
          // 侧边栏
          _buildSidebarX(
            context,
            controller,
            config,
            canToggle: false,
            extended: true,
          ),
          // 主内容区
          Expanded(
            child: Scaffold(
              backgroundColor: widget.backgroundColor,
              appBar: _buildAppBar(context, controller, showMenuButton: false),
              body: widget.body,
              floatingActionButton: widget.floatingActionButton,
              floatingActionButtonLocation: widget.floatingActionButtonLocation,
              bottomNavigationBar: widget.bottomNavigationBar,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 平板端布局 - 可收缩侧边栏
  Widget _buildTabletLayout(
    BuildContext context,
    CatNavigationController controller,
    NavigationConfig config,
  ) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Row(
        children: [
          // 可收缩侧边栏
          Obx(() => AnimatedContainer(
            duration: config.animationDuration,
            width: controller.isSidebarExpanded.value
                ? config.extendedWidth
                : config.collapsedWidth,
            child: _buildSidebarX(
              context,
              controller,
              config,
              canToggle: true,
              extended: controller.isSidebarExpanded.value,
            ),
          )),
          // 主内容区
          Expanded(
            child: Scaffold(
              backgroundColor: widget.backgroundColor,
              appBar: _buildAppBar(context, controller, showMenuButton: true),
              body: widget.body,
              floatingActionButton: widget.floatingActionButton,
              floatingActionButtonLocation: widget.floatingActionButtonLocation,
              bottomNavigationBar: widget.bottomNavigationBar,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 移动端布局 - 抽屉式侧边栏
  Widget _buildMobileLayout(
    BuildContext context,
    CatNavigationController controller,
    NavigationConfig config,
  ) {
    return Scaffold(
      key: controller.scaffoldKey,
      backgroundColor: widget.backgroundColor,
      appBar: _buildAppBar(context, controller, showMenuButton: true),
      drawer: Drawer(
        width: config.drawerWidth,
        child: _buildSidebarX(
          context,
          controller,
          config,
          canToggle: false,
          extended: true,
          isDrawer: true,
        ),
      ),
      body: widget.body,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      bottomNavigationBar: widget.bottomNavigationBar,
    );
  }
  
  /// 构建 AppBar
  PreferredSizeWidget? _buildAppBar(
    BuildContext context,
    CatNavigationController controller,
    {required bool showMenuButton}
  ) {
    if (widget.appBar != null) return widget.appBar;
    
    if (widget.title == null && widget.actions == null && !showMenuButton && widget.leading == null) {
      return null;
    }
    
    return AppBar(
      elevation: widget.elevation,
      centerTitle: widget.centerTitle,
      leading: showMenuButton
          ? IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                // 使用 post frame callback 避免在鼠标事件处理期间更新状态
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  controller.toggleSidebar();
                });
              },
            )
          : widget.leading,
      title: widget.title != null ? Text(widget.title!) : null,
      actions: widget.actions,
    );
  }
  
  /// 构建 SidebarX
  Widget _buildSidebarX(
    BuildContext context,
    CatNavigationController controller,
    NavigationConfig config,
    {required bool canToggle,
    required bool extended,
    bool isDrawer = false}
  ) {
    final theme = Theme.of(context);
    final sidebarTheme = config.theme ?? SidebarXTheme(
      width: extended ? config.extendedWidth : config.collapsedWidth,
      height: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.zero,
      ),
      iconTheme: IconThemeData(
        color: theme.colorScheme.onSurface,
        size: 22, // 稍微减小图标尺寸
      ),
      selectedIconTheme: IconThemeData(
        color: theme.colorScheme.primary,
        size: 22,
      ),
      textStyle: TextStyle(
        color: theme.colorScheme.onSurface,
        fontSize: 13, // 稍微减小字体尺寸
      ),
      selectedTextStyle: TextStyle(
        color: theme.colorScheme.primary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      itemTextPadding: const EdgeInsets.only(left: 12), // 减少内边距
      selectedItemTextPadding: const EdgeInsets.only(left: 12),
      itemDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      selectedItemDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), // 减少边距
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), // 减少内边距
    );
    
    return ClipRect( // 添加 ClipRect 防止溢出
      child: SidebarX(
        controller: controller.sidebarController,
        theme: sidebarTheme,
        extendedTheme: SidebarXTheme(
          width: config.extendedWidth,
          decoration: sidebarTheme.decoration,
          margin: sidebarTheme.margin,
          padding: sidebarTheme.padding,
          iconTheme: sidebarTheme.iconTheme,
          selectedIconTheme: sidebarTheme.selectedIconTheme,
          textStyle: sidebarTheme.textStyle,
          selectedTextStyle: sidebarTheme.selectedTextStyle,
          itemTextPadding: sidebarTheme.itemTextPadding,
          selectedItemTextPadding: sidebarTheme.selectedItemTextPadding,
          itemDecoration: sidebarTheme.itemDecoration,
          selectedItemDecoration: sidebarTheme.selectedItemDecoration,
        ),
        headerBuilder: (context, extended) => _buildHeader(
          context,
          controller,
          config,
          extended,
          canToggle,
        ),
        footerBuilder: config.footerBuilder,
        separatorBuilder: config.separatorBuilder,
        items: _buildSidebarItems(controller, isDrawer),
        showToggleButton: canToggle && config.showToggleButton,
        toggleButtonBuilder: canToggle ? (context, extended) => 
          _buildToggleButton(context, controller, extended) : null,
      ),
    );
  }
  
  /// 构建侧边栏头部
  Widget _buildHeader(
    BuildContext context,
    CatNavigationController controller,
    NavigationConfig config,
    bool extended,
    bool canToggle,
  ) {
    if (config.headerBuilder != null) {
      return config.headerBuilder!(context, extended);
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (config.logo != null) ...[
            config.logo!,
            if (extended) const SizedBox(width: 12),
          ],
          if (extended && config.appName != null)
            Expanded(
              child: Text(
                config.appName!,
                style: Theme.of(context).textTheme.titleLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
  
  /// 构建切换按钮
  Widget _buildToggleButton(
    BuildContext context,
    CatNavigationController controller,
    bool extended,
  ) {
    return IconButton(
      icon: Icon(
        extended ? Icons.chevron_left : Icons.chevron_right,
        size: 20,
      ),
      onPressed: () {
        // 使用 post frame callback 避免在构建期间更新状态
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.toggleSidebar();
        });
      },
    );
  }
  
  /// 构建侧边栏项目
  List<SidebarXItem> _buildSidebarItems(
    CatNavigationController controller,
    bool isDrawer,
  ) {
    return controller.navigationItems.map((item) {
      return SidebarXItem(
        icon: item.icon,
        label: item.label,
        onTap: () {
          // 使用 post frame callback 避免在鼠标事件处理期间执行状态更新
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // 如果是抽屉模式，选择后关闭抽屉
            if (isDrawer) {
              Get.back();
            }
            
            // 执行路由跳转
            if (item.route != null) {
              controller.navigateTo(item.route!);
              widget.onRouteChanged?.call(item.route!);
            }
            
            // 执行自定义回调
            item.onTap?.call();
          });
        },
      );
    }).toList();
  }
}

/// 导航项配置
class NavigationItem {
  final IconData icon;
  final String label;
  final String? route;
  final VoidCallback? onTap;
  final List<NavigationItem>? children;
  
  const NavigationItem({
    required this.icon,
    required this.label,
    this.route,
    this.onTap,
    this.children,
  });
}

/// 导航配置
class NavigationConfig {
  /// 侧边栏展开宽度
  final double extendedWidth;
  
  /// 侧边栏收缩宽度
  final double collapsedWidth;
  
  /// 抽屉宽度
  final double drawerWidth;
  
  /// 动画时长
  final Duration animationDuration;
  
  /// 是否显示切换按钮
  final bool showToggleButton;
  
  /// 应用名称
  final String? appName;
  
  /// Logo
  final Widget? logo;
  
  /// 自定义主题
  final SidebarXTheme? theme;
  
  /// 头部构建器
  final Widget Function(BuildContext context, bool extended)? headerBuilder;
  
  /// 底部构建器
  final Widget Function(BuildContext context, bool extended)? footerBuilder;
  
  /// 分隔线构建器
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  
  const NavigationConfig({
    this.extendedWidth = 250,
    this.collapsedWidth = 70,
    this.drawerWidth = 280,
    this.animationDuration = const Duration(milliseconds: 300),
    this.showToggleButton = true,
    this.appName,
    this.logo,
    this.theme,
    this.headerBuilder,
    this.footerBuilder,
    this.separatorBuilder,
  });
}
