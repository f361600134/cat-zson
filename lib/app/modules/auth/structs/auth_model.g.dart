// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginData _$LoginDataFromJson(Map<String, dynamic> json) => LoginData(
      json['accessToken'] as String,
      json['refreshToken'] as String,
      (json['tokenExpiry'] as num).toInt(),
      userId: (json['userId'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$LoginDataToJson(LoginData instance) => <String, dynamic>{
      'userId': instance.userId,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'tokenExpiry': instance.tokenExpiry,
    };

DeviceData _$DeviceDataFromJson(Map<String, dynamic> json) => DeviceData(
      json['deviceId'] as String,
      json['installed'] as bool,
    );

Map<String, dynamic> _$DeviceDataToJson(DeviceData instance) =>
    <String, dynamic>{
      'deviceId': instance.deviceId,
      'installed': instance.installed,
    };
