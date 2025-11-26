# Stocker 아키텍처 문서

> Clean Architecture + Feature-Based Modular 구조를 적용한 Flutter 앱 아키텍처

---

## 1. 전체 아키텍처 개요

### 1.1 설계 원칙
- **Clean Architecture**: 관심사 분리 (Separation of Concerns)
- **Feature-Based**: 기능별 모듈화로 확장성 확보
- **Repository Pattern**: 데이터 소스 추상화
- **의존성 역전**: 상위 레이어가 하위 레이어에 의존하지 않음

### 1.2 레이어 구조
```
┌─────────────────────────────────────────────────────┐
│                  Presentation Layer                  │
│        (Screens, Widgets, State Management)          │
├─────────────────────────────────────────────────────┤
│                    Domain Layer                      │
│          (Repository Interfaces, Models)             │
├─────────────────────────────────────────────────────┤
│                     Data Layer                       │
│      (API, DTO, Repository Implementations)          │
└─────────────────────────────────────────────────────┘
```

---

## 2. 디렉토리 구조

### 2.1 최상위 구조
```
lib/
├── main.dart                    # 앱 진입점, ProviderScope 설정
├── app/                         # 앱 레벨 설정 (전역)
│   ├── config/                  # 라우팅, 테마, 상수
│   └── core/                    # 공통 모듈
└── features/                    # 기능별 모듈
```

### 2.2 App 모듈 상세
```
app/
├── config/
│   ├── app_router.dart          # GoRouter 설정
│   ├── app_routes.dart          # 라우트 경로 상수
│   ├── app_theme.dart           # 테마 정의 (Light/Dark)
│   └── auth_guard.dart          # 인증 가드
└── core/
    ├── network/
    │   └── dio.dart             # Dio 인스턴스 설정
    ├── providers/
    │   └── riverpod/            # 전역 Provider
    ├── services/
    │   ├── api_client.dart      # API 클라이언트
    │   └── token_storage.dart   # 토큰 저장소
    └── widgets/                 # 공통 위젯
        ├── action_button.dart
        ├── app_card.dart
        ├── error_page.dart
        └── loading_widget.dart
```

### 2.3 Feature 모듈 상세
```
features/
├── auth/                        # 인증 (로그인, 회원가입)
├── education/                   # 교육 (챕터, 이론)
├── attendance/                  # 출석 (캘린더, 퀴즈)
├── quiz/                        # 퀴즈 시스템
├── wrong_note/                  # 오답노트
├── aptitude/                    # 투자 성향 분석
├── note/                        # 노트 기능
├── memo/                        # 메모 기능
├── learning/                    # 학습 진도
├── mypage/                      # 마이페이지
└── home/                        # 홈 & 네비게이션
```

### 2.4 Feature 내부 구조 (3-Layer)
```
feature_name/
├── data/                        # 데이터 레이어
│   ├── dto/                     # Request/Response DTO
│   ├── source/                  # API 클래스
│   └── repository/              # Repository 구현체
├── domain/                      # 도메인 레이어
│   ├── model/                   # 비즈니스 모델
│   └── repository/              # Repository 인터페이스
└── presentation/                # 프레젠테이션 레이어
    ├── screens/                 # 화면 위젯
    ├── widgets/                 # Feature 전용 위젯
    └── riverpod/                # 상태 관리 (Notifier, State)
```

---

## 3. 상태 관리 (Riverpod)

### 3.1 상태 관리 계층
```
┌────────────────────────────────────────┐
│              UI (Widget)                │
│     Consumer, ref.watch, ref.read       │
├────────────────────────────────────────┤
│         StateNotifier / Notifier        │
│           비즈니스 로직 처리             │
├────────────────────────────────────────┤
│             Repository                  │
│          데이터 소스 추상화              │
├────────────────────────────────────────┤
│            API / Storage                │
│          실제 데이터 접근                │
└────────────────────────────────────────┘
```

