import 'package:cat_framework/app/core/network/protocol_adapter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'auth_proto.g.dart'; // 指定生成文件的路径

@JsonSerializable()
class ResSms {
  String code;

  ResSms({required this.code});

  // 从JSON创建一个实例
  factory ResSms.fromJson(Map<String, dynamic> json) => _$ResSmsFromJson(json);

  // 将实例转换为JSON
  Map<String, dynamic> toJson() => _$ResSmsToJson(this);
}

@JsonSerializable()
class ResLogin {

  UserDto userDto;
  String token;
  String refreshToken;
  int expiresAt;

  ResLogin({
    required this.userDto,
    required this.token,
    required this.refreshToken,
    required this.expiresAt,
  });

  // 从JSON创建一个实例
  factory ResLogin.fromJson(Map<String, dynamic> json) => _$ResLoginFromJson(json);

  // 将实例转换为JSON
  Map<String, dynamic> toJson() => _$ResLoginToJson(this);

}

@JsonSerializable()
class UserDto {

  int userId;
  String username;
  String nickname;
  String avatar;

  UserDto({required this.userId,
    required this.username,
    required this.nickname,
    required this.avatar,
  });

  // 从JSON创建一个实例
  factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);

  // 将实例转换为JSON
  Map<String, dynamic> toJson() => _$UserDtoToJson(this);

}

///请求刷新token
@JsonSerializable()
class ReqRefreshToken extends IProtocolReq<ResRefreshToken>{

  String refreshToken;

  ReqRefreshToken(this.refreshToken);

  @override
  ApiResponse<ResRefreshToken> decode(data) {
   return ApiResponse<ResRefreshToken>.fromJson(data, (json) => ResRefreshToken.fromJson(json as Map<String, dynamic>));
  }

  factory ReqRefreshToken.fromJson(Map<String, dynamic> json) => _$ReqRefreshTokenFromJson(json);
  
  Map<String, dynamic> toJson() => _$ReqRefreshTokenToJson(this);

  @override
  String get url => "/api/auth/refresh-token";

  @override
  HttpMethod get method => HttpMethod.post;

}

@JsonSerializable()
class ResRefreshToken {

  int userId;
  String token;
  String refreshToken;
  //过期时间点
  int expiresAt;

  ResRefreshToken({required this.userId, required this.refreshToken, required this.token, required this.expiresAt});

  // 从JSON创建一个实例
  factory ResRefreshToken.fromJson(Map<String, dynamic> json) => _$ResRefreshTokenFromJson(json);

  // 将实例转换为JSON
  Map<String, dynamic> toJson() => _$ResRefreshTokenToJson(this);

}

/// 响应设备信息
@JsonSerializable()
class ReqCheckDeviceInfo extends IProtocolReq<ResCheckDeviceInfo>{
  /// 设备uuid
  String deviceId;
  /// 平台
  String platform;
  //
  String model;
  // 系统版本
  String osVersion;
  // 应用版本
  String appVersion;

  ReqCheckDeviceInfo(this.deviceId, this.platform, this.model, this.osVersion, this.appVersion);

  // 从JSON创建一个实例
  factory ReqCheckDeviceInfo.fromJson(Map<String, dynamic> json) => _$ReqCheckDeviceInfoFromJson(json);

  // 将实例转换为JSON
  @override
  Map<String, dynamic> toJson() => _$ReqCheckDeviceInfoToJson(this);
  
  @override
  ApiResponse<ResCheckDeviceInfo> decode(data) {
    return ApiResponse<ResCheckDeviceInfo>.fromJson(data, (json) => ResCheckDeviceInfo.fromJson(json as Map<String, dynamic>));
  }

  @override
  String get url => "/api/user/check-device-info";

}

@JsonSerializable()
class ResCheckDeviceInfo{
  //是否更换了设备
  bool same;

  ResCheckDeviceInfo(this.same);

  // 从JSON创建一个实例
  factory ResCheckDeviceInfo.fromJson(Map<String, dynamic> json) => _$ResCheckDeviceInfoFromJson(json);

  // 将实例转换为JSON
  Map<String, dynamic> toJson() => _$ResCheckDeviceInfoToJson(this);

}

