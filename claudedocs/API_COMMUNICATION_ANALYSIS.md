# API 통신 분석 리포트 📡

> **분석일**: 2025-11-21
> **목적**: Real API 모드에서 API 문서와 실제 코드 통신 일치성 검증

---

## 🎯 분석 개요

Flutter 앱의 모든 API 클라이언트를 분석하여 [API_DOCUMENTATION.md](API_DOCUMENTATION.md)의 Swagger 명세와 실제 코드가 일치하는지 검증했습니다.

### ✅ 분석 결과 요약

- **총 API 클라이언트**: 10개
- **완벽 일치**: 5개 ✅
- **부분 일치**: 3개 ⚠️
- **불일치/미구현**: 2개 ❌

---

## 📊 API별 상세 분석

### 1️⃣ AuthApi ✅ 완벽 일치

**파일**: [lib/features/auth/data/source/auth_api.dart](../lib/features/auth/data/source/auth_api.dart)

| 엔드포인트 | 문서 | 코드 | 상태 |
|-----------|------|------|------|
| POST /api/user/login | ✅ | ✅ Line 18 | ✅ 일치 |
| POST /api/user/signup | ✅ | ✅ Line 40 | ✅ 일치 |
| POST /api/user/logout | ✅ | ✅ Line 52 | ✅ 일치 |
| POST /api/user/profile | ✅ | ✅ Line 74 | ✅ 일치 |

**요청/응답 형식**:
- ✅ 로그인: `{ email, password }` → `{ message, user, token, refreshToken }`
- ✅ 회원가입: `{ email, password, nickname }` → 성공 시 응답 없음
- ✅ 로그아웃: `{ email }` 필수 - 백엔드 요구사항 정확히 준수
- ✅ 프로필 수정: `{ nickname }` → `{ message, user }`

**인증 헤더**:
```dart
// ✅ 모든 API에서 정확히 구현됨
Authorization: Bearer {accessToken}
x-refresh-token: {refreshToken}
```

---

### 2️⃣ EducationApi ✅ 완벽 일치

**파일**: [lib/features/education/data/education_api.dart](../lib/features/education/data/education_api.dart)

| 엔드포인트 | 문서 | 코드 | 상태 |
|-----------|------|------|------|
| GET /api/chapters | ✅ | ✅ Line 43 | ✅ 일치 |
| POST /api/theory/enter | ✅ | ✅ Line 98 | ✅ 일치 |
| PATCH /api/theory/progress | ✅ | ✅ Line 141 | ✅ 일치 |
| PATCH /api/theory/complete | ✅ | ✅ Line 174 | ✅ 일치 |

**요청/응답 형식**:
- ✅ 챕터 목록: 응답 `[{ id, title, description, ... }]`
- ✅ 이론 진입: `{ chapter_id }` → `{ content, current_page, total_pages }`
- ✅ 진도 갱신: `{ chapter_id, current_page }`
- ✅ 이론 완료: `{ chapter_id }`

**상세 로깅**:
```dart
// ✅ 개발 모드에서 상세한 debugPrint 로그 포함
debugPrint('🚀 [EDU_API] 챕터 목록 조회 시작');
debugPrint('✅ [EDU_API] 챕터 목록 조회 성공 - Status: ${response.statusCode}');
```

---

### 3️⃣ InvestmentProfileApi ✅ 완벽 일치

**파일**: [lib/features/investment_profile/data/source/investment_profile_api.dart](../lib/features/investment_profile/data/source/investment_profile_api.dart)

| 엔드포인트 | 문서 | 코드 | 상태 |
|-----------|------|------|------|
| GET /api/investment_profile/test | ✅ | ✅ Line 33 | ✅ 일치 |
| POST /api/investment_profile/result | ✅ | ✅ Line 48 | ✅ 일치 |
| GET /api/investment_profile/result | ✅ | ✅ Line 63 | ✅ 일치 |
| PUT /api/investment_profile/result | ✅ | ✅ Line 87 | ✅ 일치 |
| GET /api/investment_profile/masters | ✅ | ✅ Line 101 | ✅ 일치 |

**요청/응답 형식**:
- ✅ 검사지 조회: `?version=v1.1` → `{ version, questions: [...] }`
- ✅ 최초 저장: `{ version, answers }` → `{ profile, master }`
- ✅ 결과 조회: 없음 → `{ profile, master }` 또는 404
- ✅ 재검사: `{ version, answers }` → `{ profile, master }`
- ✅ 거장 목록: 없음 → `[{ master_code, name, description, ... }]`

