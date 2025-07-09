import 'package:flutter/material.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    await Future.delayed(const Duration(milliseconds: 1200));
    
    final statuses = ['待付款', '已付款', '已发货', '已完成'];
    _orders = List.generate(12, (index) => {
      'orderNumber': 'ORD${(1000 + index + DateTime.now().millisecond % 100).toString()}',
      'customer': '客户${index + 1}',
      'amount': '¥${(199.9 + index * 50 + DateTime.now().second).toStringAsFixed(2)}',
      'status': statuses[index % statuses.length],
      'date': '${DateTime.now().subtract(Duration(days: index)).month}-${DateTime.now().subtract(Duration(days: index)).day}',
      'items': (index % 3) + 1,
    });
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (_isLoading && _orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('加载订单数据...'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 页面标题
            FittedBox( // 用FittedBox包装标题行
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 32, // 减去padding
                child: Row(
                  children: [
                    Icon(Icons.shopping_cart, size: 32, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 12),
                    Text(
                      '订单管理', 
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (_isLoading) 
                      const SizedBox(
                        width: 20, 
                        height: 20, 
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // 统计卡片
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topLeft, // 改为左上对齐
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 32,
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildStatCard(
                      title: '待付款',
                      count: _orders.where((o) => o['status'] == '待付款').length,
                      color: Colors.orange,
                      icon: Icons.payment,
                    ),
                    _buildStatCard(
                      title: '已付款',
                      count: _orders.where((o) => o['status'] == '已付款').length,
                      color: Colors.blue,
                      icon: Icons.paid,
                    ),
                    _buildStatCard(
                      title: '已发货',
                      count: _orders.where((o) => o['status'] == '已发货').length,
                      color: Colors.purple,
                      icon: Icons.local_shipping,
                    ),
                    _buildStatCard(
                      title: '已完成',
                      count: _orders.where((o) => o['status'] == '已完成').length,
                      color: Colors.green,
                      icon: Icons.check_circle,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 订单列表
            Text(
              '订单列表',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            ..._orders.map((order) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topLeft, // 改为左上对齐
                  child: Column( // 去掉IntrinsicWidth，直接用Column
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 第一行：订单号和状态
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 64,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start, // 确保Row内容左对齐
                          children: [
                            Flexible(
                              child: Text(
                                order['orderNumber'], 
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order['status']).withAlpha(25),
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
                      ),
                      const SizedBox(height: 8),
                      // 第二行：客户信息和金额
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 64,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start, // 确保Row内容左对齐
                          children: [
                            Icon(Icons.person, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${order['customer']}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.shopping_bag, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('${order['items']} 商品'),
                            const Spacer(),
                            Text(
                              order['amount'], 
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      // 第三行：日期
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 64,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start, // 确保Row内容左对齐
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '下单时间: ${order['date']}', 
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )).toList(),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft, // 改为左对齐
          child: Row( // 去掉IntrinsicWidth，直接用Row
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start, // 确保Row内容左对齐
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start, // 确保Column内容左对齐
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
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
