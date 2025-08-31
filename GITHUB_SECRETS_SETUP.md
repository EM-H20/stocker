# 🔐 GitHub Secrets 설정 가이드

이 문서는 Stocker Flutter 앱의 CI/CD 파이프라인을 위한 GitHub Secrets 설정 방법을 안내합니다.

## 📍 설정 위치

1. GitHub 리포지토리 페이지로 이동
2. **Settings** 탭 클릭
3. 왼쪽 사이드바에서 **Secrets and variables** → **Actions** 클릭
4. **New repository secret** 버튼 클릭

## 🔑 필수 Secrets 목록

아래 Secrets를 **정확한 이름**으로 설정해주세요:

### 1. API_BASE_URL
```
Name: API_BASE_URL
Value: https://your-production-api-url.com
```
**설명**: 프로덕션 환경의 백엔드 API URL

### 2. ENVIRONMENT
```
Name: ENVIRONMENT
Value: production
```
**설명**: 앱 실행 환경 (개발용은 development, 배포용은 production)

### 3. DEBUG_MODE
```
Name: DEBUG_MODE
Value: false
```
**설명**: 디버그 모드 활성화 여부 (배포용은 false)

### 4. CONNECT_TIMEOUT
```
Name: CONNECT_TIMEOUT
Value: 15
```
**설명**: API 연결 타임아웃 (초 단위)

### 5. RECEIVE_TIMEOUT
```
Name: RECEIVE_TIMEOUT
Value: 15
```
**설명**: API 응답 타임아웃 (초 단위)

### 6. JWT_LOGIN_ENDPOINT
```
Name: JWT_LOGIN_ENDPOINT
Value: /api/user/login
```
**설명**: 로그인 API 엔드포인트

### 7. JWT_SIGNUP_ENDPOINT
```
Name: JWT_SIGNUP_ENDPOINT
Value: /api/user/signup
```
**설명**: 회원가입 API 엔드포인트

### 8. JWT_LOGOUT_ENDPOINT
```
Name: JWT_LOGOUT_ENDPOINT
Value: /api/user/logout
```
**설명**: 로그아웃 API 엔드포인트

## 🚀 설정 완료 후 테스트

1. **CI 테스트**: 새로운 브랜치에서 코드 변경 후 Pull Request 생성
2. **CD 테스트**: 새로운 태그 생성으로 릴리스 빌드 테스트
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

## 📋 체크리스트

- [ ] API_BASE_URL (프로덕션 API URL로 설정)
- [ ] ENVIRONMENT (production으로 설정)
- [ ] DEBUG_MODE (false로 설정)
- [ ] CONNECT_TIMEOUT (15로 설정)
- [ ] RECEIVE_TIMEOUT (15로 설정)
- [ ] JWT_LOGIN_ENDPOINT (/api/user/login으로 설정)
- [ ] JWT_SIGNUP_ENDPOINT (/api/user/signup으로 설정)
- [ ] JWT_LOGOUT_ENDPOINT (/api/user/logout으로 설정)

## 🎯 워크플로우 동작 방식

### CI Pipeline (자동 실행)
- **트리거**: `main`, `develop`, `euimin` 브랜치에 Push 또는 Pull Request
- **동작**: 코드 분석, 테스트 실행, 디버그 APK 빌드

### CD Pipeline (릴리스 빌드)
- **트리거**: `v*` 형태의 태그 Push 또는 수동 실행
- **동작**: 릴리스 APK/AAB 빌드, GitHub Release 자동 생성

## 🔧 문제 해결

### Secret이 인식되지 않는 경우
1. Secret 이름의 대소문자가 정확한지 확인
2. 값에 불필요한 공백이나 줄바꿈이 없는지 확인
3. 브라우저를 새로고침하고 다시 시도

### 빌드 실패 시
1. GitHub Actions 탭에서 실패한 워크플로우 로그 확인
2. Flutter 버전 호환성 확인
3. 의존성 충돌 여부 확인

## 📞 문의사항

GitHub Actions 관련 문제가 있을 경우 Repository Issues에 등록해주세요.

---
*이 가이드는 Stocker 프로젝트의 CI/CD 파이프라인 구축을 위해 작성되었습니다.*