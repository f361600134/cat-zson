import 'package:flutter/material.dart';
import '../../core/framework/base_page.dart';

class MarketingPage extends BasePage {
  const MarketingPage({super.key});

  @override
  BasePageState createPageState() => _MarketingPageState();
}

class _MarketingPageState extends BasePageState<MarketingPage> {
  List<Map<String, dynamic>> _campaigns = [];

  @override
  void onPageDidShow() {
    super.onPageDidShow();
    refreshData();
  }

  @override
  Future<void> onRefreshData({bool force = false}) async {
    await Future.delayed(const Duration(milliseconds: 700));
    
    _campaigns = [
      {
        'name': '春季促销活动',
        'type': '折扣活动',
        'status': '进行中',
        'reach': '${12000 + DateTime.now().second * 10}',
        'conversion': '${(8.5 + DateTime.now().millisecond / 100).toStringAsFixed(1)}%',
      },
      {
        'name': '新用户注册优惠',
        'type': '优惠券',
        'status': '已结束',
        'reach': '${8500 + DateTime.now().minute * 20}',
        'conversion': '${(12.3 + DateTime.now().millisecond / 200).toStringAsFixed(1)}%',
      },
      {
        'name': '会员专属活动',
        'type': '积分兑换',
        'status': '计划中',
        'reach': '0',
        'conversion': '0%',
      },
    ];
  }

  @override
  Widget buildPage(BuildContext context) {
    if (isRefreshing && _campaigns.isEmpty) {
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
                Icon(Icons.campaign, size: 32, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Text('营销中心', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                if (isRefreshing) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
            const SizedBox(height: 24),
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
                          child: Text(campaign['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(campaign['status']).withOpacity(0.1),
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
                    const SizedBox(height: 8),
                    Text('类型: ${campaign['type']}', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('覆盖人数', style: Theme.of(context).textTheme.bodySmall),
                              Text(campaign['reach'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('转化率', style: Theme.of(context).textTheme.bodySmall),
                              Text(campaign['conversion'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case '进行中': return Colors.green;
      case '已结束': return Colors.grey;
      case '计划中': return Colors.blue;
      default: return Colors.grey;
    }
  }
}