**에러 핸들링**:
```dart
// ✅ 404 에러 시 null 반환 (결과 없음 케이스)
if (e.response?.statusCode == 404) {
  return null;
}
```

---

### 4️⃣ AttendanceApi ✅ 완벽 일치

**파일**: [lib/features/attendance/data/source/attendance_api.dart](../lib/features/attendance/data/source/attendance_api.dart)

| 엔드포인트 | 문서 | 코드 | 상태 |
|-----------|------|------|------|
| GET /api/attendance/history | ✅ | ✅ Line 29 | ✅ 일치 |
| GET /api/attendance/quiz/start | ✅ | ✅ Line 39 | ✅ 일치 |
| POST /api/attendance/quiz/submit | ✅ | ✅ Line 49 | ✅ 일치 |

**요청/응답 형식**:
- ✅ 당월 출석 이력: 없음 → `{ month, attendance_dates: [...] }`
- ✅ 퀴즈 시작: 없음 → `{ questions: [3개 퀴즈] }`
- ✅ 출석 제출: `{ isPresent: true }` → 성공 응답

---

### 5️⃣ MemoApi ✅ 완벽 일치

**파일**: [lib/features/memo/data/source/memo_api.dart](../lib/features/memo/data/source/memo_api.dart)

| 엔드포인트 | 문서 | 코드 | 상태 |
|-----------|------|------|------|
| GET /api/memo/ | ✅ | ✅ Line 31 | ✅ 일치 |
| PUT /api/memo/ | ✅ | ✅ Line 44 | ✅ 일치 |
| DELETE /api/memo/{id} | ✅ | ✅ Line 58 | ✅ 일치 |

**요청/응답 형식**:
- ✅ 메모 전체 조회: 없음 → `{ memos: [...] }`
- ✅ 메모 저장·갱신: `{ template, content, id? }` → `{ memo: {...} }`
- ✅ 메모 삭제: 없음 → `{ message }`

**Note**: 메모 API는 `/memo/` (trailing slash) 사용 - 문서와 정확히 일치

---

### 6️⃣ QuizApi ⚠️ 부분 일치 (문서와 다름)

**파일**: [lib/features/quiz/data/quiz_api.dart](../lib/features/quiz/data/quiz_api.dart)

| 엔드포인트 | 문서 | 코드 | 상태 |
|-----------|------|------|------|
| POST /api/quiz/enter | ✅ | ✅ Line 34 | ✅ 일치 |
| PATCH /api/quiz/progress | ✅ | ✅ Line 70 | ✅ 일치 |
| POST /api/quiz/complete | ✅ | ✅ Line 107 | ⚠️ **필드명 불일치** |

**⚠️ 발견된 문제**:

**quiz_api.dart:109-110**:
```dart
data: {
  'chapter_id': chapterId, // ⚠️ 문서: chapter_id 사용
  'answers': answers,
},
```

**API_DOCUMENTATION.md**:
```json
{
  "chapterId": 1,  // ⚠️ 문서는 camelCase 사용
  "answers": [...]
}
```

**💡 권장사항**: 백엔드 팀과 확인 필요
- 문서는 `chapterId` (camelCase)
- 코드는 `chapter_id` (snake_case)
- 실제 백엔드가 어느 쪽을 받는지 확인 필요

---

### 7️⃣ NoteApi ⚠️ 부분 일치 (Memo API 재사용)

**파일**: [lib/features/note/data/source/note_api.dart](../lib/features/note/data/source/note_api.dart)

| 엔드포인트 | 문서 | 코드 | 상태 |
|-----------|------|------|------|
| GET /api/memo/ | ✅ | ✅ Line 28 | ⚠️ Memo API 재사용 |
| PUT /api/memo/ | ✅ | ✅ Line 48 | ⚠️ Memo API 재사용 |
| DELETE /api/memo/{id} | ✅ | ✅ Line 89 | ⚠️ Memo API 재사용 |

**⚠️ 발견된 문제**:

Note 기능이 Memo API를 그대로 재사용하고 있음:
- Note는 별도 기능이지만 백엔드 API가 없음
- MemoApi를 직접 호출하여 Note로 사용 중
- 문서에는 Note 관련 API 명세가 없음

