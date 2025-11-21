# 인증 가드 라우팅 시스템 구현 계획 🔐

> **작성일**: 2025-11-21
> **목적**: 로그인하지 않은 사용자가 보호된 페이지 접근 시 자동으로 로그인 화면으로 리다이렉트

---

## 🎯 문제 정의

### 현재 상황
- 로그인하지 않아도 모든 페이지 접근 가능 ❌
- 홈 화면(`/education`)을 누구나 접근할 수 있음
- 사용자 인증이 필요한 기능도 로그인 없이 사용 가능

### 목표
- 로그인하지 않은 사용자는 **자동으로 로그인 화면**으로 리다이렉트 ✅
- 로그인 후 **원래 가려던 페이지**로 자동 이동 ✅
- 공개 페이지(로그인, 회원가입)는 인증 없이 접근 가능 ✅

---

## 📋 구현 계획

### Phase 1: GoRouter Redirect 메커니즘 구현 🛡️

**목표**: GoRouter의 `redirect` 콜백을 사용하여 인증 상태에 따라 자동 리다이렉트

#### 1.1 AuthGuard 클래스 생성

**파일**: `lib/app/config/auth_guard.dart` (신규)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/riverpod/auth_notifier.dart';
import 'app_routes.dart';

/// 인증 상태에 따른 라우팅 가드
class AuthGuard {
  /// 공개 페이지 목록 (로그인 없이 접근 가능)
  static const publicRoutes = [
    AppRoutes.login,    // '/login'
    AppRoutes.register, // '/register'
  ];

  /// 라우팅 리다이렉트 로직
  ///
  /// Returns:
  /// - null: 현재 경로 유지 (접근 허용)
  /// - '/login': 로그인 페이지로 리다이렉트
  static String? redirect(
    BuildContext context,
    GoRouterState state,
    WidgetRef ref,
  ) {
    // 1. 현재 인증 상태 확인
    final authState = ref.read(authNotifierProvider);

    // 초기화 중이면 로딩 중이므로 아무것도 하지 않음
    if (authState.isLoading || authState.value?.isInitializing == true) {
      return null;
    }

    final isLoggedIn = authState.value?.user != null;
    final currentPath = state.matchedLocation;

    debugPrint('🔐 [AUTH_GUARD] Checking route: $currentPath');
    debugPrint('🔐 [AUTH_GUARD] Logged in: $isLoggedIn');

    // 2. 공개 페이지인지 확인
    final isPublicRoute = publicRoutes.contains(currentPath);

    // 3. 로그인하지 않았고, 공개 페이지가 아니면 → 로그인으로 리다이렉트
    if (!isLoggedIn && !isPublicRoute) {
      debugPrint('⚠️ [AUTH_GUARD] Not logged in, redirecting to login');
      debugPrint('📍 [AUTH_GUARD] Original destination: $currentPath');

      // 원래 가려던 경로를 쿼리 파라미터로 저장
      return '${AppRoutes.login}?redirect=$currentPath';
    }

    // 4. 로그인했는데 로그인/회원가입 페이지에 있으면 → 홈으로 리다이렉트
    if (isLoggedIn && isPublicRoute) {
      debugPrint('ℹ️ [AUTH_GUARD] Already logged in, redirecting to home');
      return AppRoutes.education; // 기본 홈 화면
    }

    // 5. 그 외의 경우 → 현재 경로 유지
    return null;
  }
}
```

**핵심 기능**:
- ✅ 로그인하지 않은 사용자 → 로그인 페이지로 자동 리다이렉트
- ✅ 원래 가려던 경로를 `redirect` 파라미터로 저장
- ✅ 로그인한 사용자가 로그인 페이지 접근 → 홈으로 리다이렉트
- ✅ 초기화 중에는 리다이렉트하지 않음 (깜빡임 방지)

---

### Phase 2: GoRouter에 Redirect 통합 🔧

**목표**: `app_router.dart`에 AuthGuard 적용

#### 2.1 app_router.dart 수정

**파일**: `lib/app/config/app_router.dart`

**변경 전**:
```dart
class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: AppRoutes.education,
    debugLogDiagnostics: true,
    routes: [ ... ],
    errorBuilder: (context, state) => ErrorPage(...),
  );
}
```

**변경 후**:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_guard.dart';

class AppRouter {
  /// WidgetRef를 받아서 GoRouter 생성
  static GoRouter createRouter(WidgetRef ref) {
    return GoRouter(
      initialLocation: AppRoutes.education,
      debugLogDiagnostics: true,

      // ✅ 인증 가드 리다이렉트 추가
      redirect: (context, state) => AuthGuard.redirect(context, state, ref),

      // ✅ 인증 상태 변경 시 라우터 갱신
      refreshListenable: GoRouterRefreshStream(
        ref.watch(authNotifierProvider.notifier).stream,
      ),

      routes: [ ... ],
      errorBuilder: (context, state) => ErrorPage(...),
    );
  }
}
```

