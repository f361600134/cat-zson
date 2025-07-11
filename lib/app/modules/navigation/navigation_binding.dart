import 'package:cat_framework/app/core/framework/page_cache_manager.dart';
import 'package:get/get.dart';
import 'navigation_controller.dart';

class NavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PageCacheManager());
    Get.lazyPut(() => NavigationController());
  }
}