**💡 권장사항**:
- Note와 Memo를 구분할 필요가 있다면 백엔드 API 추가 필요
- 아니면 Note 기능을 Memo로 통합하는 것이 명확함

---

### 8️⃣ WrongNoteApi ❌ 불일치 (문서 누락)

**파일**: [lib/features/wrong_note/data/wrong_note_api.dart](../lib/features/wrong_note/data/wrong_note_api.dart)

| 엔드포인트 | 문서 | 코드 | 상태 |
|-----------|------|------|------|
| GET /api/wrong_note/mypage | ❌ 없음 | ✅ Line 21 | ❌ 문서 누락 |
| POST /api/wrong_note/submit | ❌ 없음 | ✅ Line 37 | ❌ 문서 누락 |
| PATCH /api/wrong_note/{id}/retry | ❌ 없음 | ✅ Line 49 | ❌ 문서 누락 |
| POST /api/wrong_note/single | ❌ 없음 | ✅ Line 67 | ❌ 문서 누락 |
| DELETE /api/wrong_note/{id} | ❌ 없음 | ✅ Line 86 | ❌ 문서 누락 |

**❌ 발견된 문제**:

API_DOCUMENTATION.md에 오답노트 API가 **전혀 문서화되지 않음**

**실제 구현된 API**:
```dart
// 1. 오답노트 조회
GET /api/wrong_note/mypage?chapter_id={id}

// 2. 퀴즈 결과 제출 (다중)
POST /api/wrong_note/submit
{ chapterId, wrongItems: [...] }

// 3. 재시도 표시
PATCH /api/wrong_note/{quizId}/retry

// 4. 단일 퀴즈 제출
POST /api/wrong_note/single
{ chapterId, quizId, selectedOption }

// 5. 오답노트 삭제
DELETE /api/wrong_note/{quizId}
```

**💡 권장사항**:
- Swagger 문서에 오답노트 API 추가 필요
- 백엔드 팀에 문서화 요청

---

### 9️⃣ LearningProgressApi ❌ 불일치 (문서 누락)

**파일**: [lib/features/learning/data/source/learning_progress_api.dart](../lib/features/learning/data/source/learning_progress_api.dart)

| 엔드포인트 | 문서 | 코드 | 상태 |
|-----------|------|------|------|
| GET /api/user/progress | ❌ 없음 | ✅ Line 11 | ❌ 문서 누락 |
| POST /api/user/progress | ❌ 없음 | ✅ Line 22 | ❌ 문서 누락 |
| POST /api/user/progress/chapter/{id}/complete | ❌ 없음 | ✅ Line 33 | ❌ 문서 누락 |
| POST /api/user/progress/quiz/{id}/complete | ❌ 없음 | ✅ Line 38 | ❌ 문서 누락 |
| DELETE /api/user/progress | ❌ 없음 | ✅ Line 43 | ❌ 문서 누락 |

**❌ 발견된 문제**:

학습 진도 관련 API가 **전혀 문서화되지 않음**

**실제 구현된 API**:
```dart
// 1. 진도 조회
GET /api/user/progress

// 2. 진도 저장/업데이트
POST /api/user/progress
{ lastChapterId, lastStep, completedChapters, completedQuizzes, lastStudyDate }

// 3. 챕터 완료
POST /api/user/progress/chapter/{chapterId}/complete

// 4. 퀴즈 완료
POST /api/user/progress/quiz/{chapterId}/complete

// 5. 진도 초기화
DELETE /api/user/progress
```

**💡 권장사항**:
- Swagger 문서에 학습 진도 API 추가 필요
- 백엔드 팀에 문서화 요청

---

### 🔟 AptitudeApi ⚠️ 부분 일치

**파일**: [lib/features/aptitude/data/source/aptitude_api.dart](../lib/features/aptitude/data/source/aptitude_api.dart)

| 엔드포인트 | 문서 | 코드 | 상태 |
|-----------|------|------|------|
| GET /api/investment_profile/test | ✅ | ✅ Line 16 | ✅ 일치 |
| POST /api/investment_profile/result | ✅ | ✅ Line 31 | ✅ 일치 |
| GET /api/investment_profile/result | ✅ | ✅ Line 40 | ✅ 일치 |
| PUT /api/investment_profile/result | ✅ | ✅ Line 47 | ✅ 일치 |
| GET /api/investment_profile/masters | ✅ | ✅ Line 57 | ✅ 일치 |
| GET /api/aptitude-test/results/details/{type} | ❌ 없음 | ⚠️ Line 66 | ⚠️ 미확인 API |

