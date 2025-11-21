# Stock Edu API Documentation

> 주식 교육 플랫폼 백엔드 API 공식 문서
> Base URL: `http://158.180.84.121:3000/api`
> Local Dev: `http://localhost:8080/api`

## 📋 목차

- [인증 (Authentication)](#인증-authentication)
- [프로필 관리](#프로필-관리)
- [챕터 관리](#챕터-관리)
- [이론 학습](#이론-학습)
- [퀴즈](#퀴즈)
- [오답노트](#오답노트)
- [출석 체크](#출석-체크)
- [투자 성향 테스트](#투자-성향-테스트)
- [메모](#메모)
- [기타](#기타)

---

## 🔐 인증 (Authentication)

모든 인증 API는 JWT 토큰 기반으로 동작합니다.

### 회원가입

**POST** `/user/signup`

새로운 사용자를 등록합니다.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "1234abcd",
  "nickname": "주환",
  "age": 28,              // 선택
  "occupation": "개발자",  // 선택
  "provider": "local",     // 선택
  "profile_image_url": "https://example.com/profile.png"  // 선택
}
```

**Response (201 Created):**
```json
{
  "message": "회원가입 성공",
  "userId": 1
}
```

**Error Responses:**
- `400 Bad Request`: 이메일 중복, 유효하지 않은 입력값

---

### 로그인

**POST** `/user/login`

이메일과 비밀번호로 로그인하여 JWT 토큰을 발급받습니다.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "1234abcd"
}
```

**Response (200 OK):**
```json
{
  "message": "로그인 성공",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "nickname": "주환",
    "access_token": "eyJhbGciOiJIUzI1NiIsInR...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR..."
  }
}
```

**Error Responses:**
- `401 Unauthorized`: 잘못된 이메일 또는 비밀번호

**Flutter 사용 예시:**
```dart
// lib/features/auth/data/api/auth_api_client.dart
final response = await dio.post(
  '/user/login',
  data: {'email': email, 'password': password},
);

final accessToken = response.data['user']['access_token'];
final refreshToken = response.data['user']['refresh_token'];

// 토큰 저장
await secureStorage.write(key: 'access_token', value: accessToken);
await secureStorage.write(key: 'refresh_token', value: refreshToken);
```

---

### 로그아웃

**POST** `/user/logout`

🔒 **인증 필요** (Bearer Token + Refresh Token)

**Headers:**
```
Authorization: Bearer <access_token>
x-refresh-token: <refresh_token>
```

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response (200 OK):**
```json
{
  "message": "로그아웃 성공"
}
```

---

## 👤 프로필 관리

### 프로필 수정

**POST** `/user/profile`

🔒 **인증 필요**

사용자 프로필 정보를 업데이트합니다.

**Request Body:**
```json
{
  "nickname": "주환짱",
  "profile_image_url": "https://example.com/new-profile.png",
  "age": 29,
  "occupation": "백엔드 개발자"
}
```

**Response (200 OK):**
```json
{
  "message": "프로필이 업데이트되었습니다.",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "nickname": "주환짱",
    "profile_image_url": "https://example.com/new-profile.png",
    "provider": "local",
    "age": 29,
    "occupation": "백엔드 개발자",
    "created_date": "2025-08-17T12:34:56.000Z"
  }
}
```

---

## 📚 챕터 관리

### 챕터 목록 조회

**GET** `/chapters`

🔒 **인증 필요**

사용자가 접근 가능한 챕터 목록과 진행 상태를 조회합니다.

**Response (200 OK):**
```json
[
  {
    "chapter_id": 1,
    "title": "주식 기초 개념",
    "keyword": "기초",
    "is_theory_completed": 1,  // 0: 미완료, 1: 완료
    "is_quiz_completed": 0
  },
  {
    "chapter_id": 2,
    "title": "주식 차트 읽기",
    "keyword": "차트",
    "is_theory_completed": 0,
    "is_quiz_completed": 0
  }
]
```

**Flutter 사용 예시:**
```dart
// lib/features/education/data/api/education_api_client.dart
final response = await dio.get('/chapters');
final chapters = (response.data as List)
    .map((json) => ChapterModel.fromJson(json))
    .toList();
```

---

## 📖 이론 학습

### 이론 페이지 진입

**POST** `/theory/enter`

🔒 **인증 필요**

특정 챕터의 이론 페이지로 진입하여 학습 내용을 불러옵니다.

**Request Body:**
```json
{
  "chapter_id": 1
}
```

**Response (200 OK):**
```json
{
  "theory_pages": [
    {
      "page_no": 1,
      "id": 1,
      "Word": "주식이란?",
      "content": "주식은 기업의 소유권을 나타내는 증서입니다..."
    },
    {
      "page_no": 2,
      "id": 2,
      "Word": "주식의 종류",
      "content": "보통주와 우선주가 있습니다..."
    }
  ],
  "total_pages": 5,
  "current_page": 1
}
```

---

### 이론 진행 상황 업데이트

**PATCH** `/theory/progress`

🔒 **인증 필요**

사용자가 현재 보고 있는 이론 페이지를 업데이트합니다.

**Request Body:**
```json
{
  "chapter_id": 1,
  "current_theory_id": 2
}
```

**Response (200 OK):**
```json
{
  "message": "진행 상황 업데이트 완료"
}
```

---

### 이론 완료 처리

**PATCH** `/theory/complete`

🔒 **인증 필요**

특정 챕터의 이론 학습을 완료 처리합니다.

**Request Body:**
```json
{
  "chapter_id": 1
}
```

**Response (200 OK):**
```json
{
  "message": "이론 학습 완료"
}
```

---

## ✏️ 퀴즈

### 퀴즈 진입

**POST** `/quiz/enter`

🔒 **인증 필요**

특정 챕터의 퀴즈를 시작하고 문제 목록을 받아옵니다.

**Request Body:**
```json
{
  "chapter_id": 1
}
```

**Response (200 OK):**
```json
{
  "chapter_id": 1,
  "quiz_list": [
    {
      "id": 1,
      "question": "주식의 가격은 무엇에 의해 결정되나요?",
      "option_1": "회사의 크기",
      "option_2": "수요와 공급",
      "option_3": "정부의 결정",
      "option_4": "CEO의 결정",
      "hint": "시장 원리를 생각해보세요"
    },
    {
      "id": 2,
      "question": "배당금이란 무엇인가요?",
      "option_1": "주식 판매 수수료",
      "option_2": "회사 이익의 일부 분배금",
      "option_3": "주식 구매 비용",
      "option_4": "세금",
      "hint": null
    }
  ],
  "current_quiz_id": 1
}
```

**Flutter 사용 예시:**
```dart
// lib/features/quiz/data/api/quiz_api_client.dart
final response = await dio.post(
  '/quiz/enter',
  data: {'chapter_id': chapterId},
);

final quizList = (response.data['quiz_list'] as List)
    .map((json) => QuizModel.fromJson(json))
    .toList();
```

---

### 퀴즈 진행 상황 업데이트

**PATCH** `/quiz/progress`

🔒 **인증 필요**

현재 풀고 있는 퀴즈 번호를 업데이트합니다.

**Request Body:**
```json
{
  "chapter_id": 1,
  "current_quiz_id": 2
}
```

**Response (200 OK):**
```json
{
  "message": "퀴즈 진행 상황 업데이트 완료"
}
```

---

### 퀴즈 완료 및 채점

**POST** `/quiz/complete`

🔒 **인증 필요**

퀴즈 답안을 제출하고 채점 결과를 받습니다.

**Request Body:**
```json
{
  "chapter_id": 1,
  "answers": [
    {
      "quiz_id": 1,
      "answer": 2  // 1~4 중 선택
    },
    {
      "quiz_id": 2,
      "answer": 2
    },
    {
      "quiz_id": 3,
      "answer": 1
    }
  ]
}
```

**Response (200 OK):**
```json
{
  "total": 3,
  "correct": 2,
  "wrong": 1
}
```

**Flutter 사용 예시:**
```dart
// 퀴즈 답안 제출
final answers = quizAnswers.map((qa) => {
  'quiz_id': qa.quizId,
  'answer': qa.selectedAnswer,
}).toList();

final response = await dio.post(
  '/quiz/complete',
  data: {
    'chapter_id': chapterId,
    'answers': answers,
  },
);

final score = QuizScoreModel.fromJson(response.data);
```

---

## 📝 오답노트

### 오답노트 조회

**GET** `/wrong_note/mypage`

🔒 **인증 필요**

사용자의 오답 문제를 조회합니다. 챕터별 필터링 가능.

**Query Parameters:**
- `chapter_id` (optional): 특정 챕터의 오답만 조회

**Request Examples:**
```
GET /wrong_note/mypage                  // 전체 오답
GET /wrong_note/mypage?chapter_id=1     // 챕터 1의 오답만
```

**Response (200 OK):**
```json
[
  {
    "quiz_id": 5,
    "chapter_id": 1,
    "question": "주식의 가격은 무엇에 의해 결정되나요?",
    "options": [
      "회사의 크기",
      "수요와 공급",
      "정부의 결정",
      "CEO의 결정"
    ],
    "correct_option": 2,
    "selected_option": 1,
    "created_date": "2025-08-27"
  }
]
```

---

## ✅ 출석 체크

### 출석 퀴즈 시작

**GET** `/attendance/quiz/start`

🔒 **인증 필요**

랜덤 OX 퀴즈 3문제를 받아옵니다.

**Response (200 OK):**
```json
{
  "quizzes": [
    {
      "quizOX_id": 1,
      "question_OX": "주식은 항상 수익을 보장한다.",
      "is_correct": false
    },
    {
      "quizOX_id": 5,
      "question_OX": "배당금은 회사 이익의 일부를 주주에게 분배하는 것이다.",
      "is_correct": true
    },
    {
      "quizOX_id": 12,
      "question_OX": "주식 시장은 주말에도 운영된다.",
      "is_correct": false
    }
  ]
}
```

---

### 출석 제출

**POST** `/attendance/quiz/submit`

🔒 **인증 필요**

출석 여부를 제출합니다.

**Request Body:**
```json
{
  "isPresent": true
}
```

**Response (200 OK):**
```json
{
  "message": "출석 완료",
  "streak_days": 7,
  "total_attendance": 45
}
```

---

### 출석 기록 조회

**GET** `/attendance/history`

🔒 **인증 필요**

사용자의 당월 출석 기록을 조회합니다.

**Response (200 OK):**
```json
{
  "history": [
    {
      "date": "2025-08-01",
      "is_present": true
    },
    {
      "date": "2025-08-02",
      "is_present": true
    },
    {
      "date": "2025-08-05",
      "is_present": true
    }
  ],
  "total_days": 3,
  "streak_days": 2
}
```

---

## 🎯 투자 성향 테스트

### 투자 성향 질문 조회

**GET** `/investment_profile/test`

🔒 **인증 필요**

투자 성향 테스트 질문 목록을 가져옵니다.

**Query Parameters:**
- `version` (optional): 테스트 버전 (예: "v1.1")

**Response (200 OK):**
```json
{
  "version": "v1",
  "questions": [
    {
      "questionId": 1,
      "version": "v1",
      "globalNo": 1,
      "dimCode": "AP",
      "dimName": "공격성향",
      "leftLabel": "매우 아니다",
      "rightLabel": "매우 그렇다",
      "question": "나는 높은 수익을 위해 높은 위험을 감수할 수 있다.",
      "isReverse": false,
      "note": null
    },
    {
      "questionId": 2,
      "version": "v1",
      "globalNo": 2,
      "dimCode": "LT",
      "dimName": "장기투자",
      "leftLabel": "매우 아니다",
      "rightLabel": "매우 그렇다",
      "question": "나는 단기보다 장기 투자를 선호한다.",
      "isReverse": false,
      "note": "역코딩 문항"
    }
  ]
}
```

---

### 투자 성향 답변 제출 (최초)

**POST** `/investment_profile/result`

🔒 **인증 필요**

투자 성향 테스트 답변을 최초로 제출하고 결과를 저장합니다.

**Request Body:**
```json
{
  "answers": [
    {
      "globalNo": 1,
      "answer": 4
    },
    {
      "globalNo": 2,
      "answer": 3
    },
    {
      "globalNo": 3,
      "answer": 5
    }
  ]
}
```

**Response (200 OK):**
```json
{
  "profile_id": 1,
  "user_id": 1,
  "type_code": "AGGRESSIVE_GROWTH",
  "matched_master": [
    {
      "master_id": 1,
      "name": "워런 버핏",
      "bio": "가치 투자의 전설",
      "portfolio_summary": "장기 가치 투자 중심",
      "image_url": "https://example.com/buffett.jpg",
      "style": "가치 투자",
      "type_code": "VALUE_INVESTOR",
      "score": 85.5
    },
    {
      "master_id": 3,
      "name": "피터 린치",
      "bio": "성장주 투자의 대가",
      "portfolio_summary": "성장주 중심 포트폴리오",
      "image_url": "https://example.com/lynch.jpg",
      "style": "성장주 투자",
      "type_code": "GROWTH_INVESTOR",
      "score": 78.2
    }
  ]
}
```

---

### 투자 성향 결과 조회

**GET** `/investment_profile/result`

🔒 **인증 필요**

가장 최근 투자 성향 테스트 결과를 조회합니다.

**Response (200 OK):**
```json
{
  "profile_id": 1,
  "user_id": 1,
  "type_code": "AGGRESSIVE_GROWTH",
  "matched_master": [
    {
      "master_id": 1,
      "name": "워런 버핏",
      "bio": "가치 투자의 전설",
      "portfolio_summary": "장기 가치 투자 중심",
      "image_url": "https://example.com/buffett.jpg",
      "style": "가치 투자",
      "type_code": "VALUE_INVESTOR",
      "score": 85.5
    }
  ]
}
```

---

## 📌 메모

### 메모 전체 조회

**GET** `/memo/`

🔒 **인증 필요**

사용자의 모든 메모 목록을 조회합니다.

**Response (200 OK):**
```json
{
  "memos": [
    {
      "id": 1,
      "user_id": 1,
      "template_type": "STOCK_ANALYSIS",
      "content": {
        "company": "삼성전자",
        "price": 72000,
        "target_price": 85000,
        "reason": "반도체 시장 회복 기대"
      },
      "created_at": "2025-08-27T10:30:00.000Z"
    }
  ]
}
```

---

### 메모 저장

**POST** `/memo/`

🔒 **인증 필요**

새로운 메모를 저장합니다.

**Request Body:**
```json
{
  "template_type": "STOCK_ANALYSIS",
  "content": {
    "company": "삼성전자",
    "price": 72000,
    "target_price": 85000,
    "reason": "반도체 시장 회복 기대",
    "notes": "3분기 실적 확인 후 재검토"
  }
}
```

**Response (201 Created):**
```json
{
  "id": 1,
  "user_id": 1,
  "template_type": "STOCK_ANALYSIS",
  "content": {
    "company": "삼성전자",
    "price": 72000,
    "target_price": 85000,
    "reason": "반도체 시장 회복 기대",
    "notes": "3분기 실적 확인 후 재검토"
  },
  "created_at": "2025-08-27T10:30:00.000Z"
}
```

---

### 메모 수정

**PUT** `/memo/{id}`

🔒 **인증 필요**

특정 메모를 수정합니다.

**Request Body:**
```json
{
  "template_type": "STOCK_ANALYSIS",
  "content": {
    "company": "삼성전자",
    "price": 72000,
    "target_price": 90000,
    "reason": "반도체 시장 회복 기대 + AI 수요 증가",
    "notes": "목표가 상향 조정"
  }
}
```

**Response (200 OK):**
```json
{
  "id": 1,
  "user_id": 1,
  "template_type": "STOCK_ANALYSIS",
  "content": {
    "company": "삼성전자",
    "price": 72000,
    "target_price": 90000,
    "reason": "반도체 시장 회복 기대 + AI 수요 증가",
    "notes": "목표가 상향 조정"
  },
  "created_at": "2025-08-27T10:30:00.000Z"
}
```

---

### 메모 삭제

**DELETE** `/memo/{id}`

🔒 **인증 필요**

특정 메모를 삭제합니다.

**Response (200 OK):**
```json
{
  "message": "메모가 삭제되었습니다."
}
```

### 투자 성향 재검사 (결과 갱신)

**PUT** `/investment_profile/result`

🔒 **인증 필요**

투자 성향 테스트를 재수행하고 결과를 갱신합니다.

**Request Body:**
```json
{
  "answers": [
    {
      "globalNo": 1,
      "answer": 4
    },
    {
      "globalNo": 2,
      "answer": 3
    }
  ]
}
```

**Response (200 OK):**
```json
{
  "profile_id": 1,
  "user_id": 1,
  "type_code": "AGGRESSIVE_GROWTH",
  "matched_master": [
    {
      "master_id": 1,
      "name": "워런 버핏",
      "bio": "가치 투자의 전설",
      "portfolio_summary": "장기 가치 투자 중심",
      "image_url": "https://example.com/buffett.jpg",
      "style": "가치 투자",
      "type_code": "VALUE_INVESTOR",
      "score": 85.5
    }
  ]
}
```

---

### 모든 투자 거장 목록 조회

**GET** `/investment_profile/masters`

🔒 **인증 필요**

등록된 모든 투자 거장(성향 타입) 목록을 조회합니다.

**Response (200 OK):**
```json
[
  {
    "master_id": 1,
    "name": "워런 버핏",
    "bio": "가치 투자의 전설",
    "style": "가치 투자",
    "type_code": "VALUE_INVESTOR"
  },
  {
    "master_id": 2,
    "name": "벤자민 그레이엄",
    "bio": "가치 투자의 아버지",
    "style": "가치 투자",
    "type_code": "VALUE_INVESTOR"
  }
]
```

---

## 🔧 기타

### 헬스체크

**GET** `/health`

서버 상태를 확인합니다. 인증 불필요.

**Response (200 OK):**
```json
{
  "status": "ok",
  "timestamp": "2025-08-27T10:00:00.000Z"
}
```

---

## 🔐 인증 방식

### JWT Bearer Token

모든 인증이 필요한 API는 다음과 같은 헤더를 포함해야 합니다:

```
Authorization: Bearer <access_token>
x-refresh-token: <refresh_token>
```

### Flutter Dio Interceptor 예시

```dart
// lib/app/core/network/dio_client.dart
class DioClient {
  final Dio dio;
  final FlutterSecureStorage storage;

  DioClient(this.dio, this.storage) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await storage.read(key: 'access_token');
          final refreshToken = await storage.read(key: 'refresh_token');

          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          if (refreshToken != null) {
            options.headers['x-refresh-token'] = refreshToken;
          }

          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // 토큰 만료 - 재로그인 필요
            // 로그인 화면으로 이동
          }
          return handler.next(error);
        },
      ),
    );
  }
}
```

---

## 📱 Flutter 통합 가이드

### 1. API Client 설정

```dart
// lib/app/core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DioClient {
  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api',
        connectTimeout: Duration(seconds: 15),
        receiveTimeout: Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 로깅 인터셉터 (개발 환경)
    if (dotenv.env['DEBUG_MODE'] == 'true') {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }

    return dio;
  }
}
```

### 2. Repository 패턴 예시

```dart
// lib/features/education/domain/repositories/education_repository.dart
abstract class EducationRepository {
  Future<List<ChapterModel>> getChapters();
  Future<TheoryResponse> enterTheory(int chapterId);
  Future<void> updateTheoryProgress(int chapterId, int theoryId);
  Future<void> completeTheory(int chapterId);
}

// lib/features/education/data/repositories/education_repository_impl.dart
class EducationRepositoryImpl implements EducationRepository {
  final EducationApiClient apiClient;

  EducationRepositoryImpl(this.apiClient);

  @override
  Future<List<ChapterModel>> getChapters() async {
    try {
      final response = await apiClient.getChapters();
      return response;
    } catch (e) {
      throw Exception('챕터 목록 조회 실패: $e');
    }
  }

  @override
  Future<TheoryResponse> enterTheory(int chapterId) async {
    try {
      return await apiClient.enterTheory(chapterId);
    } catch (e) {
      throw Exception('이론 진입 실패: $e');
    }
  }
}
```

### 3. Provider 예시

```dart
// lib/features/education/presentation/education_provider.dart
class EducationProvider extends ChangeNotifier {
  final EducationRepository repository;

  List<ChapterModel> _chapters = [];
  bool _isLoading = false;
  String? _error;

  List<ChapterModel> get chapters => _chapters;
  bool get isLoading => _isLoading;
  String? get error => _error;

  EducationProvider(this.repository);

  Future<void> loadChapters() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _chapters = await repository.getChapters();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

---

## ⚠️ 주의사항

1. **토큰 관리**: Access Token과 Refresh Token을 모두 안전하게 저장하세요
2. **에러 핸들링**: 모든 API 호출에 대해 적절한 에러 처리를 구현하세요
3. **타임아웃**: 네트워크 타임아웃을 적절히 설정하세요 (권장: 15초)
4. **재시도 로직**: 네트워크 오류 시 재시도 로직을 구현하는 것이 좋습니다
5. **로그 보안**: 운영 환경에서는 민감한 정보(토큰, 비밀번호 등)를 로그에 남기지 마세요

---

## 📞 문의

API 관련 문의사항은 백엔드 팀에게 연락해주세요.

**Last Updated**: 2025-11-21
**API Version**: 1.0.0
**Swagger Documentation**: http://158.180.84.121:3000/api-docs/