**핵심 변경사항**:
- `redirect` 콜백으로 모든 라우팅에 인증 체크 적용
- `refreshListenable`로 인증 상태 변경 시 자동 갱신

#### 2.2 GoRouterRefreshStream 헬퍼 클래스 추가

**파일**: `lib/app/config/auth_guard.dart` (추가)

```dart
import 'package:flutter/foundation.dart';

/// Stream을 Listenable로 변환하는 헬퍼
/// 인증 상태 변경 시 GoRouter를 자동으로 갱신
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
```

---

### Phase 3: main.dart에서 ProviderScope 통합 🚀

**목표**: Riverpod의 WidgetRef를 GoRouter에 전달

#### 3.1 main.dart 수정

**파일**: `lib/main.dart`

**변경 전**:
```dart
class StockerApp extends StatelessWidget {
  const StockerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      builder: (context, child) {
        return Consumer(
          builder: (context, ref, child) {
            final currentThemeMode = ref.watch(themeModeProvider);

            return MaterialApp.router(
              routerConfig: AppRouter.router,  // ❌ 정적 라우터
              // ...
            );
          },
        );
      },
    );
  }
}
```

**변경 후**:
```dart
class StockerApp extends ConsumerWidget {  // ✅ StatelessWidget → ConsumerWidget
  const StockerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {  // ✅ WidgetRef 추가
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      builder: (context, child) {
        final currentThemeMode = ref.watch(themeModeProvider);

        return MaterialApp.router(
          routerConfig: AppRouter.createRouter(ref),  // ✅ ref 전달
          // ...
        );
      },
    );
  }
}
```

**핵심 변경사항**:
- `StatelessWidget` → `ConsumerWidget`으로 변경
- `AppRouter.router` → `AppRouter.createRouter(ref)`로 변경
- WidgetRef를 통해 인증 상태 접근 가능

---

### Phase 4: 로그인 후 원래 페이지로 복귀 🔄

**목표**: 로그인 성공 시 원래 가려던 페이지로 자동 이동

#### 4.1 login_screen.dart 수정

**파일**: `lib/features/auth/presentation/login_screen.dart`

**현재 코드 (login_screen.dart:34-41)**:
```dart
if (isSuccess) {
  debugPrint('✅ [LOGIN] 로그인 성공 - 홈으로 이동');

  final currentState = ref.read(authNotifierProvider).value;

  // 로그인 성공 시 홈으로 이동 (교육 페이지 대신 홈으로)
  context.go(AppRoutes.home);  // ❌ 항상 홈으로
```

