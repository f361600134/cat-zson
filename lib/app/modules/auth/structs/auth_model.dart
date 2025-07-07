import 'package:json_annotation/json_annotation.dart';

part 'auth_model.g.dart'; // 指定生成文件的路径

///description: 登录相关数据
///author: Jeremy
///date: 2025/4/2
@JsonSerializable()
class LoginData {

  int userId;
  String accessToken;
  String refreshToken;
  int tokenExpiry;

  LoginData(this.accessToken, this.refreshToken, this.tokenExpiry, {this.userId = 0});

  // 构造一个空对象
  factory LoginData.empty() => LoginData(userId:0, "", "", 0);

  // 创建新实例的方法
  LoginData copyWith({
    int? userId,
    String? accessToken,
    String? refreshToken,
    int? tokenExpiry,
  }) {
    return LoginData(
      userId: userId ?? this.userId,
      accessToken ?? this.accessToken,
      refreshToken ?? this.refreshToken,
      tokenExpiry ?? this.tokenExpiry,
    );
  }

  // 从JSON创建一个实例
  factory LoginData.fromJson(Map<String, dynamic> json) => _$LoginDataFromJson(json);

  // 将实例转换为JSON
  Map<String, dynamic> toJson() => _$LoginDataToJson(this);
}


///description: 设备数据信息
///author: Jeremy
///date: 2025/4/4
@JsonSerializable()
class DeviceData {

  ///设备id
  String deviceId;
  ///是否安装过, 用于埋点, 一次性记录.
  bool installed;

  DeviceData(this.deviceId, this.installed);

  // 构造一个空对象
  factory DeviceData.empty() => DeviceData("", false);

  // 从JSON创建一个实例
  factory DeviceData.fromJson(Map<String, dynamic> json) => _$DeviceDataFromJson(json);

  // 将实例转换为JSON
  Map<String, dynamic> toJson() => _$DeviceDataToJson(this);

}