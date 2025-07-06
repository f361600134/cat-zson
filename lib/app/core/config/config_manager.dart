import 'dart:convert';
import 'dart:async';
import 'package:get/get.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// 配置接口 - 所有配置类必须实现此接口
abstract class IConfig {
  int get id;
}

/// 抽象的配置容器接口
abstract class IConfigContainer<T extends IConfig> {
  /// 加载所有配置
  Future<void> loadAll();

  /// 获取指定id的配置
  T? getConfig(int id);

  /// 获取默认第一条配置
  T? get getUnique;

  /// 获取全部配置
  Map<int, T> get allConfigs;

  /// 加载完成后执行的回调
  void afterLoad();

  /// 重新加载配置
  Future<bool> reloadAll(bool force);
}

/// 抽象的配置容器实现
abstract class AbstractConfigContainer<T extends IConfig> implements IConfigContainer<T> {
  final Map<int, T> _configMap = {};

  final String jsonName;
  final T Function(Map<String, dynamic>) jsonParser;

  AbstractConfigContainer({
    required this.jsonName,
    required this.jsonParser,
  });

  @override
  Map<int, T> get allConfigs => _configMap;

  /// 子类需要实现具体的内容读取逻辑
  Future<String> readContent();

  T parseJson(Map<String, dynamic> json) => jsonParser(json);

  @override
  T? getConfig(int id) => _configMap[id];

  @override
  T? get getUnique => _configMap.isNotEmpty ? _configMap.entries.first.value : null;

  @override
  Future<void> loadAll() async {
    try {
      final jsonString = await readContent();
      if (jsonString.isNotEmpty) {
        load(jsonString);
      }
    } catch (e) {
      print("ConfigContainer loadAll error: $e");
      rethrow;
    }
  }

  /// 加载配置数据
  void load(String content) {
    _configMap.clear();
    final List<dynamic> jsonList = jsonDecode(content);
    for (var item in jsonList) {
      T config = parseJson(item);
      _configMap[config.id] = config;
    }
  }

  @override
  Future<bool> reloadAll(bool force) async {
    if (!force) {
      return false;
    }
    String content = await readContent();
    if (content.isNotEmpty) {
      load(content);
      return true;
    }
    return false;
  }

  @override
  void afterLoad() {}
}

/// 本地配置容器 - 从Assets读取配置
class LocalConfigContainer<T extends IConfig> extends AbstractConfigContainer<T> {
  LocalConfigContainer({
    required T Function(Map<String, dynamic>) jsonParser,
    required String jsonName,
  }) : super(jsonParser: jsonParser, jsonName: jsonName);

  @override
  Future<String> readContent() async {
    try {
      return await rootBundle.loadString("assets/config/$jsonName");
    } catch (e) {
      print("LocalConfigContainer readContent error: $e");
      return "";
    }
  }
}

/// 远程配置容器 - 从服务器读取配置
class RemoteConfigContainer<T extends IConfig> extends AbstractConfigContainer<T> {
  /// 本次加载成功时配置的md5
  String? md5Code;
  final String baseUrl;

  RemoteConfigContainer({
    required T Function(Map<String, dynamic>) jsonParser,
    required String jsonName,
    required this.baseUrl,
  }) : super(jsonParser: jsonParser, jsonName: jsonName);

  @override
  Future<String> readContent() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/config/$jsonName'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return response.body;
      }
      return "";
    } catch (e) {
      print("RemoteConfigContainer readContent error: $e");
      return "";
    }
  }

  @override
  void load(String content) {
    super.load(content);
    md5Code = md5.convert(utf8.encode(content)).toString();
  }

  @override
  Future<bool> reloadAll(bool force) async {
    String content = await readContent();
    if (content.isEmpty) return false;
    
    var newMd5 = md5.convert(utf8.encode(content)).toString();
    if (!force && md5Code == newMd5) {
      // 非强制刷新且配置内容一致时不再刷新
      return false;
    }
    load(content);
    return true;
  }
}

/// 配置加载来源枚举
enum LoadSource {
  local,
  remote,
}

/// 配置管理器 - 全局单例管理所有配置
class ConfigManager {
  static final ConfigManager _instance = ConfigManager._internal();
  factory ConfigManager() => _instance;
  ConfigManager._internal();

  final Map<Type, IConfigContainer> _configMap = {};

  /// 获取指定类型的配置容器
  IConfigContainer? getContainer<T extends IConfig>() => _configMap[T];

