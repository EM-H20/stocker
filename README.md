📘 Stocker 프론트엔드 공동 개발 가이드 (Flutter)

Flutter + Spring Boot 기반 앱 프로젝트인 **Stocker**의 프론트엔드 개발을 위한 공동 작업 가이드입니다. 프로젝트 구조, 상태관리, API 연동, 패키지 사용 방식 등을 일관성 있게 정리하여 원활한 협업과 유지보수를 목표로 합니다.

---

## 🔧 1. 프로젝트 개요

- **앱명**: Stocker
- **역할**: 사용자 교육/출석/퀴즈/성향분석/노트/인증 기능을 제공하는 종합 학습 관리 앱
- **기술스택**:
    - Flutter SDK: ^3.4.0
    - 상태관리: provider ^6.1.5
    - 라우팅: go_router ^16.0.0
    - API 통신: dio ^5.8.0+1
    - 보안 저장소: flutter_secure_storage ^9.2.4
    - 환경설정: flutter_dotenv ^6.0.0
    - UI: flutter_screenutil ^5.9.3, table_calendar ^3.1.3, fl_chart ^1.0.0, percent_indicator ^4.2.5
    - 리치 에디터: flutter_quill ^11.4.2
    - 로깅: logger ^2.6.1
    - 기타: flutter_spinkit, haptic_feedback, shared_preferences 등
- **백엔드**: Spring Boot REST API (JWT 기반 인증)

---

## 📁 2. 폴더 구조 (현재 실제 구조)

현재 프로젝트는 Clean Architecture 기반의 feature별 모듈화 구조로 구성되어 있습니다.

```
lib/
├── main.dart                          # 앱 진입점 + MultiProvider 전역 주입
├── app/                              
│   ├── config/                        # 앱 레벨 설정
│   │   ├── app_router.dart           # GoRouter 라우팅 설정
│   │   ├── app_routes.dart           # 라우트 경로 상수
│   │   └── app_theme.dart            # 다크/라이트 테마 정의
│   └── core/                         # 공통 기능
│       ├── network/
│       │   └── dio.dart              # Dio 인스턴스 설정
│       ├── providers/
│       │   └── theme_provider.dart   # 테마 상태 관리
│       ├── services/                 # 공통 서비스
│       │   ├── api_client.dart
│       │   ├── dio_interceptor.dart
│       │   └── token_storage*.dart
│       └── widgets/                  # 공통 위젯
│           ├── action_button.dart
│           └── error_page.dart
├── features/                         # 기능별 모듈
│   ├── home/                         # 홈 및 네비게이션
│   │   └── presentation/
│   │       ├── home_shell.dart       # BottomNavigationBar 구현
│   │       ├── tap_item.dart         # 탭 enum (4개 탭)
│   │       ├── main_dashboard_screen.dart # 메인 대시보드
│   │       └── widgets/              # 홈 관련 위젯들
│   ├── auth/                         # 인증 시스템
│   │   ├── data/
│   │   │   ├── dto/                  # API 요청/응답 DTO
│   │   │   ├── repository/           # Repository 구현체
│   │   │   └── source/               # API 소스
│   │   ├── domain/
│   │   │   ├── model/                # 비즈니스 모델
│   │   │   └── auth_repository.dart  # Repository 인터페이스
│   │   └── presentation/             # UI 및 Provider
│   ├── education/                    # 교육 기능
│   │   ├── data/, domain/, presentation/
│   │   └── (이론, 챕터 관련 기능)
│   ├── attendance/                   # 출석 기능
│   │   ├── data/, domain/, presentation/
│   │   └── (캘린더, 퀴즈 다이얼로그)
│   ├── aptitude/                     # 성향 분석 (신규)
│   │   ├── data/, domain/, presentation/
│   │   └── (퀴즈, 결과 차트, 타입별 분석)
│   ├── note/                         # 노트 기능 (신규)
│   │   ├── data/, domain/, presentation/
│   │   └── (flutter_quill 기반 리치 에디터)
│   ├── quiz/                         # 퀴즈 시스템
│   │   ├── data/, domain/, presentation/
│   │   └── (O/X 퀴즈, 결과 분석)
│   ├── wrong_note/                   # 오답노트
│   │   ├── data/, domain/, presentation/
│   │   └── (오답 분석, 통계)
│   └── mypage/                       # 마이페이지
│       └── presentation/
│           ├── mypage_screen.dart
│           └── widgets/              # 프로필, 통계 카드들
```