**⚠️ 발견된 문제**:

**aptitude_api.dart:64-68**:
```dart
// ✅ [추가] 특정 타입의 상세 결과 조회 API (가정)
Future<AptitudeResultDto> getResultByType(String typeCode) async {
  // 백엔드에 이런 API가 있다고 가정합니다.
  final response = await _dio.get('/api/aptitude-test/results/details/$typeCode');
  return AptitudeResultDto.fromJson(response.data);
}
```

**💡 권장사항**:
- 이 API가 실제로 존재하는지 확인 필요
- 주석에 "가정"이라고 명시되어 있음
- 사용하지 않는다면 제거, 사용한다면 문서화 필요

---

## 🔍 인증 헤더 사용 패턴 분석

### ✅ 정확한 헤더 사용 (8개 API)

모든 주요 API 클라이언트가 **정확한 인증 헤더**를 사용하고 있습니다:

```dart
Future<Options> _getAuthOptions() async {
  final access = await TokenStorage.accessToken;
  final refresh = await TokenStorage.refreshToken;

  return Options(headers: {
    if (access != null && access.isNotEmpty)
      'Authorization': 'Bearer $access',
    if (refresh != null && refresh.isNotEmpty)
      'x-refresh-token': refresh,
  });
}
```

**적용된 API**: AuthApi, EducationApi, InvestmentProfileApi, AttendanceApi, MemoApi, NoteApi

### ❌ 인증 헤더 누락 (2개 API)

- **WrongNoteApi**: 인증 헤더를 직접 추가하지 않음 (Dio Interceptor에 의존)
- **LearningProgressApi**: 인증 헤더를 직접 추가하지 않음 (Dio Interceptor에 의존)

