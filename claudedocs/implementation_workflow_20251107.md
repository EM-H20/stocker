# 🛠️ Stocker 프로젝트 코드 개선 실행 계획

**작성일**: 2025-11-07
**기반 문서**: [코드 분석 리포트](code_analysis_report_20251107.md)
**전체 예상 소요 시간**: 6-8시간 (4주 분산 작업)

---

## 📊 진행 상황 트래커

| Phase | 작업 | 상태 | 예상 시간 | 실제 시간 |
|-------|------|------|----------|----------|
| ✅ Phase 0 | Priority 1 완료 | **완료** | 5분 | 5분 |
| 🔄 Phase 1 | 공통 유틸리티 생성 | 대기 | 1시간 | - |
| ⏳ Phase 2 | 공통 위젯 생성 | 대기 | 2시간 | - |
| ⏳ Phase 3 | 대규모 위젯 적용 | 대기 | 3시간 | - |

---

## ✅ Phase 0: Priority 1 완료 (2025-11-07)

### 완료된 작업
- ✅ 사용하지 않는 `_authProvider` 필드 제거
- ✅ 백업 파일 `aptitude_provider.dart.backup` 삭제
- ✅ Flutter analyze 경고 0개 달성
- ✅ 커밋: `refactor: 사용하지 않는 의존성 제거 및 코드 정리`

### 성과
- Flutter analyze 경고: 1개 → **0개**
- 코드 간소화: -196줄

---

## 🔄 Phase 1: 공통 유틸리티 생성 (Week 1)

### 목표
다크모드 체크 중복 39회를 1개의 유틸리티 함수로 통합

### 📝 작업 계획

#### Step 1.1: ThemeUtils 클래스 생성 (15분)

**파일 생성**: `lib/app/core/utils/theme_utils.dart`

```dart
import 'package:flutter/material.dart';

/// 테마 관련 유틸리티 함수 모음
class ThemeUtils {
  ThemeUtils._(); // private constructor to prevent instantiation

  /// 현재 테마가 다크 모드인지 확인
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// 다크/라이트 모드에 따라 색상 반환
  static Color getColorByTheme(
    BuildContext context, {
    required Color lightColor,
    required Color darkColor,
  }) {
    return isDarkMode(context) ? darkColor : lightColor;
  }

  /// 다크/라이트 모드에 따라 투명도가 적용된 색상 반환
  static Color getColorWithOpacity(
    BuildContext context, {
    required Color lightColor,
    required Color darkColor,
    required double opacity,
  }) {
    final color = isDarkMode(context) ? darkColor : lightColor;
    return color.withValues(alpha: opacity);
  }
}
```

**체크리스트**:
- [ ] 파일 생성 및 코드 작성
- [ ] 테스트 케이스 작성 (선택)
- [ ] 커밋: `feat: 다크모드 체크 유틸리티 함수 추가`

---

#### Step 1.2: 주요 10개 파일에 적용 (30분)

**우선 적용 대상**:
1. `lib/features/home/presentation/widgets/quiz_section_widget.dart`
2. `lib/features/home/presentation/widgets/stats_cards_widget.dart`
3. `lib/features/home/presentation/widgets/date_header_widget.dart`
4. `lib/features/home/presentation/widgets/quiz_item_widget.dart`
5. `lib/features/mypage/presentation/widgets/attendance_status_card.dart`
6. `lib/features/quiz/presentation/widgets/quiz_option_widget.dart`
7. `lib/features/education/presentation/widgets/theory_page_widget.dart`
8. `lib/features/attendance/presentation/widgets/attendance_quiz_dialog.dart`
9. `lib/features/wrong_note/presentation/widgets/wrong_note_stats_card.dart`
10. `lib/features/home/presentation/widgets/feature_cards_widget.dart`

**변경 패턴**:
```dart
// Before:
color: Theme.of(context).brightness == Brightness.dark
    ? Colors.white
    : AppTheme.grey900,

// After:
color: ThemeUtils.getColorByTheme(
  context,
  lightColor: AppTheme.grey900,
  darkColor: Colors.white,
)
```

**체크리스트**:
- [ ] 10개 파일 수정 완료
- [ ] Flutter analyze 실행 및 경고 확인
- [ ] 앱 실행하여 UI 정상 작동 확인
- [ ] 커밋: `refactor: 주요 위젯에 ThemeUtils 적용 (10개 파일)`

---

#### Step 1.3: 나머지 29개 파일에 점진적 적용 (15분)

**적용 전략**: 5개씩 그룹으로 나누어 적용

