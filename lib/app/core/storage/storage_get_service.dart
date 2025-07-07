
import 'package:get_storage/get_storage.dart';
import 'package:flutter/foundation.dart';

/// 封装 GetStorage 的存储服务
class StorageGetService {
  static final StorageGetService _instance = StorageGetService._internal();
  late GetStorage _box;

  factory StorageGetService() => _instance;

  StorageGetService._internal();

  /// 初始化存储（必须在应用启动时调用）
  static Future<void> init() async {
    await GetStorage.init();
    _instance._box = GetStorage();
  }

  /// 写入数据（同步内存，异步持久化）
  void write<T>(String key, T value) {
    try {
      _box.write(key, value);
    } catch (e) {
      debugPrint('Storage Write Error: $e');
    }
  }

  /// 读取数据（同步）
  T? read<T>(String key) {
    try {
      return _box.read<T>(key);
    } catch (e) {
      debugPrint('Storage Read Error: $e');
      return null;
    }
  }

  /// 删除指定键
  void remove(String key) {
    _box.remove(key);
  }

  /// 清空所有数据
  void clearAll() {
    _box.erase();
  }

  /// 监听特定键变化
  VoidCallback listenKey(String key, Function(dynamic) callback) {
    return _box.listenKey(key, callback);
  }

  /// 手动持久化到磁盘（可选）
  Future<void> save() async {
    await _box.save();
  }

  /// 读取数据并指定默认值
  T readWithDefault<T>(String key, T defaultValue) {
    return read<T>(key) ?? defaultValue;
  }

  /// 存储对象（自动JSON序列化）
  void writeObject(String key, Object value) {
    write(key, value);
  }

  /// 读取对象（自动JSON反序列化）
  T? readObject<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final data = read<Map<String, dynamic>>(key);
    return data != null ? fromJson(data) : null;
  }

  /// 存储任意对象列表
  void writeList<T>(String key, List<T> items, {required Map<String, dynamic> Function(T) toJson}) {
    final jsonList = items.map((item) => toJson(item)).toList();
    write(key, jsonList);
  }

  /// 读取任意对象列表
  List<T> readList<T>(String key, {required T Function(Map<String, dynamic>) fromJson}) {
    final jsonList = read<List<dynamic>>(key);
    if (jsonList == null) return [];
    return jsonList
        .map((json) => fromJson(json as Map<String, dynamic>))
        .toList();
  }

}