import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/theme_utils.dart';
import '../../config/app_theme.dart';

/// 공통 카드 위젯
///
/// 앱 전체에서 일관된 카드 디자인을 제공합니다.
/// 다양한 스타일과 패딩 옵션을 지원합니다.
class AppCard extends StatelessWidget {
  /// 카드 내부 컨텐츠
  final Widget child;

  /// 내부 패딩
  final EdgeInsetsGeometry? padding;

  /// 외부 마진
  final EdgeInsetsGeometry? margin;

  /// 배경색 (null이면 테마의 cardColor 사용)
  final Color? backgroundColor;

  /// 테두리 색상 (null이면 기본 테두리 색상 사용)
  final Color? borderColor;

  /// 테두리 두께
  final double borderWidth;

  /// 모서리 반경
  final double borderRadius;

  /// 그림자 여부
  final bool withShadow;

  /// 탭 이벤트
  final VoidCallback? onTap;

  /// 폭 (null이면 부모 폭 사용)
  final double? width;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius = 16.0,
    this.withShadow = true,
    this.onTap,
    this.width,
  });

  /// 기본 패딩이 적용된 카드
  factory AppCard.standard({
    required Widget child,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    VoidCallback? onTap,
  }) {
    return AppCard(
      padding: EdgeInsets.all(20.w),
      margin: margin,
      backgroundColor: backgroundColor,
      onTap: onTap,
      child: child,
    );
  }

  /// 작은 패딩이 적용된 카드
  factory AppCard.compact({
    required Widget child,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    VoidCallback? onTap,
  }) {
    return AppCard(
      padding: EdgeInsets.all(12.w),
      margin: margin,
      backgroundColor: backgroundColor,
      borderRadius: 12.0,
      onTap: onTap,
      child: child,
    );
  }

  /// 그림자 없는 플랫 카드
  factory AppCard.flat({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    VoidCallback? onTap,
  }) {
    return AppCard(
      padding: padding ?? EdgeInsets.all(16.w),
      margin: margin,
      backgroundColor: backgroundColor,
      withShadow: false,
      onTap: onTap,
      child: child,
    );
  }

  /// 아웃라인 강조 카드
  factory AppCard.outlined({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? borderColor,
    VoidCallback? onTap,
  }) {
    return AppCard(
      padding: padding ?? EdgeInsets.all(16.w),
      margin: margin,
      borderColor: borderColor ?? AppTheme.primaryColor,
      borderWidth: 2.0,
      withShadow: false,
      onTap: onTap,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor =
        backgroundColor ?? Theme.of(context).cardColor;

    final effectiveBorderColor = borderColor ??
        ThemeUtils.getColorWithOpacity(
          context,
          lightColor: AppTheme.grey300,
          darkColor: AppTheme.grey700,
          opacity: ThemeUtils.isDarkMode(context) ? 0.3 : 0.5,
        );

    Widget content = Container(
      width: width,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius.r),
        border: Border.all(
          color: effectiveBorderColor,
          width: borderWidth,
        ),
        boxShadow: withShadow
            ? [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius.r),
        child: content,
      );
    }

    return content;
  }
}