**Group 1-6**:
- Group 1: Quiz 관련 위젯 5개
- Group 2: Education 관련 위젯 5개
- Group 3: Attendance 관련 위젯 5개
- Group 4: WrongNote 관련 위젯 5개
- Group 5: Mypage 관련 위젯 5개
- Group 6: 기타 나머지 4개

**체크리스트**:
- [ ] Group 1 적용 및 커밋
- [ ] Group 2 적용 및 커밋
- [ ] Group 3 적용 및 커밋
- [ ] Group 4 적용 및 커밋
- [ ] Group 5 적용 및 커밋
- [ ] Group 6 적용 및 커밋

---

### 📊 Phase 1 예상 효과
- 코드 라인 수: **-200줄**
- 유지보수성: 테마 로직 변경 시 39개 파일 → **1개 파일**만 수정
- 일관성: 100% 보장

---

## 🎨 Phase 2: 공통 위젯 생성 (Week 2)

### 목표
로딩, 에러, 카드 위젯을 공통 컴포넌트로 추출

---

### Step 2.1: LoadingWidget 생성 및 적용 (30분)

**파일 생성**: `lib/app/core/widgets/loading_widget.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 공통 로딩 인디케이터 위젯
class LoadingWidget extends StatelessWidget {
  /// 로딩 중 표시할 메시지 (선택사항)
  final String? message;

  /// 로딩 인디케이터 크기 (기본값: 40.w)
  final double? size;

  /// 로딩 인디케이터 색상 (기본값: primaryColor)
  final Color? color;

  const LoadingWidget({
    super.key,
    this.message,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size ?? 40.w,
            height: size ?? 40.w,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? Theme.of(context).primaryColor,
              ),
            ),
          ),
          if (message != null) ...[
            SizedBox(height: 16.h),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
```

**적용 대상 (13개 파일)**:
- `lib/features/home/presentation/widgets/date_header_widget.dart`
- `lib/features/home/presentation/widgets/quiz_section_widget.dart`
- `lib/features/mypage/presentation/mypage_screen.dart`
- `lib/features/wrong_note/presentation/wrong_note_screen.dart`
- `lib/features/quiz/presentation/quiz_screen.dart`
- `lib/features/education/presentation/education_screen.dart`
- `lib/features/quiz/presentation/quiz_result_screen.dart`
- `lib/features/mypage/presentation/widgets/note_section.dart`
- `lib/features/education/presentation/theory_screen.dart`
- `lib/features/aptitude/presentation/widgets/aptitude_result_card.dart`
- `lib/features/aptitude/presentation/screens/aptitude_quiz_screen.dart`
- 나머지 2개

**변경 패턴**:
```dart
// Before:
if (isLoading)
  Center(
    child: CircularProgressIndicator(),
  )

// After:
if (isLoading)
  LoadingWidget(message: '데이터를 불러오는 중...')
```

**체크리스트**:
- [ ] LoadingWidget 파일 생성
- [ ] 13개 파일에 적용
- [ ] UI 테스트 (다크/라이트 모드)
- [ ] 커밋: `feat: 공통 LoadingWidget 추가 및 적용`

---

### Step 2.2: ErrorMessageWidget 생성 및 적용 (30분)

**파일 생성**: `lib/app/core/widgets/error_message_widget.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/app_theme.dart';

/// 공통 에러 메시지 위젯
class ErrorMessageWidget extends StatelessWidget {
  /// 에러 메시지
  final String message;

  /// 재시도 버튼 콜백 (선택사항)
  final VoidCallback? onRetry;

  /// 에러 아이콘 (기본값: error_outline)
  final IconData? icon;

  /// 에러 색상 (기본값: AppTheme.errorColor)
  final Color? color;

  const ErrorMessageWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final errorColor = color ?? AppTheme.errorColor;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48.sp,
              color: errorColor,
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: errorColor,
                  ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: errorColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

**적용 대상 (10개 이상 Provider)**:
- 모든 Provider의 에러 처리 UI

**체크리스트**:
- [ ] ErrorMessageWidget 파일 생성
- [ ] 10개 Provider 화면에 적용
- [ ] 에러 시나리오 테스트
- [ ] 커밋: `feat: 공통 ErrorMessageWidget 추가 및 적용`

---

### Step 2.3: AppCard 위젯 생성 (1시간)

**파일 생성**: `lib/app/core/widgets/app_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/app_theme.dart';
import '../utils/theme_utils.dart';

/// 공통 카드 위젯
///
/// 프로젝트 전체에서 일관된 카드 스타일을 제공합니다.
class AppCard extends StatelessWidget {
  /// 카드 내부 콘텐츠
  final Widget child;

