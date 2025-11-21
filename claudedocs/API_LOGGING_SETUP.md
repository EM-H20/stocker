# API 로깅 시스템 설정 완료 ✅

> **설정 완료일**: 2025-11-21
> **목적**: Real API 모드에서 모든 API 요청/응답을 상세하게 로깅

---

## 🎯 개요

Flutter 앱의 모든 API 통신을 **자동으로 상세 로깅**하는 시스템을 구축했습니다!

### ✨ 주요 기능

1. **자동 요청 로깅** - 모든 API 호출 시 요청 정보 자동 출력
2. **상세 응답 로깅** - 응답 데이터를 JSON 포맷으로 예쁘게 출력
3. **에러 상세 로깅** - 에러 발생 시 상세한 디버깅 정보 제공
4. **개발 모드 전용** - 운영 환경에서는 자동으로 비활성화

---

## 📁 추가된 파일

### 1. API Logger 유틸리티
**파일**: [lib/app/core/utils/api_logger.dart](../lib/app/core/utils/api_logger.dart)

```dart
class ApiLogger {
  // API 요청 로깅
  static void logRequest({
    required String method,
    required String url,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  });

  // API 응답 로깅 (성공)
  static void logResponse({
    required String method,
    required String url,
    required int statusCode,
    required dynamic data,
    Duration? duration,
  });

  // API 에러 로깅
  static void logError({
    required String method,
    required String url,
    required dynamic error,
  });
}
```

**기능**:
- ✅ JSON 데이터를 **예쁘게 들여쓰기**하여 출력
- ✅ 박스 형태로 **가독성 좋은** 로그 포맷
- ✅ HTTP 메서드, URL, Status Code, 응답 데이터 모두 출력
- ✅ 개발 모드에서만 동작 (`kDebugMode` 체크)

---

## 🔧 수정된 파일

### 1. Dio Interceptor 업데이트
**파일**: [lib/app/core/services/dio_interceptor.dart](../lib/app/core/services/dio_interceptor.dart)

#### 추가된 기능

**1) onRequest - 요청 로깅**
```dart
@override
void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
  // ... 기존 인증 헤더 추가 로직 ...

  // ✅ API 요청 로깅 추가
  ApiLogger.logRequest(
    method: options.method,
    url: '${options.baseUrl}${options.path}',
    data: options.data is Map<String, dynamic> ? options.data : null,
    queryParameters: options.queryParameters,
  );

  handler.next(options);
}
```

**2) onResponse - 응답 로깅 (NEW!)**
```dart
@override
void onResponse(Response response, ResponseInterceptorHandler handler) {
  // ✅ API 응답 로깅 추가
  ApiLogger.logResponse(
    method: response.requestOptions.method,
    url: '${response.requestOptions.baseUrl}${response.requestOptions.path}',
    statusCode: response.statusCode ?? 0,
    data: response.data,
  );

  handler.next(response);
}
```

**3) onError - 에러 로깅 개선**
```dart
@override
void onError(DioException err, ErrorInterceptorHandler handler) async {
  // ✅ API 에러 로깅 추가
  ApiLogger.logError(
    method: err.requestOptions.method,
    url: '${err.requestOptions.baseUrl}${err.requestOptions.path}',
    error: err,
  );

  // ... 기존 에러 처리 로직 ...
}
```

---

## 📊 로그 출력 예시

### ✅ 성공 요청/응답 로그

#### 1. 요청 로그
```
╔═══════════════════════════════════════════════════════════
║ 🚀 API REQUEST
╠═══════════════════════════════════════════════════════════
║ Method: POST
║ URL: http://158.180.84.121:3000/api/user/login
║ Request Body:
║   {
║     "email": "user@example.com",
║     "password": "****"
║   }
╚═══════════════════════════════════════════════════════════
```

#### 2. 응답 로그
```
╔═══════════════════════════════════════════════════════════
║ ✅ API RESPONSE SUCCESS
╠═══════════════════════════════════════════════════════════
║ Method: POST
║ URL: http://158.180.84.121:3000/api/user/login
║ Status: 200
║ Response Data:
║   {
║     "message": "로그인 성공",
║     "user": {
║       "id": 1,
║       "email": "user@example.com",
║       "nickname": "주환"
║     },
║     "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
║     "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
║   }
╚═══════════════════════════════════════════════════════════
```

### ❌ 에러 로그

