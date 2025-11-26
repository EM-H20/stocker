# Stocker 기능 상세 설명서

> 각 기능(Feature)에 대한 상세 설명과 구현 내용

---

## 목차
1. [인증 (Auth)](#1-인증-auth)
2. [교육 (Education)](#2-교육-education)
3. [출석 (Attendance)](#3-출석-attendance)
4. [퀴즈 (Quiz)](#4-퀴즈-quiz)
5. [오답노트 (Wrong Note)](#5-오답노트-wrong-note)
6. [투자 성향 분석 (Aptitude)](#6-투자-성향-분석-aptitude)
7. [노트 (Note)](#7-노트-note)
8. [마이페이지 (MyPage)](#8-마이페이지-mypage)

---

## 1. 인증 (Auth)

### 1.1 기능 개요
사용자 인증(로그인, 회원가입) 및 세션 관리 기능

### 1.2 주요 기능
| 기능 | 설명 |
|------|------|
| 로그인 | 이메일/비밀번호 기반 로그인 |
| 회원가입 | 이름, 이메일, 비밀번호로 신규 가입 |
| 자동 로그인 | 토큰 기반 자동 인증 |
| 로그아웃 | 토큰 삭제 및 로그아웃 |
| 프로필 수정 | 사용자 정보 변경 |

### 1.3 화면 구성
```
LoginScreen
├── 이메일 입력 필드
├── 비밀번호 입력 필드
├── 로그인 버튼
└── 회원가입 링크

SignupScreen
├── 이름 입력 필드
├── 이메일 입력 필드
├── 비밀번호 입력 필드
├── 비밀번호 확인 필드
├── 비밀번호 유효성 가이드
└── 회원가입 버튼
```

### 1.4 데이터 흐름
```
[로그인]
UI → AuthNotifier.login() → AuthRepository.login() → AuthApi.login()
                                                            ↓
UI ← AuthState 업데이트 ← TokenStorage 저장 ← Response (token, user)
```

### 1.5 관련 파일
- `features/auth/presentation/login_screen.dart`
- `features/auth/presentation/signup_screen.dart`
- `features/auth/domain/auth_repository.dart`
- `features/auth/data/repository/auth_api_repository.dart`

---

## 2. 교육 (Education)

### 2.1 기능 개요
주식 투자에 대한 체계적인 이론 학습 시스템

### 2.2 주요 기능
| 기능 | 설명 |
|------|------|
| 챕터 목록 | 학습 주제별 챕터 리스트 |
| 이론 학습 | 각 챕터의 이론 콘텐츠 학습 |
| 진도 관리 | 학습 진행률 추적 |
| 검색 | 챕터/이론 검색 |
| 퀴즈 연동 | 이론 학습 후 퀴즈 풀기 |

### 2.3 화면 구성
```
EducationScreen
├── 검색바
├── 진행률 표시 (PercentIndicator)
└── 챕터 카드 리스트
    ├── 챕터 제목
    ├── 요약 설명
    ├── 진행 상태 표시
    └── 이론 학습 / 퀴즈 버튼

TheoryScreen
├── 이론 페이지 (PageView)
│   ├── 제목
│   ├── 본문 내용
│   └── 예시/참고 자료
├── 페이지 네비게이션
└── 학습 완료 버튼
```

### 2.4 데이터 모델
```dart
class ChapterInfo {
  final int id;
  final String title;
  final String description;
  final int totalTheories;
  final int completedTheories;
  final double progressRate;
}

class TheoryInfo {
  final int id;
  final int chapterId;
  final String title;
  final String content;
  final int pageNumber;
  final bool isCompleted;
}
```

### 2.5 관련 파일
- `features/education/presentation/education_screen.dart`
- `features/education/presentation/theory_screen.dart`
- `features/education/domain/models/chapter_info.dart`
- `features/education/domain/models/theory_info.dart`

---

## 3. 출석 (Attendance)

### 3.1 기능 개요
매일 출석 체크와 출석 퀴즈를 통한 학습 동기 부여

### 3.2 주요 기능
| 기능 | 설명 |
|------|------|
| 출석 캘린더 | 월별 출석 현황 확인 |
| 출석 퀴즈 | 당일 출석 인정을 위한 퀴즈 |
| 연속 출석 | 연속 출석일 트래킹 |
| 출석 통계 | 월간/총 출석 현황 |

### 3.3 화면 구성
```
AttendanceScreen
├── TableCalendar
│   ├── 출석일 마킹
│   ├── 오늘 날짜 강조
│   └── 월 이동 버튼
├── 출석 통계 카드
│   ├── 이번 달 출석
│   ├── 연속 출석일
│   └── 총 출석일
└── 출석 체크 버튼
    └── 출석 퀴즈 다이얼로그

AttendanceQuizDialog
├── 퀴즈 문제
├── O/X 선택 버튼
└── 제출/결과 표시
```

### 3.4 데이터 모델
```dart
class AttendanceDay {
  final DateTime date;
  final bool isPresent;
  final bool hasQuiz;
  final bool quizCompleted;
}

class AttendanceQuiz {
  final int id;
  final String question;
  final bool answer;
  final String explanation;
}
```

### 3.5 관련 파일
- `features/attendance/presentation/screens/attendance_screen.dart`
- `features/attendance/domain/model/attendance_day.dart`
- `features/attendance/domain/model/attendance_quiz.dart`

---

## 4. 퀴즈 (Quiz)

### 4.1 기능 개요
챕터별 O/X 퀴즈로 학습 이해도 검증

### 4.2 주요 기능
| 기능 | 설명 |
|------|------|
| O/X 퀴즈 | 참/거짓 선택 문제 |
| 즉시 피드백 | 정답 여부 즉시 확인 |
| 해설 제공 | 문제별 상세 해설 |
| 결과 분석 | 퀴즈 완료 후 점수/분석 |
| 오답 저장 | 틀린 문제 자동 저장 |

### 4.3 화면 구성
```
QuizScreen
├── 진행률 표시 (ProgressWidget)
├── 문제 카드
│   ├── 문제 번호
│   ├── 문제 내용
│   └── O/X 선택 버튼
├── 해설 영역 (선택 후 표시)
│   ├── 정답 여부
│   └── 해설 내용
└── 네비게이션 버튼

QuizResultScreen
├── 점수 표시
├── 정답률 그래프
├── 문제별 결과 리스트
└── 오답노트 확인 버튼
```

### 4.4 데이터 모델
```dart
class QuizInfo {
  final int id;
  final int chapterId;
  final String question;
  final bool correctAnswer;
  final String explanation;
}

class QuizResult {
  final int totalQuestions;
  final int correctCount;
  final double score;
  final List<QuizAnswer> answers;
}

class QuizSession {
  final int chapterId;
  final List<QuizInfo> quizzes;
  final Map<int, bool> userAnswers;
  final int currentIndex;
}
```

### 4.5 관련 파일
- `features/quiz/presentation/quiz_screen.dart`
- `features/quiz/presentation/quiz_result_screen.dart`
- `features/quiz/domain/models/quiz_info.dart`
- `features/quiz/domain/models/quiz_result.dart`

---

## 5. 오답노트 (Wrong Note)

### 5.1 기능 개요
틀린 문제를 자동 수집하여 복습할 수 있는 기능

### 5.2 주요 기능
| 기능 | 설명 |
|------|------|
| 오답 수집 | 퀴즈에서 틀린 문제 자동 저장 |
| 챕터별 필터 | 특정 챕터의 오답만 필터링 |
| 재학습 | 오답 문제 다시 풀기 |
| 삭제 | 완전 학습 후 오답 삭제 |
| 통계 | 챕터별 오답 현황 |

### 5.3 화면 구성
```
WrongNoteScreen
├── 필터 탭 (전체/챕터별)
├── 오답 문제 리스트
│   ├── 문제 내용
│   ├── 나의 답변
│   ├── 정답
│   └── 해설 보기 버튼
└── 다시 풀기 버튼
```

### 5.4 데이터 모델
```dart
class WrongNote {
  final int id;
  final int quizId;
  final int chapterId;
  final String question;
  final bool correctAnswer;
  final bool userAnswer;
  final String explanation;
  final DateTime wrongDate;
}
```

### 5.5 관련 파일
- `features/wrong_note/presentation/wrong_note_screen.dart`
- `features/wrong_note/data/models/wrong_note_request.dart`

---

## 6. 투자 성향 분석 (Aptitude)

### 6.1 기능 개요
20개 문항을 통해 사용자의 투자 성향을 분석하고 맞춤 정보 제공

### 6.2 주요 기능
| 기능 | 설명 |
|------|------|
| 성향 테스트 | 20문항 설문 응답 |
| 유형 분석 | 5가지 투자자 유형 분류 |
| 결과 차트 | 레이더 차트로 성향 시각화 |
| 포트폴리오 추천 | 성향별 자산 배분 추천 |
| 타 유형 비교 | 다른 투자 유형 정보 확인 |

### 6.3 투자자 유형
| 유형 | 설명 | 특징 |
|------|------|------|
| **안정추구형** | 원금 보존 최우선 | 저위험 상품 선호 |
| **안정성장형** | 안정+소폭 성장 | 채권/배당주 선호 |
| **균형투자형** | 위험/수익 균형 | 분산 투자 선호 |
| **성장추구형** | 높은 수익 추구 | 성장주 선호 |
| **적극투자형** | 공격적 투자 | 고위험 고수익 |

### 6.4 화면 구성
```
AptitudeInitialScreen
├── 성향 분석 소개
├── 테스트 시작 버튼
└── 모든 유형 보기 링크

AptitudeQuizScreen
├── 진행률 표시 (1/20)
├── 질문 카드
├── 4-5개 선택지 버튼
└── 이전/다음 네비게이션

AptitudeResultScreen
├── 투자 유형 결과
├── 레이더 차트 (5개 지표)
├── 유형 설명
├── 포트폴리오 추천 (파이 차트)
└── 다시 테스트 버튼

AptitudeTypesListScreen
├── 5가지 유형 카드 리스트
└── 각 유형 상세 보기
```

### 6.5 데이터 모델
```dart
class AptitudeQuestion {
  final int id;
  final String question;
  final List<AptitudeOption> options;
}

class AptitudeOption {
  final int value;
  final String text;
}

class AptitudeResult {
  final String typeName;
  final String description;
  final Map<String, double> scores; // 5가지 지표 점수
  final List<PortfolioItem> recommendedPortfolio;
}

class AptitudeTypeSummary {
  final String typeName;
  final String shortDescription;
  final String iconEmoji;
  final Color themeColor;
}
```

### 6.6 관련 파일
- `features/aptitude/presentation/screens/aptitude_initial_screen.dart`
- `features/aptitude/presentation/screens/aptitude_quiz_screen.dart`
- `features/aptitude/presentation/screens/aptitude_result_screen.dart`
- `features/aptitude/domain/model/aptitude_result.dart`

---

## 7. 노트 (Note)

### 7.1 기능 개요
학습 내용을 정리하는 리치 텍스트 노트 기능

### 7.2 주요 기능
| 기능 | 설명 |
|------|------|
| 노트 목록 | 작성한 노트 리스트 |
| 노트 작성 | 리치 텍스트 에디터로 작성 |
| 템플릿 | 미리 정의된 템플릿 제공 |
| 편집/삭제 | 기존 노트 수정/삭제 |

### 7.3 화면 구성
```
NoteListScreen
├── 노트 검색
├── 노트 카드 리스트
│   ├── 제목
│   ├── 작성일
│   └── 미리보기
└── 새 노트 작성 FAB

NoteEditorScreen
├── 제목 입력
├── QuillEditor (리치 텍스트)
│   ├── 볼드/이탤릭/밑줄
│   ├── 리스트/체크리스트
│   └── 헤더/인용
└── 저장 버튼
```

### 7.4 노트 템플릿
```dart
enum NoteTemplate {
  blank('빈 노트'),
  learningNote('학습 노트'),
  investmentAnalysis('투자 분석'),
  tradingLog('거래 일지'),
  readingNote('독서 메모');
}
```

### 7.5 관련 파일
- `features/note/presentation/screens/note_list_screen.dart`
- `features/note/presentation/screens/note_editor_screen.dart`
- `features/note/presentation/constants/note_templates.dart`

---

## 8. 마이페이지 (MyPage)

### 8.1 기능 개요
사용자 프로필 관리 및 앱 설정

### 8.2 주요 기능
| 기능 | 설명 |
|------|------|
| 프로필 표시 | 사용자 정보 표시 |
| 학습 통계 | 학습 현황 요약 |
| 성향 분석 | 성향 분석 바로가기 |
| 노트 | 노트 목록 바로가기 |
| 설정 | 테마, 알림 등 설정 |
| 로그아웃 | 계정 로그아웃 |

### 8.3 화면 구성
```
MypageScreen
├── 프로필 섹션
│   ├── 프로필 이미지
│   ├── 이름
│   └── 이메일
├── 학습 통계 카드
│   ├── 출석 현황
│   ├── 학습 진도
│   └── 퀴즈 성적
├── 기능 바로가기
│   ├── 성향 분석
│   ├── 노트
│   └── 오답노트
├── 설정 섹션
│   ├── 다크모드 토글
│   └── 알림 설정
└── 로그아웃 버튼
```

### 8.4 관련 파일
- `features/mypage/presentation/mypage_screen.dart`
- `features/mypage/presentation/widgets/attendance_status_card.dart`
- `features/mypage/presentation/widgets/note_section.dart`
- `features/mypage/presentation/widgets/wrong_note_card.dart`

---

## 기능 간 연결 관계

```
                    ┌─────────────────────────────────────┐
                    │              Auth                    │
                    │     (로그인 → 모든 기능 접근)         │
                    └──────────────────┬──────────────────┘
                                       │
         ┌─────────────────────────────┼─────────────────────────────┐
         │                             │                             │
         ▼                             ▼                             ▼
   ┌──────────┐                  ┌──────────┐                  ┌──────────┐
   │ Education │                 │Attendance│                  │  MyPage  │
   │  (교육)   │                 │  (출석)   │                  │ (마이)   │
   └────┬─────┘                  └────┬─────┘                  └────┬─────┘
        │                             │                             │
        ▼                             │                             │
   ┌──────────┐                       │                 ┌───────────┴───────────┐
   │   Quiz   │◄──────────────────────┘                 │                       │
   │  (퀴즈)  │                                         ▼                       ▼
   └────┬─────┘                                   ┌──────────┐            ┌──────────┐
        │                                         │ Aptitude │            │   Note   │
        ▼                                         │ (성향분석)│            │  (노트)  │
   ┌──────────┐                                   └──────────┘            └──────────┘
   │Wrong Note│
   │ (오답)   │
   └──────────┘
```

---

## 기술적 하이라이트

### 1. 상태 관리
- **Riverpod** 사용으로 타입 안전한 상태 관리
- **freezed** 패키지로 Immutable State 구현

### 2. 네비게이션
- **GoRouter** 사용으로 선언적 라우팅
- **ShellRoute**로 BottomNavigation 유지

### 3. UI
- **flutter_screenutil**로 반응형 디자인
- **fl_chart**로 통계 시각화
- **flutter_quill**로 리치 텍스트 편집

### 4. 데이터
- **Repository Pattern**으로 데이터 소스 추상화
- **Mock/Real** 전환 가능한 유연한 구조
