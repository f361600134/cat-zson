import 'package:logger/logger.dart';
import 'package:get/get.dart';

final logger = Logger(
  printer: PrettyPrinter(
    dateTimeFormat: DateTimeFormat.dateAndTime, //时间格式化
  ),
  level: Get.isLogEnable ? Level.debug : Level.off,
);