import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 테마 모드 열거형
enum AppThemeMode {
  light('라이트'),
  dark('다크'),
  system('시스템');

  const AppThemeMode(this.displayName);
  final String displayName;
}

/// 앱 테마 상태 관리 Provider
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  AppThemeMode _currentThemeMode = AppThemeMode.system;
  SharedPreferences? _prefs;

  AppThemeMode get currentThemeMode => _currentThemeMode;

  /// Flutter의 ThemeMode로 변환
  ThemeMode get themeMode {
    switch (_currentThemeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  /// 초기화 - SharedPreferences에서 저장된 테마 로드
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    final savedThemeIndex = _prefs?.getInt(_themeKey);
    
    if (savedThemeIndex != null && savedThemeIndex < AppThemeMode.values.length) {
      _currentThemeMode = AppThemeMode.values[savedThemeIndex];
      notifyListeners();
    }
  }

  /// 테마 모드 변경
  Future<void> setThemeMode(AppThemeMode themeMode) async {
    if (_currentThemeMode == themeMode) return;
    
    _currentThemeMode = themeMode;
    
    // SharedPreferences에 저장
    await _prefs?.setInt(_themeKey, themeMode.index);
    
    notifyListeners();
  }

  /// 현재 테마가 다크 모드인지 확인 (시스템 설정 고려)
  bool isDarkMode(BuildContext context) {
    switch (_currentThemeMode) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
  }
}
