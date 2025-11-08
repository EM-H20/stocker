# Phase 2: 복잡 Provider 변환 상세 계획

**목표**: ChangeNotifierProvider들을 Riverpod AsyncNotifier/Notifier로 변환
**예상 기간**: 5-7일
**난이도**: ⭐⭐⭐⭐ (높음)

---

## 📊 변환 대상 Provider 분석

### 우선순위 1: 핵심 Provider (1-2일)

#### 1. AuthProvider → AuthNotifier
**복잡도**: ⭐⭐⭐⭐⭐ (매우 높음)
- **파일**: `lib/features/auth/presentation/auth_provider.dart`
- **상태 변수**: 5개 (`_user`, `_errorMessage`, `_isLoading`, `_isInitializing`, `_isUpdatingProfile`)
- **특별 패턴**: `ValueNotifier<bool> loginSuccessNotifier` (HomeShell 콜백)
- **메서드**: 7개 (initialize, login, logout, signup, updateProfile, quickTestLogin, _setLoading)
- **의존성**: AuthRepository, TokenStorage

**변환 전략**:
```dart
// 1. 상태 클래스 정의 (freezed)
@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    User? user,
    @Default(false) bool isLoading,
    @Default(false) bool isInitializing,
    @Default(false) bool isUpdatingProfile,
    String? errorMessage,
  }) = _AuthState;
}

// 2. AsyncNotifier 패턴
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<AuthState> build() async {
    // 자동 초기화
    return await _initialize();
  }

  Future<AuthState> _initialize() async {
    // TokenStorage 확인 및 자동 로그인
  }

  Future<bool> login(String email, String password) async {
    state = AsyncValue.loading();
    // Repository 사용: ref.read(authRepositoryProvider)
  }
}

// 3. 로그인 성공 이벤트 Provider (ValueNotifier 대체)
@riverpod
class LoginSuccessNotifier extends _$LoginSuccessNotifier {
  @override
  bool build() => false;

  void trigger() {
    state = true;
    Future.delayed(Duration(milliseconds: 100), () {
      state = false;
    });
  }
}
```

**UI 변환**:
```dart
// Before
final authProvider = context.read<AuthProvider>();
await authProvider.login(email, password);

// After
final authNotifier = ref.read(authNotifierProvider.notifier);
await authNotifier.login(email, password);
```

**HomeShell 콜백 변환**:
```dart
// Before (HomeShell)
_authProvider?.loginSuccessNotifier.addListener(_showAttendanceQuizIfNeeded);

// After (HomeShell with ConsumerStatefulWidget)
ref.listen(loginSuccessNotifierProvider, (prev, next) {
  if (next == true) {
    _showAttendanceQuizIfNeeded();
  }
});
```

---

### 우선순위 2: Repository 의존 Provider (2-3일)

#### 2. EducationProvider → EducationNotifier
**복잡도**: ⭐⭐⭐⭐
- **파일**: `lib/features/education/presentation/education_provider.dart`
- **의존성**: EducationRepository
- **특징**: 챕터 데이터, 진행률 관리

#### 3. QuizProvider → QuizNotifier
**복잡도**: ⭐⭐⭐⭐
- **파일**: `lib/features/quiz/presentation/quiz_provider.dart`
- **의존성**: QuizRepository
- **특징**: 퀴즈 상태, 답변 검증

#### 4. AttendanceProvider → AttendanceNotifier
**복잡도**: ⭐⭐⭐⭐
- **파일**: `lib/features/attendance/presentation/provider/attendance_provider.dart`
- **의존성**: AttendanceRepository
- **특징**: 출석 체크, 퀴즈 모달 (HomeShell 연동)

#### 5. AptitudeProvider → AptitudeNotifier
**복잡도**: ⭐⭐⭐
- **파일**: `lib/features/aptitude/presentation/provider/aptitude_provider.dart`
- **의존성**: AptitudeRepository
- **특징**: 성향 분석 결과

#### 6. NoteProvider → NoteNotifier
**복잡도**: ⭐⭐⭐
- **파일**: `lib/features/note/presentation/provider/note_provider.dart`
- **의존성**: NoteRepository
- **특징**: 메모 CRUD

#### 7. WrongNoteProvider → WrongNoteNotifier
**복잡도**: ⭐⭐⭐
- **파일**: `lib/features/wrong_note/presentation/wrong_note_provider.dart`
- **의존성**: WrongNoteRepository
- **특징**: 오답노트 관리

#### 8. LearningProgressProvider → LearningProgressNotifier
**복잡도**: ⭐⭐⭐
- **파일**: `lib/features/learning/presentation/provider/learning_progress_provider.dart`
- **의존성**: LearningProgressRepository
- **특징**: 학습 진행도 추적

---

## 🔧 공통 변환 패턴

### 1. ChangeNotifier → Notifier 변환

**Before (Provider)**:
```dart
class MyProvider with ChangeNotifier {
  MyData? _data;
  bool _isLoading = false;
  String? _error;

  MyData? get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _data = await repository.getData();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

**After (Riverpod)**:
```dart
@freezed
class MyState with _$MyState {
  const factory MyState({
    MyData? data,
    @Default(false) bool isLoading,
    String? error,
  }) = _MyState;
}

@riverpod
class MyNotifier extends _$MyNotifier {
  @override
  MyState build() {
    return const MyState();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true);

