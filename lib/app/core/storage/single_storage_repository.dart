import 'package:cat_framework/app/core/storage/storage_get_service.dart';

///description: 单存储服务
///author: Jeremy
///date: 2025/2/5
abstract class SingleStorageRepository<T> {

  final StorageGetService storage;
  final String storageKey;

  //late T data;

  SingleStorageRepository({
    required this.storage,
    required this.storageKey,
  });


  /// 读取单个对象
  T? read({
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    final data = storage.read(storageKey);
    if (data != null){
      return fromJson(data);
    }
    return null;
  }

  /// 读取数据, 不存在则返回一个默认数据
  T readOrDefault({
    required T Function(Map<String, dynamic>) fromJson,
    required T defaultValue,
  }) {
    final data = storage.read(storageKey);
    return data != null ? fromJson(data) : defaultValue;
  }

  /// 保存单个对象
  void write({
    required T item,
    required Map<String, dynamic> Function(T) toJson,
  }) {
    storage.write(storageKey, toJson(item));
  }

  /// 删除对象
  void remove() {
    storage.remove(storageKey);
  }

}