### 3.2 Provider 패턴 예시
```dart
// 1. State 정의 (freezed 사용)
@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    User? user,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _AuthState;
}

// 2. Notifier 정의
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() => const AuthState();

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await ref.read(authRepositoryProvider).login(email, password);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }
}

// 3. UI에서 사용
Consumer(
  builder: (context, ref, child) {
    final authState = ref.watch(authNotifierProvider);
    if (authState.isLoading) return LoadingWidget();
    return Text(authState.user?.name ?? '로그인 필요');
  },
)
```

### 3.3 전역 Provider 구조
```dart
// main.dart
void main() async {
  runApp(
    ProviderScope(
      child: const StockerApp(),
    ),
  );
}

// 전역 Provider 정의
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(...);
final dioProvider = Provider<Dio>((ref) => setupDio());
final authRepositoryProvider = Provider<AuthRepository>((ref) => ...);
```

---

## 4. 라우팅 (GoRouter)

### 4.1 라우팅 구조
```
                    ┌─────────────────┐
                    │      /login     │
                    │    /register    │
                    └────────┬────────┘
                             │
              ┌──────────────┴──────────────┐
              │        ShellRoute           │
              │    (BottomNavigationBar)    │
              └──────────────┬──────────────┘
                             │
         ┌───────────────────┼───────────────────┐
         │                   │                   │
    /education          /attendance          /mypage
         │                   │                   │
    /theory?id          (Calendar)          /aptitude
    /quiz?id                                 /notes
    /quiz-result
```

### 4.2 라우트 상수 관리
```dart
// app_routes.dart
class AppRoutes {
  // 메인 탭
  static const education = '/education';
  static const attendance = '/attendance';
  static const wrongNote = '/wrong-note';
  static const mypage = '/mypage';

  // 인증
  static const login = '/login';
  static const register = '/register';

  // 서브 화면
  static const theory = '/theory';
  static const quiz = '/quiz';
  static const quizResult = '/quiz-result';
  static const aptitude = '/aptitude';
  static const aptitudeQuiz = '/aptitude/quiz';
  static const aptitudeResult = '/aptitude/result';
  static const noteList = '/notes';
  static const noteEditor = '/notes/editor';
}
```

### 4.3 인증 가드 (AuthGuard)
```dart
// auth_guard.dart
class AuthGuard {
  static String? redirect(BuildContext context, GoRouterState state, WidgetRef ref) {
    final isLoggedIn = ref.read(authNotifierProvider).isLoggedIn;
    final isAuthRoute = state.matchedLocation == AppRoutes.login ||
                        state.matchedLocation == AppRoutes.register;

    if (!isLoggedIn && !isAuthRoute) {
      return AppRoutes.login;  // 비로그인 → 로그인 페이지
    }
    if (isLoggedIn && isAuthRoute) {
      return AppRoutes.education;  // 로그인됨 → 메인 화면
    }
    return null;  // 정상 진행
  }
}
```

---

## 5. 네트워크 (Dio)

### 5.1 Dio 설정
```dart
// dio.dart
Future<void> setupDio() async {
  final dio = Dio(BaseOptions(
    baseUrl: dotenv.env['API_BASE_URL'] ?? '',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  // 인터셉터 추가
  dio.interceptors.add(AuthInterceptor());
  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
}
```

### 5.2 인증 인터셉터
```dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await TokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // 토큰 갱신 로직
      final refreshed = await _refreshToken();
      if (refreshed) {
        return handler.resolve(await _retry(err.requestOptions));
      }
    }
    handler.next(err);
  }
}
```

---

## 6. Repository 패턴

### 6.1 Repository 인터페이스 (Domain)
```dart
// domain/repository/auth_repository.dart
abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> register(String name, String email, String password);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<User?> getCurrentUser();
}
```

### 6.2 API Repository 구현체 (Data)
```dart
// data/repository/auth_api_repository.dart
class AuthApiRepository implements AuthRepository {
  final AuthApi _api;

  AuthApiRepository(this._api);

  @override
  Future<User> login(String email, String password) async {
    final response = await _api.login(LoginRequest(email: email, password: password));
    await TokenStorage.saveTokens(response.accessToken, response.refreshToken);
    return User.fromDto(response.user);
  }
}
```

