import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stocker/app/config/app_theme.dart';
import 'package:stocker/app/core/utils/theme_utils.dart';

/// SnackBar 타입 정의
enum SnackBarType {
  success,
  error,
  warning,
  info,
}

/// 커스텀 SnackBar 유틸리티 클래스
class CustomSnackBar {
  /// SnackBar 표시
  ///
  /// [context]: BuildContext
  /// [type]: SnackBar 타입 (success, error, warning, info)
  /// [message]: 표시할 메시지
  /// [duration]: 표시 지속 시간 (기본값: 3초)
  static void show({
    required BuildContext context,
    required SnackBarType type,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    final isDarkMode = ThemeUtils.isDarkMode(context);

    // 타입별 색상 및 아이콘 설정
    final config = _getSnackBarConfig(type, isDarkMode);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _SnackBarContent(
          type: type,
          message: message,
          config: config,
          isDarkMode: isDarkMode,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        margin: EdgeInsets.only(
          bottom: 20.h,
          left: 16.w,
          right: 16.w,
        ),
      ),
    );
  }

  /// 타입별 SnackBar 설정 반환
  static _SnackBarConfig _getSnackBarConfig(
      SnackBarType type, bool isDarkMode) {
    switch (type) {
      case SnackBarType.success:
        return _SnackBarConfig(
          icon: Icons.check_circle,
          backgroundColor: isDarkMode
              ? AppTheme.successColor.withValues(alpha: 0.2)
              : AppTheme.successColor.withValues(alpha: 0.1),
          borderColor: AppTheme.successColor,
          iconColor: AppTheme.successColor,
          textColor: isDarkMode ? Colors.white : AppTheme.grey900,
        );

      case SnackBarType.error:
        return _SnackBarConfig(
          icon: Icons.error,
          backgroundColor: isDarkMode
              ? AppTheme.errorColor.withValues(alpha: 0.2)
              : AppTheme.errorColor.withValues(alpha: 0.1),
          borderColor: AppTheme.errorColor,
          iconColor: AppTheme.errorColor,
          textColor: isDarkMode ? Colors.white : AppTheme.grey900,
        );

      case SnackBarType.warning:
        return _SnackBarConfig(
          icon: Icons.warning_amber_rounded,
          backgroundColor: isDarkMode
              ? AppTheme.warningColor.withValues(alpha: 0.2)
              : AppTheme.warningColor.withValues(alpha: 0.1),
          borderColor: AppTheme.warningColor,
          iconColor: AppTheme.warningColor,
          textColor: isDarkMode ? Colors.white : AppTheme.grey900,
        );

      case SnackBarType.info:
        return _SnackBarConfig(
          icon: Icons.info,
          backgroundColor: isDarkMode
              ? AppTheme.primaryColor.withValues(alpha: 0.2)
              : AppTheme.primaryColor.withValues(alpha: 0.1),
          borderColor: AppTheme.primaryColor,
          iconColor: AppTheme.primaryColor,
          textColor: isDarkMode ? Colors.white : AppTheme.grey900,
        );
    }
  }
}

/// SnackBar 설정 데이터 클래스
class _SnackBarConfig {
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;

  const _SnackBarConfig({
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
  });
}

/// SnackBar 컨텐츠 위젯
class _SnackBarContent extends StatelessWidget {
  final SnackBarType type;
  final String message;
  final _SnackBarConfig config;
  final bool isDarkMode;

  const _SnackBarContent({
    required this.type,
    required this.message,
    required this.config,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          // 아이콘
          Icon(
            config.icon,
            color: config.iconColor,
            size: 20.sp,
          ),

          SizedBox(width: 10.w),

          // 메시지
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: config.textColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
