
// lib/features/auth/data/source/auth_api.dart
import 'package:dio/dio.dart';
import '../../../../app/core/services/token_storage.dart';
import '../../../auth/data/dto/login_request.dart';
import '../../../auth/data/dto/signup_request.dart';
import '../dto/auth_response.dart';
class AuthApi {
  final Dio _dio;
  AuthApi(this._dio);

  // 로그인
  Future<AuthResponse> login(LoginRequest request) async {
    final res = await _dio.post(
      '/api/auth/login',
      data: request.toJson(),
    );

    final data = AuthResponse.fromJson(res.data);

    // ✅ 토큰 + userId 저장 (static)
    await TokenStorage.saveTokens(
      data.accessToken,
      data.refreshToken,
      data.userId,
    );

    return data;
  }

  // 회원가입
  Future<void> signup(SignupRequest request) async {
    await _dio.post(
      '/api/auth/register',
      data: request.toJson(),
    );
  }

  // 로그아웃
  Future<void> logout(int userId) async {
    try {
      final access = await TokenStorage.accessToken;
      await _dio.post(
        '/api/auth/logout',
        data: { 'user_id': userId },
        options: Options(headers: {
          if (access != null && access.isNotEmpty)
            'Authorization': 'Bearer $access',
        }),
      );
    } finally {
      await TokenStorage.clear();
    }
  }

  // (선택) 명시적 refresh 호출이 필요할 때
  Future<String> refreshToken() async {
    final refresh = await TokenStorage.refreshToken;
    final userId = await TokenStorage.userId;

    if (refresh == null || userId == null) {
      throw Exception('No refresh token or user id');
    }

    final res = await _dio.post(
      '/api/auth/refresh',
      data: {
        'user_id': int.tryParse(userId) ?? userId,
        'refresh_token': refresh,
      },
    );

    final newAccess = res.data['access_token'] as String;
    final newRefresh = (res.data['refresh_token'] as String?) ?? refresh;

    await TokenStorage.saveTokens(
      newAccess,
      newRefresh,
      int.tryParse(userId) ?? userId,
    );

    return newAccess;
  }
}

