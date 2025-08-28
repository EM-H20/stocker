import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 네비게이션 안전성을 보장하는 가드 클래스
/// 무한 루프, 중복 네비게이션 등을 방지합니다
class NavigationGuard {
  static final List<String> _navigationHistory = [];
  static const int maxHistorySize = 50; // 최대 히스토리 크기
  static const int maxConsecutiveSameRoute = 3; // 동일 라우트 연속 방문 허용 횟수

  /// 안전한 네비게이션 수행 (go)
  static void safeGo(BuildContext context, String route, {Object? extra}) {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    
    debugPrint('🛡️ [NAVIGATION_GUARD] GO 네비게이션 요청: $currentRoute → $route');
    
    // 동일한 라우트로 이동하는 경우 체크
    if (currentRoute == route) {
      debugPrint('⚠️ [NAVIGATION_GUARD] 동일한 라우트로 이동 시도 무시: $route');
      return;
    }

    // 히스토리에 추가
    _addToHistory(route);
    
    // 연속 동일 라우트 체크
    if (_hasExcessiveConsecutiveVisits(route)) {
      debugPrint('🚨 [NAVIGATION_GUARD] 과도한 연속 방문 감지, 홈으로 리다이렉트: $route');
      context.go('/'); // 홈으로 강제 리다이렉트
      return;
    }

    debugPrint('✅ [NAVIGATION_GUARD] 안전한 GO 네비게이션 실행: $route');
    context.go(route, extra: extra);
  }

  /// 안전한 네비게이션 수행 (push)
  static void safePush(BuildContext context, String route, {Object? extra}) {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    
    debugPrint('🛡️ [NAVIGATION_GUARD] PUSH 네비게이션 요청: $currentRoute → $route');
    
    // 히스토리에 추가
    _addToHistory(route);
    
    // 스택 깊이 체크 (너무 깊어지면 경고)
    if (_navigationHistory.length > maxHistorySize * 0.8) {
      debugPrint('⚠️ [NAVIGATION_GUARD] 네비게이션 스택이 깊어지고 있습니다: ${_navigationHistory.length}');
    }

    debugPrint('✅ [NAVIGATION_GUARD] 안전한 PUSH 네비게이션 실행: $route');
    context.push(route, extra: extra);
  }

  /// 안전한 네비게이션 수행 (pushReplacement)
  static void safePushReplacement(BuildContext context, String route, {Object? extra}) {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    
    debugPrint('🛡️ [NAVIGATION_GUARD] PUSH_REPLACEMENT 네비게이션 요청: $currentRoute → $route');
    debugPrint('🔄 [NAVIGATION_GUARD] 현재 라우트를 교체합니다: $currentRoute → $route');

    // 히스토리에서 현재 라우트 제거 후 새 라우트 추가
    if (_navigationHistory.isNotEmpty) {
      _navigationHistory.removeLast();
    }
    _addToHistory(route);

    debugPrint('✅ [NAVIGATION_GUARD] 안전한 PUSH_REPLACEMENT 네비게이션 실행: $route');
    context.pushReplacement(route, extra: extra);
  }

  /// 히스토리에 라우트 추가
  static void _addToHistory(String route) {
    _navigationHistory.add(route);
    
    // 히스토리 크기 제한
    if (_navigationHistory.length > maxHistorySize) {
      _navigationHistory.removeAt(0);
    }
    
    debugPrint('📍 [NAVIGATION_GUARD] 현재 히스토리 크기: ${_navigationHistory.length}');
    if (kDebugMode) {
      debugPrint('📚 [NAVIGATION_GUARD] 최근 히스토리: ${_navigationHistory.take(5).toList()}');
    }
  }

  /// 과도한 연속 방문 체크
  static bool _hasExcessiveConsecutiveVisits(String route) {
    if (_navigationHistory.length < maxConsecutiveSameRoute) return false;
    
    final recentRoutes = _navigationHistory.reversed.take(maxConsecutiveSameRoute);
    return recentRoutes.every((r) => r == route);
  }

  /// 현재 네비게이션 히스토리 반환 (디버깅용)
  static List<String> get navigationHistory => List.unmodifiable(_navigationHistory);

  /// 히스토리 초기화 (테스트용)
  static void clearHistory() {
    debugPrint('🧹 [NAVIGATION_GUARD] 네비게이션 히스토리 초기화');
    _navigationHistory.clear();
  }

  /// 네비게이션 상태 리포트 출력
  static void printNavigationReport() {
    debugPrint('📊 [NAVIGATION_GUARD] === 네비게이션 리포트 ===');
    debugPrint('📊 [NAVIGATION_GUARD] 총 히스토리 크기: ${_navigationHistory.length}');
    debugPrint('📊 [NAVIGATION_GUARD] 최근 10개 경로: ${_navigationHistory.reversed.take(10).toList()}');
    
    // 가장 많이 방문한 라우트 분석
    final routeCounts = <String, int>{};
    for (final route in _navigationHistory) {
      routeCounts[route] = (routeCounts[route] ?? 0) + 1;
    }
    
    final sortedRoutes = routeCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    debugPrint('📊 [NAVIGATION_GUARD] 방문 빈도 Top 5:');
    for (int i = 0; i < sortedRoutes.length && i < 5; i++) {
      final entry = sortedRoutes[i];
      debugPrint('📊 [NAVIGATION_GUARD]   ${i + 1}. ${entry.key}: ${entry.value}회');
    }
    debugPrint('📊 [NAVIGATION_GUARD] ========================');
  }
}