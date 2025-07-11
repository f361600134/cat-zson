import 'package:cat_framework/app/core/event/event_bus.dart';
import 'package:cat_framework/app/core/storage/storage_get_service.dart';
import 'package:cat_framework/app/modules/auth/auth_service.dart';
import 'package:cat_framework/app/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

///抽象的控制器, 封装通用方法
///onInit 在创建Controller的时候调用
///onReady 在页面渲染完成后调用, 比如播放动画、展示 Dialog、Snackbar, 依赖于 UI 构建完成后的逻辑（例如定位、滚动控制等）
abstract class AbstractController extends GetxController with EventMixin {

  final RxBool isLoading = true.obs;

  @override
  void onInit() async{
    super.onInit();

    //阻塞加载配置
    await prepareData();

    await afterPrepareData();

    logger.i("AuthService.to.authStatus.value:${AuthService.to.authStatus.value}");
    // 登录成功
    if (AuthService.to.authStatus.value == AuthStatus.authenticated) {
      onLoginReady();
    }

    // 是否需要从服务端重新加载数据
    if (AuthService.to.reload.value){
      synchronizeData();
    }

    // 用户登录成功后, 再创建监听
    setupEventListeners();

    isLoading.value = false;
  }

  /// 设置监听
  setupEventListeners(){}

  /// 加载数据
  /// 如 JSON, 数据库, SharedPreferences等, 这些异步行为初始化成功后
  /// 才能继续做下一步操作
  Future<void> prepareData() async{}

  /// 加载数据后
  /// 才能继续做下一步操作
  Future<void> afterPrepareData() async{}

  /// 鉴权成功后触发，子类实现具体加载逻辑
  /// 此时可以进行网络操作
  void onLoginReady(){}

  /// 同步数据
  /// 从服务端加载当前模块的数据, 当首次登录, 更换设备时调用
  Future<void> synchronizeData() async{}

}

/// 基础的controller, 进一步对AbstractController进行扩展
class BaseController<D extends IData, S extends IState> extends AbstractController with WidgetsBindingObserver{

  final AbstractService<D> service;
  final DataStateConvert<D, S> converter;

  /// UI状态
  late final S _state;
  S get state => _state;

  BaseController({
    required this.service,
    required this.converter,
  }) : _state = converter.createEmptyState();

  /// 初始化, 加载 Data 并转换为 State
  Future<void> initState() async {
    //FIXED 不要在初始化controller的时候加载数据, service是服务层, 应该在进入导航页(渲染前)把需要的模块数据初始化好
    //service.loadData(AuthService.to.userId.toString());
    logger.i("initState: ${_state}");
    try {
      converter.convertToState(service.data, _state);
      _state.initialize();
    } catch(e){
      logger.e("initState error, service:$service", error: e);
    }finally{
      _state.isLoading.value = false;
    }
  }

  /// 保存
  Future<void> saveData() async {
    service.data = converter.convertToData(_state);
    await service.writeData(AuthService.to.userId.toString());
  }

  ///重写onInit方法
  // @override
  // void onInit() async{
  //   super.onInit();
  //
  //   //阻塞加载配置
  //   await prepareData();
  //
  //   await initState();
  //   // 登录成功
  //   if (AuthService.to.authStatus.value == AuthStatus.authenticated) {
  //     onLoginReady();
  //   }
  //   // 是否需要从服务端重新加载数据
  //   if (AuthService.to.reload.value){
  //     synchronizeData();
  //   }
  //   WidgetsBinding.instance.addObserver(this);
  // }

  @override
  Future<void> afterPrepareData() async{
    await initState();
  }

  @override
  void onClose() {
    super.onClose();
    WidgetsBinding.instance.removeObserver(this);
  }

  ///增加生命周期监听, 在进入后台, 或销毁前进行保存聊天数据
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      saveData();
    }
  }

}


/// 抽象的仓库接口, 用于读写数据
abstract class IRepository<D extends IData> {

  final StorageGetService storage;
  final String storageKey;
  ///解析器
  D Function(Map<String, dynamic>) fromJson;

  IRepository({
    required this.storage,
    required this.storageKey,
    required this.fromJson,
  });

  /// 生成完整存储键 格式: storageKey:identifier
  String _getStorageKey(dynamic identifier) => '$storageKey$identifier';

  /// 读数据
  /// 携带参数
  D? read({
    required dynamic identifier,
  }){
    final data = storage.read(_getStorageKey(identifier));
    if (data != null){
      return fromJson(data);
    }
    return null;
  }

  void write(
    D data, {
    required String identifier,
  }){
    storage.write(_getStorageKey(identifier), data.toJson());
  }

  /// 删除对象
  void remove({required String identifier}) {
    storage.remove(_getStorageKey(identifier));
  }

}

///抽象的状态类接口
abstract class IData{
  ///消息对象转json
  Map<String, dynamic> toJson();
}

///抽象的服务类, 封装通用方法
abstract class AbstractService<D extends IData> extends GetxService{
  ///存储数据
  late D data;

  ///抽象资源库
  IRepository<D> repository;

  AbstractService(this.repository){
    ServiceRegistry.register(this);
  }

  ///创建一个空的存储对象
  D createEmptyData();

  /// 加载数据
  Future<void> loadData(dynamic identifier) async{
    D? localData = repository.read(identifier: identifier);
    data = localData ?? createEmptyData();
  }

  /// 保存数据
  Future<void> writeData(dynamic identifier) async {
    repository.write(data, identifier: identifier);
  }

}


///抽象的状态类接口
abstract class IState{

  ///是否处于加载中
  var isLoading = true.obs;

  ///当初始化, 创建Controller的时候回调用该方法, 进行数据的初始化
  initialize();
}

/// 数据状态转换器
abstract class DataStateConvert<D extends IData, S extends IState> {

  ///将Data转换为State,用于初始化
  void convertToState(D data, S state);

  ///将State转换回Data,用于持久化
  D convertToData(S state);

  ///创建空State,用于默认值
  S createEmptyState();

}

/// 控制器注册表
class ControllerRegistry {

  static final Map<Type, AbstractController> _controllers = {};

  /// 控制器注册
  static void register(Type type, AbstractController controller) {
    _controllers[type] = controller;
  }

  /// 获取所有已注册控制器
  static Iterable<AbstractController> get all => _controllers.values;

  ///获得指定控制器
  static AbstractController? controller(Type type){
    return _controllers[type];
  }

}

/// 服务注册表
class ServiceRegistry {

  static final List<AbstractService> _services = [];

  /// 服务注册
  static void register(AbstractService service) {
    _services.add(service);
  }

  /// 获取所有已注册服务
  static List<AbstractService> get all => _services;

  /// 初始化所有服务
  static Future<void> initializeAll(dynamic userId) async {
    final services = all;
    await Future.wait(services.map((s) => s.loadData(userId)));
  }

}


