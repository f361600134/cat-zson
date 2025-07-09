/// 页面生命周期接口
/// 实现此接口的页面可以响应生命周期事件
abstract class PageLifecycle {
  /// 页面即将显示时调用
  /// 用于刷新数据、恢复状态等
  void onPageWillShow() {}
  
  /// 页面已显示时调用
  /// 用于启动定时器、开始动画等
  void onPageDidShow() {}
  
  /// 页面即将隐藏时调用
  /// 用于暂停定时器、保存状态等
  void onPageWillHide() {}
  
  /// 页面已隐藏时调用
  /// 用于释放资源等
  void onPageDidHide() {}
  
  /// 页面被销毁时调用
  /// 用于最终的资源清理
  void onPageDispose() {}
}

/// 页面刷新接口
/// 实现此接口的页面可以支持数据刷新
abstract class PageRefreshable {
  /// 刷新页面数据
  /// [force] 是否强制刷新（忽略缓存）
  Future<void> refreshData({bool force = false});
  
  /// 是否正在刷新
  bool get isRefreshing;
}

/// 页面配置
class PageConfig {
  /// 是否需要保活
  final bool keepAlive;
  
  /// 是否在显示时自动刷新
  final bool autoRefreshOnShow;
  
  /// 缓存优先级（数值越高优先级越高，被清理的可能性越小）
  final int cachePriority;
  
  /// 最大空闲时间（毫秒），超过此时间的页面可能被清理
  final int maxIdleTime;
  
  const PageConfig({
    this.keepAlive = true,
    this.autoRefreshOnShow = true,
    this.cachePriority = 1,
    this.maxIdleTime = 300000, // 5分钟
  });
  
  static const PageConfig defaultConfig = PageConfig();
  
  /// 高优先级配置（重要页面，不容易被清理）
  static const PageConfig highPriority = PageConfig(
    keepAlive: true,
    autoRefreshOnShow: true,
    cachePriority: 5,
    maxIdleTime: 600000, // 10分钟
  );
  
  /// 低优先级配置（可以被快速清理）
  static const PageConfig lowPriority = PageConfig(
    keepAlive: true,
    autoRefreshOnShow: true,
    cachePriority: 1,
    maxIdleTime: 180000, // 3分钟
  );
  
  /// 不保活配置
  static const PageConfig noKeepAlive = PageConfig(
    keepAlive: false,
    autoRefreshOnShow: true,
    cachePriority: 0,
    maxIdleTime: 0,
  );
}
