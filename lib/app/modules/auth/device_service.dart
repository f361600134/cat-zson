import 'package:cat_zson_pro/app/modules/auth/repository/device_repository.dart';
import 'package:cat_zson_pro/app/modules/auth/structs/auth_model.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

///description: 设备服务
///author: Jeremy
///date: 2025/4/4
class DeviceService extends GetxService{

  final DeviceRepository repository;

  late DeviceData deviceData;
  late PackageInfo _packageInfo;

  DeviceService(this.repository);

  @override
  Future<void> onInit() async {
    super.onInit();
    deviceData = repository.readOrDefault(fromJson: DeviceData.fromJson, defaultValue: DeviceData.empty());
    _packageInfo = await PackageInfo.fromPlatform();
  }

  /// 获取设备号,如果获取不到,则返回生成的uuid
  Future<String> getDeviceId() async {
    String? deviceUid = deviceData.deviceId;
    if (deviceUid != "") return deviceUid;

    final deviceInfo = DeviceInfoPlugin();
    if (await deviceInfo.deviceInfo is AndroidDeviceInfo) {
      deviceUid = (await deviceInfo.androidInfo).id;
    } else if (await deviceInfo.deviceInfo is IosDeviceInfo) {
      deviceUid = (await deviceInfo.iosInfo).identifierForVendor;
    }
    deviceUid ??= const Uuid().v4();
    deviceData.deviceId = deviceUid;
    repository.write(item: deviceData, toJson: (c) => c.toJson());
    return deviceUid;
  }

  /// 是否安卓平台
  bool get isAndroid => GetPlatform.isAndroid;

  /// 是否安卓平台
  bool get isIOS=> GetPlatform.isIOS;

  /// 获取安卓的版本
  Future<AndroidDeviceInfo> getAndroidInfo() async{
    return await DeviceInfoPlugin().androidInfo;
  }

  /// 获取IOS信息
  Future<IosDeviceInfo> getIOSInfo() async{
    return await DeviceInfoPlugin().iosInfo;
  }

  ///是否首次登录
  Future<bool> isFirstInstall() async {
    final installed = deviceData.installed;
    if (!installed) {
      deviceData.installed = true;
      return true;
    }
    return false;
  }

  ///平台信息
  String get getPlatform => isIOS ? "IOS" : (isAndroid ? "Android" : "Unknown");
  ///当前版本
  String get currentVersion => "v${_packageInfo.version}";
  ///内部版本号
  String get buildNumber => _packageInfo.buildNumber;
  ///app名字
  String get appName => _packageInfo.appName;
  ///包名
  String get packageName => _packageInfo.packageName;

}