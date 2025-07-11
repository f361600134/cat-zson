import 'package:cat_framework/app/core/network/protocol_adapter.dart';
import 'package:cat_framework/app/modules/auth/auth_service.dart';
import 'package:cat_framework/app/modules/auth/device_service.dart';
import 'package:cat_framework/app/modules/auth/repository/auth_repository.dart';
import 'package:cat_framework/app/modules/auth/repository/device_repository.dart';
import 'package:get/get.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    //Get.lazyPut(() => GoogleLoginService());
    Get.lazyPut(()=> DeviceService(DeviceRepository()));
    Get.lazyPut(() => AuthService(LoginRepository(), Get.find<DefaultProtocolClient>()));

  }
}