❗ BottomNavigationBar 관련 코드는 features/home/presentation/home_shell.dart에서만 정의합니다.

각 탭별 페이지(e.g. 출석, 챕터 등)는 자신이 보여줄 화면 UI만 구현하고, BottomNavigationBar를 다시 만들지 않습니다. 모든 탭 전환은 `home_shell.dart` 내에서 일관되게 처리합니다.

### 🧭 GoRouter 사용 원칙 및 네비게이션 구조

#### ✅ 라우팅 구조
- **중앙 집중식 라우팅**: `app/config/app_router.dart`에서 모든 라우트 관리
- **4개 탭 + 홈 복귀**: ShellRoute로 4개 메인 탭 구현, 별도 `/main` 경로로 홈 접근
- **경로 상수 관리**: `app_routes.dart`에서 문자열 경로 통합 관리
- **페이지 이동**: 반드시 `context.go(AppRoutes.xxx)` 사용

#### ✅ 탭 네비게이션 구조 (4개)
```dart
// TabItem enum 정의 (tap_item.dart)
enum TabItem { education, attendance, wrongNote, mypage }

// 실제 탭 구성
1. 교육     (Icons.school)          → AppRoutes.education
2. 출석     (Icons.calendar_today)  → AppRoutes.attendance  
3. 오답노트 (Icons.note_alt)        → AppRoutes.wrongNote
4. 마이페이지 (Icons.person)        → AppRoutes.mypage
```

#### ✅ 홈 복귀 방식
- **메인 대시보드**: `/main` 경로로 독립 화면 (ShellRoute 외부)
- **홈 복귀 버튼**: 마이페이지 상단에 홈 버튼 배치
- **사용법**: `IconButton(onPressed: () => context.go(AppRoutes.main))`

#### ❌ 주의사항
- 각 feature에서 직접 Navigator 사용 금지
- BottomNavigationBar는 `home_shell.dart`에서만 구현
- 탭 관련 상태는 `HomeNavigationProvider` 사용

그 외에 라우팅 설정은 아래와 같이 구성됩니다
 
```yaml
lib/
 └── app/
     └── config/
         ├── app_router.dart        ✅ 전체 라우팅 설정 (go_router 또는 Navigator)
         └── app_routes.dart        ✅ 문자열 경로 상수 정의 
 ```


각 feature 폴더 내부는 다음과 같이 구성합니다:

```
features/도메인명/
├── data/              # API 통신, 모델 정의
├── domain/            # Repository, 유즈케이스 등
└── presentation/      # UI 및 상태관리 Provider

```

---

## 🧩 3. 계층별 역할 정리

### ✅ Model (data/*.dart)

- 서버 JSON 데이터를 Dart 객체로 변환 및 역변환
- 예: `LoginRequest`, `ChapterResponse`

### ✅ API (data/*.api.dart)

- Dio 기반 HTTP 통신 수행
- 예: `AuthApi.login()`, `ChapterApi.fetchChapters()`

### ✅ Repository (domain/)

- API + 로컬 저장소 통합
- ViewModel이 사용할 유일한 인터페이스

### ✅ Presentation (presentation/)

- 화면 UI 및 사용자 상호작용 처리
- 상태관리 Provider는 여기 포함 (ChangeNotifier)

---

## 🧠 4. 상태관리 전략 (Provider + Repository 패턴)

### ✅ 아키텍처 개요

현재 프로젝트는 **Repository 패턴 + Provider 상태관리**를 사용합니다:
- **Repository 계층**: API 통신 및 데이터 소스 추상화
- **Provider 계층**: UI 상태 관리 및 비즈니스 로직
- **Mock/Real 분기**: 개발 단계에서 Mock 데이터 사용 가능
- **전역 주입**: main.dart에서 모든 Provider 주입

