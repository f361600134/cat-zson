import 'package:flutter/material.dart';
import 'page_lifecycle.dart';

/// 基础页面类
/// 提供统一的页面结构和生命周期管理
abstract class BasePage extends StatefulWidget {
  const BasePage({super.key});
  
  @override
  State<BasePage> createState() => createPageState();
  
  /// 子类需要实现此方法来创建具体的State
  BasePageState createPageState();
  
  // 提供默认的空实现，子类可以选择性重写
  void onPageWillShow() {}
  void onPageDidShow() {}
  void onPageWillHide() {}
  void onPageDidHide() {}
  void onPageDispose() {}
  
  bool get isRefreshing => false;
  Future<void> refreshData({bool force = false}) async {}
}

/// 基础页面State
abstract class BasePageState<T extends BasePage> extends State<T> 
    with AutomaticKeepAliveClientMixin 
    implements PageLifecycle, PageRefreshable {
  
  /// 是否正在刷新
  bool _isRefreshing = false;
  
  /// 页面是否已初始化
  bool _isInitialized = false;
  
  /// 是否需要保活（默认true）
  @override
  bool get wantKeepAlive => true;
  
  @override
  bool get isRefreshing => _isRefreshing;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _isInitialized = true;
        onPageInit();
      }
    });
  }
  
  @override
  void dispose() {
    onPageDispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用，用于AutomaticKeepAliveClientMixin
    return buildPage(context);
  }
  
  /// 子类需要实现此方法来构建页面UI
  Widget buildPage(BuildContext context);
  
  /// 页面初始化（在initState之后调用）
  void onPageInit() {}
  
  @override
  void onPageWillShow() {
    debugPrint('${runtimeType}: onPageWillShow');
  }
  
  @override
  void onPageDidShow() {
    debugPrint('${runtimeType}: onPageDidShow');
  }
  
  @override
  void onPageWillHide() {
    debugPrint('${runtimeType}: onPageWillHide');
  }
  
  @override
  void onPageDidHide() {
    debugPrint('${runtimeType}: onPageDidHide');
  }
  
  @override
  void onPageDispose() {
    debugPrint('${runtimeType}: onPageDispose');
  }
  
  @override
  Future<void> refreshData({bool force = false}) async {
    if (_isRefreshing && !force) return;
    
    _isRefreshing = true;
    if (mounted) setState(() {});
    
    try {
      debugPrint('${runtimeType}: Refreshing data (force: $force)');
      await onRefreshData(force: force);
    } catch (e) {
      debugPrint('${runtimeType}: Error refreshing data: $e');
      onRefreshError(e);
    } finally {
      _isRefreshing = false;
      if (mounted) setState(() {});
    }
  }
  
  /// 子类需要实现此方法来处理数据刷新
  Future<void> onRefreshData({bool force = false}) async {
    // 默认实现为空，子类可以重写
  }
  
  /// 刷新错误处理
  void onRefreshError(dynamic error) {
    // 默认实现为空，子类可以重写
  }
  
  /// 显示加载指示器
  Widget buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
  
  /// 显示错误页面
  Widget buildErrorPage(String message, {VoidCallback? onRetry}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('重试'),
            ),
          ],
        ],
      ),
    );
  }
  
  /// 显示空数据页面
  Widget buildEmptyPage({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            message ?? '暂无数据',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

/// 简单页面基类（不需要复杂生命周期管理的页面）
abstract class SimplePage extends StatelessWidget implements PageLifecycle, PageRefreshable {
  const SimplePage({super.key});
  
  @override
  void onPageWillShow() {
    debugPrint('${runtimeType}: onPageWillShow');
  }
  
  @override
  void onPageDidShow() {
    debugPrint('${runtimeType}: onPageDidShow');
  }
  
  @override
  void onPageWillHide() {
    debugPrint('${runtimeType}: onPageWillHide');
  }
  
  @override
  void onPageDidHide() {
    debugPrint('${runtimeType}: onPageDidHide');
  }
  
  @override
  void onPageDispose() {
    debugPrint('${runtimeType}: onPageDispose');
  }
  
  @override
  bool get isRefreshing => false;
  
  @override
  Future<void> refreshData({bool force = false}) async {
    debugPrint('${runtimeType}: refreshData called (force: $force)');
    // 简单页面默认不实现刷新逻辑
  }
}
