import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_routes.dart';

class TestNavigationPage extends StatelessWidget {
  const TestNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('测试导航'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => Get.toNamed('/'),
              child: const Text('返回首页'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Get.toNamed(AppRoutes.mainLayout),
              child: const Text('进入主应用'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Get.toNamed(AppRoutes.dashboard),
              child: const Text('仪表板'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Get.toNamed(AppRoutes.settings),
              child: const Text('设置页面'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Get.toNamed(AppRoutes.profile),
              child: const Text('个人资料'),
            ),
          ],
        ),
      ),
    );
  }
}
