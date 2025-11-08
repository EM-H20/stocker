# Riverpod Migration Progress

**시작일**: 2025-11-08
**현재 Phase**: Phase 1 진행 중 (ThemeNotifier, HomeNavigationNotifier 완료!)
**전체 진행률**: 20% (Phase 0 완료 + Phase 1 67%)

---

## ✅ Phase 0: 환경 준비 및 공존 설정 (완료!)

### 완료된 작업
- [x] **Task 0.1**: Riverpod 의존성 추가
  - flutter_riverpod ^2.6.1
  - riverpod_annotation ^2.6.1
  - freezed_annotation ^2.4.4
  - riverpod_generator, build_runner, freezed (dev)
  - build.yaml 설정 파일 생성

- [x] **Task 0.2**: ProviderScope 래핑
  - main.dart에 ProviderScope 추가
  - provider 패키지에 `legacy_provider` prefix 적용
  - MultiProvider, Provider, ChangeNotifierProvider, Consumer 모두 prefix 적용
  - 컴파일 에러 0개 달성!

- [x] **Task 0.3**: Riverpod 디렉토리 구조 생성
  ```
  lib/
  ├── app/core/providers/riverpod/
  └── features/
      ├── auth/presentation/riverpod/
      ├── education/presentation/riverpod/
      ├── quiz/presentation/riverpod/
      ├── wrong_note/presentation/riverpod/
      ├── attendance/presentation/riverpod/
      ├── aptitude/presentation/riverpod/
      ├── note/presentation/riverpod/
      ├── learning/presentation/riverpod/
      └── home/presentation/riverpod/
  ```

- [x] **Task 0.4**: Git 브랜치 전략
  - `feature/riverpod-migration` (메인 브랜치)
  - `feature/riverpod-phase0-setup` (현재 작업 브랜치)
  - 커밋 완료: "feat: Phase 0 - Riverpod 환경 설정 완료"

### 검증 결과
- ✅ `flutter analyze` 통과
- ✅ 컴파일 에러 0개
- ⏳ 앱 실행 테스트 대기 중

---

## 🎨 Phase 1: 단순 Provider 변환 (진행 중!)

### ✅ 완료된 작업

#### Task 1.1: ThemeProvider → ThemeNotifier 변환 (완료!)
- [x] **파일 생성**: `lib/app/core/providers/riverpod/theme_notifier.dart`
  - @riverpod annotation 기반 ThemeNotifier 클래스
  - SharedPreferences 통한 테마 저장/로드
  - AppThemeMode enum 재사용

- [x] **코드 생성**: `theme_notifier.g.dart` 자동 생성
  - AutoDisposeNotifier<AppThemeMode> 타입
  - themeNotifierProvider 자동 생성
  - themeModeProvider, isDarkModeProvider 추가

- [x] **UI 변환**: main.dart
  ```dart
  // Before
  legacy_provider.Consumer<ThemeProvider>(
    builder: (context, themeProvider, child) {
      return MaterialApp.router(themeMode: themeProvider.themeMode);
    },
  )

  // After
  Consumer(
    builder: (context, ref, child) {
      final currentThemeMode = ref.watch(themeModeProvider);
      return MaterialApp.router(themeMode: currentThemeMode);
    },
  )
  ```

- [x] **기존 Provider 제거**: ThemeProvider 주석 처리 및 import 제거

**검증 결과**:
- ✅ `flutter analyze` 통과
- ✅ 컴파일 에러 0개
- ✅ build_runner 코드 생성 성공
- ⏳ 앱 실행 테스트 대기

---

#### Task 1.2: HomeNavigationProvider → HomeNavigationNotifier 변환 (완료!)
- [x] **파일 생성**: `lib/features/home/presentation/riverpod/home_navigation_notifier.dart`
  - @riverpod annotation 기반 HomeNavigationNotifier 클래스
  - TabItem enum 재사용 (education, attendance, wrongNote, mypage)
  - 4개 메서드: changeTab, changeTabByIndex, isCurrentTab, currentIndex getter

- [x] **코드 생성**: `home_navigation_notifier.g.dart` 자동 생성
  - AutoDisposeNotifier<TabItem> 타입
  - homeNavigationNotifierProvider 자동 생성
  - 초기값: TabItem.education

- [x] **main.dart 업데이트**
  - HomeNavigationProvider 등록 주석 처리
  - import 주석 처리

- [x] **테스트 업데이트**: widget_test.dart
  ```dart
  test('Navigation notifier works correctly', () {
    final container = ProviderContainer();
    final notifier = container.read(homeNavigationNotifierProvider.notifier);

    // 초기 상태 확인
    expect(container.read(homeNavigationNotifierProvider), equals(TabItem.education));

    // 탭 변경 테스트
    notifier.changeTabByIndex(1);
    expect(container.read(homeNavigationNotifierProvider), equals(TabItem.attendance));
  });
  ```

