import 'package:flutter/material.dart';

/// 테마 관련 유틸리티 함수들을 제공하는 클래스
class ThemeUtils {
  ThemeUtils._(); // Private constructor to prevent instantiation

  /// 현재 다크모드 여부를 반환
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// 다크모드에 따라 색상을 반환
  ///
  /// [context]: BuildContext
  /// [lightColor]: 라이트 모드 색상
  /// [darkColor]: 다크 모드 색상
  static Color getColorByTheme(
    BuildContext context, {
    required Color lightColor,
    required Color darkColor,
  }) {
    return isDarkMode(context) ? darkColor : lightColor;
  }

  /// 다크모드에 따라 불투명도가 적용된 색상을 반환
  ///
  /// [context]: BuildContext
  /// [lightColor]: 라이트 모드 색상
  /// [darkColor]: 다크 모드 색상
  /// [opacity]: 불투명도 (0.0 ~ 1.0)
  static Color getColorWithOpacity(
    BuildContext context, {
    required Color lightColor,
    required Color darkColor,
    required double opacity,
  }) {
    return getColorByTheme(
      context,
      lightColor: lightColor.withValues(alpha: opacity),
      darkColor: darkColor.withValues(alpha: opacity),
    );
  }

  /// 텍스트 색상 (다크모드: 흰색, 라이트모드: 검은색)
  static Color getTextColor(BuildContext context) {
    return getColorByTheme(
      context,
      lightColor: Colors.black,
      darkColor: Colors.white,
    );
  }

  /// 배경 색상 (다크모드: 어두운 회색, 라이트모드: 흰색)
  static Color getBackgroundColor(BuildContext context) {
    return getColorByTheme(
      context,
      lightColor: Colors.white,
      darkColor: const Color(0xFF1E1E1E),
    );
  }

  /// 카드 배경 색상
  static Color getCardColor(BuildContext context) {
    return getColorByTheme(
      context,
      lightColor: Colors.white,
      darkColor: const Color(0xFF2C2C2C),
    );
  }
}
