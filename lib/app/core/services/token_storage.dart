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

  /// ✅ 모든 토큰/유저 데이터 삭제
  static Future<void> clear() async {
    await _storage.deleteAll();
  }

  /// 🔍 디버그용: 저장된 모든 데이터 확인
  static Future<void> debugPrintAllData() async {
    try {
      final allData = await _storage.readAll();
      debugPrint('🔍 [TOKEN_STORAGE] === 저장된 모든 데이터 ===');
      if (allData.isEmpty) {
        debugPrint('📭 [TOKEN_STORAGE] 저장된 데이터 없음');
      } else {
        allData.forEach((key, value) {
          final maskedValue = value.length > 20 ? '${value.substring(0, 20)}...' : value;
          debugPrint('🔑 [TOKEN_STORAGE] $key: $maskedValue');
        });
      }
      debugPrint('🔍 [TOKEN_STORAGE] ========================');
    } catch (e) {
      debugPrint('❌ [TOKEN_STORAGE] 데이터 조회 실패: $e');
    }
  }

  /// 🧪 테스트용: Mock 사용자 데이터 생성
  static Future<void> createTestUser() async {
    try {
      final testAccessToken = 'test_access_token_${DateTime.now().millisecondsSinceEpoch}';
      final testRefreshToken = 'test_refresh_token_${DateTime.now().millisecondsSinceEpoch}';
      final testUserId = '999'; // 테스트 유저 ID

      await saveTokens(testAccessToken, testRefreshToken, testUserId);
      
      debugPrint('🧪 [TOKEN_STORAGE] 테스트 유저 생성 완료');
      debugPrint('👤 [TOKEN_STORAGE] UserId: $testUserId');
      debugPrint('🔑 [TOKEN_STORAGE] AccessToken: ${testAccessToken.substring(0, 20)}...');
    } catch (e) {
      debugPrint('❌ [TOKEN_STORAGE] 테스트 유저 생성 실패: $e');
    }
  }

  /// 📋 현재 인증 상태 요약
  static Future<void> debugAuthStatus() async {
    try {
      final token = await accessToken;
      final userIdValue = await userId;
      final refresh = await refreshToken;

      debugPrint('📋 [TOKEN_STORAGE] === 현재 인증 상태 ===');
      if (token != null && userIdValue != null) {
        debugPrint('✅ [TOKEN_STORAGE] 로그인 상태: 인증됨');
        debugPrint('👤 [TOKEN_STORAGE] 유저 ID: $userIdValue');
        debugPrint('🔑 [TOKEN_STORAGE] 토큰 있음: ${token.length}자');
      } else {
        debugPrint('❌ [TOKEN_STORAGE] 로그인 상태: 비인증됨');
        debugPrint('💡 [TOKEN_STORAGE] 로그인 필요 - API 호출 시 401 에러 발생');
      }
      debugPrint('📋 [TOKEN_STORAGE] =====================');
    } catch (e) {
      debugPrint('❌ [TOKEN_STORAGE] 인증 상태 확인 실패: $e');
    }
  }
}
