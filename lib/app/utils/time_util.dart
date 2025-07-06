import 'package:intl/intl.dart';

class TimeUtil {

  static const String formatYearMonthDay = "yyyy-MM-dd";
  static const String formatYearMonth = "yyyy-MM";

  int DAY_MILLISECONDS = Duration(days: 1).inMilliseconds;


  /// 获取当前时间的毫秒时间戳
  static int get currentMillis => DateTime.now().millisecondsSinceEpoch;

  /// 获取当前时间的微秒时间戳
  static int get currentMicros => DateTime.now().microsecondsSinceEpoch;

  /// 获取当前时间的秒时间戳
  static int get currentSeconds => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  /// 将秒戳转换为 DateTime
  static DateTime secToDateTime(int sec) {
    return DateTime.fromMillisecondsSinceEpoch((sec * 1000));
  }

  /// 将毫秒时间戳转换为 DateTime
  static DateTime millisToDateTime(int millis) {
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  /// 将微秒时间戳转换为 DateTime
  static DateTime microsToDateTime(int micros) {
    return DateTime.fromMicrosecondsSinceEpoch(micros);
  }

  /// 将 DateTime 转换为毫秒时间戳
  static int dateTimeToMillis(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch;
  }

  /// 将 DateTime 转换为微秒时间戳
  static int dateTimeToMicros(DateTime dateTime) {
    return dateTime.microsecondsSinceEpoch;
  }

  /// 格式化 DateTime 为字符串
  /// 默认格式：yyyy-MM-dd HH:mm:ss
  static String formatDateTime(DateTime dateTime, {String pattern = 'yyyy-MM-dd HH:mm:ss'}) {
    return DateFormat(pattern).format(dateTime);
  }

  /// 格式化毫秒时间戳为字符串
  /// 默认格式：yyyy-MM-dd HH:mm:ss
  static String formatMillis(int millis, {String pattern = 'yyyy-MM-dd HH:mm:ss'}) {
    return formatDateTime(millisToDateTime(millis), pattern: pattern);
  }

  /// 格式化微秒时间戳为字符串
  /// 默认格式：yyyy-MM-dd HH:mm:ss
  static String formatMicros(int micros, {String pattern = 'yyyy-MM-dd HH:mm:ss'}) {
    return formatDateTime(microsToDateTime(micros), pattern: pattern);
  }

  /// 获取当前时间的格式化字符串
  /// 默认格式：yyyy-MM-dd HH:mm:ss
  static String getCurrentFormattedTime({String pattern = 'yyyy-MM-dd HH:mm:ss'}) {
    return formatDateTime(DateTime.now(), pattern: pattern);
  }

  /// 计算两个 DateTime 之间的时间差（以 Duration 形式返回）
  static Duration difference(DateTime start, DateTime end) {
    return end.difference(start);
  }

  /// 计算两个时间戳之间的时间差（以 Duration 形式返回）
  static Duration differenceBetweenMillis(int startMillis, int endMillis) {
    return millisToDateTime(endMillis).difference(millisToDateTime(startMillis));
  }

  /// 判断是否是同一天
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// 判断是否是同一月
  static bool isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month;
  }

  /// 判断是否是同一周
  static bool isSameWeek(DateTime date1, DateTime date2) {
    DateTime startOfWeek1 = date1.subtract(Duration(days: date1.weekday - 1));
    DateTime startOfWeek2 = date2.subtract(Duration(days: date2.weekday - 1));

    return isSameDay(startOfWeek1, startOfWeek2);
  }

  ///计算两个日期的天数, 不再关心毫秒数, 用逻辑上的"日期"来比较
  static int getDifferDay(int startTimestamp, int endTimestamp) {
    if (endTimestamp <= startTimestamp) return 0;

    final startDate = DateTime.fromMillisecondsSinceEpoch(startTimestamp);
    final endDate = DateTime.fromMillisecondsSinceEpoch(endTimestamp);

    // 只保留年月日部分，忽略时分秒（即构造出 0 点的 DateTime）
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    return end.difference(start).inDays;
  }

  ///计算当前跟指定日期相差的天数
  static int getDifferDayFromNow(int endTimestamp) {
   return getDifferDay(currentMillis, endTimestamp);
  }
}