### ✅ 현재 구현된 Provider 구조

```dart
// main.dart - 실제 Provider 주입 구조
MultiProvider(
  providers: [
    // === Repository 계층 ===
    Provider<AuthRepository>(
      create: (_) => useMock ? AuthMockRepository() : AuthApiRepository(AuthApi(dio)),
    ),
    Provider<AttendanceRepository>(
      create: (_) => useMock ? AttendanceMockRepository() : AttendanceApiRepository(AttendanceApi(dio)),
    ),
    Provider<AptitudeRepository>(
      create: (_) => useMock ? AptitudeMockRepository() : AptitudeApiRepository(AptitudeApi(dio)),
    ),
    Provider<NoteRepository>(
      create: (_) => useMock ? NoteMockRepository() : NoteApiRepository(NoteApi(dio)),
    ),

    // === Provider 계층 ===
    ChangeNotifierProvider(create: (_) => ThemeProvider()..initialize()),
    ChangeNotifierProvider(create: (_) => HomeNavigationProvider()),
    
    // Repository 의존성 주입
    ChangeNotifierProvider(
      create: (context) => AuthProvider(context.read<AuthRepository>()),
    ),
    ChangeNotifierProvider(
      create: (context) => AptitudeProvider(context.read<AptitudeRepository>()),
    ),
    ChangeNotifierProvider(
      create: (context) => NoteProvider(context.read<NoteRepository>()),
    ),
    
    // ProxyProvider로 다른 Provider 의존성 처리
    ChangeNotifierProxyProvider<AuthProvider, AttendanceProvider>(
      create: (context) => AttendanceProvider(
        context.read<AttendanceRepository>(),
        context.read<AuthProvider>(),
      ),
      update: (context, auth, _) => AttendanceProvider(context.read<AttendanceRepository>(), auth),
    ),

    // Legacy Provider (기존 방식 - 점진적 마이그레이션 중)
    ChangeNotifierProvider(create: (_) => EducationProvider.withMock(...)),
    ChangeNotifierProvider(create: (_) => QuizProvider.withMock(...)),
    ChangeNotifierProvider(create: (_) => WrongNoteProvider.withMock(...)),
  ],
  child: MaterialApp.router(...),
)
```

### ✅ Repository 패턴 구현 방식

각 feature는 다음과 같은 Repository 패턴을 따릅니다:

```dart
// 1. Repository 인터페이스 정의 (domain/)
abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<void> logout();
  Future<bool> isLoggedIn();
}

// 2. Mock Repository 구현체 (data/repository/)
class AuthMockRepository implements AuthRepository {
  @override
  Future<User> login(String email, String password) async {
    // 더미 데이터 반환
    return User(id: 1, name: '테스트 사용자', email: email);
  }
}

// 3. Real API Repository 구현체 (data/repository/)
class AuthApiRepository implements AuthRepository {
  final AuthApi _authApi;
  
  AuthApiRepository(this._authApi);
  
  @override
  Future<User> login(String email, String password) async {
    final response = await _authApi.login(LoginRequest(email, password));
    return User.fromDto(response.data);
  }
}

// 4. Provider에서 Repository 사용
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  
  AuthProvider(this._repository);
  
  Future<void> login(String email, String password) async {
    try {
      _user = await _repository.login(email, password);
      notifyListeners();
    } catch (e) {
      // 에러 처리
    }
  }
}
```

### ✅ Mock/Real API 전환

`main.dart`의 `useMock` 상수로 전역 제어:

```dart
const useMock = true; // 개발용 Mock 데이터 사용
// const useMock = false; // 실제 API 사용

// Provider 주입 시 자동 분기
Provider<AuthRepository>(
  create: (_) => useMock 
    ? AuthMockRepository() 
    : AuthApiRepository(AuthApi(dio)),
),
```

### ✅ View에서 사용법

