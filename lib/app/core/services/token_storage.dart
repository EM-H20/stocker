// lib/app/core/services/token_storage.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _userEmailKey = 'user_email'; // 🔧 추가: 사용자 이메일
  static const _userNicknameKey = 'user_nickname'; // 🔧 추가: 사용자 닉네임

  /// ✅ 사용자 정보와 토큰을 모두 저장
  static Future<void> saveUserSession({
    required String accessToken,
    required String refreshToken,
    required Object userId,
    required String email,
    String? nickname,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _userIdKey, value: userId.toString());
    await _storage.write(key: _userEmailKey, value: email);
    if (nickname != null) {
      await _storage.write(key: _userNicknameKey, value: nickname);
    }
  }

  /// ✅ accessToken, refreshToken, userId를 한 번에 저장 (기존 호환성 유지)
  static Future<void> saveTokens(
      String accessToken, String refreshToken, Object userId) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _userIdKey, value: userId.toString());
  }

  /// ✅ accessToken만 저장
  static Future<void> saveAccessToken(String accessToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
  }

  /// ✅ 저장된 accessToken 반환
  static Future<String?> get accessToken async {
    return _storage.read(key: _accessTokenKey);
  }

  /// ✅ 저장된 refreshToken 반환
  static Future<String?> get refreshToken async {
    return _storage.read(key: _refreshTokenKey);
  }

  /// ✅ 저장된 userId 반환
  static Future<String?> get userId async {
    return _storage.read(key: _userIdKey);
  }

  /// ✅ 저장된 사용자 이메일 반환
  static Future<String?> get userEmail async {
    return _storage.read(key: _userEmailKey);
  }

  /// ✅ 저장된 사용자 닉네임 반환
  static Future<String?> get userNickname async {
    return _storage.read(key: _userNicknameKey);
  }

  /// 🆕 사용자 닉네임 저장 (새로 추가된 메서드)
  static Future<void> setUserNickname(String nickname) async {
    try {
      await _storage.write(key: _userNicknameKey, value: nickname);
      debugPrint('💾 [TOKEN_STORAGE] 닉네임 저장됨: $nickname');
    } catch (e) {
      debugPrint('❌ [TOKEN_STORAGE] 닉네임 저장 실패: $e');
      rethrow;
    }
  }

  /// ✅ 모든 토큰/유저 데이터 삭제
  static Future<void> clear() async {
    await _storage.deleteAll();
  }

  /// 🔍 디버그용: 저장된 모든 데이터 확인 (개발 환경에서만)
  static Future<void> debugPrintAllData() async {
    if (!kDebugMode) return;

    try {
      final allData = await _storage.readAll();
      debugPrint('🔍 [TOKEN_STORAGE] Stored data count: ${allData.length}');
      if (allData.isEmpty) {
        debugPrint('📭 [TOKEN_STORAGE] No stored data');
      }
    } catch (e) {
      debugPrint('❌ [TOKEN_STORAGE] Failed to read data: $e');
    }
  }

  /// 🧪 테스트용: Mock 사용자 데이터 생성
  static Future<void> createTestUser() async {
    try {
      final testAccessToken =
          'test_access_token_${DateTime.now().millisecondsSinceEpoch}';
      final testRefreshToken =
          'test_refresh_token_${DateTime.now().millisecondsSinceEpoch}';
      final testUserId = '999'; // 테스트 유저 ID

      await saveTokens(testAccessToken, testRefreshToken, testUserId);

      debugPrint('🧪 [TOKEN_STORAGE] 테스트 유저 생성 완료');
      debugPrint('👤 [TOKEN_STORAGE] UserId: $testUserId');
      debugPrint(
          '🔑 [TOKEN_STORAGE] AccessToken: ${testAccessToken.substring(0, 20)}...');
    } catch (e) {
      debugPrint('❌ [TOKEN_STORAGE] 테스트 유저 생성 실패: $e');
    }
  }

  /// 📋 현재 인증 상태 요약 (개발 환경에서만)
  static Future<void> debugAuthStatus() async {
    if (!kDebugMode) return;

    try {
      final token = await accessToken;
      final userIdValue = await userId;

      debugPrint(
          '📋 [TOKEN_STORAGE] Auth status: ${token != null && userIdValue != null ? "Authenticated" : "Not authenticated"}');
      if (token != null && userIdValue != null) {
        debugPrint('👤 [TOKEN_STORAGE] User ID: $userIdValue');
      }
    } catch (e) {
      debugPrint('❌ [TOKEN_STORAGE] Failed to check auth status: $e');
    }
  }
}
