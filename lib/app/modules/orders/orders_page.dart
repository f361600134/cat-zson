import 'package:flutter/material.dart';
import '../../core/framework/base_page.dart';

class OrdersPage extends BasePage {
  const OrdersPage({super.key});

  @override
  BasePageState createPageState() => _OrdersPageState();
}

class _OrdersPageState extends BasePageState<OrdersPage> {
  List<Map<String, dynamic>> _orders = [];

  @override
  void onPageDidShow() {
    super.onPageDidShow();
    refreshData();
  }

  @override
  Future<void> onRefreshData({bool force = false}) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    
    final statuses = ['待付款', '已付款', '已发货', '已完成'];
    _orders = List.generate(12, (index) => {
      'orderNumber': 'ORD${(1000 + index + DateTime.now().millisecond % 100).toString()}',
      'customer': '客户${index + 1}',
      'amount': '¥${(199.9 + index * 50 + DateTime.now().second).toStringAsFixed(2)}',
      'status': statuses[index % statuses.length],
      'date': '${DateTime.now().subtract(Duration(days: index)).month}-${DateTime.now().subtract(Duration(days: index)).day}',
    });
  }

  @override
  Widget buildPage(BuildContext context) {
    if (isRefreshing && _orders.isEmpty) {
      return buildLoadingIndicator();
    }

    return RefreshIndicator(
      onRefresh: () => refreshData(force: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_cart, size: 32, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Text('订单管理', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                if (isRefreshing) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
            const SizedBox(height: 24),
            ..._orders.map((order) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(order['orderNumber'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(order['status']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            order['status'],
                            style: TextStyle(
                              color: _getStatusColor(order['status']),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('客户: ${order['customer']}'),
                        const Spacer(),
                        Text(order['amount'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('日期: ${order['date']}', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '待付款': return Colors.orange;
      case '已付款': return Colors.blue;
      case '已发货': return Colors.purple;
      case '已完成': return Colors.green;
      default: return Colors.grey;
    }
  }
}
