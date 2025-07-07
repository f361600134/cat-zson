import 'package:cat_zson_pro/app/core/storage/single_storage_repository.dart';
import 'package:cat_zson_pro/app/core/storage/storage_get_service.dart';
import 'package:cat_zson_pro/app/modules/auth/structs/auth_model.dart';

///description: 设备库, 存储设备信息, 不管什么账户, 设备信息不会变
///author: Jeremy
///date: 2025/4/4
class DeviceRepository extends SingleStorageRepository<DeviceData> {

  static const String key = "device";

  DeviceRepository():super(storage: StorageGetService(), storageKey: key);

}