import 'package:get_storage/get_storage.dart';

/// 抽象存储仓库接口
abstract class IStorageRepository<T> {
  /// 读取数据
  T? read({required T Function(Map<String, dynamic>) fromJson});
  
  /// 读取数据，如果不存在则返回默认值
  T readOrDefault({
    required T Function(Map<String, dynamic>) fromJson,
    required T defaultValue,
  });
  
  /// 写入数据
  void write({
    required T item,
    required Map<String, dynamic> Function(T) toJson,
  });
  
  /// 删除数据
  void remove();
  
  /// 检查是否存在
  bool exists();
}

/// 单一对象存储仓库 - 用于存储单个配置或用户信息等
// class SingleStorageRepository<T> implements IStorageRepository<T> {
//   final GetStorage _storage;
//   final String _storageKey;
//
//   SingleStorageRepository({
//     required GetStorage storage,
//     required String storageKey,
//   }) : _storage = storage, _storageKey = storageKey;
//
//   @override
//   T? read({required T Function(Map<String, dynamic>) fromJson}) {
//     try {
//       final data = _storage.read(_storageKey);
//       if (data != null && data is Map<String, dynamic>) {
//         return fromJson(data);
//       }
//       return null;
//     } catch (e) {
//       print('[SingleStorageRepository] Read error for key $_storageKey: $e');
//       return null;
//     }
//   }
//
//   @override
//   T readOrDefault({
//     required T Function(Map<String, dynamic>) fromJson,
//     required T defaultValue,
//   }) {
//     try {
//       final data = _storage.read(_storageKey);
//       if (data != null && data is Map<String, dynamic>) {
//         return fromJson(data);
//       }
//       return defaultValue;
//     } catch (e) {
//       print('[SingleStorageRepository] ReadOrDefault error for key $_storageKey: $e');
//       return defaultValue;
//     }
//   }
//
//   @override
//   void write({
//     required T item,
//     required Map<String, dynamic> Function(T) toJson,
//   }) {
//     try {
//       _storage.write(_storageKey, toJson(item));
//     } catch (e) {
//       print('[SingleStorageRepository] Write error for key $_storageKey: $e');
//       rethrow;
//     }
//   }
//
//   @override
//   void remove() {
//     try {
//       _storage.remove(_storageKey);
//     } catch (e) {
//       print('[SingleStorageRepository] Remove error for key $_storageKey: $e');
//     }
//   }
//
//   @override
//   bool exists() {
//     return _storage.hasData(_storageKey);
//   }
// }

/// 列表存储仓库 - 用于存储对象列表
class ListStorageRepository<T> {
  final GetStorage _storage;
  final String _storageKey;

  ListStorageRepository({
    required GetStorage storage,
    required String storageKey,
  }) : _storage = storage, _storageKey = storageKey;