```dart
// Consumer로 상태 구독
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    if (authProvider.isLoading) return CircularProgressIndicator();
    return Text(authProvider.user?.name ?? '로그인 필요');
  },
)

// Selector로 특정 값만 구독 (성능 최적화)  
Selector<AuthProvider, bool>(
  selector: (context, provider) => provider.isLoggedIn,
  builder: (context, isLoggedIn, child) {
    return isLoggedIn ? MainDashboardScreen() : LoginScreen();
  },
)

// 메서드 호출 (listen: false)
context.read<AuthProvider>().login(email, password);
```

### ⚠️ 주의사항

- **Repository 의존성**: Provider는 반드시 Repository를 통해서만 데이터 접근
- **전역 주입**: Repository와 Provider 모두 main.dart에서 주입
- **Mock 우선 개발**: UI 개발 시 Mock 사용, 통합 테스트 시 Real API 전환
- **에러 처리 통일**: Repository에서 API 예외를 비즈니스 예외로 변환

---

## 🌐 5. API 연동 방식 (Dio 기반 네트워킹)

### ✅ Dio 설정 및 네트워크 구조

전역 Dio 인스턴스는 `app/core/network/dio.dart`에서 설정합니다:

.env 예시:

```
API_BASE_URL=https://api.stocker.app

```

Dio 설정:

```dart
final dio = Dio(BaseOptions(baseUrl: dotenv.env['API_BASE_URL']));

```

각 feature는 자체 `*.api.dart` 파일을 통해 API를 래핑합니다.

---

## 🎨 6. UI 구현 원칙

- 모든 크기 값은 `flutter_screenutil` 사용 (반응형 대응)
- 공통 위젯은 `core/widgets/`에 저장 (ex. `LoadingSpinner`, `CustomButton`)
- 페이지 구조는 다음 기본 템플릿을 따릅니다:

```dart
Scaffold(
  appBar: AppBar(title: Text("페이지 제목")),
  body: SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(...),
    ),
  ),
)

```

---

## 📦 7. 패키지 사용 가이드 (현재 구현된 패키지들)

| 기능 | 패키지 | 사용 위치 예시 |
| --- | --- | --- |
| API 통신 | dio | `api_client.dart`, `*.api.dart` |
| 상태 저장 | flutter_secure_storage | 로그인 토큰 저장 |
| 로컬 캐시 | shared_preferences | 유저 설정 |
| 달력 | table_calendar | 출석 기능 UI |
| 진행률 표시 | percent_indicator | 퀴즈 진척도 표시 |
| 리치 에디터 | flutter_quill | 메모 작성 |
| 통계 그래프 | fl_chart | 성향 분석 결과 |
| 로딩 | flutter_spinkit | 공통 스피너 |

---

## ✅ 개발 시 원칙 정리 (현재 프로젝트 기준)

### 📝 코딩 컨벤션
| 항목 | 규칙 | 예시 |
| --- | --- | --- |
| 변수명 | camelCase | `userName`, `isLoggedIn` |
| 클래스명 | PascalCase | `AuthProvider`, `UserRepository` |
| 파일명 | snake_case.dart | `auth_provider.dart`, `main_dashboard_screen.dart` |
| 상수명 | UPPER_SNAKE_CASE | `API_BASE_URL`, `DEFAULT_TIMEOUT` |

### 🏗️ 아키텍처 원칙
| 항목 | 규칙 | 이유 |
| --- | --- | --- |
| API 접근 | 반드시 Repository 패턴 사용 | 데이터 소스 추상화, 테스트 용이성 |
| 상태 관리 | Provider만 사용, 전역 주입 | 일관성, 의존성 관리 |
| 라우팅 | GoRouter + 중앙 집중식 | 타입 안전성, 유지보수성 |
| Mock 우선 | 개발 시 Mock 데이터 사용 | 빠른 UI 개발, 백엔드 독립성 |

