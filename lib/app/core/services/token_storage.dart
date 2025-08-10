// lib/app/core/services/token_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';

  /// ✅ accessToken, refreshToken, userId를 한 번에 저장
  static Future<void> saveTokens(String accessToken, String refreshToken, Object userId) async {
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

  /// ✅ 모든 토큰/유저 데이터 삭제
  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}
