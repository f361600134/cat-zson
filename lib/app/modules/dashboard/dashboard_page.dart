
import 'package:cat_framework/app/core/i18n/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/framework/base_page.dart';

/// 仪表板页面
class DashboardPage extends BasePage {
  const DashboardPage({super.key});

  @override
  BasePageState createPageState() => _DashboardPageState();
}

class _DashboardPageState extends BasePageState<DashboardPage> {
  List<Map<String, dynamic>> _dashboardData = [];
  String? _errorMessage;

  @override
  void onPageInit() {
    super.onPageInit();
    // 页面初始化时加载数据
    refreshData();
  }

  @override
  void onPageDidShow() {
    super.onPageDidShow();
    // 每次显示页面时都刷新数据
    refreshData();
  }

  @override
  Future<void> onRefreshData({bool force = false}) async {
    try {
      // 模拟网络请求
      //await Future.delayed(const Duration(milliseconds: 1500));

      // 模拟数据
      _dashboardData = [
        {
          'title': TranslationKeys.totalSales,
          'value': '¥${(12345.67 + DateTime.now().millisecond).toStringAsFixed(2)}',
          'trend': '+12.5%',
          'icon': Icons.trending_up,
          'color': Colors.green,
        },
        {
          'title': TranslationKeys.userCount,
          'value': '${1234 + DateTime.now().second}',
          'trend': '+8.3%',
          'icon': Icons.people,
          'color': Colors.blue,
        },
        {
          'title': TranslationKeys.orderCount,
          'value': '${567 + DateTime.now().minute}',
          'trend': '+15.7%',
          'icon': Icons.shopping_cart,
          'color': Colors.orange,
        },
        {
          'title': TranslationKeys.productCount,
          'value': '${89 + DateTime.now().hour}',
          'trend': '+5.2%',
          'icon': Icons.inventory,
          'color': Colors.purple,
        },
      ];

      _errorMessage = null;
    } catch (e) {
      _errorMessage = '加载数据失败: $e';
    }
  }

  @override
  void onRefreshError(dynamic error) {
    _errorMessage = '刷新失败: $error';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_errorMessage!),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget buildPage(BuildContext context) {
    if (isRefreshing && _dashboardData.isEmpty) {
      return buildLoadingIndicator();
    }

    if (_errorMessage != null && _dashboardData.isEmpty) {
      return buildErrorPage(
        _errorMessage!,
        onRetry: () => refreshData(force: true),
      );
    }

    return RefreshIndicator(
      onRefresh: () => refreshData(force: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12), // 减少padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 页面标题
            Row(
              children: [
                Icon(
                  Icons.dashboard,
                  size: 28, // 稍微减小图标
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded( // 用Expanded包装，防止溢出
                  child: Text(
                    TranslationKeys.dashboard.tr,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isRefreshing)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16), // 减少间距

            // 数据统计卡片
            LayoutBuilder(
              builder: (context, constraints) {
                // 根据可用宽度动态计算列数和纵横比
                final screenWidth = constraints.maxWidth;
                int crossAxisCount = 2;
                double childAspectRatio = 1.5;
                
                if (screenWidth < 400) {
                  // 小屏幕：1列
                  crossAxisCount = 1;
                  childAspectRatio = 2.5;
                } else if (screenWidth < 600) {
                  // 中等屏幕：2列，调整纵横比
                  crossAxisCount = 2;
                  childAspectRatio = 1.3;
                } else {
                  // 大屏幕：2列或更多
                  crossAxisCount = 2;
                  childAspectRatio = 1.5;
                }
                
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _dashboardData.length,
                  itemBuilder: (context, index) {
                    final item = _dashboardData[index];
                    return _buildStatCard(
                      title: item['title'],
                      value: item['value'],
                      trend: item['trend'],
                      icon: item['icon'],
                      color: item['color'],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 24), // 减少间距

            // 快速操作区域
            Text(
              TranslationKeys.quickActions.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildActionButton(
                  icon: Icons.add_shopping_cart,
                  label: TranslationKeys.createOrder.tr,
                  onTap: () => {},
                ),
                _buildActionButton(
                  icon: Icons.person_add,
                  label: TranslationKeys.addUser.tr,
                  onTap: () => {},
                ),
                _buildActionButton(
                  icon: Icons.inventory_2,
                  label: TranslationKeys.manageProducts.tr,
                  onTap: () => {},
                ),
                _buildActionButton(
                  icon: Icons.analytics,
                  label: TranslationKeys.viewReports.tr,
                  onTap: () => {},
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 最近活动
            Text(
              TranslationKeys.recentActivities.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(12), // 减少padding
                child: Column(
                  mainAxisSize: MainAxisSize.min, // 重要：让Column自适应内容
                  children: [
                    _buildActivityItem(
                      icon: Icons.shopping_bag,
                      title: '${TranslationKeys.newOrder.tr} #1001',
                      subtitle: TranslationKeys.fromCustomer.tr,
                      time: TranslationKeys.minutesAgo.trParams({
                        'minutes': '2',
                      }),
                    ),
                    const Divider(height: 1),
                    _buildActivityItem(
                      icon: Icons.person,
                      title: TranslationKeys.newUserRegistration.tr,
                      subtitle: TranslationKeys.userRegistered.tr,
                      time: TranslationKeys.minutesAgo.trParams({
                      'minutes': '2',
                      }),
                    ),
                    const Divider(height: 1),
                    _buildActivityItem(
                      icon: Icons.inventory,
                      title: TranslationKeys.stockAlert.tr,
                      subtitle: TranslationKeys.productLowStock.tr,
                      time: TranslationKeys.minutesAgo.trParams({
                        'minutes': '10',
                      }),
                    ),
                  ],
                ),
              ),
            ),

            // 底部间距
            const SizedBox(height: 16), // 减少底部间距
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String trend,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12), // 减少padding
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // 重要：让Column自适应内容大小
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 20), // 减小图标大小
                    const Spacer(),
                    Flexible( // 用Flexible包装，防止溢出
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          trend,
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6), // 减少间距
                Flexible( // 用Flexible包装，防止溢出
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 2),
                Flexible( // 用Flexible包装，防止溢出
                  child: Text(
                    title.tr,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Flexible( // 用Flexible防止文字溢出
              child: Text(
                label,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16, // 稍微减小圆形头像
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Icon(
              icon,
              size: 16,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
