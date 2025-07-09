import 'package:flutter/material.dart';
import '../../core/framework/base_page.dart';

class UsersPage extends BasePage {
  const UsersPage({super.key});

  @override
  BasePageState createPageState() => _UsersPageState();
}

class _UsersPageState extends BasePageState<UsersPage> {
  List<Map<String, dynamic>> _users = [];

  @override
  void onPageDidShow() {
    super.onPageDidShow();
    refreshData();
  }

  @override
  Future<void> onRefreshData({bool force = false}) async {
    await Future.delayed(const Duration(milliseconds: 900));
    
    _users = List.generate(8, (index) => {
      'name': '用户${index + 1}',
      'email': 'user${index + 1}@example.com',
      'status': index % 3 == 0 ? '离线' : '在线',
      'lastLogin': '${DateTime.now().subtract(Duration(hours: index)).hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
    });
  }

  @override
  Widget buildPage(BuildContext context) {
    if (isRefreshing && _users.isEmpty) {
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
                Icon(Icons.people, size: 32, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Text('用户管理', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                if (isRefreshing) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
            const SizedBox(height: 24),
            ..._users.map((user) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: user['status'] == '在线' ? Colors.green : Colors.grey,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                title: Text(user['name']),
                subtitle: Text(user['email']),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(user['status'], style: TextStyle(
                      color: user['status'] == '在线' ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.w600,
                    )),
                    Text('最后登录: ${user['lastLogin']}', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}