  /// 根据指定类型获取容器
  T? getContainerByType<T extends IConfigContainer>(Type type) {
    var container = _configMap[type];
    return (container is T) ? container : null;
  }

  /// 根据id获取配置
  T? get<T extends IConfig>(int id) {
    final container = _configMap[T] as IConfigContainer<T>?;
    return container?.getConfig(id);
  }

  /// 获取唯一配置（第一条）
  T? getUnique<T extends IConfig>() {
    final container = _configMap[T] as IConfigContainer<T>?;
    return container?.getUnique;
  }

  /// 通用查询方法，通过条件查找配置项
  T? getAny<T extends IConfig>(bool Function(T) predicate) {
    final List<T> configs = getAll<T>();
    if (configs.isEmpty) return null;
    try {
      return configs.firstWhere(predicate);
    } catch (e) {
      return null;
    }
  }

  /// 查找多项满足条件的配置
  List<T> getConfigs<T extends IConfig>(bool Function(T) predicate) {
    final List<T> configs = getAll<T>();
    return configs.where(predicate).toList();
  }

  /// 获取全部配置，无序
  List<T> getAll<T extends IConfig>() {
    final container = _configMap[T] as IConfigContainer<T>?;
    if (container == null) return [];
    return container.allConfigs.values.toList();
  }

  /// 获取全部配置，按照指定规则排序（默认按id升序）
  List<T> getAllSorted<T extends IConfig>({int Function(T a, T b)? compare}) {
    final container = _configMap[T] as IConfigContainer<T>?;
    if (container == null) return [];
    final List<T> result = container.allConfigs.values.toList();
    result.sort(compare ?? (a, b) => a.id.compareTo(b.id));
    return result;
  }

  /// 加载配置容器
  Future<void> loadContainer<T extends IConfig>(IConfigContainer<T> container) async {
    try {
      await container.loadAll();
      container.afterLoad();
      _configMap[T] = container;
    } catch (e) {
      print("ConfigManager loadContainer error: $e");
      rethrow;
    }
  }

  /// 加载配置
  Future<void> load<T extends IConfig>(
    LoadSource source,
    String jsonName,
    T Function(Map<String, dynamic>) fromJson, {
    bool forceRefresh = false,
    String? baseUrl,
  }) async {
    // 如果已经加载过且未要求强制刷新，直接返回
    if (_configMap.containsKey(T) && !forceRefresh) {
      return;
    }

    late IConfigContainer<T> container;
    switch (source) {
      case LoadSource.local:
        container = LocalConfigContainer<T>(
          jsonName: jsonName,
          jsonParser: fromJson,
        );
        break;
      case LoadSource.remote:
        container = RemoteConfigContainer<T>(
          jsonName: jsonName,
          jsonParser: fromJson,
          baseUrl: baseUrl ?? 'https://api.example.com',
        );
        break;
    }

    try {
      await container.loadAll();
      container.afterLoad();
      _configMap[T] = container;
    } catch (e) {
      print("ConfigManager load error: $e");
      rethrow;
    }
  }

  /// 销毁指定类型的配置
  void destroy<T extends IConfig>() => _configMap.remove(T);

  /// 根据类型销毁配置
  void destroyByType(Type type) => _configMap.remove(type);

  /// 清空所有配置
  void destroyAll() => _configMap.clear();
}

/// 配置加载混入 - 为GetX控制器提供配置管理能力
mixin ConfigLoaderMixin on GetxController {
  final Set<Type> _loadedConfigs = {};

  /// 手动加载配置，默认加载本地配置
  Future<void> loadConfig<T extends IConfig>(
    String jsonName,
    T Function(Map<String, dynamic>) fromJson, {
    LoadSource source = LoadSource.local,
    String? baseUrl,
  }) async {
    await ConfigManager().load<T>(
      source,
      jsonName,
      fromJson,
      baseUrl: baseUrl,
    );
    _loadedConfigs.add(T);
  }

  /// 手动加载配置容器
  Future<void> loadContainer<T extends IConfig>(IConfigContainer<T> container) async {
    await ConfigManager().loadContainer(container);
    _loadedConfigs.add(T);
  }

  /// 手动销毁配置
  void removeConfig<T extends IConfig>() => ConfigManager().destroy<T>();

  @override
  void onClose() {
    // 自动清理所有加载的配置
    for (Type type in _loadedConfigs) {
      ConfigManager().destroyByType(type);
    }
    super.onClose();
  }
}
