import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';

import '../../domain/model/user.dart';
import '../../data/dto/login_request.dart';
import '../../data/dto/signup_request.dart';
import '../../../../app/core/services/token_storage.dart';
import '../../../../app/core/providers/riverpod/repository_providers.dart';
import '../../../../app/core/utils/error_message_extractor.dart';
import 'auth_state.dart';

part 'auth_notifier.g.dart';

/// 🔥 Riverpod 기반 인증 상태 관리 Notifier
/// AsyncNotifier를 사용하여 비동기 초기화 지원
@riverpod
class AuthNotifier extends _$AuthNotifier {
  final Logger _logger = Logger();

  @override
  Future<AuthState> build() async {
    // 앱 시작 시 자동으로 초기화 (토큰 확인)
    return await _initialize();
  }

  /// 앱 시작 시 저장된 토큰을 확인하여 자동 로그인 처리
  Future<AuthState> _initialize() async {
    debugPrint('🔄 [AUTH_NOTIFIER] Initializing auth state...');

    try {
      final token = await TokenStorage.accessToken;
      final userId = await TokenStorage.userId;

      if (token != null && userId != null) {
        // 저장된 실제 사용자 정보 사용
        final storedRefreshToken = await TokenStorage.refreshToken ?? '';
        final email = await TokenStorage.userEmail;
        final nickname = await TokenStorage.userNickname;

        if (email != null) {
          // 실제 사용자 정보가 있는 경우에만 사용자 복원
          final user = User(
            id: int.tryParse(userId) ?? 0,
            email: email,
            nickname: nickname ?? '',
            accessToken: token,
            refreshToken: storedRefreshToken,
          );

          debugPrint(
              '✅ [AUTH_NOTIFIER] Auto-login successful for: ${user.email}');

          return AuthState(
            user: user,
            isInitializing: false,
          );
        } else {
          // 사용자 정보가 불완전한 경우 토큰 정리
          debugPrint(
              '⚠️ [AUTH_NOTIFIER] Incomplete user data - clearing tokens');
          await TokenStorage.clear();
        }
      } else {
        debugPrint('ℹ️ [AUTH_NOTIFIER] No saved tokens - user needs to login');
      }
    } catch (e) {
      debugPrint('❌ [AUTH_NOTIFIER] Initialization error: $e');
    }

    debugPrint('🏁 [AUTH_NOTIFIER] Initialization complete - not logged in');
    return const AuthState(isInitializing: false);
  }

  /// 로그인
  Future<bool> login(String email, String password) async {
    // 로딩 상태로 변경
    state = AsyncValue.data(
      state.value!.copyWith(isLoading: true, errorMessage: null),
    );

    try {
      final request = LoginRequest(email: email, password: password);
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.login(request);

      // 로그인 성공
      state = AsyncValue.data(
        AuthState(user: user, isLoading: false, isInitializing: false),
      );

      // 로그인 성공 이벤트 트리거
      ref.read(loginSuccessNotifierProvider.notifier).trigger();

      debugPrint('✅ [AUTH_NOTIFIER] Login successful for: ${user.email}');
      return true;
    } catch (e) {
      debugPrint('❌ [AUTH_NOTIFIER] Login failed: $e');

      final errorMessage = ErrorMessageExtractor.extractAuthError(e);

      state = AsyncValue.data(
        state.value!.copyWith(
          isLoading: false,
          errorMessage: errorMessage,
        ),
      );
      return false;
    }
  }

  /// 🧪 테스트용 빠른 로그인 (개발자 전용)
  Future<bool> quickTestLogin() async {
    debugPrint('🧪 [AUTH_NOTIFIER] Quick test login started');
    final result = await login('test@example.com', 'test123');

    if (result) {
      debugPrint('✅ [AUTH_NOTIFIER] Test login successful');
    } else {
      debugPrint('❌ [AUTH_NOTIFIER] Test login failed');
    }

    return result;
  }

  /// 회원가입
  Future<bool> signup(
    String email,
    String password,
    String nickname, {
    required int age,
    required String occupation,
    String provider = 'local',
    String profileImageUrl = 'https://example.com/profile.png',
  }) async {
    state = AsyncValue.data(
      state.value!.copyWith(isLoading: true, errorMessage: null),
    );

    try {
      final request = SignupRequest(
        email: email,
        password: password,
        nickname: nickname,
        age: age,
        occupation: occupation,
        provider: provider,
        profileImageUrl: profileImageUrl,
      );

      debugPrint('🔄 [AUTH_NOTIFIER] 회원가입 요청: $request');

      final repository = ref.read(authRepositoryProvider);
      await repository.signup(request);

      state = AsyncValue.data(
        state.value!.copyWith(isLoading: false),
      );

      debugPrint('✅ [AUTH_NOTIFIER] 회원가입 성공');
      return true;
    } catch (e) {
      debugPrint('❌ [AUTH_NOTIFIER] 회원가입 실패: $e');

      final errorMessage =
          ErrorMessageExtractor.extractSubmissionError(e, '회원가입');

      state = AsyncValue.data(
        state.value!.copyWith(
          isLoading: false,
          errorMessage: errorMessage,
        ),
      );
      return false;
    }
  }

