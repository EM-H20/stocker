import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_notifier.g.dart';

/// 테마 모드 열거형
enum AppThemeMode {
  light('라이트'),
  dark('다크'),
  system('시스템');

  const AppThemeMode(this.displayName);
  final String displayName;
}

/// 🔥 Riverpod 기반 테마 상태 관리 Notifier
@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  static const String _themeKey = 'theme_mode';
  SharedPreferences? _prefs;

  @override
  AppThemeMode build() {
    // 초기화 - 비동기 처리는 Future로 분리
    _initialize();
    return AppThemeMode.system; // 기본값
  }

  /// SharedPreferences에서 저장된 테마 로드
  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();
    final savedThemeIndex = _prefs?.getInt(_themeKey);

    if (savedThemeIndex != null &&
        savedThemeIndex < AppThemeMode.values.length) {
      state = AppThemeMode.values[savedThemeIndex];
    }
  }

  /// 테마 모드 변경
  Future<void> setThemeMode(AppThemeMode themeMode) async {
    if (state == themeMode) return;

    state = themeMode; // 🔥 Riverpod: state 직접 할당 (자동 notifyListeners!)

    // SharedPreferences에 저장
    await _prefs?.setInt(_themeKey, themeMode.index);
  }
}

/// 🎨 ThemeMode 변환을 위한 Provider
@riverpod
ThemeMode themeMode(Ref ref) {
  final appThemeMode = ref.watch(themeNotifierProvider);
  switch (appThemeMode) {
    case AppThemeMode.light:
      return ThemeMode.light;
    case AppThemeMode.dark:
      return ThemeMode.dark;
    case AppThemeMode.system:
      return ThemeMode.system;
  }
}

/// 🌙 다크모드 여부 확인을 위한 Provider (BuildContext 필요)
/// 사용법: ref.watch(isDarkModeProvider(context))
@riverpod
bool isDarkMode(Ref ref, BuildContext context) {
  final appThemeMode = ref.watch(themeNotifierProvider);
  switch (appThemeMode) {
    case AppThemeMode.light:
      return false;
    case AppThemeMode.dark:
      return true;
    case AppThemeMode.system:
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
  }
}
