// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authNotifierHash() => r'cde9f30e9aa1c1edcebaf3beb326128e2ed3b88a';

/// 🔥 Riverpod 기반 인증 상태 관리 Notifier
/// AsyncNotifier를 사용하여 비동기 초기화 지원
///
/// Copied from [AuthNotifier].
@ProviderFor(AuthNotifier)
final authNotifierProvider =
    AutoDisposeAsyncNotifierProvider<AuthNotifier, AuthState>.internal(
  AuthNotifier.new,
  name: r'authNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthNotifier = AutoDisposeAsyncNotifier<AuthState>;
String _$loginSuccessNotifierHash() =>
    r'2acd11fbb286819eb08ac644f6518e180fecf8a9';

/// 🔥 로그인 성공 이벤트 Notifier
/// HomeShell에서 출석 퀴즈 모달을 띄우기 위한 이벤트 Provider
///
/// Copied from [LoginSuccessNotifier].
@ProviderFor(LoginSuccessNotifier)
final loginSuccessNotifierProvider =
    AutoDisposeNotifierProvider<LoginSuccessNotifier, bool>.internal(
  LoginSuccessNotifier.new,
  name: r'loginSuccessNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$loginSuccessNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LoginSuccessNotifier = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
