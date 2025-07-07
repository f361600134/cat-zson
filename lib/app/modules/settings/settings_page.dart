import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../core/framework/cat_framework.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveRowColumn(
      layout: ResponsiveBreakpoints.of(context).smallerThan(TABLET)
          ? ResponsiveRowColumnType.COLUMN
          : ResponsiveRowColumnType.ROW,
      children: [
        ResponsiveRowColumnItem(
          rowFlex: 1,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.settings,
                  size: 48,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  '系统设置',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                
                // 主题设置
                _buildSettingSection(
                  context,
                  '外观设置',
                  Icons.palette_outlined,
                  [
                    _buildThemeSetting(context),
                    _buildLanguageSetting(context),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // 通知设置
                _buildSettingSection(
                  context,
                  '通知设置',
                  Icons.notifications_outlined,
                  [
                    _buildSwitchSetting(
                      context,
                      '推送通知',
                      '接收系统推送通知',
                      true,
                      (value) {},
                    ),
                    _buildSwitchSetting(
                      context,
                      '邮件通知',
                      '接收邮件通知',
                      false,
                      (value) {},
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // 系统设置
                _buildSettingSection(
                  context,
                  '系统配置',
                  Icons.settings_outlined,
                  [
                    _buildClickableSetting(
                      context,
                      '缓存管理',
                      '清理应用缓存',
                      Icons.cleaning_services_outlined,
                      () => _showCacheDialog(context),
                    ),
                    _buildClickableSetting(
                      context,
                      '数据导出',
                      '导出用户数据',
                      Icons.download_outlined,
                      () => _showExportDialog(context),
                    ),
                    _buildClickableSetting(
                      context,
                      '关于应用',
                      '查看版本信息',
                      Icons.info_outline,
                      () => _showAboutDialog(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildThemeSetting(BuildContext context) {
    final themeService = Cat.theme;
    if (themeService == null) return const SizedBox.shrink();

    return Obx(() {
      final currentMode = themeService.currentThemeMode.value;
      return ListTile(
        leading: Icon(
          _getThemeIcon(currentMode),
          color: Theme.of(context).primaryColor,
        ),
        title: const Text('主题模式'),
        subtitle: Text(_getThemeText(currentMode)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _showThemeDialog(context),
      );
    });
  }

  Widget _buildLanguageSetting(BuildContext context) {
    final translationService = Cat.i18n;
    if (translationService == null) return const SizedBox.shrink();

    return Obx(() {
      final currentLocale = Get.locale ?? const Locale('zh', 'CN');
      return ListTile(
        leading: Icon(
          Icons.language,
          color: Theme.of(context).primaryColor,
        ),
        title: const Text('语言设置'),
        subtitle: Text(_getLanguageText(currentLocale)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _showLanguageDialog(context),
      );
    });
  }

  Widget _buildSwitchSetting(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildClickableSetting(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  IconData _getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.settings_system_daydream;
    }
  }

  String _getThemeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return '浅色模式';
      case ThemeMode.dark:
        return '深色模式';
      case ThemeMode.system:
        return '跟随系统';
    }
  }

  String _getLanguageText(Locale locale) {
    switch (locale.languageCode) {
      case 'zh':
        return '中文';
      case 'en':
        return 'English';
      default:
        return locale.languageCode.toUpperCase();
    }
  }

  void _showThemeDialog(BuildContext context) {
    final themeService = Cat.theme;
    if (themeService == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择主题'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(
              context,
              '浅色模式',
              Icons.light_mode,
              () {
                themeService.enableLightMode();
                Navigator.pop(context);
              },
            ),
            _buildThemeOption(
              context,
              '深色模式',
              Icons.dark_mode,
              () {
                themeService.enableDarkMode();
                Navigator.pop(context);
              },
            ),
            _buildThemeOption(
              context,
              '跟随系统',
              Icons.settings_system_daydream,
              () {
                themeService.followSystem();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final translationService = Cat.i18n;
    if (translationService == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择语言'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: translationService.languages.entries.map((entry) {
            return ListTile(
              title: Text(entry.key),
              onTap: () {
                translationService.changeLocale(
                  entry.value.languageCode,
                  entry.value.countryCode,
                );
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清理缓存'),
        content: const Text('确定要清理应用缓存吗？这将删除所有缓存的数据。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Cat.notify.showSuccess(message: '缓存清理完成');
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('数据导出'),
        content: const Text('将导出您的所有用户数据，包括设置和偏好。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Cat.notify.showInfo(message: '数据导出已开始，请稍候...');
            },
            child: const Text('导出'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Cat Framework',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: const Icon(
          Icons.pets,
          color: Colors.white,
          size: 24,
        ),
      ),
      children: [
        const Text('Cat Framework 是一个功能强大的 Flutter 脚手架框架。'),
        const SizedBox(height: 8),
        const Text('提供响应式导航、状态管理、主题系统等核心功能。'),
      ],
    );
  }
}
