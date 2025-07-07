// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_proto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResSms _$ResSmsFromJson(Map<String, dynamic> json) => ResSms(
      code: json['code'] as String,
    );

Map<String, dynamic> _$ResSmsToJson(ResSms instance) => <String, dynamic>{
      'code': instance.code,
    };

ResLogin _$ResLoginFromJson(Map<String, dynamic> json) => ResLogin(
      userDto: UserDto.fromJson(json['userDto'] as Map<String, dynamic>),
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: (json['expiresAt'] as num).toInt(),
    );

Map<String, dynamic> _$ResLoginToJson(ResLogin instance) => <String, dynamic>{
      'userDto': instance.userDto,
      'token': instance.token,
      'refreshToken': instance.refreshToken,
      'expiresAt': instance.expiresAt,
    };

UserDto _$UserDtoFromJson(Map<String, dynamic> json) => UserDto(
      userId: (json['userId'] as num).toInt(),
      username: json['username'] as String,
      nickname: json['nickname'] as String,
      avatar: json['avatar'] as String,
    );

Map<String, dynamic> _$UserDtoToJson(UserDto instance) => <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'nickname': instance.nickname,
      'avatar': instance.avatar,
    };

ReqRefreshToken _$ReqRefreshTokenFromJson(Map<String, dynamic> json) =>
    ReqRefreshToken(
      json['refreshToken'] as String,
    );

Map<String, dynamic> _$ReqRefreshTokenToJson(ReqRefreshToken instance) =>
    <String, dynamic>{
      'refreshToken': instance.refreshToken,
    };

ResRefreshToken _$ResRefreshTokenFromJson(Map<String, dynamic> json) =>
    ResRefreshToken(
      userId: (json['userId'] as num).toInt(),
      refreshToken: json['refreshToken'] as String,
      token: json['token'] as String,
      expiresAt: (json['expiresAt'] as num).toInt(),
    );

Map<String, dynamic> _$ResRefreshTokenToJson(ResRefreshToken instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'token': instance.token,
      'refreshToken': instance.refreshToken,
      'expiresAt': instance.expiresAt,
    };

ReqCheckDeviceInfo _$ReqCheckDeviceInfoFromJson(Map<String, dynamic> json) =>
    ReqCheckDeviceInfo(
      json['deviceId'] as String,
      json['platform'] as String,
      json['model'] as String,
      json['osVersion'] as String,
      json['appVersion'] as String,
    );

Map<String, dynamic> _$ReqCheckDeviceInfoToJson(ReqCheckDeviceInfo instance) =>
    <String, dynamic>{
      'deviceId': instance.deviceId,
      'platform': instance.platform,
      'model': instance.model,
      'osVersion': instance.osVersion,
      'appVersion': instance.appVersion,
    };

ResCheckDeviceInfo _$ResCheckDeviceInfoFromJson(Map<String, dynamic> json) =>
    ResCheckDeviceInfo(
      json['same'] as bool,
    );

Map<String, dynamic> _$ResCheckDeviceInfoToJson(ResCheckDeviceInfo instance) =>
    <String, dynamic>{
      'same': instance.same,
    };
