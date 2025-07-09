import 'package:cat_zson_pro/app/modules/home/home_page.dart';
import 'package:cat_zson_pro/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'app/core/framework/cat_framework.dart';
import 'app/core/network/protocol_adapter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化Cat Framework
  await CatFramework.instance.initialize(
    config: const CatFrameworkConfig(),
    networkPlugins: [
      LoggingPlugin(enableDetailLog: true),
      CachePlugin(),
      RetryPlugin(maxRetries: 2),
    ],
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CatFramework.instance.createApp(
      title: 'Cat Framework',
      home: const HomePage(),
      pages: AppPages.routes,
      builder: (context, child) {
        return ResponsiveBreakpoints.builder(
          child: child!,
          breakpoints: const [
            Breakpoint(start: 0, end: 450, name: MOBILE),
            Breakpoint(start: 451, end: 800, name: TABLET),
            Breakpoint(start: 801, end: 1920, name: DESKTOP),
            Breakpoint(start: 1921, end: double.infinity, name: '4K'),
          ],
        );
      },
    );
  }
}



