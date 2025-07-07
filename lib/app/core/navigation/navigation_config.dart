import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';

/// 预设的导航主题配置
class NavigationThemes {
  /// Material Design 3 风格主题
  static SidebarXTheme material3Theme(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return SidebarXTheme(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: colorScheme.outline.withOpacity(0.12),
            width: 1,
          ),
        ),
      ),
      iconTheme: IconThemeData(
        color: colorScheme.onSurfaceVariant,
        size: 24,
      ),
      selectedIconTheme: IconThemeData(
        color: colorScheme.primary,
        size: 24,
      ),
      textStyle: TextStyle(
        color: colorScheme.onSurfaceVariant,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      selectedTextStyle: TextStyle(
        color: colorScheme.primary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      itemTextPadding: const EdgeInsets.only(left: 16),
      selectedItemTextPadding: const EdgeInsets.only(left: 16),
      itemDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      selectedItemDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.primaryContainer,
      ),
      itemPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      selectedItemPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(vertical: 8),
      hoverColor: colorScheme.surfaceVariant.withOpacity(0.5),
      hoverTextStyle: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
  
  /// 紧凑风格主题
  static SidebarXTheme compactTheme(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return SidebarXTheme(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      iconTheme: IconThemeData(
        color: colorScheme.onSurface.withOpacity(0.7),
        size: 20,
      ),
      selectedIconTheme: IconThemeData(
        color: colorScheme.primary,
        size: 20,
      ),
      textStyle: TextStyle(
        color: colorScheme.onSurface.withOpacity(0.7),
        fontSize: 13,
      ),
      selectedTextStyle: TextStyle(
        color: colorScheme.primary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      itemTextPadding: const EdgeInsets.only(left: 12),
      selectedItemTextPadding: const EdgeInsets.only(left: 12),
      itemDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      selectedItemDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: colorScheme.primary.withOpacity(0.1),
      ),
      itemPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      selectedItemPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(vertical: 4),
    );
  }
  
  /// 现代风格主题
  static SidebarXTheme modernTheme(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return SidebarXTheme(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.surface,
            colorScheme.surface.withOpacity(0.98),
          ],
        ),
      ),
      iconTheme: IconThemeData(
        color: colorScheme.onSurface.withOpacity(0.8),
        size: 22,
      ),
      selectedIconTheme: IconThemeData(
        color: colorScheme.primary,
        size: 22,
      ),
      textStyle: TextStyle(
        color: colorScheme.onSurface.withOpacity(0.8),
        fontSize: 14,
        letterSpacing: 0.3,
      ),
      selectedTextStyle: TextStyle(
        color: colorScheme.primary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
      itemTextPadding: const EdgeInsets.only(left: 14),
      selectedItemTextPadding: const EdgeInsets.only(left: 14),
      itemDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.transparent,
          width: 1,
        ),
      ),
      selectedItemDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.primary.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      itemPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      selectedItemPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(vertical: 6),
    );
  }
  
  /// 深色主题
  static SidebarXTheme darkTheme(BuildContext context) {
    return SidebarXTheme(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFFB0B0B0),
        size: 24,
      ),
      selectedIconTheme: const IconThemeData(
        color: Color(0xFF64B5F6),
        size: 24,
      ),
      textStyle: const TextStyle(
        color: Color(0xFFB0B0B0),
        fontSize: 14,
      ),
      selectedTextStyle: const TextStyle(
        color: Color(0xFF64B5F6),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      itemTextPadding: const EdgeInsets.only(left: 16),
      selectedItemTextPadding: const EdgeInsets.only(left: 16),
      itemDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      selectedItemDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF64B5F6).withOpacity(0.1),
      ),
      itemPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      selectedItemPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(vertical: 8),
    );
  }
}

/// 导航断点配置
class NavigationBreakpoints {
  /// 移动端最大宽度
  static const double mobile = 600;
  
  /// 平板端最大宽度
  static const double tablet = 900;
  
  /// 桌面端最小宽度
  static const double desktop = 1200;
  
  /// 大屏幕最小宽度
  static const double largeDesktop = 1920;
}

/// 导航动画配置
class NavigationAnimations {
  /// 默认动画曲线
  static const Curve defaultCurve = Curves.easeInOut;
  
  /// 快速动画时长
  static const Duration fast = Duration(milliseconds: 200);
  
  /// 正常动画时长
  static const Duration normal = Duration(milliseconds: 300);
  
  /// 慢速动画时长
  static const Duration slow = Duration(milliseconds: 500);
}