### 6.3 Mock Repository 구현체 (Data)
```dart
// data/repository/auth_mock_repository.dart
class AuthMockRepository implements AuthRepository {
  @override
  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return User(
      id: 1,
      name: '테스트 사용자',
      email: email,
    );
  }
}
```

### 6.4 Mock/Real 전환
```dart
// main.dart
const useMock = String.fromEnvironment('USE_MOCK', defaultValue: 'false') == 'true';

// provider 정의
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (useMock) {
    return AuthMockRepository();
  }
  return AuthApiRepository(ref.read(authApiProvider));
});
```

---

## 7. 데이터 모델

### 7.1 DTO (Data Transfer Object)
```dart
// data/dto/login_request.dart
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}
```

### 7.2 Domain Model
```dart
// domain/model/user.dart
class User {
  final int id;
  final String name;
  final String email;
  final String? profileImage;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
  });

  factory User.fromDto(UserDto dto) => User(
    id: dto.id,
    name: dto.name,
    email: dto.email,
    profileImage: dto.profileImage,
  );
}
```

---

## 8. 테마 시스템

### 8.1 테마 정의
```dart
// app_theme.dart
class AppTheme {
  // Light Theme
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Colors.blue,
      secondary: Colors.blueAccent,
      surface: Colors.white,
    ),
    // ...
  );

  // Dark Theme
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: Colors.blue,
      secondary: Colors.blueAccent,
      surface: const Color(0xFF1E1E1E),
    ),
    // ...
  );
}
```

### 8.2 테마 전환
```dart
// 테마 Provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);

  void setThemeMode(ThemeMode mode) {
    state = mode;
    // SharedPreferences에 저장
  }
}

// 사용
ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
```

---

## 9. 보안

### 9.1 토큰 저장
```dart
// Flutter Secure Storage 사용
class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }
}
```

### 9.2 환경 변수 관리
```
# .env
API_BASE_URL=https://api.stocker.app
```

```dart
// 사용
final baseUrl = dotenv.env['API_BASE_URL'];
```

---

## 10. 의존성 그래프

```
┌──────────────────────────────────────────────────────────────┐
│                        main.dart                              │
│                     ProviderScope                             │
└──────────────────────────┬───────────────────────────────────┘
                           │
              ┌────────────┴────────────┐
              │                         │
      ┌───────┴───────┐         ┌───────┴───────┐
      │   App Config  │         │    Features   │
      │  (Router,     │         │  (auth, edu,  │
      │   Theme)      │         │   quiz, ...)  │
      └───────────────┘         └───────┬───────┘
                                        │
                         ┌──────────────┼──────────────┐
                         │              │              │
                  ┌──────┴──────┐ ┌─────┴─────┐ ┌──────┴──────┐
                  │ Presentation│ │  Domain   │ │    Data     │
                  │  (Screen,   │ │ (Model,   │ │ (API, DTO,  │
                  │   State)    │ │  Repo IF) │ │  Repo Impl) │
                  └─────────────┘ └───────────┘ └─────────────┘
                                        ↑              │
                                        └──────────────┘
                                        implements
```

---

## 11. 빌드 및 배포

### 11.1 개발 환경
```bash
# Mock 모드로 실행
flutter run --dart-define=USE_MOCK=true

# 실제 API 모드로 실행
flutter run --dart-define=USE_MOCK=false
```

### 11.2 빌드 명령어
```bash
# Android APK
flutter build apk --release --dart-define=USE_MOCK=false

# Android App Bundle
flutter build appbundle --release --dart-define=USE_MOCK=false

# iOS
flutter build ios --release --dart-define=USE_MOCK=false
```

---

## 12. 참고 자료

- [Flutter 공식 문서](https://docs.flutter.dev/)
- [Riverpod 공식 문서](https://riverpod.dev/)
- [GoRouter 공식 문서](https://pub.dev/packages/go_router)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
