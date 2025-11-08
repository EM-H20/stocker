import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/model/user.dart';

part 'auth_state.freezed.dart';

/// 🔥 Riverpod 기반 인증 상태
/// freezed를 사용한 불변 상태 클래스
@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    /// 현재 로그인된 사용자 정보
    User? user,

    /// 에러 메시지
    String? errorMessage,

    /// 로딩 상태 (로그인, 회원가입 등)
    @Default(false) bool isLoading,

    /// 초기화 중 상태 (앱 시작 시 토큰 확인)
    @Default(true) bool isInitializing,

    /// 프로필 업데이트 중 상태
    @Default(false) bool isUpdatingProfile,
  }) = _AuthState;

  const AuthState._();

  /// 로그인 상태 확인 헬퍼
  bool get isLoggedIn => user != null;
}
