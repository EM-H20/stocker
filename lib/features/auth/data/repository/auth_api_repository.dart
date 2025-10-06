// lib/features/auth/data/repository/auth_api_repository.dart
import 'package:flutter/foundation.dart';
import '../../../auth/data/dto/login_request.dart';
import '../../../auth/data/dto/signup_request.dart';
import '../dto/profile_update_request.dart';
import '../../data/dto/auth_response.dart';
import '../../domain/model/user.dart';
import '../../domain/auth_repository.dart';
import '../source/auth_api.dart';
import '../../../../app/core/services/token_storage.dart';

class AuthApiRepository implements AuthRepository {
  final AuthApi _api;
  AuthApiRepository(this._api);

  @override
  Future<User> login(LoginRequest request) async {
    debugPrint('🌐 [AUTH_API_REPO] 로그인 API 시작');
    debugPrint('📝 [AUTH_API_REPO] Email: ${request.email}');
    
    try {
      final AuthResponse res = await _api.login(request);
      // 응답 DTO -> 도메인 모델 변환
      final user = res.toUser();
      
      debugPrint('✅ [AUTH_API_REPO] 로그인 성공: ${user.nickname}');
      return user;
    } catch (e) {
      debugPrint('❌ [AUTH_API_REPO] 로그인 실패: $e');
      rethrow;
    }
  }

  @override
  Future<void> signup(SignupRequest request) async {
    debugPrint('🌐 [AUTH_API_REPO] 회원가입 API 시작');
    debugPrint('📝 [AUTH_API_REPO] Email: ${request.email}, Nickname: ${request.nickname}');
    
    try {
      await _api.signup(request);
      debugPrint('✅ [AUTH_API_REPO] 회원가입 성공');
    } catch (e) {
      debugPrint('❌ [AUTH_API_REPO] 회원가입 실패: $e');
      rethrow;
    }
  }

  @override
  Future<void> logout(String email) async {
    debugPrint('🌐 [AUTH_API_REPO] 로그아웃 API 시작: $email');
    
    try {
      await _api.logout(email);
      debugPrint('✅ [AUTH_API_REPO] 로그아웃 성공');
    } catch (e) {
      debugPrint('❌ [AUTH_API_REPO] 로그아웃 실패: $e');
      rethrow;
    }
  }

  @override
  Future<void> refreshToken() async {
    debugPrint('🌐 [AUTH_API_REPO] 토큰 갱신 API 시작');
    
    try {
      await _api.refreshToken();
      debugPrint('✅ [AUTH_API_REPO] 토큰 갱신 성공');
    } catch (e) {
      debugPrint('❌ [AUTH_API_REPO] 토큰 갱신 실패: $e');
      rethrow;
    }
  }

  @override
  Future<User> updateProfile({
    String? nickname,
    String? profileImageUrl,
    int? age,
    String? occupation,
  }) async {
    debugPrint('🌐 [AUTH_API_REPO] 프로필 수정 API 시작');
    debugPrint('📝 [AUTH_API_REPO] 변경사항: nickname=$nickname, age=$age, occupation=$occupation');
    
    try {
      // 수정할 내용이 있는지 확인
      final request = ProfileUpdateRequest(
        nickname: nickname,
        profileImageUrl: profileImageUrl,
        age: age,
        occupation: occupation,
      );

      if (!request.hasUpdates) {
        throw Exception('수정할 내용이 없습니다');
      }
      
      // API 호출 - 응답은 사용하지 않으므로 변수에 저장하지 않음
      await _api.updateProfile(request);
      
      // 현재 저장된 토큰 정보 가져오기
      final currentToken = await TokenStorage.accessToken;
      final currentRefreshToken = await TokenStorage.refreshToken;
      final currentUserId = await TokenStorage.userId;
      final currentEmail = await TokenStorage.userEmail;
      
      if (currentToken == null || currentUserId == null || currentEmail == null) {
        throw Exception('로그인 정보가 없습니다');
      }
      
      // API 응답에서 User 객체 생성 (ProfileUpdateResponse 구조에 맞게)
      final updatedUser = User(
        id: int.tryParse(currentUserId) ?? 0,
        email: currentEmail,
        nickname: nickname ?? await TokenStorage.userNickname ?? '',
        accessToken: currentToken,
        refreshToken: currentRefreshToken ?? '',
      );
      
      // TokenStorage에 업데이트된 정보 저장
      if (nickname != null) {
        await TokenStorage.setUserNickname(nickname);
        debugPrint('💾 [AUTH_API_REPO] 닉네임 저장소 업데이트: $nickname');
      }
      
      debugPrint('✅ [AUTH_API_REPO] 프로필 수정 완료: ${updatedUser.nickname}');
      
      return updatedUser;
      
    } catch (e) {
      debugPrint('❌ [AUTH_API_REPO] 프로필 수정 실패: $e');
      
      // 에러 타입에 따른 구체적인 메시지 제공
      if (e.toString().contains('401')) {
        throw Exception('로그인이 필요합니다');
      } else if (e.toString().contains('400')) {
        throw Exception('잘못된 요청입니다');
      } else if (e.toString().contains('404')) {
        throw Exception('사용자를 찾을 수 없습니다');
      } else if (e.toString().contains('500')) {
        throw Exception('서버 오류가 발생했습니다');
      } else {
        throw Exception('프로필 수정에 실패했습니다: $e');
      }
    }
  }
}