import 'package:cat_zson_pro/app/core/event/event_bus.dart';
import 'package:cat_zson_pro/app/core/framework/cat_framework.dart';
import 'package:cat_zson_pro/app/routes/app_pages.dart';
import 'package:cat_zson_pro/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('app_name'.tr), // 直接使用字符串避免冲突
        actions: [
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: () => _showThemeSelector(context),
          ),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => _showLanguageSelector(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.pets,
                      size: 64,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'welcome'.tr,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'A powerful Flutter framework with modular architecture',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildFeatureCard(
              context,
              'Configuration Management',
              'Local & remote config with type safety',
              Icons.settings,
                  () => _testConfigManager(),
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              context,
              'Event Bus System',
              'Decoupled communication between modules',
              Icons.event,
                  () => _testEventBus(),
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              context,
              'Storage Repository',
              'Type-safe local storage with JSON serialization',
              Icons.storage,
                  () => _testStorage(),
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              context,
              'Notification System',
              'Beautiful and customizable notifications',
              Icons.notifications,
                  () => _testNotifications(),
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              context,
              'Polling Service',
              'Async task management with retry logic',
              Icons.sync,
                  () => _testPolling(),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Get.toNamed(AppRoutes.mainLayout),
              child: const Text('进入主应用'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Get.toNamed('/test'),
              child: const Text('测试导航'),
            ),
            const SizedBox(height: 16), // 底部留出空间
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context,
      String title,
      String description,
      IconData icon,
      VoidCallback onTap,
      ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showThemeSelector(BuildContext context) {
    final themeService = Cat.theme;
    if (themeService == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Light Mode'),
              leading: const Icon(Icons.light_mode),
              onTap: () {
                themeService.enableLightMode();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Dark Mode'),
              leading: const Icon(Icons.dark_mode),
              onTap: () {
                themeService.enableDarkMode();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Follow System'),
              leading: const Icon(Icons.settings_system_daydream),
              onTap: () {
                themeService.followSystem();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    final translationService = Cat.i18n;
    if (translationService == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: translationService.languages.entries.map((entry) {
            return ListTile(
              title: Text(entry.key),
              onTap: () {
                translationService.changeLocale(
                  entry.value.languageCode,
                  entry.value.countryCode,
                );
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _testConfigManager() {
    Cat.notify.showInfo(
      message: 'Configuration Manager: Supports local & remote configs with type safety and MD5 validation.',
    );
  }

  void _testEventBus() {
    // 发送测试事件
    Cat.events.fire(DataRefreshEvent(dataType: 'test_data'));
    //Cat.notify.showSuccess(message: 'Event sent! Check console for event logs.');
    Cat.notify.showSuccess(message: "Event sent! Check console for event logs.");
  }

  void _testStorage() {
    Cat.notify.showInfo(
      message: 'Storage Repository: Type-safe storage with JSON serialization support.',
    );
  }

  void _testNotifications() {
    Cat.notify.showSuccess(message: 'Success notification!');
    Future.delayed(const Duration(seconds: 1), () {
      Cat.notify.showWarning(message: 'Warning notification!');
    });
    Future.delayed(const Duration(seconds: 2), () {
      Cat.notify.showError(message: 'Error notification!');
    });
  }

  void _testPolling() {
    final pollingService = Cat.polling;
    if (pollingService == null) {
      Cat.notify.showError(message: 'Polling service not available');
      return;
    }

    // // 添加测试轮询任务
    // pollingService.addTask(
    //   config: const TaskConfig(
    //     taskId: 'demo_task',
    //     interval: Duration(seconds: 2),
    //     maxRetries: 3,
    //   ),
    //   getStatus: (taskId) async {
    //     await Future.delayed(const Duration(milliseconds: 500));
    //     return DateTime.now().millisecondsSinceEpoch.toString();
    //   },
    //   isCompleted: (status) => false, // 永不完成，用于演示
    //   onUpdate: (taskId, status) {
    //     logger.i('Polling update: $taskId -> $status');
    //   },
    //   onError: (taskId, error) {
    //     logger.e('Polling error: $taskId', error: error);
    //   },
    // );

    Cat.notify.showSuccess(message: 'Polling task started! Check console for updates.');

    // // 10秒后停止任务
    // Future.delayed(const Duration(seconds: 10), () {
    //   pollingService.removeTask('demo_task');
    //   Cat.notify.showInfo(message: 'Polling task stopped.');
    // });
  }
}


class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Page'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64),
            SizedBox(height: 16),
            Text('Demo Page'),
            Text('More features coming soon...'),
          ],
        ),
      ),
    );
  }
}