  /// 프로필 수정
  Future<bool> updateProfile({
    String? nickname,
    String? profileImageUrl,
    int? age,
    String? occupation,
  }) async {
    final currentUser = state.value?.user;

    if (currentUser == null) {
      state = AsyncValue.data(
        state.value!.copyWith(errorMessage: '로그인이 필요합니다'),
      );
      return false;
    }

    state = AsyncValue.data(
      state.value!.copyWith(isUpdatingProfile: true, errorMessage: null),
    );

    try {
      debugPrint('🔄 [AUTH_NOTIFIER] 프로필 수정 시작...');
      debugPrint(
          '📝 [AUTH_NOTIFIER] 변경 내용 - nickname: $nickname, age: $age, occupation: $occupation');

      final repository = ref.read(authRepositoryProvider);
      final updatedUser = await repository.updateProfile(
        nickname: nickname,
        profileImageUrl: profileImageUrl,
        age: age,
        occupation: occupation,
      );

      // 토큰 저장소에 닉네임 업데이트
      if (nickname != null) {
        await TokenStorage.setUserNickname(nickname);
        debugPrint('💾 [AUTH_NOTIFIER] 닉네임이 토큰 저장소에 업데이트됨: $nickname');
      }

      state = AsyncValue.data(
        state.value!.copyWith(
          user: updatedUser,
          isUpdatingProfile: false,
        ),
      );

      debugPrint('✅ [AUTH_NOTIFIER] 프로필 수정 성공');
      return true;
    } catch (e) {
      debugPrint('❌ [AUTH_NOTIFIER] 프로필 수정 실패: $e');

      final errorMessage =
          ErrorMessageExtractor.extractSubmissionError(e, '프로필 수정');

      state = AsyncValue.data(
        state.value!.copyWith(
          isUpdatingProfile: false,
          errorMessage: errorMessage,
        ),
      );
      return false;
    }
  }

  /// 닉네임만 수정하는 편의 메서드
  Future<bool> updateNickname(String newNickname) async {
    debugPrint(
        '📝 [AUTH_NOTIFIER] 닉네임 변경: ${state.value?.user?.nickname} → $newNickname');
    return await updateProfile(nickname: newNickname);
  }

  /// 로그아웃
  Future<void> logout() async {
    final currentUser = state.value?.user;
    if (currentUser == null) return;

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.logout(currentUser.email);
    } catch (e) {
      _logger.e('Logout API failed: $e');
    } finally {
      await TokenStorage.clear();
      state = AsyncValue.data(
        const AuthState(isInitializing: false),
      );
      debugPrint('✅ [AUTH_NOTIFIER] 로그아웃 완료');
    }
  }

  /// 토큰 갱신 (Dio 인터셉터 등에서 사용)
  Future<void> refreshToken() async {
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.refreshToken();

      // 토큰 갱신 성공 시 사용자 상태도 동기화
      await _syncUserStateWithStorage();
    } catch (e) {
      debugPrint(
          '⚠️ [AUTH_NOTIFIER] Token refresh failed - may need re-login: $e');
    }
  }

  /// 저장소의 토큰 정보와 사용자 상태 동기화
  Future<void> _syncUserStateWithStorage() async {
    try {
      final token = await TokenStorage.accessToken;
      final userId = await TokenStorage.userId;
      final email = await TokenStorage.userEmail;
      final nickname = await TokenStorage.userNickname;
      final refreshToken = await TokenStorage.refreshToken;

      final currentUser = state.value?.user;

      if (token != null &&
          userId != null &&
          email != null &&
          currentUser != null) {
        final updatedUser = User(
          id: int.tryParse(userId) ?? currentUser.id,
          email: email,
          nickname: nickname ?? currentUser.nickname,
          accessToken: token,
          refreshToken: refreshToken ?? currentUser.refreshToken,
        );

        state = AsyncValue.data(
          state.value!.copyWith(user: updatedUser),
        );

        debugPrint('🔄 [AUTH_NOTIFIER] User state synced with updated tokens');
      }
    } catch (e) {
      debugPrint('❌ [AUTH_NOTIFIER] Failed to sync user state: $e');
    }
  }
}

/// 🔥 로그인 성공 이벤트 Notifier
/// HomeShell에서 출석 퀴즈 모달을 띄우기 위한 이벤트 Provider
@riverpod
class LoginSuccessNotifier extends _$LoginSuccessNotifier {
  @override
  bool build() => false;

  /// 로그인 성공 이벤트 트리거
  void trigger() {
    state = true;
    // 잠시 후 다시 false로 초기화하여 다음 이벤트를 위해 준비
    // Riverpod에서는 mounted 체크 불필요 - dispose된 경우 자동으로 무시됨
    Future.delayed(const Duration(milliseconds: 100), () {
      state = false;
    });
  }
}
