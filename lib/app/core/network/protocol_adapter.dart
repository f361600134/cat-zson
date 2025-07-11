import 'dart:async';
import 'package:cat_framework/app/core/framework/cat_framework.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../utils/logger.dart';

/// HTTP方法枚举
enum HttpMethod {
  get,
  post,
  put,
  delete,
}

/// 通用API响应结构
class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;

  ApiResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse<T>(
      code: json['code'] as int,
      message: json['message'] as String,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson(dynamic Function(T) toJsonT) => {
        'code': code,
        'message': message,
        'data': data != null ? toJsonT(data as T) : null,
      };

  /// 是否成功
  bool get success => code == 0;

  /// 是否警告
  bool get warn => code > 0 && code <= 100;

  /// 是否失败
  bool get failed => code > 100;

  /// 拦截并提示用户
  bool intercept({bool notice = false}) {
    bool hasError = !success;
    if (hasError && notice) {
      if (warn) {
        // 显示警告
        Cat.notify.showWarning(message:message);
      } else if (failed) {
        // 显示错误
        Cat.notify.showError(message: message);
      }
    }
    return hasError;
  }
}

/// 协议响应接口
abstract class IProtocolResp {
  Map<String, dynamic> toJson();
}

/// 抽象协议接口
abstract class IProtocolReq<T> {
  /// 请求方法
  HttpMethod get method => HttpMethod.post;

  /// API路径
  String get url;

  /// 请求参数转JSON
  Map<String, dynamic> toJson();

  /// 响应解码器
  ApiResponse<T> decode(dynamic data);
}

/// 协议客户端接口
abstract class IProtocolClient {
  Future<ApiResponse<T>> request<T>(IProtocolReq<T> proto);
}

/// 适配器插件抽象类
abstract class AdapterPlugin {
  /// 请求前执行（可返回缓存、替换请求、拦截请求）
  Future<ApiResponse<T>?> before<T>(IProtocolReq<T> proto);

  /// 请求成功后执行（可缓存结果、打印日志等）
  Future<void> after<T>(IProtocolReq<T> proto, ApiResponse<T> response);

  /// 请求出错时执行（可选择是否拦截异常、处理重试）
  Future<bool> onError<T>(IProtocolReq<T> proto, dynamic error);
}

/// 默认协议客户端实现
class DefaultProtocolClient extends IProtocolClient {
  final List<AdapterPlugin> plugins;

  DefaultProtocolClient({List<AdapterPlugin>?plugins}):plugins = plugins??[];

  @override
  Future<ApiResponse<T>> request<T>(IProtocolReq<T> proto) async {
    switch (proto.method) {
      case HttpMethod.post:
        return _post(proto);
      case HttpMethod.get:
        return _get(proto);
      case HttpMethod.put:
        return _put(proto);
      case HttpMethod.delete:
        return _delete(proto);
    }
  }

  Future<ApiResponse<T>> _post<T>(IProtocolReq<T> proto) async {
    final cached = await _runBefore(proto);
    if (cached != null) return cached;

    try {
      final response = await Get.find<GetConnect>().post(
        proto.url,
        proto.toJson(),
        decoder: (data) => proto.decode(data),
      );

      if (response.status.hasError) {
        throw Exception(response.statusText ?? 'Request failed');
      }

      final result = response.body as ApiResponse<T>;
      await _runAfter(proto, result);
      return result;
    } catch (e) {
      final handled = await _runError(proto, e);
      if (!handled) rethrow;
      rethrow;
    }
  }

  Future<ApiResponse<T>> _get<T>(IProtocolReq<T> proto) async {
    final cached = await _runBefore(proto);
    if (cached != null) return cached;

    try {
      var json = proto.toJson();
      String url = proto.url;
      
      if (json.isNotEmpty) {
        Map<String, String> queryParams = {};
        json.forEach((key, value) {
          if (value != null) {
            queryParams[key] = value.toString();
          }
        });
        url = '$url?${Uri(queryParameters: queryParams).query}';
      }

      final response = await Get.find<GetConnect>().get(
        url,
        decoder: (data) => proto.decode(data),
      );

      if (response.status.hasError) {
        throw Exception(response.statusText ?? 'Request failed');
      }

      final result = response.body as ApiResponse<T>;
      await _runAfter(proto, result);
      return result;
    } catch (e) {
      final handled = await _runError(proto, e);
      if (!handled) rethrow;
      rethrow;
    }
  }

  Future<ApiResponse<T>> _put<T>(IProtocolReq<T> proto) async {
    final cached = await _runBefore(proto);
    if (cached != null) return cached;

    try {
      final response = await Get.find<GetConnect>().put(
        proto.url,
        proto.toJson(),
        decoder: (data) => proto.decode(data),
      );

      if (response.status.hasError) {
        throw Exception(response.statusText ?? 'Request failed');
      }

      final result = response.body as ApiResponse<T>;
      await _runAfter(proto, result);
      return result;
    } catch (e) {
      final handled = await _runError(proto, e);
      if (!handled) rethrow;
      rethrow;
    }
  }