    try {
      final data = await ref.read(myRepositoryProvider).getData();
      state = state.copyWith(data: data, error: null, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
```

### 2. AsyncNotifier 패턴 (비동기 초기화)

```dart
@riverpod
class MyAsyncNotifier extends _$MyAsyncNotifier {
  @override
  Future<MyState> build() async {
    // 초기화 로직
    final initialData = await ref.read(myRepositoryProvider).getInitialData();
    return MyState(data: initialData);
  }

  Future<void> updateData() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final newData = await ref.read(myRepositoryProvider).updateData();
      return state.value!.copyWith(data: newData);
    });
  }
}
```

### 3. ValueNotifier 콜백 → ref.listen 변환

**Before**:
```dart
// Provider
final ValueNotifier<bool> myEvent = ValueNotifier(false);

void triggerEvent() {
  myEvent.value = true;
  Future.delayed(Duration(milliseconds: 100), () {
    myEvent.value = false;
  });
}

// UI (StatefulWidget)
@override
void initState() {
  super.initState();
  myProvider.myEvent.addListener(_handleEvent);
}

@override
void dispose() {
  myProvider.myEvent.removeListener(_handleEvent);
  super.dispose();
}
```

**After**:
```dart
// Notifier
@riverpod
class MyEventNotifier extends _$MyEventNotifier {
  @override
  bool build() => false;

  void trigger() {
    state = true;
    Future.delayed(Duration(milliseconds: 100), () {
      state = false;
    });
  }
}

// UI (ConsumerStatefulWidget)
@override
Widget build(BuildContext context) {
  ref.listen(myEventNotifierProvider, (prev, next) {
    if (next == true) {
      _handleEvent();
    }
  });

  return YourWidget();
}
```

### 4. Repository 주입 변경

**Before**:
```dart
// main.dart
Provider<MyRepository>(
  create: (_) => useMock ? MockRepo() : RealRepo(),
)

// Provider
class MyProvider {
  final MyRepository _repo;
  MyProvider(this._repo);
}

// main.dart Provider 주입
ChangeNotifierProvider(
  create: (context) => MyProvider(context.read<MyRepository>()),
)
```

**After**:
```dart
// Notifier에서 직접 사용
@riverpod
class MyNotifier extends _$MyNotifier {
  MyRepository get _repo => ref.read(myRepositoryProvider);

  @override
  MyState build() {
    return const MyState();
  }
}
```

---

## 🎯 단계별 작업 순서

### Step 1: AuthProvider 변환 (1-2일)
1. ✅ AuthState 클래스 작성 (freezed)
2. ✅ AuthNotifier 작성 (@riverpod)
3. ✅ LoginSuccessNotifier 분리
4. ✅ TokenStorage 통합
5. ✅ build_runner 실행
6. ✅ main.dart 업데이트
7. ✅ HomeShell ref.listen 변환
8. ✅ 로그인/회원가입 화면 업데이트
9. ✅ 테스트 및 검증

### Step 2: 나머지 Provider 변환 (2-3일)
각 Provider마다:
1. State 클래스 작성
2. Notifier 작성
3. Repository ref.read 연결
4. build_runner 실행
5. UI 화면 업데이트
6. 테스트

### Step 3: main.dart 정리 (0.5일)
1. 모든 legacy_provider 제거
2. ProviderScope만 남기기
3. import 정리
4. 최종 검증

---

## ⚠️ 주의사항

### 1. 콜백 패턴 처리
- ValueNotifier는 별도 Provider로 분리
- ref.listen으로 이벤트 감지
- ConsumerStatefulWidget 사용 필수

### 2. 비동기 초기화
- AsyncNotifier 패턴 사용
- build()에서 Future 반환
- UI에서 AsyncValue 처리

### 3. 에러 처리
- AsyncValue.guard() 활용
- 상태에 error 필드 유지
- UI에서 에러 표시

### 4. 테스트
- ProviderContainer로 테스트
- Mock Repository 활용
- 각 Provider별 단위 테스트

---

## 📝 체크리스트

### AuthProvider 변환
- [ ] AuthState 클래스 (freezed)
- [ ] AuthNotifier (AsyncNotifier)
- [ ] LoginSuccessNotifier 분리
- [ ] Repository 연결
- [ ] UI 업데이트
- [ ] HomeShell ref.listen
- [ ] 테스트
- [ ] 커밋

### 기타 Provider 변환 (각각)
- [ ] State 클래스
- [ ] Notifier 작성
- [ ] Repository 연결
- [ ] UI 업데이트
- [ ] 테스트
- [ ] 커밋

### 최종 정리
- [ ] legacy_provider 완전 제거
- [ ] import 정리
- [ ] flutter analyze 통과
- [ ] 전체 앱 테스트
- [ ] Phase 2 완료 커밋

---

## 🚀 다음 세션 시작 명령어

```bash
# Phase 2 AuthProvider부터 시작
"Phase 2 시작해줘 - AuthProvider부터 변환해줘"

# 또는 특정 Provider 지정
"AttendanceProvider를 Riverpod으로 변환해줘"
```

---

**작성일**: 2025-11-08 22:10
**작성자**: Claude Code 🤖
**현재 브랜치**: feature/riverpod-phase0-setup
**Phase 1 완료**: ✅ ThemeNotifier, HomeNavigationNotifier, Repository Providers