**현재 상황**:
- Dio Interceptor ([dio_interceptor.dart:14-24](../lib/app/core/services/dio_interceptor.dart#L14-L24))가 자동으로 헤더 추가
- 따라서 실제로는 문제 없음 ✅
- 하지만 일관성을 위해 다른 API처럼 `_getAuthOptions()` 패턴 사용 권장

---

## 🚨 발견된 주요 문제점

### 1. API 문서 누락 (Critical) 🔴

**문제**:
- 오답노트 API (5개 엔드포인트) - 문서 전혀 없음
- 학습 진도 API (5개 엔드포인트) - 문서 전혀 없음

**영향**:
- 프론트엔드 개발자가 API 스펙을 모르고 작업해야 함
- API 변경 시 통지받을 수 없음
- 테스트 및 디버깅이 어려움

**해결방안**:
```bash
# 백엔드 팀에게 요청
1. Swagger 문서에 다음 API 추가:
   - /api/wrong_note/* (5개 엔드포인트)
   - /api/user/progress/* (5개 엔드포인트)

2. 각 API의 요청/응답 형식 문서화
3. 에러 코드 및 메시지 정의
```

### 2. 필드명 불일치 (Warning) ⚠️

**문제**:
- QuizApi의 `quiz/complete` 엔드포인트
- 문서: `chapterId` (camelCase)
- 코드: `chapter_id` (snake_case)

**해결방안**:
```bash
# 백엔드와 확인 필요
1. 실제 백엔드가 어느 쪽을 받는지 테스트
2. 문서와 백엔드 중 하나를 수정하여 통일
3. 프론트엔드 코드 수정
```

### 3. Note API 중복 (Info) ℹ️

**문제**:
- Note와 Memo가 같은 API를 사용

**해결방안**:
```bash
# 다음 중 하나 선택
Option 1: Note와 Memo를 완전히 통합
Option 2: Note 전용 API 엔드포인트 추가
Option 3: 현상 유지 (기능적으로는 문제 없음)
```

---

## 📋 테스트 계획

### Real API 모드 테스트 순서

ApiLogger 시스템이 구현되었으므로, 다음 순서로 테스트:

#### Phase 1: 인증 흐름 테스트
```bash
1. 회원가입 (POST /api/user/signup)
   → 로그에서 요청/응답 확인

2. 로그인 (POST /api/user/login)
   → 토큰 저장 확인

3. 프로필 수정 (POST /api/user/profile)
   → 인증 헤더 확인
```

#### Phase 2: 학습 흐름 테스트
```bash
4. 챕터 목록 조회 (GET /api/chapters)
   → 응답 데이터 구조 확인

5. 이론 진입 (POST /api/theory/enter)
   → chapter_id 전송 확인

6. 이론 진도 갱신 (PATCH /api/theory/progress)
   → current_page 업데이트 확인

7. 이론 완료 (PATCH /api/theory/complete)
   → 성공 응답 확인
```

#### Phase 3: 퀴즈 흐름 테스트
```bash
8. 퀴즈 진입 (POST /api/quiz/enter)
   → 퀴즈 목록 응답 확인

9. 퀴즈 진도 갱신 (PATCH /api/quiz/progress)
   → current_quiz_id 업데이트 확인

10. 퀴즈 완료 (POST /api/quiz/complete)
    → ⚠️ chapter_id vs chapterId 필드명 확인
    → 점수 결과 응답 확인
```

#### Phase 4: 부가 기능 테스트
```bash
11. 투자성향 검사 (GET /api/investment_profile/test)
    → ?version=v1.1 쿼리 파라미터 확인

12. 투자성향 결과 저장 (POST /api/investment_profile/result)
    → 거장 매칭 결과 확인

13. 출석 체크 (POST /api/attendance/quiz/submit)
    → { isPresent: true } 형식 확인

14. 메모 저장 (PUT /api/memo/)
    → trailing slash 확인
```

#### Phase 5: 문서 누락 API 테스트
```bash
15. 오답노트 조회 (GET /api/wrong_note/mypage)
    → 실제 동작 여부 확인

16. 학습 진도 조회 (GET /api/user/progress)
    → 실제 동작 여부 확인
```

### 테스트 실행 방법

```bash
# 1. Real API 모드로 전환
# lib/main.dart에서 확인:
const useMock = String.fromEnvironment('USE_MOCK', defaultValue: 'false') == 'true';
# 현재 기본값이 'false'이므로 이미 Real API 모드!

# 2. .env 파일 확인
cat .env
# API_BASE_URL이 올바른지 확인

# 3. 앱 실행
flutter run

# 4. 콘솔 로그 확인
# ApiLogger가 모든 API 통신을 다음 형식으로 출력:
#
# ╔═══════════════════════════════════════════════════════════
# ║ 🚀 API REQUEST
# ╠═══════════════════════════════════════════════════════════
# ║ Method: POST
# ║ URL: http://158.180.84.121:3000/api/user/login
# ║ Request Body:
# ║   {
# ║     "email": "user@example.com",
# ║     "password": "****"
# ║   }
# ╚═══════════════════════════════════════════════════════════
#
# ╔═══════════════════════════════════════════════════════════
# ║ ✅ API RESPONSE SUCCESS
# ╠═══════════════════════════════════════════════════════════
# ║ Method: POST
# ║ URL: http://158.180.84.121:3000/api/user/login
# ║ Status: 200
# ║ Response Data:
# ║   {
# ║     "message": "로그인 성공",
# ║     "user": { ... },
# ║     "token": "...",
# ║     "refreshToken": "..."
# ║   }
# ╚═══════════════════════════════════════════════════════════
```

---

## 🎯 다음 액션 아이템

### 즉시 조치 필요 (P0)
- [ ] **오답노트 API 문서화** - 백엔드 팀 요청
- [ ] **학습 진도 API 문서화** - 백엔드 팀 요청
- [ ] **QuizApi chapter_id 필드명 통일** - 백엔드와 협의

### 권장 조치 (P1)
- [ ] Real API 모드로 전체 테스트 실행 (Phase 1~5)
- [ ] 로그 결과를 기반으로 문서 업데이트
- [ ] WrongNoteApi, LearningProgressApi에 `_getAuthOptions()` 패턴 적용
- [ ] AptitudeApi의 `/api/aptitude-test/results/details/{type}` 실제 존재 여부 확인

### 개선 제안 (P2)
- [ ] Note와 Memo 기능 통합 또는 분리 결정
- [ ] API 에러 응답 형식 통일
- [ ] 모든 API에 요청/응답 DTO 클래스 추가 (타입 안정성)

---

## 📞 문의

API 통신 분석 관련 문의나 개선 사항은 개발팀에게 연락해주세요.

**문서 작성**: 2025-11-21
**분석 도구**: ApiLogger v1.0.0
**다음 업데이트**: Real API 테스트 후 결과 반영 예정