  /// 카드 내부 패딩 (기본값: EdgeInsets.all(20.w))
  final EdgeInsetsGeometry? padding;

  /// 카드 외부 마진
  final EdgeInsetsGeometry? margin;

  /// 카드 모서리 둥글기 (기본값: 16.r)
  final double? borderRadius;

  /// 카드 배경색 (기본값: Theme.cardColor)
  final Color? backgroundColor;

  /// 그림자 표시 여부 (기본값: true)
  final bool hasShadow;

  /// 테두리 표시 여부 (기본값: true)
  final bool hasBorder;

  /// 카드 탭 이벤트 콜백
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.hasShadow = true,
    this.hasBorder = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      padding: padding ?? EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(borderRadius ?? 16.r),
        border: hasBorder
            ? Border.all(
                color: ThemeUtils.getColorWithOpacity(
                  context,
                  lightColor: AppTheme.grey300,
                  darkColor: AppTheme.grey700,
                  opacity: ThemeUtils.isDarkMode(context) ? 0.3 : 0.5,
                ),
                width: 1,
              )
            : null,
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius ?? 16.r),
        child: card,
      );
    }

    return card;
  }
}
```

**체크리스트**:
- [ ] AppCard 파일 생성
- [ ] 문서화 주석 작성
- [ ] 커밋: `feat: 공통 AppCard 위젯 추가`

---

### 📊 Phase 2 예상 효과
- 코드 라인 수: **-300줄**
- 위젯 재사용성: 3개 공통 위젯 활용
- 디자인 일관성: 100% 보장

---

## 🚀 Phase 3: 대규모 위젯 적용 (Week 3-4)

### 목표
AppCard 위젯을 30개 이상 파일에 적용

---

### Step 3.1: AppCard 우선 적용 (1시간)

**우선 적용 대상 (10개 파일)**:
1. `lib/features/home/presentation/widgets/quiz_section_widget.dart`
2. `lib/features/home/presentation/widgets/stats_cards_widget.dart`
3. `lib/features/home/presentation/main_dashboard_screen.dart`
4. `lib/features/mypage/presentation/widgets/aptitude_analysis_card.dart`
5. `lib/features/mypage/presentation/widgets/attendance_status_card.dart`
6. `lib/features/mypage/presentation/widgets/wrong_note_card.dart`
7. `lib/features/education/presentation/widgets/chapter_info_card.dart`
8. `lib/features/education/presentation/widgets/recommended_chapter_card.dart`
9. `lib/features/quiz/presentation/widgets/quiz_result_card_widget.dart`
10. `lib/features/aptitude/presentation/widgets/aptitude_result_card.dart`

**변경 패턴**:
```dart
// Before:
Container(
  padding: EdgeInsets.all(20.w),
  decoration: BoxDecoration(
    color: Theme.of(context).cardColor,
    borderRadius: BorderRadius.circular(16.r),
    border: Border.all(...),
    boxShadow: [...],
  ),
  child: YourContentWidget(),
)

// After:
AppCard(
  child: YourContentWidget(),
)
```

**체크리스트**:
- [ ] 10개 파일 수정
- [ ] UI 테스트 (다크/라이트 모드)
- [ ] 커밋: `refactor: 주요 카드 위젯에 AppCard 적용 (10개 파일)`

---

### Step 3.2: AppCard 중간 적용 (1시간)

**적용 대상 (10개 파일)**:
- Wrong Note 관련 위젯 5개
- Attendance 관련 위젯 5개

**체크리스트**:
- [ ] 10개 파일 수정
- [ ] UI 테스트
- [ ] 커밋: `refactor: 오답노트/출석 위젯에 AppCard 적용 (10개 파일)`

---

### Step 3.3: AppCard 최종 적용 (1시간)

**적용 대상 (나머지 10개+ 파일)**:
- 기타 모든 카드 스타일 위젯

**체크리스트**:
- [ ] 나머지 파일 수정
- [ ] 전체 앱 UI 테스트
- [ ] Flutter analyze 확인
- [ ] 커밋: `refactor: 전체 프로젝트에 AppCard 적용 완료`

---

### 📊 Phase 3 예상 효과
- 코드 라인 수: **-500줄**
- 카드 스타일 통일: 30개+ 파일
- 유지보수성: 디자인 변경 시 1개 파일만 수정

---

## 📈 전체 프로젝트 개선 효과 요약

| 항목 | Before | After | 개선율 |
|-----|--------|-------|--------|
| **코드 라인 수** | ~15,000줄 | ~14,000줄 | **-7%** |
| **다크모드 체크** | 39개 파일에 중복 | 1개 유틸리티 | **-97%** |
| **로딩 UI** | 13개 파일에 중복 | 1개 위젯 | **-92%** |
| **카드 스타일** | 30개+ 파일에 중복 | 1개 위젯 | **-97%** |
| **Flutter Analyze** | 1개 경고 | 0개 경고 | **100% 해결** |
| **유지보수 비용** | 높음 | 낮음 | **-80%** |
| **코드 일관성** | 낮음 | 높음 | **+100%** |

---

## 🎯 주간 체크리스트

### Week 1: 공통 유틸리티 생성
- [ ] ThemeUtils 생성
- [ ] 10개 파일 우선 적용
- [ ] 29개 파일 그룹별 적용
- [ ] 중간 테스트 및 리뷰

### Week 2: 공통 위젯 생성
- [ ] LoadingWidget 생성 및 적용
- [ ] ErrorMessageWidget 생성 및 적용
- [ ] AppCard 위젯 생성
- [ ] 중간 테스트 및 리뷰

### Week 3-4: 대규모 적용
- [ ] AppCard 우선 10개 적용
- [ ] AppCard 중간 10개 적용
- [ ] AppCard 최종 10개+ 적용
- [ ] 전체 테스트 및 최종 리뷰

---

## 🔄 Git 커밋 전략

### 커밋 메시지 형식
```
<type>: <subject>