**검증 결과**:
- ✅ `flutter analyze` 통과
- ✅ Navigation notifier 테스트 통과
- ✅ 컴파일 에러 0개
- ✅ build_runner 코드 생성 성공
- ⏳ 앱 실행 테스트 대기

---

### 🔄 진행 중인 작업

### Phase 1 계획 (예상 2~3일, 현재 67% 완료)
1. ✅ **ThemeProvider → ThemeNotifier** (완료)
   - 가장 단순, 의존성 없음
   - @riverpod annotation 사용
   - build_runner 코드 생성
   - UI 변환 및 테스트

2. ✅ **HomeNavigationProvider → HomeNavigationNotifier** (완료)
   - 단순 상태 관리
   - 빠른 변환 완료

3. ⏳ **Repository Provider 변환** (다음 단계)
   - AuthRepository
   - AttendanceRepository
   - AptitudeRepository
   - NoteRepository

### 예상 산출물
- `lib/app/core/providers/riverpod/theme_notifier.dart`
- `lib/app/core/providers/riverpod/theme_notifier.g.dart` (자동 생성)
- `lib/features/home/presentation/riverpod/home_navigation_notifier.dart`
- 각 feature의 repository_provider.dart

---

## 📊 전체 Phase 진행 상황

| Phase | 이름 | 상태 | 진행률 |
|-------|------|------|--------|
| 0 | 환경 준비 | ✅ 완료 | 100% |
| 1 | 단순 Provider 변환 | 🔄 진행중 | 67% (2/3) |
| 2 | 복잡 Provider 변환 | ⏳ 대기 | 0% |
| 3 | UI 레이어 전환 | ⏳ 대기 | 0% |
| 4 | Mock/Real 개선 | ⏳ 대기 | 0% |
| 5 | 최종 정리 | ⏳ 대기 | 0% |

**변환 완료**: ThemeProvider ✅, HomeNavigationProvider ✅
**다음 대상**: Repository Providers (AuthRepository, AttendanceRepository, AptitudeRepository, NoteRepository)

---

## 📝 주요 결정사항

### 공존 전략
- **선택**: provider 패키지에 `legacy_provider` prefix 적용
- **이유**: Riverpod Provider와 이름 충돌 방지
- **영향**: 모든 Provider 사용처에 prefix 필요 (자동 변환 완료)

### 코드 생성 전략
- **선택**: riverpod_annotation + build_runner 사용
- **이유**:
  - 코드 제네레이터로 보일러플레이트 감소
  - 타입 안전성 향상
  - Notifier 패턴 자동 생성

---

## 🚨 발생한 이슈 및 해결

### Issue #1: freezed_annotation 버전 충돌
- **문제**: `freezed_annotation ^2.4.5` 버전이 존재하지 않음
- **해결**: `freezed_annotation ^2.4.4`로 다운그레이드
- **영향**: 없음 (기능상 차이 없음)

### Issue #2: Provider/Riverpod 네임 충돌
- **문제**: Provider, ChangeNotifierProvider, Consumer 이름 충돌
- **해결**: `import 'package:provider/provider.dart' as legacy_provider;`
- **영향**: 기존 코드 수정 필요 (자동 변환 완료)

---

## 🎯 다음 작업 명령어

```bash
# Phase 1 시작
# ThemeProvider 변환부터 시작
flutter pub run build_runner watch

# 또는 단계별 진행
"Phase 1 시작해줘"
"ThemeProvider부터 변환해줘"
```

---

---

## 📝 Phase 1 학습 포인트

### 1. @riverpod annotation 사용법
```dart
@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  AppThemeMode build() {
    return AppThemeMode.system; // 초기값
  }

  void setThemeMode(AppThemeMode mode) {
    state = mode; // 자동 notifyListeners!
  }
}
```

### 2. Provider 파생 패턴
```dart
// 메인 Notifier
@riverpod
class ThemeNotifier extends _$ThemeNotifier { ... }

// 파생 Provider (변환 로직)
@riverpod
ThemeMode themeMode(Ref ref) {
  final appThemeMode = ref.watch(themeNotifierProvider);
  return convertToThemeMode(appThemeMode);
}
```

### 3. build_runner 사용
```bash
# 코드 생성
dart run build_runner build --delete-conflicting-outputs

# watch 모드 (자동 감지)
dart run build_runner watch
```

---

**마지막 업데이트**: 2025-11-08 21:30
**작성자**: Claude Code 🤖
**현재 브랜치**: feature/riverpod-phase0-setup
**최근 커밋**: feat: Phase 1 Task 1.2 - HomeNavigationProvider → HomeNavigationNotifier 변환 완료
