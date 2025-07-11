import 'package:cat_framework/app/core/i18n/zh-cn/zh_cn.dart';
import 'package:cat_framework/app/core/i18n/zh-hk/zh_hk.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../storage/storage_repository.dart';
import 'en-us/en_us.dart';
import 'ja-jp/ja-jp.dart';
import 'ko-kr/ko-kr.dart';

/// 多语言翻译服务
class TranslationService extends Translations {
  static const String _keyLanguage = 'app_language';
  
  final RxString selectedLanguage = 'en_us'.obs;
  final Rx<Locale> locale = const Locale('en', 'us').obs;
  
  late final KeyValueStorageRepository _storage;

  /// 初始化翻译服务
  Future<TranslationService> init() async {
    // 初始化存储
    final storageManager = StorageManager.instance;
    await storageManager.initStorage('app_settings');
    _storage = storageManager.createKeyValueRepository(containerName: 'app_settings');
    
    // 读取保存的语言设置
    final savedLanguage = _storage.readString(_keyLanguage);
    if (savedLanguage != null && languages.containsValue(_getLocaleFromString(savedLanguage))) {
      _setLanguage(savedLanguage);
    }
    
    return this;
  }

  /// 切换语言
  void changeLocale(String languageCode, String? countryCode) {
    final localeString = countryCode == null ? languageCode : '${languageCode}_$countryCode';
    final newLocale = Locale(languageCode, countryCode);
    
    // 检查是否支持该语言
    if (!languages.containsValue(newLocale)) {
      print('[TranslationService] Unsupported language: $localeString');
      return;
    }
    
    Get.updateLocale(newLocale);
    _setLanguage(localeString);
    _storage.writeString(_keyLanguage, localeString);
    
    print('[TranslationService] Language changed to: $localeString');
  }

  /// 根据语言名称切换语言
  void changeLocaleByName(String languageName) {
    final targetLocale = languages[languageName];
    if (targetLocale != null) {
      changeLocale(targetLocale.languageCode, targetLocale.countryCode);
    }
  }

  /// 获取当前语言的显示名称
  String get currentLanguageName {
    return languages.entries
        .firstWhere(
          (entry) => entry.value == locale.value,
          orElse: () => const MapEntry('English', Locale('en', 'us')),
        )
        .key;
  }

  /// 检查是否为RTL语言
  bool get isRTL {
    final rtlLanguages = ['ar', 'he', 'fa', 'ur'];
    return rtlLanguages.contains(locale.value.languageCode);
  }

  void _setLanguage(String languageString) {
    selectedLanguage.value = languageString;
    locale.value = _getLocaleFromString(languageString);
  }

  Locale _getLocaleFromString(String languageString) {
    final parts = languageString.split('_');
    return Locale(parts[0], parts.length > 1 ? parts[1] : null);
  }

  /// 支持的语言映射
  final Map<String, Locale> languages = {
    'English': const Locale('en', 'us'),
    '简体中文': const Locale('zh', 'cn'),
    '繁體中文': const Locale('zh', 'tw'),
    '日本語': const Locale('ja', 'jp'),
    '한국어': const Locale('ko', 'kr'),
  };

  /// 翻译键值对映射
  @override
  Map<String, Map<String, String>> get keys => {
    'zh_cn': ZhCn.values,
    'zh_hk': ZhHk.values,
    'en_us': EnUs.values,
    'ja_jp': JaJp.values,
    'ko_kr': KoKr.values,
  };
}