### 🎨 UI 구현 원칙
| 항목 | 규칙 | 도구 |
| --- | --- | --- |
| 반응형 디자인 | 모든 크기값 `.w`, `.h`, `.sp` 사용 | `flutter_screenutil` |
| 네비게이션 | BottomNavigationBar는 home_shell.dart만 | 중복 방지, 일관성 |
| 테마 지원 | 다크/라이트 모드 대응 | `ThemeProvider` |
| 에러 처리 | 사용자 친화적 에러 메시지 | Repository에서 변환 |

### 🔄 워크플로우 원칙
| 항목 | 규칙 | 도구/방법 |
| --- | --- | --- |
| 커밋 메시지 | Conventional Commits | `feat:`, `fix:`, `refactor:` 등 |
| Mock/Real 전환 | `useMock` 상수로 제어 | main.dart에서 전역 설정 |
| 기능 개발 순서 | Mock → UI → Real API | 점진적 통합 |
| 테스트 | Provider 단위 테스트 우선 | Mock Repository 활용 |

---

## 🚀 배포 및 개발 명령어

### ✅ 개발 환경 설정

```bash
# 의존성 설치
flutter pub get

# 코드 생성 (build_runner 사용 시)
flutter pub run build_runner build

# 정적 분석
flutter analyze

# 테스트 실행
flutter test
```

### ✅ 앱 설정 변경

```bash
# 앱 아이콘 업데이트
flutter pub run flutter_launcher_icons:main

# 패키지명 변경 (배포 전 필수)
flutter pub run change_app_package_name:main com.팀명.stocker

# 앱 이름 변경은 android/app/src/main/AndroidManifest.xml에서 수동 변경
```

### ✅ 빌드 및 배포

```bash
# 디버그 빌드 (개발용)
flutter run

# 릴리즈 APK 빌드 (Android)
flutter build apk --release

# 릴리즈 AAB 빌드 (Google Play Store용)  
flutter build appbundle --release

# iOS 릴리즈 빌드
flutter build ios --release

# 웹 빌드 (필요시)
flutter build web
```

### ⚠️ 배포 전 체크리스트

- [ ] `useMock = false`로 설정하여 실제 API 사용
- [ ] API Base URL이 프로덕션 서버로 설정됨
- [ ] 패키지명이 고유한 이름으로 변경됨
- [ ] 앱 아이콘이 올바르게 설정됨
- [ ] 모든 테스트가 통과함
- [ ] 정적 분석 경고가 해결됨

## 🆕 새로운 기능 사용 가이드

### 🧠 성향분석 (Aptitude) 기능
```dart
// Provider 사용법
context.read<AptitudeProvider>().startQuiz(); // 퀴즈 시작
context.read<AptitudeProvider>().submitAnswer(questionId, answer); // 답변 제출
context.read<AptitudeProvider>().getResult(); // 결과 조회

// fl_chart를 활용한 포트폴리오 분석 차트 구현
// features/aptitude/presentation/widgets/master_portfolio_chart.dart 참고
```

### 📝 노트 (Note) 기능  
```dart
// flutter_quill 리치 에디터 사용
QuillEditor.basic(
  controller: _controller,
  readOnly: false,
);

// 템플릿 기반 노트 생성
context.read<NoteProvider>().createNoteFromTemplate(template);
```

### 🏠 메인 대시보드 네비게이션
```dart
// 마이페이지에서 홈으로 복귀
IconButton(
  onPressed: () => context.go(AppRoutes.main),
  icon: Icon(Icons.home),
  tooltip: '홈으로',
)

// 4개 탭 네비게이션 (home_shell.dart에서 자동 처리)
// 교육 → 출석 → 오답노트 → 마이페이지
```

### 🔐 인증 시스템
```dart
// 로그인
context.read<AuthProvider>().login(email, password);

// 자동 로그인 체크
context.read<AuthProvider>().checkAutoLogin();

// 로그아웃
context.read<AuthProvider>().logout();
```

---

## 📎 협업 참고 링크 (예시)

- API 명세서: [백엔드 부분]
- 디자인 시안: [Figma 링크]
- GitHub: [깃허브 링크]
- 백업 GitHub : [백허브 링크]

---