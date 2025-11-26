import 'package:shared_preferences/shared_preferences.dart';

/// 투자 성향 분석 유도 다이얼로그 표시 여부 관리 서비스
///
/// SharedPreferences를 사용하여 "다음에" 클릭 여부를 로컬에 저장합니다.
/// - 로그인 시: isDismissed() 확인 → false면 다이얼로그 표시
/// - "다음에" 클릭 시: setDismissed(true) 호출
/// - 로그아웃 시: clearDismissed() 호출 → 다음 로그인 때 다시 표시
class AptitudePromptService {
  static const String _dismissedKey = 'aptitude_prompt_dismissed';

  /// 다이얼로그가 이미 닫혔는지 확인
  static Future<bool> isDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_dismissedKey) ?? false;
  }

  /// "다음에" 클릭 시 호출 - 다이얼로그 닫힘 상태 저장
  static Future<void> setDismissed(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dismissedKey, value);
  }

  /// 로그아웃 시 호출 - 캐시 삭제
  static Future<void> clearDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dismissedKey);
  }
}
