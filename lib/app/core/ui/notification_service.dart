import 'package:cat_framework/app/core/i18n/translation_keys.dart';
import 'package:cat_framework/app/core/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 通知类型枚举
enum NotificationType {
  success,
  error,
  warning,
  info,
}

/// 通知配置
class NotificationConfig {
  final String title;
  final String message;
  final NotificationType type;
  final SnackPosition position;
  final Duration duration;
  final bool isDismissible;
  final VoidCallback? onTap;
  final String? actionText;
  final VoidCallback? onAction;
  final IconData? customIcon;
  final Color? customColor;
  final Duration animationDuration;

  const NotificationConfig({
    required this.title,
    required this.message,
    this.type = NotificationType.info,
    this.position = SnackPosition.TOP,
    this.duration = const Duration(seconds: 3),
    this.isDismissible = false,
    this.onTap,
    this.actionText,
    this.onAction,
    this.customIcon,
    this.customColor,
    this.animationDuration = const Duration(seconds: 1),
  });
}

/// 通知主题数据
class _NotificationTheme {
  final Color backgroundColor;
  final Color textColor;

  const _NotificationTheme({
    required this.backgroundColor,
    required this.textColor,
  });
}

/// 通知服务 - 统一管理应用内的所有提示信息
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static NotificationService get instance => _instance;

  /// 显示通用通知
  void show(NotificationConfig config) {
    // 先关闭现有的Snackbar（如果需要）
    if (config.isDismissible) {
      Get.closeAllSnackbars();
    }

    final themeData = _getThemeData(config.type, config.customColor);
    final icon = config.customIcon ?? _getDefaultIcon(config.type);

    final titleWidget = config.onAction != null && config.actionText != null
        ? _buildTitleWithAction(config.title, themeData.textColor, icon, config.actionText!, config.onAction!)
        : _buildTitle(config.title, themeData.textColor, icon);

    Get.snackbar(
      '',
      '',
      titleText: titleWidget,
      messageText: _buildMessage(config.message, themeData.textColor),
      backgroundColor: themeData.backgroundColor,
      colorText: themeData.textColor,
      snackPosition: config.position,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: config.duration,
      isDismissible: config.isDismissible,
      dismissDirection: DismissDirection.vertical,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      animationDuration: config.animationDuration,
      onTap: config.onTap != null ? (_) => config.onTap!() : null,
    );
  }

  /// 显示成功提示
  void showSuccess({
    required String message,
    String? title,
    Duration? duration,
    bool isDismissible = false,
    SnackPosition position = SnackPosition.TOP,
    VoidCallback? onTap,
    String? actionText,
    VoidCallback? onAction,
  }) {
    show(NotificationConfig(
      title: title ?? TranslationKeys.success.tr,
      message: message,
      type: NotificationType.success,
      isDismissible: isDismissible,
      position: position,
      duration: duration ?? const Duration(seconds: 3),
      onTap: onTap,
      actionText: actionText,
      onAction: onAction,
    ));
  }

  /// 显示错误提示
  void showError({
    required String message,
    String? title,
    Duration? duration,
    bool isDismissible = false,
    SnackPosition position = SnackPosition.TOP,
    VoidCallback? onTap,
    String? actionText,
    VoidCallback? onAction,
  }) {
    show(NotificationConfig(
      title: title ?? TranslationKeys.error.tr,
      message: message,
      type: NotificationType.error,
      isDismissible: isDismissible,
      position: position,
      duration: duration ?? const Duration(seconds: 5),
      onTap: onTap,
      actionText: actionText,
      onAction: onAction,
    ));
  }

  /// 显示警告提示
  void showWarning({
    required String message,
    String? title,
    Duration? duration,
    bool isDismissible = false,
    SnackPosition position = SnackPosition.TOP,
    VoidCallback? onTap,
    String? actionText,
    VoidCallback? onAction,
  }) {
    show(NotificationConfig(
      title: title ?? 'Warning',
      message: message,
      type: NotificationType.warning,
      isDismissible: isDismissible,
      position: position,
      duration: duration ?? const Duration(seconds: 4),
      onTap: onTap,
      actionText: actionText,
      onAction: onAction,
    ));
  }

  /// 显示信息提示
  void showInfo({
    required String message,
    String? title,
    Duration? duration,
    SnackPosition position = SnackPosition.TOP,
    VoidCallback? onTap,
    String? actionText,
    VoidCallback? onAction,
  }) {
    show(NotificationConfig(
      title: title ?? 'Info',
      message: message,
      type: NotificationType.info,
      position: position,
      duration: duration ?? const Duration(seconds: 3),
      onTap: onTap,
      actionText: actionText,
      onAction: onAction,
    ));
  }

  /// 隐藏所有通知
  void hideAll() {
    Get.closeAllSnackbars();
  }

  /// 隐藏当前通知
  void hide() {
    if (Get.isSnackbarOpen) {
      Get.back();
    }
  }

  // 私有方法
  Widget _buildTitle(String title, Color textColor, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: textColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTitleWithAction(String title, Color textColor, IconData icon, String actionText, VoidCallback onAction) {
    return Row(
      children: [
        Icon(icon, color: textColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(
            actionText,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessage(String message, Color textColor) {
    return Text(
      message,
      style: TextStyle(
        color: textColor.withOpacity(0.9),
        fontSize: 14,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  IconData _getDefaultIcon(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle_outline;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.warning:
        return Icons.warning_amber_outlined;
      case NotificationType.info:
        return Icons.info_outline;
    }
  }

  _NotificationTheme _getThemeData(NotificationType type, Color? customColor) {
    if (customColor != null) {
      return _NotificationTheme(
        backgroundColor: customColor,
        textColor: _getContrastColor(customColor),
      );
    }

    switch (type) {
      case NotificationType.success:
        return const _NotificationTheme(
          backgroundColor: AppColors.success,
          textColor: AppColors.white,
        );
      case NotificationType.error:
        return const _NotificationTheme(
          backgroundColor: AppColors.error,
          textColor: AppColors.white,
        );
      case NotificationType.warning:
        return const _NotificationTheme(
          backgroundColor: AppColors.warning,
          textColor: AppColors.white,
        );
      case NotificationType.info:
        return const _NotificationTheme(
          backgroundColor: AppColors.info,
          textColor: AppColors.white,
        );
    }
  }

  Color _getContrastColor(Color color) {
    // 计算颜色亮度，返回合适的对比色
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? AppColors.black : AppColors.white;
  }
}
