// lib/features/auth/data/source/auth_api.dart
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../app/core/services/token_storage.dart';
import '../../../auth/data/dto/login_request.dart';
import '../../../auth/data/dto/signup_request.dart';
import '../dto/auth_response.dart';
import '../dto/profile_update_request.dart';
import '../dto/profile_update_response.dart';

class AuthApi {
  final Dio _dio;
  AuthApi(this._dio);

  // 로그인
  Future<AuthResponse> login(LoginRequest request) async {
    final endpoint = dotenv.env['JWT_LOGIN_ENDPOINT'] ?? '/api/user/login';
    final res = await _dio.post(
      endpoint,
      data: request.toJson(),
    );

    final data = AuthResponse.fromJson(res.data);

    // 🔧 수정: 토큰과 사용자 정보 모두 저장
    await TokenStorage.saveUserSession(
      accessToken: data.accessToken,
      refreshToken: data.refreshToken,
      userId: data.userId,
      email: data.email,
      nickname: data.nickname.isNotEmpty ? data.nickname : null,
    );

    return data;
  }

  // 회원가입
  Future<void> signup(SignupRequest request) async {
    final endpoint = dotenv.env['JWT_SIGNUP_ENDPOINT'] ?? '/api/user/signup';
    await _dio.post(
      endpoint,
      data: request.toJson(),
    );
  }

  // 로그아웃 - 이메일이 필요함
  Future<void> logout(String email) async {
    try {
      final endpoint = dotenv.env['JWT_LOGOUT_ENDPOINT'] ?? '/api/user/logout';
      final access = await TokenStorage.accessToken;
      final refresh = await TokenStorage.refreshToken;
      await _dio.post(
        endpoint,
        data: {'email': email}, // 백엔드는 email을 기대함
        options: Options(headers: {
          if (access != null && access.isNotEmpty)
            'Authorization': 'Bearer $access',
          if (refresh != null && refresh.isNotEmpty) 'x-refresh-token': refresh,
        }),
      );
    } finally {
      await TokenStorage.clear();
    }
  }

  // 프로필 수정
  Future<ProfileUpdateResponse> updateProfile(
      ProfileUpdateRequest request) async {
    final endpoint =
        dotenv.env['PROFILE_UPDATE_ENDPOINT'] ?? '/api/user/profile';
    final access = await TokenStorage.accessToken;
    final refresh = await TokenStorage.refreshToken;

    final response = await _dio.post(
      endpoint,
      data: request.toJson(),
      options: Options(headers: {
        if (access != null && access.isNotEmpty)
          'Authorization': 'Bearer $access',
        if (refresh != null && refresh.isNotEmpty) 'x-refresh-token': refresh,
      }),
    );

    return ProfileUpdateResponse.fromJson(response.data);
  }

  // 백엔드는 미들웨어에서 자동으로 토큰 갱신을 처리하므로
  // 별도의 refresh 엔드포인트 호출은 필요하지 않음
  Future<String> refreshToken() async {
    // 백엔드 미들웨어 방식에서는 자동 처리됨
    // 401 에러 발생 시 인터셉터에서 x-access-token 헤더를 확인
    throw UnimplementedError('백엔드 미들웨어에서 자동 토큰 갱신 처리됨');
  }
}