  Future<ApiResponse<T>> _delete<T>(IProtocolReq<T> proto) async {
    final cached = await _runBefore(proto);
    if (cached != null) return cached;

    try {
      final response = await Get.find<GetConnect>().delete(
        proto.url,
        decoder: (data) => proto.decode(data),
      );

      if (response.status.hasError) {
        throw Exception(response.statusText ?? 'Request failed');
      }

      final result = response.body as ApiResponse<T>;
      await _runAfter(proto, result);
      return result;
    } catch (e) {
      final handled = await _runError(proto, e);
      if (!handled) rethrow;
      rethrow;
    }
  }

  Future<ApiResponse<T>?> _runBefore<T>(IProtocolReq<T> proto) async {
    for (final plugin in plugins) {
      final result = await plugin.before(proto);
      if (result != null) return result;
    }
    return null;
  }

  Future<void> _runAfter<T>(IProtocolReq<T> proto, ApiResponse<T> response) async {
    for (final plugin in plugins) {
      await plugin.after(proto, response);
    }
  }

  Future<bool> _runError<T>(IProtocolReq<T> proto, dynamic error) async {
    for (final plugin in plugins) {
      final handled = await plugin.onError(proto, error);
      if (handled) return true;
    }
    return false;
  }
}

/// 日志插件
class LoggingPlugin extends AdapterPlugin {
  final bool enableDetailLog;

  LoggingPlugin({this.enableDetailLog = false});

  @override
  Future<ApiResponse<T>?> before<T>(IProtocolReq<T> proto) async {
    logger.i('Sending: ${proto.url}');
    if (enableDetailLog) {
      logger.d('Request: ${proto.toJson()}');
    }
    return null;
  }

  @override
  Future<void> after<T>(IProtocolReq<T> proto, ApiResponse<T> response) async {
    logger.i('Success: ${proto.url} - Code: ${response.code}');
    if (enableDetailLog) {
      if (response.data is IProtocolResp) {
        var resp = response.data as IProtocolResp;
        logger.d('Response: ${resp.toJson()}');
      } else {
        logger.d('Response: ${response.message}');
      }
    }
  }

  @override
  Future<bool> onError<T>(IProtocolReq<T> proto, error) async {
    logger.e('Error: ${proto.url}', error: error);
    return false;
  }
}

/// 重试插件
class RetryPlugin extends AdapterPlugin {
  final int maxRetries;
  int _currentRetryCount = 0;

  RetryPlugin({this.maxRetries = 2});

  @override
  Future<bool> onError<T>(IProtocolReq<T> proto, error) async {
    if (_currentRetryCount < maxRetries) {
      _currentRetryCount++;
      logger.i('Retrying ${proto.url} (attempt $_currentRetryCount/$maxRetries)');
      return true; // 告知框架重新执行请求
    }
    _currentRetryCount = 0; // 重置计数器
    return false;
  }

  @override
  Future<ApiResponse<T>?> before<T>(IProtocolReq<T> proto) async => null;

  @override
  Future<void> after<T>(IProtocolReq<T> proto, ApiResponse<T> response) async {
    _currentRetryCount = 0; // 成功后重置
  }
}

/// 加载指示器插件
class LoadingPlugin extends AdapterPlugin {
  final String message;
  final bool showDialog;

  LoadingPlugin({
    this.message = '请稍候...',
    this.showDialog = true,
  });

  @override
  Future<ApiResponse<T>?> before<T>(IProtocolReq<T> proto) async {
    if (showDialog) {
      Get.dialog(
        AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 16),
              Text(message, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
        barrierDismissible: false,
      );
    }
    return null;
  }

  @override
  Future<void> after<T>(IProtocolReq<T> proto, ApiResponse<T> response) async {
    if (showDialog && Get.isDialogOpen == true) {
      Get.back();
    }
  }

  @override
  Future<bool> onError<T>(IProtocolReq<T> proto, error) async {
    if (showDialog && Get.isDialogOpen == true) {
      Get.back();
    }
    return false;
  }
}

/// 缓存插件
class CachePlugin extends AdapterPlugin {
  final Map<String, dynamic> _cache = {};
  final Duration cacheDuration;

  CachePlugin({this.cacheDuration = const Duration(minutes: 5)});

  @override
  Future<ApiResponse<T>?> before<T>(IProtocolReq<T> proto) async {
    final key = _getCacheKey(proto);
    final cachedData = _cache[key];
    
    if (cachedData != null) {
      final cacheTime = cachedData['timestamp'] as DateTime;
      if (DateTime.now().difference(cacheTime) < cacheDuration) {
        logger.d('Cache hit: ${proto.url}');
        return cachedData['response'] as ApiResponse<T>;
      } else {
        _cache.remove(key);
      }
    }
    return null;
  }

  @override
  Future<void> after<T>(IProtocolReq<T> proto, ApiResponse<T> response) async {
    if (response.success) {
      final key = _getCacheKey(proto);
      _cache[key] = {
        'response': response,
        'timestamp': DateTime.now(),
      };
      logger.d('Cached: ${proto.url}');
    }
  }

  @override
  Future<bool> onError<T>(IProtocolReq<T> proto, error) async => false;

  String _getCacheKey<T>(IProtocolReq<T> proto) {
    return '${proto.url}_${proto.toJson().toString()}';
  }

  void clearCache() => _cache.clear();
}
