import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../storage/storage_repository.dart';

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
    'Español': const Locale('es', 'es'),
    'Français': const Locale('fr', 'fr'),
    'Deutsch': const Locale('de', 'de'),
    'العربية': const Locale('ar', 'sa'),
  };

  /// 翻译键值对映射
  @override
  Map<String, Map<String, String>> get keys => {
    // 英语
    'en_us': {
      'app_name': 'Cat Framework',
      'welcome': 'Welcome',
      'hello': 'Hello',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'settings': 'Settings',
      'about': 'About',
      'logout': 'Logout',
      'login': 'Login',
      'email': 'Email',
      'password': 'Password',
      'username': 'Username',
      'phone': 'Phone',
      'language': 'Language',
      'theme': 'Theme',
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'retry': 'Retry',
      'refresh': 'Refresh',
      'no_data': 'No data available',
      'network_error': 'Network connection error',
      'timeout_error': 'Request timeout',
      'unknown_error': 'Unknown error occurred',
    },
    
    // 简体中文
    'zh_cn': {
      'app_name': 'Cat框架',
      'welcome': '欢迎',
      'hello': '你好',
      'loading': '加载中...',
      'error': '错误',
      'success': '成功',
      'cancel': '取消',
      'confirm': '确认',
      'save': '保存',
      'delete': '删除',
      'edit': '编辑',
      'add': '添加',
      'settings': '设置',
      'about': '关于',
      'logout': '退出登录',
      'login': '登录',
      'email': '邮箱',
      'password': '密码',
      'username': '用户名',
      'phone': '手机号',
      'language': '语言',
      'theme': '主题',
      'dark_mode': '暗黑模式',
      'light_mode': '明亮模式',
      'retry': '重试',
      'refresh': '刷新',
      'no_data': '暂无数据',
      'network_error': '网络连接错误',
      'timeout_error': '请求超时',
      'unknown_error': '未知错误',
    },
    
    // 繁體中文
    'zh_tw': {
      'app_name': 'Cat框架',
      'welcome': '歡迎',
      'hello': '你好',
      'loading': '載入中...',
      'error': '錯誤',
      'success': '成功',
      'cancel': '取消',
      'confirm': '確認',
      'save': '儲存',
      'delete': '刪除',
      'edit': '編輯',
      'add': '新增',
      'settings': '設定',
      'about': '關於',
      'logout': '登出',
      'login': '登入',
      'email': '電子郵件',
      'password': '密碼',
      'username': '使用者名稱',
      'phone': '電話號碼',
      'language': '語言',
      'theme': '主題',
      'dark_mode': '深色模式',
      'light_mode': '淺色模式',
      'retry': '重試',
      'refresh': '重新整理',
      'no_data': '暫無資料',
      'network_error': '網路連線錯誤',
      'timeout_error': '請求逾時',
      'unknown_error': '未知錯誤',
    },
    
    // 日本語
    'ja_jp': {
      'app_name': 'Catフレームワーク',
      'welcome': 'ようこそ',
      'hello': 'こんにちは',
      'loading': '読み込み中...',
      'error': 'エラー',
      'success': '成功',
      'cancel': 'キャンセル',
      'confirm': '確認',
      'save': '保存',
      'delete': '削除',
      'edit': '編集',
      'add': '追加',
      'settings': '設定',
      'about': 'について',
      'logout': 'ログアウト',
      'login': 'ログイン',
      'email': 'メール',
      'password': 'パスワード',
      'username': 'ユーザー名',
      'phone': '電話番号',
      'language': '言語',
      'theme': 'テーマ',
      'dark_mode': 'ダークモード',
      'light_mode': 'ライトモード',
      'retry': '再試行',
      'refresh': '更新',
      'no_data': 'データがありません',
      'network_error': 'ネットワーク接続エラー',
      'timeout_error': 'リクエストタイムアウト',
      'unknown_error': '不明なエラーが発生しました',
    },
    
    // 한국어
    'ko_kr': {
      'app_name': 'Cat 프레임워크',
      'welcome': '환영합니다',
      'hello': '안녕하세요',
      'loading': '로딩 중...',
      'error': '오류',
      'success': '성공',
      'cancel': '취소',
      'confirm': '확인',
      'save': '저장',
      'delete': '삭제',
      'edit': '편집',
      'add': '추가',
      'settings': '설정',
      'about': '정보',
      'logout': '로그아웃',
      'login': '로그인',
      'email': '이메일',
      'password': '비밀번호',
      'username': '사용자명',
      'phone': '전화번호',
      'language': '언어',
      'theme': '테마',
      'dark_mode': '다크 모드',
      'light_mode': '라이트 모드',
      'retry': '재시도',
      'refresh': '새로고침',
      'no_data': '데이터가 없습니다',
      'network_error': '네트워크 연결 오류',
      'timeout_error': '요청 시간 초과',
      'unknown_error': '알 수 없는 오류가 발생했습니다',
    },
  };
}

/// 翻译常量类 - 提供类型安全的翻译键
class TranslationKeys {
  static const String appName = 'app_name';
  static const String welcome = 'welcome';
  static const String hello = 'hello';
  static const String loading = 'loading';
  static const String error = 'error';
  static const String success = 'success';
  static const String cancel = 'cancel';
  static const String confirm = 'confirm';
  static const String save = 'save';
  static const String delete = 'delete';
  static const String edit = 'edit';
  static const String add = 'add';
  static const String settings = 'settings';
  static const String about = 'about';
  static const String logout = 'logout';
  static const String login = 'login';
  static const String email = 'email';
  static const String password = 'password';
  static const String username = 'username';
  static const String phone = 'phone';
  static const String language = 'language';
  static const String theme = 'theme';
  static const String darkMode = 'dark_mode';
  static const String lightMode = 'light_mode';
  static const String retry = 'retry';
  static const String refresh = 'refresh';
  static const String noData = 'no_data';
  static const String networkError = 'network_error';
  static const String timeoutError = 'timeout_error';
  static const String unknownError = 'unknown_error';
}
