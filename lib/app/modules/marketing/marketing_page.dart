import 'package:flutter/material.dart';

class MarketingPage extends StatefulWidget {
  const MarketingPage({super.key});

  @override
  State<MarketingPage> createState() => _MarketingPageState();
}

class _MarketingPageState extends State<MarketingPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Map<String, dynamic>> _campaigns = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    await Future.delayed(const Duration(milliseconds: 700));
    
    _campaigns = [
      {
        'name': '春季促销活动',
        'type': '折扣活动',
        'status': '进行中',
        'reach': '${12000 + DateTime.now().second * 10}',
        'conversion': '${(8.5 + DateTime.now().millisecond / 100).toStringAsFixed(1)}%',
        'budget': '50000',
        'spent': '32500',
      },
      {
        'name': '新用户注册优惠',
        'type': '优惠券',
        'status': '已结束',
        'reach': '${8500 + DateTime.now().minute * 20}',
        'conversion': '${(12.3 + DateTime.now().millisecond / 200).toStringAsFixed(1)}%',
        'budget': '30000',
        'spent': '28900',
      },
      {
        'name': '会员专属活动',
        'type': '积分兑换',
        'status': '计划中',
        'reach': '0',
        'conversion': '0%',
        'budget': '20000',
        'spent': '0',
      },
    ];
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (_isLoading && _campaigns.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('加载营销数据...'),
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
            Row(
              children: [
                Icon(Icons.campaign, size: 32, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Text(
                  '营销中心', 
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
            const SizedBox(height: 24),
            
            // 统计概览
            Row(
              children: [
                Expanded(
                  child: _buildOverviewCard(
                    title: '活动总数',
                    value: _campaigns.length.toString(),
                    icon: Icons.campaign,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOverviewCard(
                    title: '进行中',
                    value: _campaigns.where((c) => c['status'] == '进行中').length.toString(),
                    icon: Icons.play_circle,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOverviewCard(
                    title: '总预算',
                    value: '¥${(_campaigns.fold(0.0, (sum, c) => sum + double.parse(c['budget'])) / 1000).toStringAsFixed(0)}K',
                    icon: Icons.attach_money,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 营销活动列表
            Text(
              '营销活动',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            ..._campaigns.map((campaign) => Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                campaign['name'], 
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                campaign['type'], 
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(campaign['status']).withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            campaign['status'],
                            style: TextStyle(
                              color: _getStatusColor(campaign['status']),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 数据指标
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricItem(
                            label: '覆盖人数',
                            value: campaign['reach'],
                            icon: Icons.people,
                          ),
                        ),
                        Expanded(
                          child: _buildMetricItem(
                            label: '转化率',
                            value: campaign['conversion'],
                            icon: Icons.trending_up,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricItem(
                            label: '预算',
                            value: '¥${double.parse(campaign['budget']).toStringAsFixed(0)}',
                            icon: Icons.account_balance_wallet,
                          ),
                        ),
                        Expanded(
                          child: _buildMetricItem(
                            label: '已花费',
                            value: '¥${double.parse(campaign['spent']).toStringAsFixed(0)}',
                            icon: Icons.paid,
                          ),
                        ),
                      ],
                    ),
                    
                    // 预算进度条
                    if (campaign['status'] != '计划中') ...[
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '预算使用情况',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                '${(_getSpentPercentage(campaign['budget'], campaign['spent']) * 100).toStringAsFixed(0)}%',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: _getSpentPercentage(campaign['budget'], campaign['spent']),
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getSpentPercentage(campaign['budget'], campaign['spent']) > 0.8 
                                  ? Colors.red 
                                  : Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            )).toList(),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _getSpentPercentage(String budget, String spent) {
    try {
      final budgetAmount = double.parse(budget);
      final spentAmount = double.parse(spent);
      return budgetAmount > 0 ? spentAmount / budgetAmount : 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '进行中': return Colors.green;
      case '已结束': return Colors.grey;
      case '计划中': return Colors.blue;
      default: return Colors.grey;
    }
  }
}
