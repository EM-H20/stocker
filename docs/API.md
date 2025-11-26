# Stocker API 명세서

> Flutter 앱에서 사용하는 백엔드 API 목록 및 명세

---

## 목차
1. [공통 사항](#공통-사항)
2. [인증 API](#인증-api)
3. [교육 API](#교육-api)
4. [출석 API](#출석-api)
5. [퀴즈 API](#퀴즈-api)
6. [성향 분석 API](#성향-분석-api)
7. [오답노트 API](#오답노트-api)
8. [노트 API](#노트-api)
9. [학습 진도 API](#학습-진도-api)

---

## 공통 사항

### Base URL
```
개발: http://localhost:3000 (또는 .env의 API_BASE_URL)
운영: https://api.stocker.app (예시)
```

### 인증 헤더
대부분의 API는 인증이 필요하며 다음 헤더를 포함해야 합니다:
```
Authorization: Bearer {access_token}
x-refresh-token: {refresh_token}
```

### 공통 응답 형식
```json
{
  "success": true,
  "data": { ... },
  "message": "성공"
}
```

### 에러 응답
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "에러 메시지"
  }
}
```

### HTTP 상태 코드
| 코드 | 설명 |
|------|------|
| 200 | 성공 |
| 201 | 생성 성공 |
| 400 | 잘못된 요청 |
| 401 | 인증 필요 |
| 403 | 권한 없음 |
| 404 | 리소스 없음 |
| 500 | 서버 오류 |

---

## 인증 API

### 1. 로그인
사용자 로그인 및 토큰 발급

**Endpoint**: `POST /api/user/login`

**Request Body**:
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response** (200 OK):
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIs...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
  "userId": 1,
  "email": "user@example.com",
  "nickname": "홍길동"
}
```

**Error Cases**:
- 400: 이메일/비밀번호 누락
- 401: 이메일 또는 비밀번호 불일치
- 404: 사용자 없음

---

### 2. 회원가입
새 사용자 계정 생성

**Endpoint**: `POST /api/user/signup`

**Request Body**:
```json
{
  "name": "홍길동",
  "email": "user@example.com",
  "password": "Password123!"
}
```

**Response** (201 Created):
```json
{
  "message": "회원가입이 완료되었습니다.",
  "userId": 1
}
```

**Error Cases**:
- 400: 필수 필드 누락 또는 유효성 검사 실패
- 409: 이미 존재하는 이메일

---

### 3. 로그아웃
세션 종료 및 토큰 무효화

**Endpoint**: `POST /api/user/logout`

**Headers**:
```
Authorization: Bearer {access_token}
x-refresh-token: {refresh_token}
```

**Request Body**:
```json
{
  "email": "user@example.com"
}
```

**Response** (200 OK):
```json
{
  "message": "로그아웃되었습니다."
}
```

---

### 4. 프로필 수정
사용자 정보 업데이트

**Endpoint**: `POST /api/user/profile`

**Headers**:
```
Authorization: Bearer {access_token}
x-refresh-token: {refresh_token}
```

**Request Body**:
```json
{
  "nickname": "새닉네임"
}
```

**Response** (200 OK):
```json
{
  "message": "프로필이 수정되었습니다.",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "nickname": "새닉네임"
  }
}
```

---

## 교육 API

### 1. 챕터 목록 조회
모든 학습 챕터 목록 및 진행 상태 조회

**Endpoint**: `GET /api/chapters`

**Headers**:
```
Authorization: Bearer {access_token}
x-refresh-token: {refresh_token}
```

**Response** (200 OK):
```json
[
  {
    "chapter_id": 1,
    "title": "주식 기초",
    "description": "주식 투자의 기본 개념을 배웁니다.",
    "total_theories": 5,
    "completed_theories": 2,
    "progress_rate": 0.4,
    "is_completed": false
  },
  {
    "chapter_id": 2,
    "title": "기술적 분석",
    "description": "차트 분석 방법을 학습합니다.",
    "total_theories": 8,
    "completed_theories": 0,
    "progress_rate": 0.0,
    "is_completed": false
  }
]
```

---

### 2. 이론 진입
특정 챕터의 이론 학습 시작

**Endpoint**: `POST /api/theory/enter`

**Request Body**:
```json
{
  "chapter_id": 1
}
```

**Response** (200 OK):
```json
{
  "chapter_id": 1,
  "chapter_title": "주식 기초",
  "theories": [
    {
      "theory_id": 1,
      "title": "주식이란?",
      "content": "주식은 회사의 소유권을 나타내는...",
      "page_number": 1,
      "is_completed": true
    },
    {
      "theory_id": 2,
      "title": "주식 시장의 구조",
      "content": "주식 시장은 크게...",
      "page_number": 2,
      "is_completed": false
    }
  ],
  "current_page": 1,
  "total_pages": 5
}
```

---

### 3. 이론 진도 갱신
현재 학습 중인 페이지 저장

**Endpoint**: `PATCH /api/theory/progress`

**Request Body**:
```json
{
  "chapter_id": 1,
  "current_page": 3
}
```

**Response** (200 OK):
```json
{
  "message": "진도가 저장되었습니다."
}
```

---

### 4. 이론 완료 처리
챕터 이론 학습 완료 표시

**Endpoint**: `PATCH /api/theory/complete`

**Request Body**:
```json
{
  "chapter_id": 1
}
```

**Response** (200 OK):
```json
{
  "message": "이론 학습이 완료되었습니다.",
  "chapter_id": 1,
  "is_completed": true
}
```

---

## 출석 API

### 1. 출석 이력 조회
당월 출석 현황 조회

**Endpoint**: `GET /api/attendance/history`

**Headers**:
```
Authorization: Bearer {access_token}
x-refresh-token: {refresh_token}
```

**Response** (200 OK):
```json
{
  "year": 2024,
  "month": 1,
  "attendance_days": [
    {"date": "2024-01-01", "is_present": true},
    {"date": "2024-01-02", "is_present": true},
    {"date": "2024-01-03", "is_present": false}
  ],
  "total_attendance": 15,
  "streak": 5,
  "monthly_attendance": 10
}
```

---

### 2. 출석 퀴즈 시작
오늘의 출석 퀴즈 문제 조회

**Endpoint**: `GET /api/attendance/quiz/start`

**Response** (200 OK):
```json
{
  "quiz_id": 1,
  "questions": [
    {
      "id": 1,
      "question": "주식은 회사의 소유권을 나타낸다.",
      "answer": true
    },
    {
      "id": 2,
      "question": "코스피는 한국의 대표적인 주가지수이다.",
      "answer": true
    },
    {
      "id": 3,
      "question": "채권은 주식보다 일반적으로 위험하다.",
      "answer": false
    }
  ]
}
```

---

### 3. 출석 제출
출석 퀴즈 답안 제출

**Endpoint**: `POST /api/attendance/quiz/submit`

**Request Body**:
```json
{
  "isPresent": true
}
```

**Response** (200 OK):
```json
{
  "message": "출석이 완료되었습니다.",
  "date": "2024-01-15",
  "streak": 6
}
```

---

## 퀴즈 API

### 1. 퀴즈 진입
챕터 퀴즈 시작 및 문제 조회

**Endpoint**: `POST /api/quiz/enter`

**Request Body**:
```json
{
  "chapter_id": 1
}
```

**Response** (200 OK):
```json
{
  "chapter_id": 1,
  "chapter_title": "주식 기초",
  "quizzes": [
    {
      "quiz_id": 1,
      "question": "주식은 회사의 소유권을 나타낸다.",
      "options": ["O", "X"],
      "correct_answer": 0
    },
    {
      "quiz_id": 2,
      "question": "PER은 주가수익비율을 의미한다.",
      "options": ["O", "X"],
      "correct_answer": 0
    }
  ],
  "total_quizzes": 10,
  "current_quiz_id": 1
}
```

---

### 2. 퀴즈 진도 업데이트
현재 풀고 있는 퀴즈 번호 저장

**Endpoint**: `PATCH /api/quiz/progress`

**Request Body**:
```json
{
  "chapter_id": 1,
  "current_quiz_id": 5
}
```

**Response** (200 OK):
```json
{
  "message": "퀴즈 진도가 저장되었습니다."
}
```

---

### 3. 퀴즈 완료
퀴즈 답안 제출 및 결과 확인

**Endpoint**: `POST /api/quiz/complete`

**Request Body**:
```json
{
  "chapter_id": 1,
  "answers": [
    {"quiz_id": 1, "selected_option": 0},
    {"quiz_id": 2, "selected_option": 1},
    {"quiz_id": 3, "selected_option": 0}
  ]
}
```

**Response** (200 OK):
```json
{
  "chapter_id": 1,
  "total_questions": 10,
  "correct_count": 8,
  "score": 80.0,
  "wrong_quiz_ids": [2, 5],
  "results": [
    {
      "quiz_id": 1,
      "is_correct": true,
      "correct_answer": 0,
      "selected_answer": 0,
      "explanation": "주식은 회사의 소유권을 나누어 놓은 것입니다."
    },
    {
      "quiz_id": 2,
      "is_correct": false,
      "correct_answer": 0,
      "selected_answer": 1,
      "explanation": "PER은 Price Earning Ratio의 약자로..."
    }
  ]
}
```

---

## 성향 분석 API

### 1. 검사지 조회
성향 분석 질문 목록 조회

**Endpoint**: `GET /api/investment_profile/test`

**Response** (200 OK):
```json
{
  "version": "1.0",
  "questions": [
    {
      "question_id": 1,
      "question": "투자 시 가장 중요하게 생각하는 것은?",
      "options": [
        {"value": 1, "text": "원금 보존"},
        {"value": 2, "text": "안정적인 수익"},
        {"value": 3, "text": "적당한 위험과 수익"},
        {"value": 4, "text": "높은 수익"},
        {"value": 5, "text": "최대 수익"}
      ]
    },
    {
      "question_id": 2,
      "question": "투자 손실이 발생했을 때 어떻게 대응하시겠습니까?",
      "options": [
        {"value": 1, "text": "즉시 손절"},
        {"value": 2, "text": "일정 기간 관망"},
        {"value": 3, "text": "추가 매수 고려"},
        {"value": 4, "text": "공격적 추가 매수"}
      ]
    }
  ]
}
```

---

### 2. 결과 저장
성향 분석 결과 최초 저장

**Endpoint**: `POST /api/investment_profile/result`

**Request Body**:
```json
{
  "answers": [
    {"question_id": 1, "selected_value": 3},
    {"question_id": 2, "selected_value": 2},
    {"question_id": 3, "selected_value": 4}
  ]
}
```

**Response** (200 OK):
```json
{
  "type_code": "BALANCED",
  "type_name": "균형투자형",
  "description": "위험과 수익의 균형을 중시하는 투자자입니다.",
  "scores": {
    "stability": 60,
    "growth": 65,
    "risk_tolerance": 55,
    "activity": 50,
    "diversification": 70
  },
  "recommended_portfolio": [
    {"asset": "국내주식", "ratio": 40},
    {"asset": "해외주식", "ratio": 20},
    {"asset": "채권", "ratio": 30},
    {"asset": "예금", "ratio": 10}
  ]
}
```

---

### 3. 결과 조회
저장된 성향 분석 결과 조회

**Endpoint**: `GET /api/investment_profile/result`

**Response**: 위 결과 저장과 동일한 형식

---

### 4. 재검사 갱신
기존 결과를 새 결과로 업데이트

**Endpoint**: `PUT /api/investment_profile/result`

**Request Body**: 결과 저장과 동일
**Response**: 결과 저장과 동일

---

### 5. 모든 성향 목록 조회
5가지 투자 성향 유형 목록

**Endpoint**: `GET /api/investment_profile/masters`

**Response** (200 OK):
```json
[
  {
    "type_code": "CONSERVATIVE",
    "type_name": "안정추구형",
    "short_description": "원금 보존을 최우선으로",
    "icon": "shield",
    "color": "#4CAF50"
  },
  {
    "type_code": "STABLE_GROWTH",
    "type_name": "안정성장형",
    "short_description": "안정 속에서 성장을",
    "icon": "trending_up",
    "color": "#2196F3"
  },
  {
    "type_code": "BALANCED",
    "type_name": "균형투자형",
    "short_description": "위험과 수익의 균형",
    "icon": "balance",
    "color": "#FF9800"
  },
  {
    "type_code": "GROWTH",
    "type_name": "성장추구형",
    "short_description": "높은 성장을 추구",
    "icon": "rocket",
    "color": "#9C27B0"
  },
  {
    "type_code": "AGGRESSIVE",
    "type_name": "적극투자형",
    "short_description": "공격적인 고수익 추구",
    "icon": "flash",
    "color": "#F44336"
  }
]
```

---

## 오답노트 API

### 1. 오답 목록 조회
틀린 문제 목록 조회 (챕터별 필터 가능)

**Endpoint**: `GET /api/wrong-notes`

**Query Parameters**:
- `chapter_id` (optional): 특정 챕터 필터

**Response** (200 OK):
```json
{
  "wrong_notes": [
    {
      "id": 1,
      "quiz_id": 5,
      "chapter_id": 1,
      "chapter_title": "주식 기초",
      "question": "PBR은 주가순자산비율이다.",
      "correct_answer": true,
      "user_answer": false,
      "explanation": "PBR은 Price Book-value Ratio의 약자로...",
      "wrong_date": "2024-01-15T10:30:00Z"
    }
  ],
  "total_count": 15,
  "chapter_stats": {
    "1": 5,
    "2": 3,
    "3": 7
  }
}
```

---

### 2. 오답 삭제
학습 완료된 오답 삭제

**Endpoint**: `DELETE /api/wrong-notes/{wrong_note_id}`

**Response** (200 OK):
```json
{
  "message": "오답이 삭제되었습니다."
}
```

---

## 노트 API

### 1. 노트 목록 조회
사용자의 노트 목록

**Endpoint**: `GET /api/notes`

**Response** (200 OK):
```json
{
  "notes": [
    {
      "id": 1,
      "title": "주식 기초 정리",
      "preview": "주식이란 회사의 소유권을...",
      "created_at": "2024-01-10T09:00:00Z",
      "updated_at": "2024-01-15T14:30:00Z"
    }
  ],
  "total_count": 5
}
```

---

### 2. 노트 상세 조회
특정 노트 내용 조회

**Endpoint**: `GET /api/notes/{note_id}`

**Response** (200 OK):
```json
{
  "id": 1,
  "title": "주식 기초 정리",
  "content": "{\"ops\":[{\"insert\":\"주식이란...\\n\"}]}",
  "created_at": "2024-01-10T09:00:00Z",
  "updated_at": "2024-01-15T14:30:00Z"
}
```

---

### 3. 노트 생성
새 노트 작성

**Endpoint**: `POST /api/notes`

**Request Body**:
```json
{
  "title": "새 노트",
  "content": "{\"ops\":[{\"insert\":\"내용...\\n\"}]}"
}
```

**Response** (201 Created):
```json
{
  "id": 10,
  "message": "노트가 생성되었습니다."
}
```

---

### 4. 노트 수정
기존 노트 내용 수정

**Endpoint**: `PUT /api/notes/{note_id}`

**Request Body**:
```json
{
  "title": "수정된 제목",
  "content": "{\"ops\":[{\"insert\":\"수정된 내용...\\n\"}]}"
}
```

**Response** (200 OK):
```json
{
  "message": "노트가 수정되었습니다."
}
```

---

### 5. 노트 삭제
노트 삭제

**Endpoint**: `DELETE /api/notes/{note_id}`

**Response** (200 OK):
```json
{
  "message": "노트가 삭제되었습니다."
}
```

---

## 학습 진도 API

### 1. 전체 학습 진도 조회
사용자의 전체 학습 현황 요약

**Endpoint**: `GET /api/learning/progress`

**Response** (200 OK):
```json
{
  "total_chapters": 10,
  "completed_chapters": 3,
  "total_theories": 50,
  "completed_theories": 15,
  "total_quizzes": 100,
  "completed_quizzes": 30,
  "overall_progress": 0.30,
  "quiz_accuracy": 0.85,
  "last_activity": "2024-01-15T18:00:00Z"
}
```

---

## 에러 코드 참조

| 코드 | 설명 |
|------|------|
| `AUTH_001` | 인증 토큰 만료 |
| `AUTH_002` | 유효하지 않은 토큰 |
| `AUTH_003` | 권한 없음 |
| `USER_001` | 사용자를 찾을 수 없음 |
| `USER_002` | 이미 존재하는 이메일 |
| `CHAPTER_001` | 챕터를 찾을 수 없음 |
| `QUIZ_001` | 퀴즈를 찾을 수 없음 |
| `QUIZ_002` | 이미 완료된 퀴즈 |
| `ATTENDANCE_001` | 오늘 이미 출석 완료 |

---

## 변경 이력

| 버전 | 날짜 | 변경 내용 |
|------|------|----------|
| v1.0.0 | 2024-01 | 최초 작성 |
| v1.0.1 | 2024-01 | 성향 분석 API 추가 |