**수정 후**:
```dart
if (isSuccess) {
  debugPrint('✅ [LOGIN] 로그인 성공');

  final currentState = ref.read(authNotifierProvider).value;

  // ✅ 쿼리 파라미터에서 원래 경로 가져오기
  final redirectPath = Uri.parse(
    GoRouterState.of(context).uri.toString()
  ).queryParameters['redirect'];

  // ✅ 원래 가려던 페이지로 이동 (없으면 기본 홈)
  final destination = redirectPath ?? AppRoutes.education;

  debugPrint('📍 [LOGIN] Redirecting to: $destination');
  context.go(destination);

  // 성공 메시지 표시
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('${currentState?.user?.nickname ?? "사용자"}님 환영합니다! 🎉'),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
    ),
  );
}
```

**핵심 기능**:
- 로그인 전 가려던 페이지 경로를 쿼리 파라미터에서 복원
- 로그인 성공 시 원래 경로로 자동 이동
- 경로가 없으면 기본 홈(`/education`)으로 이동

---

## 🎨 사용자 경험 플로우

### 시나리오 1: 로그인하지 않고 보호된 페이지 접근
```
1. 사용자: 앱 실행
   → GoRouter: initialLocation = '/education'
   → AuthGuard: 로그인 체크 → 로그인 안 됨!
   → Redirect: '/login?redirect=/education'

2. 사용자: 로그인 화면 표시됨
   → 이메일/비밀번호 입력

3. 사용자: 로그인 버튼 클릭
   → AuthNotifier: login() 성공
   → LoginScreen: redirect 파라미터 확인 → '/education'
   → context.go('/education')

4. 사용자: 원래 가려던 교육 페이지 표시됨 ✅
```

### 시나리오 2: 로그인 상태에서 로그인 페이지 접근
```
1. 사용자: 이미 로그인된 상태
   → URL에 '/login' 입력

2. GoRouter: '/login' 라우팅 시도
   → AuthGuard: 로그인 체크 → 이미 로그인됨!
   → Redirect: '/education' (홈으로)

3. 사용자: 자동으로 홈 화면 표시됨 ✅
```

### 시나리오 3: 공개 페이지 접근
```
1. 사용자: 회원가입 버튼 클릭
   → GoRouter: '/register' 라우팅

2. AuthGuard: 공개 페이지 체크 → publicRoutes에 포함됨
   → Redirect: null (접근 허용)

3. 사용자: 회원가입 화면 표시됨 ✅
```

---

## 🔧 구현 체크리스트

### Phase 1: AuthGuard 구현 ✅
- [ ] `lib/app/config/auth_guard.dart` 파일 생성
- [ ] `AuthGuard.redirect()` 메서드 구현
- [ ] `publicRoutes` 상수 정의
- [ ] `GoRouterRefreshStream` 헬퍼 클래스 추가
- [ ] 로그 메시지 추가 (디버깅용)

### Phase 2: GoRouter 통합 ✅
- [ ] `app_router.dart`에 `auth_guard.dart` import
- [ ] `AppRouter` 클래스를 정적 → 인스턴스 메서드로 변경
- [ ] `createRouter(WidgetRef ref)` 메서드 추가
- [ ] `redirect` 콜백 추가
- [ ] `refreshListenable` 추가

### Phase 3: main.dart 수정 ✅
- [ ] `StockerApp`을 `ConsumerWidget`으로 변경
- [ ] `build()` 메서드에 `WidgetRef ref` 파라미터 추가
- [ ] `AppRouter.router` → `AppRouter.createRouter(ref)` 변경

### Phase 4: 로그인 후 복귀 구현 ✅
- [ ] `login_screen.dart`에서 `redirect` 파라미터 추출
- [ ] 로그인 성공 시 원래 경로로 이동하도록 수정
- [ ] 로그 메시지 추가

### Phase 5: 테스트 ✅
- [ ] 로그아웃 상태에서 `/education` 접근 → 로그인 화면으로 리다이렉트
- [ ] 로그인 후 원래 페이지(`/education`)로 복귀 확인
- [ ] 로그인 상태에서 `/login` 접근 → 홈으로 리다이렉트
- [ ] `/register` 페이지는 로그인 없이 접근 가능한지 확인
- [ ] 딥링크 테스트: `/quiz?chapterId=1` 접근 시 로그인 후 복귀

