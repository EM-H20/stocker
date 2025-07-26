📘 Stocker 프론트엔드 공동 개발 가이드 (Flutter)

Flutter + Spring Boot 기반 앱 프로젝트인 **Stocker**의 프론트엔드 개발을 위한 공동 작업 가이드입니다. 프로젝트 구조, 상태관리, API 연동, 패키지 사용 방식 등을 일관성 있게 정리하여 원활한 협업과 유지보수를 목표로 합니다.

---

## 🔧 1. 프로젝트 개요

- **앱명**: Stocker
- **역할**: 사용자 교육/출석/퀴즈/성향분석/메모 기능 제공
- **기술스택**:
    - Flutter SDK: ^3.7.0
    - 상태관리: provider
    - API 통신: dio
    - 보안 저장소: flutter_secure_storage
    - 환경설정: flutter_dotenv
    - UI: screenutil, table_calendar, fl_chart, percent_indicator, flutter_quill 등
- **백엔드**: Spring Boot REST API (JWT 기반 인증)

---

## 📁 2. 폴더 구조 (*디자인 나오기 전 참고용)

- 회의 때 말한 (공통 디자인 테마, Navigation_provider 정의 됨)

```
lib/
├── main.dart                          # 앱 진입점
├── bootstrap.dart                     # 앱 초기화 로직 (env, dio, storage)
├── app/
│   ├── config/                        # 테마, 라우터, 상수, env
│		│			 └── app_theme.dart          # 전체 Material 디자인 테마를 정의(ThemeData)
│   └── core/
│       ├── widgets/                  # 공통 위젯 (앱 배경화면이나, 버튼, 카드)
│       ├── utils/                    # 유틸리티 함수, 포맷터 등
│       ├── services/                 # Dio, Storage, Notification 등
│       └── settings/                 # 알림, 진동, 소리 설정 등
├── features/
│   ├── home/                         # 바텀네비게이션 및 탭 라우팅
│   │   └── presentation/
│   │       ├── home_shell.dart       # BottomNavigationBar 및 탭별 전환 담당
│   │       ├── tab_item.dart         # 탭 enum 정의
│   │       └── home_navigation_provider.dart # 탭 상태 관리 (provider)
│   ├── auth/                         # 로그인/회원가입
│   ├── education/                    # 챕터/이론/퀴즈
│   ├── attendance/                   # 출석 캘린더
│   ├── aptitude/                     # 성향 분석
│   ├── wrong_note/                   # 오답노트
│   ├── memo/                         # 메모 및 노트
│   └── mypage/                       # 마이페이지
├── l10n/                              # 다국어 (intl_ko.arb)
└── gen/                               # 자동 생성 코드 (build_runner)

```

❗ BottomNavigationBar 관련 코드는 features/home/presentation/home_shell.dart에서만 정의합니다.

각 탭별 페이지(e.g. 출석, 챕터 등)는 자신이 보여줄 화면 UI만 구현하고, BottomNavigationBar를 다시 만들지 않습니다. 모든 탭 전환은 `home_shell.dart` 내에서 일관되게 처리합니다.

### 🧭 GoRouter 사용 원칙

- **라우팅 관리는 `app/config/app_router.dart`에서 중앙 통제**
- **탭 네비게이션은 `ShellRoute` 기반으로 구현** (BottomNavigation 고정)
- **각 페이지는 GoRoute로 구성되며, 화면만 담당**
- **라우팅 경로 문자열은 `app_routes.dart`에 정리**
- **페이지 이동은 반드시 `context.go()` 사용**
- **로그인 상태에 따라 페이지 접근 제어 시 `redirect` 기능 사용**

❌ **각 feature 내부에서 직접 Navigator 사용 금지**

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

## 🧠 4. 상태관리 전략 (Provider)

### ✅ 전역 상태 관리 구조

- **main.dart에서 MultiProvider로 전역 주입**: 모든 Provider는 앱 최상위에서 주입
- **각 기능별로 ChangeNotifier 정의**: 관심사 분리를 통한 유지보수성 향상
- **라우터에서 Provider 중첩 금지**: 복잡성 방지 및 성능 최적화
- View는 `Consumer`, `Selector`, `Provider.of()` 등으로 상태 구독

### ✅ Provider 주입 방식

```dart
// main.dart - 전역 Provider 주입
MultiProvider(
  providers: [
    // 홈 네비게이션 상태 관리
    ChangeNotifierProvider(create: (_) => HomeNavigationProvider()),
    // 인증 상태 관리
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    // 교육 상태 관리
    ChangeNotifierProvider(create: (_) => EducationProvider()),
    // 출석 상태 관리
    ChangeNotifierProvider(create: (_) => AttendanceProvider()),
    // 성향분석 상태 관리
    ChangeNotifierProvider(create: (_) => AptitudeProvider()),
  ],
  child: MaterialApp.router(...),
)
```

### ✅ 라우터 구조

```dart
// app_router.dart - Provider 없이 단순하게
ShellRoute(
  builder: (context, state, child) {
    return HomeShell(child: child); // ❌ Provider 중첩 금지
  },
  routes: [...],
)
```

### ✅ View에서 사용법

```dart
// Consumer로 상태 구독
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    return Text(authProvider.user?.name ?? '로그인 필요');
  },
)

// Selector로 특정 값만 구독 (성능 최적화)
Selector<AuthProvider, bool>(
  selector: (context, provider) => provider.isLoggedIn,
  builder: (context, isLoggedIn, child) {
    return isLoggedIn ? HomeScreen() : LoginScreen();
  },
)

// 메서드 호출 (listen: false)
Provider.of<AuthProvider>(context, listen: false).login();
```

### ⚠️ 주의사항

- **Provider 중첩 금지**: 라우터나 위젯 트리에서 Provider를 중첩하지 않음
- **전역 주입 원칙**: 모든 상태는 main.dart에서 주입
- **관심사 분리**: 각 기능별로 별도 Provider 생성
- **성능 최적화**: Selector 적극 활용하여 불필요한 리빌드 방지

---

## 🌐 5. API 연동 방식 (Dio + .env)

- API Base URL은 `.env`에 정의
- Dio 설정은 `core/services/api_client.dart`에서 Singleton으로 관리

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

## 📦 7. 패키지 사용 가이드

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

## ✅ 개발 시 원칙 정리

| 항목 | 규칙 |
| --- | --- |
| 변수명 | camelCase |
| 클래스명 | PascalCase |
| 파일명 | snake_case.dart |
| 커밋 메시지 | feat:, fix:, refactor: 등 Conventional Commit 사용 |
| API 사용 | 반드시 Repository를 통해서만 호출 (View에서 API 직접 호출 ❌) |
| UI 구성 | 반응형 (`flutter_screenutil`), 공통 위젯 분리 |
| BottomNavigationBar | `home_shell.dart`에서만 작성. 다른 페이지에서는 구현 ❌ |

---

## 🚀 배포 및 기타

```bash
flutter pub get                        # 의존성 설치
flutter pub run flutter_launcher_icons:main   # 아이콘 설정
flutter pub run change_app_package_name:main com.팀명.stocker  # 패키지명 변경
flutter build apk / flutter build ios # 릴리즈 빌드

```

---

## 📎 협업 참고 링크 (예시)

- API 명세서: [백엔드 부분]
- 디자인 시안: [Figma 링크]
- GitHub: [깃허브 링크]
- 백업 GitHub : [백허브 링크]

---