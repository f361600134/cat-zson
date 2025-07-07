import 'package:cat_zson_pro/app/modules/home/home_page.dart';
import 'package:cat_zson_pro/app/modules/main/main_layout.dart';
import 'package:cat_zson_pro/app/modules/profile/profile_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'app_routes.dart';

class AppPages {

  static final initial = AppRoutes.mainLayout;

  static final routes = [
    GetPage(name: '/', page: () => const HomePage()),
    GetPage(name: '/demo', page: () => const DemoPage()),
    GetPage(name: AppRoutes.mainLayout, page: () => const MainLayout()),
    GetPage(name: AppRoutes.dashboard, page: () => const MainLayout()),
    GetPage(name: AppRoutes.analytics, page: () => const MainLayout()),
    GetPage(name: AppRoutes.products, page: () => const MainLayout()),
    GetPage(name: AppRoutes.users, page: () => const MainLayout()),
    GetPage(name: AppRoutes.orders, page: () => const MainLayout()),
    GetPage(name: AppRoutes.marketing, page: () => const MainLayout()),
    GetPage(name: AppRoutes.support, page: () => const MainLayout()),
    GetPage(name: AppRoutes.settings, page: () => const MainLayout()),
    GetPage(name: AppRoutes.profile, page: () => const ProfilePage()),
    // GetPage(
    //   name: AppRoutes.splash,
    //   page: () => SplashView(),
    //   binding: SplashBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.navigation,
    //   page: () => NavigationView(),
    //   binding: NavigationBinding(),
    //   bindings: [
    //   ],
    //   middlewares: [AuthMiddleware()], // 受保护页面使用中间件
    // ),
  ];
}

class AuthMiddleware extends GetMiddleware {

  @override
  int? get priority => 1; // 控制中间件的执行优先级，数值越小优先级越高

  @override
  RouteSettings? redirect(String? route) {
    // if (!AuthService.to.isLoggedIn) {
    //   return const RouteSettings(name: AppRoutes.login);
    // }
    return null; // 表示通过
  }
}
