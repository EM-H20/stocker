import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/riverpod/auth_notifier.dart';
import 'app_routes.dart';

/// 인증 상태에 따른 라우팅 가드
///
/// GoRouter의 redirect 콜백에서 사용되며,
/// 로그인하지 않은 사용자가 보호된 페이지에 접근할 때
/// 자동으로 로그인 화면으로 리다이렉트합니다.
class AuthGuard {
  /// 공개 페이지 목록 (로그인 없이 접근 가능)
  static const publicRoutes = [
    AppRoutes.login, // '/login'
    AppRoutes.register, // '/register'
  ];

  /// 라우팅 리다이렉트 로직
  ///
  /// Returns:
  /// - null: 현재 경로 유지 (접근 허용)
  /// - '/login?redirect=...': 로그인 페이지로 리다이렉트 (원래 경로 보존)
  /// - '/education': 홈 페이지로 리다이렉트
  static String? redirect(
    BuildContext context,
    GoRouterState state,
    WidgetRef ref,
  ) {
    // 1. 현재 인증 상태 확인
    // ⚠️ redirect 콜백에서는 ref.read() 사용! (ref.watch() 사용 시 앱 전체 rebuild 발생)
    final authState = ref.read(authNotifierProvider);

    // 초기화 중이면 아무것도 하지 않음 (깜빡임 방지)
    if (authState.isLoading || authState.value?.isInitializing == true) {
      debugPrint('🔐 [AUTH_GUARD] Initializing... skipping redirect');
      return null;
    }

    final isLoggedIn = authState.value?.user != null;
    final currentPath = state.matchedLocation;

    // ✅ 강화된 디버그 로그: 상태 세부 정보 출력
    debugPrint('🔐 [AUTH_GUARD] ═══════════════════════════');
    debugPrint('🔐 [AUTH_GUARD] Route check: $currentPath');
    debugPrint('🔐 [AUTH_GUARD] Is logged in: $isLoggedIn');
    debugPrint('🔐 [AUTH_GUARD] User email: ${authState.value?.user?.email ?? "null"}');
    debugPrint('🔐 [AUTH_GUARD] Auth loading: ${authState.isLoading}');
    debugPrint('🔐 [AUTH_GUARD] Auth initializing: ${authState.value?.isInitializing ?? "null"}');

    // 2. 공개 페이지인지 확인
    final isPublicRoute = publicRoutes.contains(currentPath);
    debugPrint('🔐 [AUTH_GUARD] Is public route: $isPublicRoute');

    // 3. 로그인하지 않았고, 공개 페이지가 아니면 → 로그인으로 리다이렉트
    if (!isLoggedIn && !isPublicRoute) {
      debugPrint('⚠️ [AUTH_GUARD] ❌ Access denied - not logged in');
      debugPrint('📍 [AUTH_GUARD] Redirecting to login with return path: $currentPath');

      // 원래 가려던 경로를 쿼리 파라미터로 저장
      final encodedPath = Uri.encodeComponent(currentPath);
      return '${AppRoutes.login}?redirect=$encodedPath';
    }

    // 4. 로그인했는데 로그인/회원가입 페이지에 있으면 → 홈으로 리다이렉트
    if (isLoggedIn && isPublicRoute) {
      debugPrint('ℹ️ [AUTH_GUARD] Already logged in, redirecting to home');
      return AppRoutes.education; // 기본 홈 화면
    }

    // 5. 그 외의 경우 → 현재 경로 유지
    debugPrint('✅ [AUTH_GUARD] ✅ Access granted to: $currentPath');
    debugPrint('🔐 [AUTH_GUARD] ═══════════════════════════');
    return null;
  }
}

/// Stream을 Listenable로 변환하는 헬퍼
///
/// 인증 상태 변경 시 GoRouter를 자동으로 갱신하기 위해 사용됩니다.
/// GoRouter의 refreshListenable에 전달하여 인증 상태가 변경될 때마다
/// 라우터가 자동으로 redirect 로직을 재실행하도록 합니다.
class GoRouterRefreshStream extends ChangeNotifier {
  /// Stream 구독을 저장
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
