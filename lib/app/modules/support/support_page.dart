import 'package:flutter/material.dart';
import '../../core/framework/base_page.dart';

class SupportPage extends BasePage {
  const SupportPage({super.key});

  @override
  BasePageState createPageState() => _SupportPageState();
}

class _SupportPageState extends BasePageState<SupportPage> {
  List<Map<String, dynamic>> _tickets = [];

  @override
  void onPageDidShow() {
    super.onPageDidShow();
    refreshData();
  }

  @override
  Future<void> onRefreshData({bool force = false}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    final priorities = ['高', '中', '低'];
    final statuses = ['待处理', '处理中', '已解决', '已关闭'];
    
    _tickets = List.generate(6, (index) => {
      'id': 'T${(1000 + index + DateTime.now().millisecond % 50).toString()}',
      'title': '${['登录问题', '支付异常', '功能咨询', '账户问题', '系统错误', '使用建议'][index]}',
      'customer': '客户${index + 1}',
      'priority': priorities[index % priorities.length],
      'status': statuses[index % statuses.length],
      'time': '${DateTime.now().subtract(Duration(hours: index * 2)).hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
    });
  }

  @override
  Widget buildPage(BuildContext context) {
    if (isRefreshing && _tickets.isEmpty) {
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
                Icon(Icons.support_agent, size: 32, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Text('客户服务', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                if (isRefreshing) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
            const SizedBox(height: 24),
            ..._tickets.map((ticket) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(ticket['id'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(ticket['priority']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            ticket['priority'],
                            style: TextStyle(
                              color: _getPriorityColor(ticket['priority']),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(ticket['status']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            ticket['status'],
                            style: TextStyle(
                              color: _getStatusColor(ticket['status']),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(ticket['title'], style: const TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('提交人: ${ticket['customer']}', style: Theme.of(context).textTheme.bodySmall),
                        const Spacer(),
                        Text('时间: ${ticket['time']}', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case '高': return Colors.red;
      case '中': return Colors.orange;
      case '低': return Colors.green;
      default: return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '待处理': return Colors.red;
      case '处理中': return Colors.blue;
      case '已解决': return Colors.green;
      case '已关闭': return Colors.grey;
      default: return Colors.grey;
    }
  }
}
