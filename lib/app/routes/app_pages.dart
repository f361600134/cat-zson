import 'package:cat_zson_pro/app/modules/dashboard/dashboard_page.dart';
import 'package:cat_zson_pro/app/modules/home/home_page.dart';
import 'package:cat_zson_pro/app/modules/navigation/navigation_binding.dart';
import 'package:cat_zson_pro/app/modules/profile/profile_page.dart';
import 'package:cat_zson_pro/app/modules/navigation/navigation_page.dart';
import 'package:cat_zson_pro/app/modules/settings/settings_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'app_routes.dart';

// DemoPage 别名，指向 DashboardPage
typedef DemoPage = DashboardPage;

class AppPages {

  static final initial = AppRoutes.navigation;

  static final routes = [
    GetPage(name: '/', page: () => const DashboardPage()),
    GetPage(name: AppRoutes.profile, page: () => const ProfilePage()),
    GetPage(name: AppRoutes.navigation, page: () => const NavigationPage()
        , binding: NavigationBinding(), middlewares: [AuthMiddleware()]),

    // GetPage(
    //   name: AppRoutes.splash,
    //   page: () => SplashView(),
    //   binding: SplashBinding(),
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