  /// 读取所有数据
  List<T> readAll({required T Function(Map<String, dynamic>) fromJson}) {
    try {
      final data = _storage.read(_storageKey);
      if (data != null && data is List) {
        return data
            .cast<Map<String, dynamic>>()
            .map((json) => fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('[ListStorageRepository] ReadAll error for key $_storageKey: $e');
      return [];
    }
  }

  /// 写入所有数据
  void writeAll({
    required List<T> items,
    required Map<String, dynamic> Function(T) toJson,
  }) {
    try {
      final jsonList = items.map((item) => toJson(item)).toList();
      _storage.write(_storageKey, jsonList);
    } catch (e) {
      print('[ListStorageRepository] WriteAll error for key $_storageKey: $e');
      rethrow;
    }
  }

  /// 添加单个项目
  void add({
    required T item,
    required Map<String, dynamic> Function(T) toJson,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    try {
      final currentList = readAll(fromJson: fromJson);
      currentList.add(item);
      writeAll(items: currentList, toJson: toJson);
    } catch (e) {
      print('[ListStorageRepository] Add error for key $_storageKey: $e');
      rethrow;
    }
  }

  /// 更新项目
  void update({
    required T item,
    required bool Function(T) where,
    required Map<String, dynamic> Function(T) toJson,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    try {
      final currentList = readAll(fromJson: fromJson);
      final index = currentList.indexWhere(where);
      if (index != -1) {
        currentList[index] = item;
        writeAll(items: currentList, toJson: toJson);
      }
    } catch (e) {
      print('[ListStorageRepository] Update error for key $_storageKey: $e');
      rethrow;
    }
  }

  /// 删除项目
  void deleteWhere({
    required bool Function(T) where,
    required Map<String, dynamic> Function(T) toJson,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    try {
      final currentList = readAll(fromJson: fromJson);
      currentList.removeWhere(where);
      writeAll(items: currentList, toJson: toJson);
    } catch (e) {
      print('[ListStorageRepository] DeleteWhere error for key $_storageKey: $e');
      rethrow;
    }
  }

  /// 清空所有数据
  void clear() {
    try {
      _storage.remove(_storageKey);
    } catch (e) {
      print('[ListStorageRepository] Clear error for key $_storageKey: $e');
    }
  }

  /// 检查是否存在
  bool exists() {
    return _storage.hasData(_storageKey);
  }

  /// 获取数量
  int count({required T Function(Map<String, dynamic>) fromJson}) {
    return readAll(fromJson: fromJson).length;
  }
}

/// 键值对存储仓库 - 用于存储简单的键值对
class KeyValueStorageRepository {
  final GetStorage _storage;

  KeyValueStorageRepository({required GetStorage storage}) : _storage = storage;

  /// 读取字符串
  String? readString(String key) {
    try {
      return _storage.read(key);
    } catch (e) {
      print('[KeyValueStorageRepository] ReadString error for key $key: $e');
      return null;
    }
  }

  /// 写入字符串
  void writeString(String key, String value) {
    try {
      _storage.write(key, value);
    } catch (e) {
      print('[KeyValueStorageRepository] WriteString error for key $key: $e');
    }
  }

  /// 读取整数
  int? readInt(String key) {
    try {
      return _storage.read(key);
    } catch (e) {
      print('[KeyValueStorageRepository] ReadInt error for key $key: $e');
      return null;
    }
  }

  /// 写入整数
  void writeInt(String key, int value) {
    try {
      _storage.write(key, value);
    } catch (e) {
      print('[KeyValueStorageRepository] WriteInt error for key $key: $e');
    }
  }

  /// 读取布尔值
  bool? readBool(String key) {
    try {
      return _storage.read(key);
    } catch (e) {
      print('[KeyValueStorageRepository] ReadBool error for key $key: $e');
      return null;
    }
  }

  /// 写入布尔值
  void writeBool(String key, bool value) {
    try {
      _storage.write(key, value);
    } catch (e) {
      print('[KeyValueStorageRepository] WriteBool error for key $key: $e');
    }
  }

  /// 读取双精度浮点数
  double? readDouble(String key) {
    try {
      return _storage.read(key);
    } catch (e) {
      print('[KeyValueStorageRepository] ReadDouble error for key $key: $e');
      return null;
    }
  }

  /// 写入双精度浮点数
  void writeDouble(String key, double value) {
    try {
      _storage.write(key, value);
    } catch (e) {
      print('[KeyValueStorageRepository] WriteDouble error for key $key: $e');
    }
  }

  /// 删除键
  void remove(String key) {
    try {
      _storage.remove(key);
    } catch (e) {
      print('[KeyValueStorageRepository] Remove error for key $key: $e');
    }
  }

  /// 检查键是否存在
  bool exists(String key) {
    return _storage.hasData(key);
  }

  /// 获取所有键
  Iterable<String> get keys => _storage.getKeys();

  /// 清空所有数据
  void clear() {
    try {
      _storage.erase();
    } catch (e) {
      print('[KeyValueStorageRepository] Clear error: $e');
    }
  }
}

/// 存储管理器 - 统一管理不同的存储实例
class StorageManager {
  static final StorageManager _instance = StorageManager._internal();
  factory StorageManager() => _instance;
  StorageManager._internal();

  static StorageManager get instance => _instance;

  final Map<String, GetStorage> _storageInstances = {};

  /// 初始化存储实例
  Future<GetStorage> initStorage(String containerName) async {
    if (_storageInstances.containsKey(containerName)) {
      return _storageInstances[containerName]!;
    }

    try {
      await GetStorage.init(containerName);
      final storage = GetStorage(containerName);
      _storageInstances[containerName] = storage;
      return storage;
    } catch (e) {
      print('[StorageManager] Init storage error for $containerName: $e');
      rethrow;
    }
  }

  /// 获取存储实例
  GetStorage? getStorage(String containerName) {
    return _storageInstances[containerName];
  }

  // /// 创建单一对象存储仓库
  // SingleStorageRepository<T> createSingleRepository<T>({
  //   required String containerName,
  //   required String key,
  // }) {
  //   final storage = getStorage(containerName);
  //   if (storage == null) {
  //     throw Exception('Storage container $containerName not initialized');
  //   }
  //   return SingleStorageRepository<T>(storage: storage, storageKey: key);
  // }

  /// 创建列表存储仓库
  ListStorageRepository<T> createListRepository<T>({
    required String containerName,
    required String key,
  }) {
    final storage = getStorage(containerName);
    if (storage == null) {
      throw Exception('Storage container $containerName not initialized');
    }
    return ListStorageRepository<T>(storage: storage, storageKey: key);
  }

  /// 创建键值对存储仓库
  KeyValueStorageRepository createKeyValueRepository({
    required String containerName,
  }) {
    final storage = getStorage(containerName);
    if (storage == null) {
      throw Exception('Storage container $containerName not initialized');
    }
    return KeyValueStorageRepository(storage: storage);
  }

  /// 销毁所有存储实例
  void dispose() {
    _storageInstances.clear();
  }
}