```
╔═══════════════════════════════════════════════════════════
║ ❌ API ERROR
╠═══════════════════════════════════════════════════════════
║ Method: POST
║ URL: http://158.180.84.121:3000/api/quiz/complete
║ Error Type: DioExceptionType.badResponse
║ Message: Http status error [400]
║ Status Code: 400
║ Response Data:
║   {
║     "message": "잘못된 요청입니다",
║     "error": "INVALID_ANSWER_FORMAT"
║   }
║ Headers:
║   - content-type: application/json
║   - x-access-token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
╚═══════════════════════════════════════════════════════════
```

---

## 🚀 사용 방법

### 1. Real API 모드로 전환

**파일**: [lib/main.dart](../lib/main.dart)

```dart
// main.dart 파일 상단
const useMock = false;  // ✅ false로 설정하면 Real API 모드
```

또는 **환경 변수**로 실행:
```bash
flutter run --dart-define=USE_MOCK=false
```

### 2. 앱 실행

```bash
flutter run
```

### 3. 로그 확인

앱에서 API를 호출하면 **자동으로 상세 로그**가 콘솔에 출력됩니다!

**예시**:
1. 로그인 버튼 클릭 → `POST /api/user/login` 요청/응답 로그 출력
2. 챕터 목록 조회 → `GET /api/chapters` 요청/응답 로그 출력
3. 퀴즈 제출 → `POST /api/quiz/complete` 요청/응답 로그 출력

---

## 🔍 디버깅 활용 방법

### 1. API 응답 구조 확인
로그에서 **응답 JSON 구조**를 그대로 볼 수 있으므로:
- DTO 모델이 제대로 파싱되는지 확인
- 누락된 필드가 있는지 확인
- 응답 형식이 API 문서와 일치하는지 확인

### 2. 에러 원인 파악
에러 로그에서:
- **정확한 에러 메시지** 확인
- **HTTP 상태 코드** 확인
- **백엔드 응답 데이터** 확인
- **어떤 API 호출**에서 에러가 발생했는지 확인

### 3. 인증 문제 추적
- Authorization 헤더가 제대로 추가되는지 확인
- x-refresh-token이 전송되는지 확인
- 토큰 갱신이 제대로 동작하는지 확인

---

## 📋 체크리스트

### ✅ 완료된 작업

- [x] ApiLogger 유틸리티 클래스 생성
- [x] Dio Interceptor에 통합 로깅 추가
- [x] onRequest 로깅 구현
- [x] onResponse 로깅 구현
- [x] onError 로깅 개선
- [x] JSON 포맷팅 기능 추가
- [x] 개발 모드 전용 활성화 (`kDebugMode` 체크)

### 🧪 테스트 필요

- [ ] Real API 모드로 로그인 테스트
- [ ] 챕터 목록 조회 테스트
- [ ] 이론 학습 API 테스트
- [ ] 퀴즈 API 테스트
- [ ] 출석 체크 API 테스트
- [ ] 투자 성향 테스트 API 테스트
- [ ] 에러 케이스 테스트 (잘못된 비밀번호, 네트워크 오류 등)

---

## 🎯 기대 효과

### 1. 빠른 디버깅
- API 문제 발생 시 즉시 원인 파악 가능
- 백엔드와 프론트엔드 데이터 불일치 빠르게 발견

### 2. 개발 생산성 향상
- API 응답 구조를 바로 확인 가능
- DTO 모델 작성 시 실제 응답 참고 가능

### 3. 품질 향상
- 모든 API 통신을 모니터링
- 잠재적 문제 조기 발견

---

## ⚠️ 주의사항

### 1. 운영 환경
- 운영 빌드에서는 자동으로 비활성화됨
- `kDebugMode == false`일 때는 로그 출력 안 함

### 2. 민감 정보
- 비밀번호, 토큰 등 민감한 정보도 로그에 출력됨
- **개발 환경에서만 사용**하고, 로그를 공유하지 말 것

### 3. 성능
- 로깅 오버헤드가 있으므로 대량의 API 호출 시 약간의 성능 저하 가능
- 개발 환경에서만 사용하므로 실제 사용자에게는 영향 없음

---

## 📞 문의

API 로깅 시스템 관련 문의나 개선 사항은 개발팀에게 연락해주세요.

**문서 작성**: 2025-11-21
**버전**: 1.0.0
