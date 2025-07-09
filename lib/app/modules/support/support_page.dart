import 'package:flutter/material.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Map<String, dynamic>> _tickets = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // 模拟加载延迟
    await Future.delayed(const Duration(milliseconds: 800));
    
    final priorities = ['高', '中', '低'];
    final statuses = ['待处理', '处理中', '已解决', '已关闭'];
    
    _tickets = List.generate(6, (index) => {
      'id': 'T${(1000 + index).toString()}',
      'title': ['登录问题', '支付异常', '功能咨询', '账户问题', '系统错误', '使用建议'][index],
      'customer': '客户${index + 1}',
      'priority': priorities[index % priorities.length],
      'status': statuses[index % statuses.length],
      'time': '${DateTime.now().subtract(Duration(hours: index * 2)).hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
    });
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用，用于AutomaticKeepAliveClientMixin
    
    if (_isLoading && _tickets.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('加载客户服务数据...'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12), // 减少padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 页面标题 - 优化小屏幕显示
            Row(
              children: [
                Icon(
                  Icons.support_agent, 
                  size: 28, // 稍微减小图标
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded( // 使用Expanded防止溢出
                  child: Text(
                    '客户服务', 
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_isLoading) 
                  const SizedBox(
                    width: 16, 
                    height: 16, 
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 统计信息卡片 - 使用响应式布局
            LayoutBuilder(
              builder: (context, constraints) {
                // 根据屏幕宽度决定布局
                if (constraints.maxWidth < 400) {
                  // 小屏幕：垂直排列
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              title: '待处理',
                              count: _tickets.where((t) => t['status'] == '待处理').length,
                              color: Colors.red,
                              icon: Icons.pending_actions,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard(
                              title: '处理中',
                              count: _tickets.where((t) => t['status'] == '处理中').length,
                              color: Colors.blue,
                              icon: Icons.work,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              title: '已解决',
                              count: _tickets.where((t) => t['status'] == '已解决').length,
                              color: Colors.green,
                              icon: Icons.check_circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard(
                              title: '已关闭',
                              count: _tickets.where((t) => t['status'] == '已关闭').length,
                              color: Colors.grey,
                              icon: Icons.close,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  // 大屏幕：水平排列
                  return Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: '待处理',
                          count: _tickets.where((t) => t['status'] == '待处理').length,
                          color: Colors.red,
                          icon: Icons.pending_actions,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          title: '处理中',
                          count: _tickets.where((t) => t['status'] == '处理中').length,
                          color: Colors.blue,
                          icon: Icons.work,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          title: '已解决',
                          count: _tickets.where((t) => t['status'] == '已解决').length,
                          color: Colors.green,
                          icon: Icons.check_circle,
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            
            const SizedBox(height: 24),
            
            // 工单列表标题
            Text(
              '工单列表',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // 工单列表
            ..._tickets.map((ticket) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12), // 减少padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 工单头部 - 使用Wrap防止溢出
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Text(
                          ticket['id'], 
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(ticket['priority']).withAlpha(25),
                            borderRadius: BorderRadius.circular(6),
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(ticket['status']).withAlpha(25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            ticket['status'],
                            style: TextStyle(
                              color: _getStatusColor(ticket['status']),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ticket['title'], 
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // 底部信息 - 使用Flexible防止溢出
                    Row(
                      children: [
                        Flexible(
                          flex: 2,
                          child: Text(
                            '${ticket['customer']}', 
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          flex: 1,
                          child: Text(
                            '${ticket['time']}', 
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )).toList(),
            
            // 底部间距
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
        padding: const EdgeInsets.all(8), // 减少padding
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 根据可用宽度调整布局
            final isSmall = constraints.maxWidth < 80;
            
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: isSmall ? 16 : 20),
                SizedBox(height: isSmall ? 4 : 6),
                FittedBox(
                  child: Text(
                    count.toString(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                SizedBox(height: isSmall ? 2 : 4),
                FittedBox(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: isSmall ? 10 : 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ),
              ],
            );
          },
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