---

## ⚠️ 주의사항

### 1. 초기화 상태 처리
```dart
// ❌ 나쁜 예: 초기화 중 리다이렉트
if (!isLoggedIn) {
  return AppRoutes.login;
}

// ✅ 좋은 예: 초기화 완료 후 리다이렉트
if (authState.value?.isInitializing == true) {
  return null; // 초기화 중에는 리다이렉트하지 않음
}

if (!isLoggedIn && !isPublicRoute) {
  return AppRoutes.login;
}
```

### 2. 무한 리다이렉트 방지
```dart
// ✅ 공개 페이지 체크로 무한 루프 방지
final isPublicRoute = publicRoutes.contains(currentPath);

if (!isLoggedIn && !isPublicRoute) {
  return AppRoutes.login; // 로그인 페이지는 공개이므로 무한 루프 없음
}
```

### 3. 로그인 후 딥링크 유지
```dart
// ✅ 쿼리 파라미터를 URL에 인코딩하여 보존
return '${AppRoutes.login}?redirect=${Uri.encodeComponent(currentPath)}';

// ❌ 나쁜 예: 쿼리 파라미터 손실
return '${AppRoutes.login}?redirect=$currentPath'; // '?'가 중복될 수 있음
```

---

## 🚀 기대 효과

### 보안 향상
- ✅ 로그인하지 않은 사용자의 보호된 리소스 접근 차단
- ✅ 인증 상태 중앙 집중 관리
- ✅ 토큰 만료 시 자동 로그인 화면 이동

### 사용자 경험 개선
- ✅ 로그인 후 원래 가려던 페이지로 자동 복귀
- ✅ 로그인 상태에서 로그인 페이지 접근 시 자동 홈 이동
- ✅ 깜빡임 없는 부드러운 리다이렉트

### 개발자 경험 개선
- ✅ 각 페이지에서 인증 체크 불필요 (중앙 집중식)
- ✅ 공개/보호 페이지 관리 용이
- ✅ 디버깅 로그로 라우팅 플로우 추적 가능

---

## 📊 파일 변경 요약

| 파일 | 변경 유형 | 설명 |
|-----|---------|------|
| `lib/app/config/auth_guard.dart` | ✨ 신규 | AuthGuard 및 GoRouterRefreshStream 구현 |
| `lib/app/config/app_router.dart` | 🔧 수정 | redirect, refreshListenable 추가 |
| `lib/main.dart` | 🔧 수정 | ConsumerWidget으로 변경, ref 전달 |
| `lib/features/auth/presentation/login_screen.dart` | 🔧 수정 | redirect 파라미터 처리 |

---

## 🧪 테스트 시나리오

### 테스트 1: 로그아웃 상태 리다이렉트
```bash
1. 앱 실행 (로그아웃 상태)
2. 기대: 자동으로 로그인 화면 표시
3. URL 확인: /login?redirect=/education
```

### 테스트 2: 로그인 후 원래 페이지 복귀
```bash
1. 로그아웃 상태에서 /quiz?chapterId=1 접근 시도
2. 로그인 화면으로 리다이렉트됨
3. 로그인 성공
4. 기대: 자동으로 /quiz?chapterId=1로 이동
```

### 테스트 3: 로그인 상태 홈 리다이렉트
```bash
1. 로그인 상태
2. /login 또는 /register 접근 시도
3. 기대: 자동으로 /education (홈)으로 리다이렉트
```

### 테스트 4: 공개 페이지 접근
```bash
1. 로그아웃 상태
2. /register 접근
3. 기대: 회원가입 화면 정상 표시
```

---

## 📞 문의

인증 가드 라우팅 시스템 관련 문의는 개발팀에게 연락해주세요.

**문서 작성**: 2025-11-21
**버전**: 1.0.0
**다음 단계**: Phase 1부터 순차적으로 구현 시작
