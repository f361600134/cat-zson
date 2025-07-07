import 'package:cat_zson_pro/app/core/network/protocol_adapter.dart';
import 'package:cat_zson_pro/app/modules/auth/device_service.dart';
import 'package:cat_zson_pro/app/modules/auth/repository/auth_repository.dart';
import 'package:cat_zson_pro/app/modules/auth/structs/auth_model.dart';
import 'package:cat_zson_pro/app/modules/auth/structs/auth_proto.dart';
import 'package:cat_zson_pro/app/routes/app_routes.dart';
import 'package:cat_zson_pro/app/utils/logger.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';

/// 验证状态
enum AuthStatus {
  unknown, //未知
  authenticated, //已认证
  unauthenticated, //未验证
}

///description: 登录认证服务管理类, 存储业务可以抽出来实现一个repository
///author: Jeremy
///date: 2025/3/8
class AuthService extends GetxService {

  final LoginRepository loginRepository;
  final IProtocolClient client;

  AuthService(this.loginRepository, this.client);

  ///是否处于登录
  final authStatus = AuthStatus.unknown.obs;
  ///是否重新加载数据
  final reload = false.obs;

  late LoginData loginData;

  // 快捷访问方式 AuthService.to
  static AuthService get to => Get.find();

  /// 取 token
  String getToken() => loginData.accessToken;

  /// 获取刷新令牌
  String getRefreshToken() => loginData.refreshToken;

  /// 获取令牌过期时间
  int getTokenExpiry() => loginData.tokenExpiry;

  /// 清 token
  void clearTokens() {
    loginData = LoginData.empty();
    loginRepository.write(item: loginData, toJson: (c) => c.toJson());
  }

  /// 存token
  void saveTokens(int userId, String accessToken, String refreshToken, int expiresAt) {
    loginData = loginData.copyWith(
      userId: userId,
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenExpiry: expiresAt,
    );
    //表示登录成功, 改状态为已校验
    authStatus.value = AuthStatus.authenticated;
    loginRepository.write(item: loginData, toJson: (c) => c.toJson());
  }

  /// 初始化：同步加载本地 token
  @override
  Future<void> onInit() async {
    loginData = loginRepository.readOrDefault(
      fromJson: LoginData.fromJson,
      defaultValue: LoginData.empty(),
    );
    super.onInit();
  }

  /// 退出登录，清理 Token
  Future<void> logout() async {
    clearTokens();
    
    // 如果Google登录服务存在，同时登出Google账号
    // try {
    //   if (Get.isRegistered<GoogleLoginService>()) {
    //     final googleService = Get.find<GoogleLoginService>();
    //     await googleService.signOut();
    //   }
    // } catch (e) {
    //   logger.w('Google sign out error during logout', error: e);
    // }
    
    Get.offAllNamed(AppRoutes.login); // 跳转到登录页面
  }

  /// 检查是否已登录
  bool get isLoggedIn => getToken().isNotEmpty && getRefreshToken().isNotEmpty;

  /// 获取当前账号用户id
  int get userId => loginData.userId;

  /// 检查令牌是否过期
  bool isTokenExpired() {
    int expiryTime = getTokenExpiry();
    if (expiryTime == 0) return true;
    // 提前5分钟刷新令牌，避免刚好在请求时过期
    return DateTime.now().millisecondsSinceEpoch + 300000 > expiryTime;
  }

  // 刷新令牌锁, 防止多次刷新
  bool _isRefreshing = false;

  // 刷新访问令牌
  Future<bool> refreshToken() async {
    // 如果已经在刷新中，等待
    if (_isRefreshing) {
      // 等待1秒后再检查是否还在刷新
      await Future.delayed(Duration(seconds: 1));
      return !isTokenExpired();
    }
    try {
      _isRefreshing = true;
      // 获取刷新令牌
      String refreshToken = getRefreshToken();
      if (refreshToken.isEmpty) {
        return false;
      }
      // 发送刷新令牌请求
      //final response = await _loginAdapter.refreshToken(refreshToken);
      final response = await client.request(ReqRefreshToken(refreshToken));
      if (response.success) {
        ResRefreshToken resRefreshToken = response.data!;
        // 保存新令牌
        saveTokens(resRefreshToken.userId, resRefreshToken.token, resRefreshToken.refreshToken,resRefreshToken.expiresAt);
        return true;
      }
      // 刷新失败, 清除令牌并返回登录页
      clearTokens();
      Get.offAllNamed(AppRoutes.login);
      return false;
    } catch (e) {
      logger.e('Token refresh error', error: e);
      // 发生错误，清除令牌并返回登录页
      logout();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  ///校验设备信息是否一致
  ///true: 一致
  Future<bool> checkDeviceInfo() async{
    final deviceService = Get.find<DeviceService>();
    //判断平台
    ReqCheckDeviceInfo req;
    if(deviceService.isIOS){
      //IOS
      String deviceId = await deviceService.getDeviceId();
      IosDeviceInfo deviceInfo = await deviceService.getIOSInfo();
      String appVersion = deviceService.currentVersion;
      req = ReqCheckDeviceInfo(deviceId, "IOS", deviceInfo.model, deviceInfo.utsname.machine, appVersion);
    }else{
      //Android
      String deviceId = await deviceService.getDeviceId();
      AndroidDeviceInfo deviceInfo = await deviceService.getAndroidInfo();
      String appVersion = deviceService.currentVersion;
      req = ReqCheckDeviceInfo(deviceId, "Android", deviceInfo.model, deviceInfo.version.release, appVersion);
    }

    try {
      final response = await client.request(req);
      if (response.intercept(notice: true)) {
        return false;
      }
      return response.data!.same;
    }catch(e){
      logger.e("checkDeviceInfo error", error: e);
    }
    return false;
  }

  /// 验证授权
  Future<void> checkAuth() async {
    // 检查令牌是否需要刷新
    if (isLoggedIn && isTokenExpired()) {
      //如果过期, 尝试刷新token
      bool refresh = await refreshToken();
      if (!refresh){
        //认证失败
        authStatus.value = AuthStatus.unauthenticated;
      }
    }
    authStatus.value = isLoggedIn ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    // 检查是否需要重载数据
    reload.value = !await checkDeviceInfo();
    // 发登录成功事件
    //AppEventBus.instance.fire(LoginSuccessEvent());
  }


}