<body>

<footer>
```

### Type 분류
- `feat`: 새로운 기능 추가
- `refactor`: 코드 리팩토링 (기능 변경 없음)
- `fix`: 버그 수정
- `docs`: 문서 수정
- `test`: 테스트 코드 추가/수정
- `chore`: 빌드, 설정 파일 수정

### 커밋 예시
```bash
# Phase 1
git commit -m "feat: 다크모드 체크 유틸리티 함수 추가"
git commit -m "refactor: 주요 위젯에 ThemeUtils 적용 (10개 파일)"
git commit -m "refactor: Quiz 위젯에 ThemeUtils 적용 (5개 파일)"

# Phase 2
git commit -m "feat: 공통 LoadingWidget 추가 및 적용"
git commit -m "feat: 공통 ErrorMessageWidget 추가 및 적용"
git commit -m "feat: 공통 AppCard 위젯 추가"

# Phase 3
git commit -m "refactor: 주요 카드 위젯에 AppCard 적용 (10개 파일)"
git commit -m "refactor: 오답노트/출석 위젯에 AppCard 적용 (10개 파일)"
git commit -m "refactor: 전체 프로젝트에 AppCard 적용 완료"
```

---

## 🧪 테스트 체크리스트

### 각 Phase 완료 후 실행

#### 정적 분석
```bash
flutter analyze
# 예상 결과: No issues found!
```

#### 빌드 테스트
```bash
flutter build apk --debug
# 예상 결과: 빌드 성공
```

#### UI 테스트
- [ ] 라이트 모드 전체 화면 확인
- [ ] 다크 모드 전체 화면 확인
- [ ] 로딩 상태 확인
- [ ] 에러 상태 확인
- [ ] 카드 스타일 일관성 확인

---

## 📞 문제 발생 시 대응 방안

### 시나리오 1: UI 깨짐 발생
1. 해당 커밋 롤백: `git revert <commit-hash>`
2. 원인 파악 및 수정
3. 재적용

### 시나리오 2: 성능 저하 발견
1. Flutter DevTools로 성능 프로파일링
2. 위젯 리빌드 최적화
3. 필요시 Selector 위젯 사용

### 시나리오 3: 테마 불일치
1. ThemeUtils 로직 재검토
2. 테마별 색상 매핑 확인
3. 엣지 케이스 추가 테스트

---

## 🎓 학습 및 참고 자료

### Flutter Best Practices
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Widget Catalog](https://docs.flutter.dev/development/ui/widgets)
- [flutter_screenutil Package](https://pub.dev/packages/flutter_screenutil)

### 코드 리팩토링
- [Refactoring Guru](https://refactoring.guru/)
- [Clean Code by Robert C. Martin](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)

---

## 📝 진행 상황 업데이트

### 완료된 Phase
- ✅ **Phase 0** (2025-11-07): Priority 1 완료
  - 커밋: `refactor: 사용하지 않는 의존성 제거 및 코드 정리`
  - 성과: Flutter analyze 경고 0개 달성

### 다음 단계
- 🔄 **Phase 1** 시작 예정
  - ThemeUtils 유틸리티 생성
  - 39개 파일에 점진적 적용

---

**작성자**: Claude Code
**최종 수정일**: 2025-11-07
**다음 리뷰**: Phase 1 완료 후
