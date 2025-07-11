
import 'package:cat_framework/app/core/storage/single_storage_repository.dart';
import 'package:cat_framework/app/core/storage/storage_get_service.dart';

import '../structs/auth_model.dart';

class LoginRepository extends SingleStorageRepository<LoginData> {

  static const String key = "login";

  LoginRepository():super(storage: StorageGetService(), storageKey: key);

}