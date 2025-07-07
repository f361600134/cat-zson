import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart' hide Condition;
import 'package:responsive_framework/responsive_framework.dart' as rf;

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveRowColumn(
      layout: ResponsiveBreakpoints.of(context).smallerThan(TABLET)
          ? ResponsiveRowColumnType.COLUMN
          : ResponsiveRowColumnType.ROW,
      children: [
        ResponsiveRowColumnItem(
          rowFlex: 1,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 头部信息
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'John Doe',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'john@example.com',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '管理员',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ResponsiveVisibility(
                      hiddenConditions: const [rf.Condition.smallerThan(name: TABLET)],
                      child: ElevatedButton.icon(
                        onPressed: () => _showEditDialog(context),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('编辑'),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // 个人信息
                _buildInfoSection(
                  context,
                  '个人信息',
                  Icons.person_outline,
                  [
                    _buildInfoItem(context, '用户名', 'john_doe'),
                    _buildInfoItem(context, '全名', 'John Doe'),
                    _buildInfoItem(context, '邮箱', 'john@example.com'),
                    _buildInfoItem(context, '电话', '+86 138 0013 8000'),
                    _buildInfoItem(context, '部门', '技术部'),
                    _buildInfoItem(context, '职位', '高级开发工程师'),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // 账户设置
                _buildInfoSection(
                  context,
                  '账户设置',
                  Icons.security_outlined,
                  [
                    _buildActionItem(
                      context,
                      '修改密码',
                      '更新您的登录密码',
                      Icons.lock_outline,
                      () => _showPasswordDialog(context),
                    ),
                    _buildActionItem(
                      context,
                      '两步验证',
                      '增强账户安全性',
                      Icons.verified_user_outlined,
                      () => _showTwoFactorDialog(context),
                    ),
                    _buildActionItem(
                      context,
                      '登录历史',
                      '查看最近的登录记录',
                      Icons.history,
                      () => _showLoginHistory(context),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // 偏好设置
                _buildInfoSection(
                  context,
                  '偏好设置',
                  Icons.tune_outlined,
                  [
                    _buildActionItem(
                      context,
                      '通知偏好',
                      '设置接收通知的类型',
                      Icons.notifications_outlined,
                      () => _showNotificationSettings(context),
                    ),
                    _buildActionItem(
                      context,
                      '隐私设置',
                      '管理您的隐私选项',
                      Icons.privacy_tip_outlined,
                      () => _showPrivacySettings(context),
                    ),
                  ],
                ),
                
                // 移动端编辑按钮
                ResponsiveVisibility(
                  visibleConditions: const [rf.Condition.smallerThan(name: TABLET)],
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showEditDialog(context),
                        icon: const Icon(Icons.edit),
                        label: const Text('编辑个人信息'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑个人信息'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: '全名',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: 'John Doe'),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: '邮箱',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: 'john@example.com'),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: '电话',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: '+86 138 0013 8000'),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: '部门',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: '技术部'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage(context, '个人信息已更新');
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改密码'),
        content: const SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: '当前密码',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: '新密码',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: '确认新密码',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage(context, '密码已更新');
            },
            child: const Text('更新密码'),
          ),
        ],
      ),
    );
  }

  void _showTwoFactorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('两步验证'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('启用两步验证可以为您的账户提供额外的安全保护。'),
            SizedBox(height: 16),
            Text('当前状态：未启用'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage(context, '两步验证已启用');
            },
            child: const Text('启用'),
          ),
        ],
      ),
    );
  }

  void _showLoginHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('登录历史'),
        content: const SizedBox(
          width: 500,
          height: 300,
          child: Center(
            child: Text('登录历史记录将在这里显示'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('通知偏好'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: Text('邮件通知'),
              subtitle: Text('接收重要更新的邮件通知'),
              value: true,
              onChanged: null,
            ),
            CheckboxListTile(
              title: Text('推送通知'),
              subtitle: Text('接收应用推送通知'),
              value: false,
              onChanged: null,
            ),
            CheckboxListTile(
              title: Text('短信通知'),
              subtitle: Text('接收安全相关的短信通知'),
              value: true,
              onChanged: null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage(context, '通知偏好已更新');
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('隐私设置'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text('个人资料可见'),
              subtitle: Text('允许其他用户查看您的个人资料'),
              value: true,
              onChanged: null,
            ),
            SwitchListTile(
              title: Text('活动状态'),
              subtitle: Text('显示您的在线状态'),
              value: false,
              onChanged: null,
            ),
            SwitchListTile(
              title: Text('数据分析'),
              subtitle: Text('允许收集匿名使用数据'),
              value: true,
              onChanged: null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage(context, '隐私设置已更新');
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
