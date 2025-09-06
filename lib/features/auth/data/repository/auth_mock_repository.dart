import 'package:flutter/foundation.dart';
import '../../../../app/core/services/token_storage.dart';
import '../../domain/model/user.dart';
import '../../domain/auth_repository.dart';
import '../dto/login_request.dart';
import '../dto/signup_request.dart';

class AuthMockRepository implements AuthRepository {
  @override
  Future<User> login(LoginRequest request) async {
    debugPrint('🎭 [AUTH_MOCK] Mock 로그인 시작');
    debugPrint('🎭 [AUTH_MOCK] Email: ${request.email}');

    // Mock 로그인 지연시간 (실제 API 호출 시뮬레이션)
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock 사용자 생성
    final user = User(
      id: 1,
      email: request.email,
      nickname: '목테스터', // 더 한국적인 닉네임
      accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken:
          'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
    );

    // 토큰을 실제 저장소에 저장 (Mock이지만 실제 동작 시뮬레이션)
    await TokenStorage.saveTokens(user.accessToken, user.refreshToken, user.id);

    debugPrint('✅ [AUTH_MOCK] Mock 로그인 성공 - User: ${user.nickname}');
    return user;
  }

  @override
  Future<void> signup(SignupRequest request) async {
    debugPrint('🎭 [AUTH_MOCK] Mock 회원가입 시작');
    debugPrint(
        '🎭 [AUTH_MOCK] Email: ${request.email}, Nickname: ${request.nickname}');

    // 회원가입 지연시간 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 800));

    debugPrint('✅ [AUTH_MOCK] Mock 회원가입 완료');
  }

  @override
  Future<void> logout(String email) async {
    debugPrint('🎭 [AUTH_MOCK] Mock 로그아웃 시작 - Email: $email');

    // 로그아웃 지연시간 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 300));

    // 실제 토큰 저장소에서 제거
    await TokenStorage.clear();

    debugPrint('✅ [AUTH_MOCK] Mock 로그아웃 완료');
  }

  @override
  Future<User> refreshToken() async {
    debugPrint('🎭 [AUTH_MOCK] Mock 토큰 갱신 시작');

    await Future.delayed(const Duration(milliseconds: 400));

    final user = User(
      id: 1,
      email: 'tester@example.com', // Mock refresh에서는 고정 이메일
      nickname: '목테스터',
      accessToken:
          'refreshed_mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken:
          'refreshed_mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
    );

    // 갱신된 토큰 저장
    await TokenStorage.saveTokens(user.accessToken, user.refreshToken, user.id);

    debugPrint('✅ [AUTH_MOCK] Mock 토큰 갱신 완료');
    return user;
  }
}
