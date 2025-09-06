- 정리 양식
    
    엔드포인트마다 “요약 → 요청 → 응답 → 에러 → 비고” 순서로 고정하고, 마지막에 요약 표를 붙인다.
    
    # 공통
    
    - Base URL: `https://api.example.com/investment_profile` (로컬: `http://localhost:8080/investment_profile`)
    - Auth: `Authorization: Bearer <access_token>`
    - Content-Type: `application/json`
    - 버전: 쿼리스트링 `version=v1.1` 또는 Body의 `version` 사용
    - 에러 포맷(통일):
    
    ```json
    json
    복사편집
    { "message": "에러 설명", "code": "OPTIONAL_CODE" }
    
    ```
    
    ---
    
    # 0) 검사지 조회 (문항 마스터 내려주기)
    
    **GET** `/test?version=v1.1`
    
    **목적**: 프론트에서 문항/차원 메타데이터 렌더링
    
    ### 요청
    
    - Headers: `Authorization: Bearer <token>`
    - Query: `version` (기본값 `v1.1`)
    
    ### cURL
    
    ```bash
    bash
    복사편집
    curl -X GET 'http://localhost:8080/investment_profile/test?version=v1.1' \
      -H 'Authorization: Bearer <token>'
    
    ```
    
    ### 성공 응답 (200)
    
    ```json
    json
    복사편집
    {
      "version": "v1.1",
      "questions": [
        {
          "questionId": 1,
          "version": "v1.1",
          "globalNo": 1,
          "dimCode": "A",
          "dimName": "리스크 수용성",
          "leftLabel": "E",
          "rightLabel": "C",
          "question": "가격이 많이 움직여도, 기회라고 느끼면 살 수 있다.",
          "isReverse": false,
          "note": "E 정문"
        }
      ]
    }
    
    ```
    
    ### 에러
    
    - 401: 토큰 누락/만료
    - 500: 서버 내부 오류(모델/DB 미연결 등)
    
    ### 비고
    
    - `questions`는 화면 표시와 응답 매핑에 그대로 사용.
    
    ---
    
    # 1) 최초 저장 (응답 → 계산 → 저장)
    
    **POST** `/result`
    
    **목적**: 프론트는 사용자 응답만 전송. 백이 계산하고 저장.
    
    ### 요청
    
    - Headers: `Authorization`, `Content-Type: application/json`
    - Body:
    
    ```json
    json
    복사편집
    {
      "version": "v1.1",
      "answers": [
        { "globalNo": 1, "answer": 4 },
        { "globalNo": 2, "answer": 4 },
        { "globalNo": 3, "answer": 2 }
        // ...총 12문항
      ]
    }
    
    ```
    
    ### cURL
    
    ```bash
    bash
    복사편집
    curl -X POST 'http://localhost:8080/investment_profile/result' \
      -H 'Authorization: Bearer <token>' \
      -H 'Content-Type: application/json' \
      -d '{
        "version":"v1.1",
        "answers":[{"globalNo":1,"answer":4},{"globalNo":2,"answer":4},{"globalNo":3,"answer":2}]
      }'
    
    ```
    
    ### 성공 응답
    
    - **201 Created**(최초) / **200 OK**(이미 존재)
    
    ```json
    json
    복사편집
    {
      "created": true,
      "profile_id": 12,
      "user_id": 101,
      "type_code": "ESAI",
      "matched_master": [ /* 추천 Top5 */ ],
      "computed": {
        "version": "v1.1",
        "type_code": "ESAI",
        "dimensions": {
          "A": { "avg": 3.33, "label": "E", "confidence": 0.33, "left": "E", "right": "C" },
          "B": { "avg": 3.33, "label": "S", "confidence": 0.33, "left": "S", "right": "L" },
          "C": { "avg": 3.67, "label": "A", "confidence": 0.67, "left": "A", "right": "P" },
          "D": { "avg": 3.33, "label": "I", "confidence": 0.33, "left": "I", "right": "D" }
        },
        "detail": [ /* 문항별 raw/adjusted */ ]
      }
    }
    
    ```
    
    ### 에러
    
    - 400: 요청 형식 오류(answers 누락/범위 외)
    - 401: 인증 실패
    - 500: 내부 오류
    
    ### 비고
    
    - 프론트는 `type_code`, `matched_master`, `dimensions`로 결과 화면 구성.
    
    ---
    
    # 
    

## 기능 정리

1. 회원가입, 로그인, 로그아웃, 프로필 수정
2. 출석 퀴즈, 출석 퀴즈 제출, 출석 로그 조회
3. 성향 분석 검사지 응답, 검사결과 요청 저장, 조회, 재검사 갱신, 모든 거장 정보 반환
4. 마이페이지 
프로필 수정 → user.service에 updateProfile
출석 현황 조회 → attendance.service.js에 있음. /history 경로로 조회하면 됨
오답노트 → 한웅이가 하는 중
메모 작성 및 조회 → 

## api 명세서

- JWT 로그인 (유저)
→ 토큰을 사용하는 이유는 유저 로컬에 토큰이 저장되어 있기 때문에 가져와서 사용하면됨
→ JWT Payload에 여러 정보를 담을 수 있음
인증이 필요한 경우에는 header에 
Authorize : Bearer access_token, x-refresh-token : refresh_token 넣어줘야함
    
    ### 1. 회원가입 (Signup)
    
    - **URL**: `POST /api/user/signup`
    - **Access**: Public
    - **Request Body**
    
    ```json
    
    {
      "email": "user@example.com",
      "password": "1234abcd",
      "nickname": "주환",
      "age": 28,
      "occupation": "개발자",
      "provider": "local",
      "profile_image_url": "https://example.com/profile.png"
    }
    
    ```
    
    - **Response (201 Created)**
    
    ```json
    
    {
      "message": "회원가입 성공",
      "userId": 1
    }
    
    ```
    
    - **Error (400 Bad Request)**
    
    ```json
    
    {
      "message": "이미 등록된 이메일입니다."
    }
    
    ```
    
    ---
    
    ### 2. 로그인 (Login)
    
    - **URL**: `POST /api/user/login`
    - **Access**: Public
    - **Request Body**
    
    ```json
    
    {
      "email": "user@example.com",
      "password": "1234abcd"
    }
    
    ```
    
    - **Response (200 OK)**
    
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
    
    - **Error (401 Unauthorized)**
    
    ```json
    
    {
      "message": "비밀번호가 일치하지 않습니다."
    }
    
    ```
    
    ---
    
    ### 3. 로그아웃 (Logout)
    
    - **URL**: `POST /api/user/logout`
    - **Access**: Private (🔑 `Authorization: Bearer <access_token>`)
    - **Request Body**
    
    ```json
    
    {
      "email": "user@example.com"
    }
    
    ```
    
    - **Response (200 OK)**
    
    ```json
    
    {
      "message": "로그아웃 성공"
    }
    
    ```
    
    - **Error (500 Server Error)**
    
    ```json
    
    {
      "message": "로그아웃 실패"
    }
    
    ```
    
    ---
    
    ### 4. 프로필 수정 (Update Profile)
    
    - **URL**: `POST /api/user/profile`
    - **Access**: Private (🔑 `Authorization: Bearer <access_token>`)
    - **Request Body (허용된 필드만 전송 가능)**
    
    ```json
    
    {
      "nickname": "주환짱",
      "profile_image_url": "https://example.com/new-profile.png",
      "age": 29,
      "occupation": "백엔드 개발자"
    }
    
    ```
    
    - **Response (200 OK)**
    
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
    
    - **Error (400 Bad Request)**
    
    ```json
    
    {
      "message": "수정할 항목이 없습니다."
    }
    
    ```
    
    | 기능 | 메서드 | URL | 인증 필요 | Request Body 예시 | Response 성공 예시 |
    | --- | --- | --- | --- | --- | --- |
    | 회원가입 | POST | `/api/users/signup` | ❌ Public | `{ email, password, nickname, age, occupation, provider, profile_image_url }` | `{ message, userId }` |
    | 로그인 | POST | `/api/users/login` | ❌ Public | `{ email, password }` | `{ message, user { id, email, nickname, access_token, refresh_token } }` |
    | 로그아웃 | POST | `/api/users/logout` | ✅ Private | `{ email }` | `{ message }` |
    | 프로필 수정 | POST | `/api/users/profile` | ✅ Private | `{ nickname?, profile_image_url?, age?, occupation?, provider? }` | `{ message, user }` |
    
    ![image.png](attachment:554238d1-71db-428d-8ab8-9ffc45110f80:image.png)
    
- 챕터
    
    1. 챕터조회 (교육 페이지 진입 시점)
    
    - **URL**: `GET /api/chapters`
    - **Auth**: ✅ 필요 (Authorization 헤더)
    - **Headers**
    
    ```
    
    Authorization: Bearer {{accessToken}}
    x-refresh-token : {refreshToken}
    ```
    
    - **Request Body**: 없음
    - **Response 예시 (챕터 목로 조회)**
    
    ```json
    [
        {
            "chapter_id": 1,
            "title": "주식용어",
            "keyword": null,
            "is_theory_completed": 1,
            "is_quiz_completed": 1
        },
        {
            "chapter_id": 2,
            "title": "재무제표의 이해",
            "keyword": null,
            "is_theory_completed": 1,
            "is_quiz_completed": 1
        }
    ]
    
    ```
    
    ---
    
    ## 2.이론 페이지 진입
    
    - **URL**: `POST /api/theory/enter`
    - **Auth**: ✅ 필요
    - **Headers**
    
    ```
    
    Authorization: Bearer {{accessToken}}
    x-refresh-token : {refreshToken}
    ```
    
    - **Request Body**
    
    ```json
    {
      "chpater_id" : 1
    }
    ```
    
    - **Response 예시 (정상 제출)**
    
    ```json
    {
        "theory_pages": [
            {
                "page_no": 1,
                "id": 1,
                "Word": "투자",
                "content": "현재의 소비를 줄이고 미래의 수익을 위해 자산에 자본을 투입하는 행위"
            },
            {
                "page_no": 2,
                "id": 2,
                "Word": "리스크",
                "content": "투자 결과가 예측과 다를 수 있는 가능성"
            },
            {
                "page_no": 3,
                "id": 3,
                "Word": "분산투자",
                "content": "다양한 자산에 투자하여 리스크를 줄이는 전략"
            }
        ],
        "total_pages": 3,
        "current_page": 1
    }
    ```
    
    - **Error 예시 (출석 정보가 없는 경우)**
    
    ```json
    {
        "message": "chapter_id는 필수입니다."
    }
    ```
    
    ## 3.이론 페이지 최신화
    
    - **URL**: `Patch /api/theory/progress`
    - **Auth**: ✅ 필요
    - **Headers**
    
    ```
    
    Authorization: Bearer {{accessToken}}
    x-refresh-token : {refreshToken}
    ```
    
    - **Request Body**
    
    ```json
    {
      "chpater_id" : 1,
      "current_theory_id" : 2
    }
    ```
    
    - **Response 예시 (정상 제출)**
    
    ```json
    {
        "message": "현재 이론 페이지 저장 완료"
    }
    ```
    
    - **Error 예시 (출석 정보가 없는 경우)**
    
    ```json
    {
        "message": "chapter_id와 current_theory_id는 필수입니다."
    }
    ```
    
    ## 4.이론 페이지 완료처리
    
    - **URL**: `Patch /api/theory/complete`
    - **Auth**: ✅ 필요
    - **Headers**
    
    ```
    
    Authorization: Bearer {{accessToken}}
    x-refresh-token : {refreshToken}
    ```
    
    - **Request Body**
    
    ```json
    {
      "chpater_id" : 1
    }
    ```
    
    - **Response 예시 (정상 제출)**
    
    ```json
    {
        "message": "이론 학습 완료 처리 완료"
    }
    ```
    
    - **Error 예시 (출석 정보가 없는 경우)**
    
    ```json
    {
        "message": "chapter_id는 필수입니다."
    }
    ```
    
- 퀴즈
    
    1. 퀴즈 진입 
    
    - **URL**:  `POST/api/quiz/enter`
    - **Auth**: ✅ 필요 (Authorization 헤더)
    - **Headers**
    
    ```
    
    Authorization: Bearer {{accessToken}}
    x-refresh-token : {refreshToken}
    ```
    
    - **Request Body**:
    
    ```java
    {
    	"chapter_id" : 1
    }
    ```
    
    - **Response 예시 (퀴즈 목록 조회)**
    
    ```json
    {
        "chapter_id": 1,
        "quiz_list": [
            {
                "id": 1,
                "question": "투자의 목적은 무엇인가요?",
                "option_1": "지금 당장 소비",
                "option_2": "미래를 위한 자산 증식",
                "option_3": "단기 만족",
                "option_4": "세금 회피",
                "hint": "이 문항의 핵심 개념은 ~ 입니다."
            },
            {
                "id": 2,
                "question": "리스크를 줄이기 위한 전략은?",
                "option_1": "한 종목 몰빵",
                "option_2": "현금만 보유",
                "option_3": "분산 투자",
                "option_4": "외환거래",
                "hint": "임한우."
            },
            {
                "id": 3,
                "question": "ETF는 어떤 상품인가요?",
                "option_1": "개별 주식",
                "option_2": "채권",
                "option_3": "펀드 형태의 상품",
                "option_4": "부동산",
                "hint": null
            }
        ],
        "current_quiz_id": 2
    }
    ```
    
    ---
    
    ## 2.퀴즈 페이지 최신화
    
    - **URL**:  `PATCH/api/quiz/progress`
    - **Auth**: ✅ 필요
    - **Headers**
    
    ```
    
    Authorization: Bearer {{accessToken}}
    x-refresh-token : {refreshToken}
    ```
    
    - **Request Body**
    
    ```json
    {
      "chpater_id" : 1,
      "curent_quiz_id" : 2
    }
    ```
    
    - **Response 예시 (정상 제출)**
    
    ```json
    {
        "message": "퀴즈 위치 저장 완료"
    }
    ```
    
    - **Error 예시 (출석 정보가 없는 경우)**
    
    ```json
    {
        "message": "chapter_id와 current_quiz_id는 필수입니다."
    }
    ```
    
    ## 3.퀴즈 완료 처리
    
    - **URL**: `POST /api/quiz/complete`
    - **Auth**: ✅ 필요
    - **Headers**
    
    ```
    
    Authorization: Bearer {{accessToken}}
    x-refresh-token : {refreshToken}
    ```
    
    - **Request Body**
    
    ```json
    {
      "chapter_id": 1,
      "answers": [
        { "quiz_id": 1, "answer": 2 },
        { "quiz_id": 2, "answer": 4 },
        { "quiz_id": 3, "answer": 1 }
      ]
    }
    ```
    
    - **Response 예시 (정상 제출)**
    
    ```json
    {
        "total": 3,
        "correct": 0,
        "wrong": 3
    }
    ```
    
    - **Error 예시 (출석 정보가 없는 경우)**
    
    ```json
    {
        "message": "chapter_id와 answers 배열은 필수입니다."
    }
    ```
    
- 오답
    
    ## 1.오답노트 조회
    
    - **URL**:  `GET/api/wrong_note/mypage`
    - **Auth**: ✅ 필요
    - **Headers**
    
    ```
    
    Authorization: Bearer {{accessToken}}
    x-refresh-token : {refreshToken}
    ```
    
    - **Request Body**
    
    ```json
    {
      "chpater_id" : 1
    }
    ```
    
    - **Response 예시 (정상 제출)**
    
    ```json
    [
        {
            "quiz_id": 1,
            "chapter_id": 1,
            "question": "투자의 목적은 무엇인가요?",
            "options": [
                "지금 당장 소비",
                "미래를 위한 자산 증식",
                "단기 만족",
                "세금 회피"
            ],
            "correct_option": 2,
            "selected_option": null,
            "created_date": "2025-08-27"
        },
        {
            "quiz_id": 2,
            "chapter_id": 1,
            "question": "리스크를 줄이기 위한 전략은?",
            "options": [
                "한 종목 몰빵",
                "현금만 보유",
                "분산 투자",
                "외환거래"
            ],
            "correct_option": 3,
            "selected_option": null,
            "created_date": "2025-08-27"
        },
        {
            "quiz_id": 3,
            "chapter_id": 1,
            "question": "ETF는 어떤 상품인가요?",
            "options": [
                "개별 주식",
                "채권",
                "펀드 형태의 상품",
                "부동산"
            ],
            "correct_option": 3,
            "selected_option": null,
            "created_date": "2025-08-27"
        }
    ]
    ```
    
    - **Error 예시 (출석 정보가 없는 경우)**
    
    ```json
    {
        "message": "chapter_id는 필수입니다."
    }
    ```
    
- 출석 퀴즈
    
    ## 1. 퀴즈 시작 (랜덤 3문제)
    
    - **URL**: `GET /api/attendance/quiz/start`
    - **Auth**: ✅ 필요 (Authorization 헤더)
    - **Headers**
    
    ```
    
    Authorization: Bearer {{accessToken}}
    x-refresh-token : {refreshToken}
    ```
    
    - **Request Body**: 없음
    - **Response 예시 (첫 출석, 랜덤 3문제)**
    
    ```json
    
    {
      "quizzes": [
        {
          "quizOX_id": 5,
          "question_OX": "지구는 태양 주위를 돈다?",
          "is_correct": true},
        {
          "quizOX_id": 9,
          "question_OX": "2+2는 5이다?",
          "is_correct": false},
        {
          "quizOX_id": 12,
          "question_OX": "대한민국의 수도는 서울이다?",
          "is_correct": true}
      ]
    }
    
    ```
    
    - **Response 예시 (이미 출석 완료한 날 호출)**
    
    ```json
    
    {
      "quizzes": []
    }
    
    ```
    
    ---
    
    ## 2. 출석 제출
    
    - **URL**: `POST /api/attendance/quiz/submit`
    - **Auth**: ✅ 필요
    - **Headers**
    
    ```
    
    Authorization: Bearer {{accessToken}}
    x-refresh-token : {refreshToken}
    ```
    
    - **Request Body**
    
    ```json
    {
      "isPresent": true
    }
    ```
    
    - **Response 예시 (정상 제출)**
    
    ```json
    {
      "success": true
    }
    ```
    
    - **Error 예시 (출석 정보가 없는 경우)**
    
    ```json
    {
      "message": "출석정보가 존재하지 않습니다."
    }
    ```
    
    ---
    
    ## 3. 당월 출석 이력 조회
    
    - **URL**: `GET /api/attendance/history`
    - **Auth**: ✅ 필요
    - **Headers**
    
    ```
    
    Authorization: Bearer {{accessToken}}
    x-refresh-token : {refreshToken}
    ```
    
    - **Request Body**: 없음
    - **Response 예시**
    
    ```json
    json
    복사편집
    {
      "history": [
        {
          "date": "2025-08-01",
          "is_present": true},
        {
          "date": "2025-08-02",
          "is_present": false},
        {
          "date": "2025-08-03",
          "is_present": true}
      ]
    }
    
    ```
    
    ---
    
    # 📊 요약 표
    
    | 기능 | 메서드 | URL | Auth 필요 | Request 예시 | Response 예시 |
    | --- | --- | --- | --- | --- | --- |
    | 퀴즈 시작 | GET | `/api/attendance/quiz/start` | ✅ | 없음 | `{ quizzes: [ {quizOX_id, question_OX, is_correct} ] }` |
    | 출석 제출 | POST | `/api/attendance/quiz/submit` | ✅ | `{ isPresent: true }` | `{ success: true }` |
    | 당월 출석 이력 조회 | GET | `/api/attendance/history` | ✅ | 없음 | `{ history: [ { date, is_present } ] }` |
- 투자 성향  & 거장
    
    ## 0. 검사지 제공
    
    - **URL**: `GET /api/investment_profile/test?version=v1.1`
    - **Auth**: ✅ 필요
    - **Headers**
    
    ```
    Authorization: Bearer {{accessToken}}
    x-refresh-token: {{refreshToken}}
    ```
    
    - **Request Body**: 없음
    - **Response 예시**
    
    ```json
    {
      "version": "v1.1",
      "questions": [
        {
          "questionId": 1,
          "version": "v1.1",
          "globalNo": 1,
          "dimCode": "A",
          "dimName": "리스크 성향",
          "leftLabel": "E",
          "rightLabel": "C",
          "question": "나는 주식 투자에서 위험을 감수할 수 있다.",
          "isReverse": false,
          "note": null},
        {
          "questionId": 2,
          "version": "v1.1",
          "globalNo": 2,
          "dimCode": "B",
          "dimName": "투자 기간",
          "leftLabel": "S",
          "rightLabel": "L",
          "question": "나는 단기간 성과보다 장기간 투자를 선호한다.",
          "isReverse": true,
          "note": null}
      ]
    }
    
    ```
    
    ---
    
    ## 1. 최초 결과 저장
    
    - **URL**: `POST /api/investment_profile/result`
    - **Auth**: ✅ 필요
    - **Headers**
    
    ```
    Authorization: Bearer {{accessToken}}
    x-refresh-token: {{refreshToken}}
    ```
    
    - **Request Body 예시**
    
    ```json
    {
      "version": "v1.1",
      "answers": [
        { "globalNo": 1, "answer": 4 },
        { "globalNo": 2, "answer": 2 },
        { "globalNo": 3, "answer": 5 }
      ]
    }
    
    ```
    
    - **Response 예시 (최초 저장 성공)**
    
    ```json
    {
      "created": true,
      "profile_id": 1,
      "user_id": 6,
      "type_code": "ELAI",
      "matched_master": [
        {
          "master_id": 1,
          "name": "워렌 버핏",
          "bio": "가치투자의 대가",
          "portfolio_summary": "장기 가치 중심 투자",
          "image_url": "https://example.com/buffett.jpg",
          "style": "가치 투자",
          "type_code": "CLPD",
          "score": 3
        }
      ],
      "computed": {
        "version": "v1.1",
        "type_code": "ELAI",
        "dimensions": {
          "A": { "avg": 3.7, "label": "E", "confidence": 0.7, "left": "E", "right": "C" },
          "B": { "avg": 2.0, "label": "L", "confidence": 1.0, "left": "S", "right": "L" },
          "C": { "avg": 4.0, "label": "A", "confidence": 1.0, "left": "A", "right": "P" },
          "D": { "avg": 3.0, "label": "I", "confidence": 0.0, "left": "I", "right": "D" }
        }
      }
    }
    
    ```
    
    - **Response 예시 (이미 저장된 경우)**
    
    ```json
    {
      "created": false,
      "profile_id": 1,
      "user_id": 6,
      "type_code": "ELAI",
      "matched_master": [ ... ],
      "computed": { ... }
    }
    
    ```
    
    ---
    
    ## 2. 결과 조회
    
    - **URL**: `GET /api/investment_profile/result`
    - **Auth**: ✅ 필요
    - **Headers**
    
    ```
    Authorization: Bearer {{accessToken}}
    x-refresh-token: {{refreshToken}}
    ```
    
    - **Response 예시 (있음)**
    
    ```json
    {
      "profile_id": 1,
      "user_id": 6,
      "type_code": "ELAI",
      "matched_master": [
        {
          "master_id": 1,
          "name": "워렌 버핏",
          "bio": "가치투자의 대가",
          "portfolio_summary": "장기 가치 중심 투자",
          "image_url": "https://example.com/buffett.jpg",
          "style": "가치 투자",
          "type_code": "CLPD"
        }
      ]
    }
    
    ```
    
    - **Response 예시 (없음)**
    
    ```json
    {
      "profile": null,
      "matched_master": []
    }
    
    ```
    
    ---
    
    ## 3. 재검사 갱신
    
    - **URL**: `PUT /api/investment_profile/result`
    - **Auth**: ✅ 필요
    - **Headers**
    
    ```
    Authorization: Bearer {{accessToken}}
    x-refresh-token: {{refreshToken}}
    ```
    
    - **Request Body 예시**
    
    ```json
    {
      "version": "v1.1",
      "answers": [
        { "globalNo": 1, "answer": 2 },
        { "globalNo": 2, "answer": 5 },
        { "globalNo": 3, "answer": 3 }
      ]
    }
    ```
    
    - **Response 예시**
    
    ```json
    {
      "profile_id": 1,
      "user_id": 6,
      "type_code": "CLPD",
      "matched_master": [ ... ],
      "computed": {
        "version": "v1.1",
        "type_code": "CLPD",
        "dimensions": {
          "A": { "avg": 2.0, "label": "C", "confidence": 1.0, "left": "E", "right": "C" },
          "B": { "avg": 5.0, "label": "S", "confidence": 2.0, "left": "S", "right": "L" },
          "C": { "avg": 3.0, "label": "A", "confidence": 0.0, "left": "A", "right": "P" },
          "D": { "avg": 4.0, "label": "I", "confidence": 1.0, "left": "I", "right": "D" }
        }
      }
    }
    
    ```
    
    ---
    
    ## 4. 모든 거장 조회
    
    - **URL**: `GET /api/investment_profile/masters`
    - **Auth**: ✅ 필요
    - **Headers**
    
    ```
    Authorization: Bearer {{accessToken}}
    x-refresh-token: {{refreshToken}}
    
    ```
    
    - **Request Body**: 없음
    - **Response 예시**
    
    ```json
    [
      {
        "master_id": 1,
        "name": "워렌 버핏",
        "bio": "가치투자의 대가",
        "portfolio_summary": "장기 가치 중심 투자",
        "image_url": "https://example.com/buffett.jpg",
        "style": "가치 투자",
        "type_code": "CLPD"
      },
      {
        "master_id": 2,
        "name": "피터 린치",
        "bio": "성장주 투자 전문가",
        "portfolio_summary": "기업 성장성 중심 투자",
        "image_url": "https://example.com/lynch.jpg",
        "style": "성장 투자",
        "type_code": "ELAI"
      }
    ]
    
    ```
    
    ---
    
    # 📊 요약 표
    
    | 기능 | 메서드 | URL | Request Body | Response |
    | --- | --- | --- | --- | --- |
    | 검사지 제공 | GET | `/api/investment_profile/test` | 없음 | `{ version, questions }` |
    | 최초 저장 | POST | `/api/investment_profile/result` | `{ version, answers[] }` | `{ created, profile_id, ... }` |
    | 결과 조회 | GET | `/api/investment_profile/result` | 없음 | `{ profile_id, user_id, type_code, matched_master }` |
    | 재검사 갱신 | PUT | `/api/investment_profile/result` | `{ version, answers[] }` | `{ profile_id, user_id, type_code, matched_master, computed }` |
    | 모든 거장 조회 | GET | `/api/investment_profile/masters` | 없음 | `[ { master_id, name, ... }, ... ]` |
    
    ---
    
- 메모
    
    → 메모의 경우에는 처음부터 토큰으로 해당 유저의 메모를 전부 반환해주고 프론트에서 필요한 양식이나 방법에 따라 정렬할 수 있게 해둠.
    
    프론트에서는 →
    
    - **템플릿별 분류** (`일지`, `일기`, `체크리스트` 등)
    - **JSON content 기반 커스텀 렌더링** (예: 체크리스트는 체크박스로, 일기는 텍스트 영역으로)
    - **최신 수정일 기준 정렬** (`created_at` 내림차순)
    
    ## 1. 유저 메모 전체 조회
    
    - **URL**: `GET /api/memo/`
    - **Auth**: ✅ 필요
    - **Headers**
    
    ```
    Authorization: Bearer {{accessToken}}
    x-refresh-token: {{refreshToken}}
    ```
    
    - **Request Body**: 없음
    - **Response 예시**
    
    ```json
    {
      "memos": [
        {
          "id": 10,
          "user_id": 6,
          "template_type": "일지",
          "content": {
            "title": "8월 26일 회의 정리",
            "tasks": ["API 명세 작성", "JWT 토큰 검증 버그 수정"]
          },
          "created_at": "2025-08-26T09:15:32.000Z"
        },
        {
          "id": 9,
          "user_id": 6,
          "template_type": "체크리스트",
          "content": {
            "items": [
              { "text": "알고리즘 문제 풀기", "done": true },
              { "text": "운동하기", "done": false }
            ]
          },
          "created_at": "2025-08-25T18:00:11.000Z"
        }
      ]
    }
    
    ```
    
    ---
    
    ## 2. 메모 저장·갱신
    
    - **URL**: `PUT /api/memo/`
    - **Auth**: ✅ 필요
    - **Headers**
    
    ```
    Authorization: Bearer {{accessToken}}
    x-refresh-token: {{refreshToken}}
    
    ```
    
    ### (1) 신규 저장
    
    - **Request Body 예시**
    
    ```json
    {
      "template_type": "일기",
      "content": {
        "mood": "😊",
        "text": "오늘은 JWT 토큰 문제를 해결해서 기분이 좋다."
      }
    }
    
    ```
    
    - **Response 예시**
    
    ```json
    {
      "memo": {
        "id": 11,
        "user_id": 6,
        "template_type": "일기",
        "content": {
          "mood": "😊",
          "text": "오늘은 JWT 토큰 문제를 해결해서 기분이 좋다."
        },
        "created_at": "2025-08-26T10:05:00.000Z"
      }
    }
    
    ```
    
    ---
    
    ### (2) 기존 메모 갱신
    
    - **Request Body 예시**
    
    ```json
    {
      "id": 11,
      "template_type": "일기",
      "content": {
        "mood": "🤔",
        "text": "JWT 문제 해결은 했지만 아직 최적화가 필요하다."
      }
    }
    
    ```
    
    - **Response 예시**
    
    ```json
    {
      "memo": {
        "id": 11,
        "user_id": 6,
        "template_type": "일기",
        "content": {
          "mood": "🤔",
          "text": "JWT 문제 해결은 했지만 아직 최적화가 필요하다."
        },
        "created_at": "2025-08-26T10:20:00.000Z"
      }
    }
    
    ```
    
    - **Error 예시 (존재하지 않는 id)**
    
    ```json
    {
      "message": "memo not found"
    }
    
    ```
    
    ![image.png](attachment:88bcdef7-f550-44e6-972e-dbde36638f20:image.png)
    
    ![image.png](attachment:22cff4fd-64a0-4a41-8363-0407cfc76538:image.png)
    
    → 템플릿 양식은 enum을 수정해서 DB와 맞춰주면 됨
    
    ## 3. 메모 삭제
    
    - **URL**: `DELETE /api/memo/{id}`
    - **Auth**: ✅ 필요
    - **Headers**
    
    ```
    Authorization: Bearer {{accessToken}}
    x-refresh-token: {{refreshToken}}
    ```
    
    - **예시 요청**
    
    ```
    DELETE /api/memo/11
    ```
    
    - **Response 예시 (성공)**
    
    ```json
    {
      "success": true}
    
    ```
    
    - **Error 예시**
    
    ```json
    {
      "message": "memo not found"
    }
    
    ```
    
    ---
    
    # 📊 요약 표
    
    | 기능 | 메서드 | URL | Request Body 예시 | Response 예시 |
    | --- | --- | --- | --- | --- |
    | 메모 전체 조회 | GET | `/api/memo/` | 없음 | `{ memos: [...] }` |
    | 메모 저장·갱신 | PUT | `/api/memo/` | `{ template_type, content }` or `{ id, template_type, content }` | `{ memo: {...} }` |
    | 메모 삭제 | DELETE | `/api/memo/:id` | 없음 | `{ success: true }` |

?? 500 internal Server Error

헤더에 refresh, access 둘 다 넣어서 요청. refresh로 재발급. 컨트롤러에서 인증(토큰)이 필요한 로직에서는 토큰에서 id를 추출해서 사용하면 됨. 

## DB 쿼리

- 생성 쿼리
    
    ```sql
    
    -- DATABASE 생성
    CREATE DATABASE IF NOT EXISTS stocker_test
      DEFAULT CHARACTER SET utf8mb4
      DEFAULT COLLATE utf8mb4_general_ci;
    
    USE stocker_test;
    
    -- USERS
    CREATE TABLE user (
        id INT AUTO_INCREMENT PRIMARY KEY,
        email VARCHAR(255) NOT NULL,
        password VARCHAR(255) NOT NULL,
        nickname VARCHAR(255),
        profile_image_url TEXT,
        provider VARCHAR(50),
        age INT,
        occupation VARCHAR(100),
        created_date DATE DEFAULT (CURRENT_DATE),
        access_token TEXT,
        refresh_token TEXT
    );
    
    -- USER SETTINGS
    CREATE TABLE user_settings (
        setting_id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        nickname VARCHAR(100),
        bio TEXT,
        profile_image VARCHAR(255),
        user_job VARCHAR(100),
        FOREIGN KEY (user_id) REFERENCES user(id)
    );
    
    -- MEMOS
    CREATE TABLE memos (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        template_type ENUM('일지','복기','체크리스트','자유','재무제표') NOT NULL,
        content JSON NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES user(id)
    );
    
    -- INVESTMENT MASTER
    CREATE TABLE investment_master (
        master_id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(100),
        bio TEXT,
        portfolio_summary TEXT,
        image_url VARCHAR(255),
        style VARCHAR(255),
        type_code VARCHAR(100)
    );
    
    -- INVESTMENT PROFILE
    CREATE TABLE investment_profile (
        profile_id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        type_code VARCHAR(100),
        matched_master TEXT,
        FOREIGN KEY (user_id) REFERENCES user(id)
    );
    
    -- TEST MASTER (성향검사지 마스터)
    CREATE TABLE test_master (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        version VARCHAR(20),
        dimension_code CHAR(1),
        dimension_name VARCHAR(50),
        left_label VARCHAR(50),
        right_label VARCHAR(50),
        left_desc VARCHAR(50),
        right_desc VARCHAR(50),
        global_no INT,
        dm_no INT,
        question_text VARCHAR(500),
        is_reverse TINYINT(1),
        note VARCHAR(100)
    );
    
    -- CHAPTERS
    CREATE TABLE chapter (
        id INT AUTO_INCREMENT PRIMARY KEY,
        title VARCHAR(255),
        keyword VARCHAR(100)
    );
    
    -- QUIZZES
    CREATE TABLE quiz (
        id INT AUTO_INCREMENT PRIMARY KEY,
        chapter_id INT,
        question TEXT,
        option_1 TEXT,
        option_2 TEXT,
        option_3 TEXT,
        option_4 TEXT,
        correct_option INT,
        hint TEXT,
        FOREIGN KEY (chapter_id) REFERENCES chapter(id)
    );
    
    -- THEORY
    CREATE TABLE theory (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        chapter_id INT,
        word VARCHAR(255),
        content TEXT,
        FOREIGN KEY (chapter_id) REFERENCES chapter(id)
    );
    
    -- WRONG NOTE
    CREATE TABLE wrong_note (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        quiz_id INT,
        chapter_id INT,
        user_id INT,
        created_date DATE,
        selected_option INT,
        FOREIGN KEY (quiz_id) REFERENCES quiz(id),
        FOREIGN KEY (chapter_id) REFERENCES chapter(id),
        FOREIGN KEY (user_id) REFERENCES user(id)
    );
    
    -- CHAPTER PROGRESS
    CREATE TABLE chapter_progress (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        user_id INT,
        chapter_id INT,
        is_theory_completed BOOLEAN,
        is_quiz_completed BOOLEAN,
        is_chapter_completed BOOLEAN,
        current_theory_id BIGINT,
        current_quiz_id BIGINT,
        FOREIGN KEY (user_id) REFERENCES user(id),
        FOREIGN KEY (chapter_id) REFERENCES chapter(id)
    );
    
    -- ATTENDANCE
    CREATE TABLE attendance (
        attendance_id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT,
        date DATE,
        is_present BOOLEAN,
        FOREIGN KEY (user_id) REFERENCES user(id)
    );
    
    -- ATTENDANCE_QUIZ (퀴즈 마스터, 출석과 무관하게 저장)
    CREATE TABLE attendance_quiz (
        quizOX_id INT AUTO_INCREMENT PRIMARY KEY,
        question_OX TEXT NOT NULL,
        is_correct TINYINT NOT NULL
    );
    -- DATABASE 생성
    CREATE DATABASE IF NOT EXISTS stocker_test
      DEFAULT CHARACTER SET utf8mb4
      DEFAULT COLLATE utf8mb4_general_ci;
    
    USE stocker_test;
    
    -- USERS
    CREATE TABLE user (
        id INT AUTO_INCREMENT PRIMARY KEY,
        email VARCHAR(255) NOT NULL,
        password VARCHAR(255) NOT NULL,
        nickname VARCHAR(255),
        profile_image_url TEXT,
        provider VARCHAR(50),
        age INT,
        occupation VARCHAR(100),
        created_date DATE DEFAULT (CURRENT_DATE),
        access_token TEXT,
        refresh_token TEXT
    );
    
    -- USER SETTINGS
    CREATE TABLE user_settings (
        setting_id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        nickname VARCHAR(100),
        bio TEXT,
        profile_image VARCHAR(255),
        user_job VARCHAR(100),
        FOREIGN KEY (user_id) REFERENCES user(id)
    );
    
    -- MEMOS
    CREATE TABLE memos (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        template_type ENUM('일지','복기','체크리스트','자유','재무제표') NOT NULL,
        content JSON NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES user(id)
    );
    
    -- INVESTMENT MASTER
    CREATE TABLE investment_master (
        master_id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(100),
        bio TEXT,
        portfolio_summary TEXT,
        image_url VARCHAR(255),
        style VARCHAR(255),
        type_code VARCHAR(100)
    );
    
    -- INVESTMENT PROFILE
    CREATE TABLE investment_profile (
        profile_id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        type_code VARCHAR(100),
        matched_master TEXT,
        FOREIGN KEY (user_id) REFERENCES user(id)
    );
    
    -- TEST MASTER (성향검사지 마스터)
    CREATE TABLE test_master (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        version VARCHAR(20),
        dimension_code CHAR(1),
        dimension_name VARCHAR(50),
        left_label VARCHAR(50),
        right_label VARCHAR(50),
        left_desc VARCHAR(50),
        right_desc VARCHAR(50),
        global_no INT,
        dm_no INT,
        question_text VARCHAR(500),
        is_reverse TINYINT(1),
        note VARCHAR(100)
    );
    
    -- CHAPTERS
    CREATE TABLE chapter (
        id INT AUTO_INCREMENT PRIMARY KEY,
        title VARCHAR(255),
        keyword VARCHAR(100)
    );
    
    -- QUIZZES
    CREATE TABLE quiz (
        id INT AUTO_INCREMENT PRIMARY KEY,
        chapter_id INT,
        question TEXT,
        option_1 TEXT,
        option_2 TEXT,
        option_3 TEXT,
        option_4 TEXT,
        correct_option INT,
        hint TEXT,
        FOREIGN KEY (chapter_id) REFERENCES chapter(id)
    );
    
    -- THEORY
    CREATE TABLE theory (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        chapter_id INT,
        word VARCHAR(255),
        content TEXT,
        FOREIGN KEY (chapter_id) REFERENCES chapter(id)
    );
    
    -- WRONG NOTE
    CREATE TABLE wrong_note (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        quiz_id INT,
        chapter_id INT,
        user_id INT,
        created_date DATE,
        selected_option INT,
        FOREIGN KEY (quiz_id) REFERENCES quiz(id),
        FOREIGN KEY (chapter_id) REFERENCES chapter(id),
        FOREIGN KEY (user_id) REFERENCES user(id)
    );
    
    -- CHAPTER PROGRESS
    CREATE TABLE chapter_progress (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        user_id INT,
        chapter_id INT,
        is_theory_completed BOOLEAN,
        is_quiz_completed BOOLEAN,
        is_chapter_completed BOOLEAN,
        current_theory_id BIGINT,
        current_quiz_id BIGINT,
        FOREIGN KEY (user_id) REFERENCES user(id),
        FOREIGN KEY (chapter_id) REFERENCES chapter(id)
    );
    
    -- ATTENDANCE
    CREATE TABLE attendance (
        attendance_id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT,
        date DATE,
        is_present BOOLEAN,
        FOREIGN KEY (user_id) REFERENCES user(id)
    );
    
    -- ATTENDANCE_QUIZ (퀴즈 마스터, 출석과 무관하게 저장)
    CREATE TABLE attendance_quiz (
        quizOX_id INT AUTO_INCREMENT PRIMARY KEY,
        question_OX TEXT NOT NULL,
        is_correct TINYINT NOT NULL
    );
    ```
    
- 목데이터 쿼리
    
    investment_mater
    
    ```sql
    
    INSERT INTO investment_master (master_id, name, bio, portfolio_summary, image_url, style, type_code)
    VALUES
    (1, 'Warren Buffett', '버크셔 해서웨이 회장. 가치·안전마진·장기 보유', '코카콜라, 애플 등 장적 우량주를 적정가 이하에 매수 후 장기 보유', NULL, '가치·장기·저위험(Buy & Hold)·데이터 기반', 'CLPD'),
    (2, 'Charlie Munger', '워렌 버핏 파트너. 인문학적 사고와 장기 투자', '소수의 질 좋은 기업을 적정 가치에 매수, 복리 효과를 노림', NULL, '가치·장기·집중·복리·분석적', 'CLPI'),
    (3, 'Ray Dalio', '브리지워터 설립자. 리스크 패리티 전략', '다양화된 자산군 기반 자산배분(레버리지 기반)', NULL, '장기·데이터·매크로·리스크 관리', 'CLAD'),
    (4, 'Howard Marks', '오크트리 공동창업자. 사이클/심리 분석 전문가', '사이클 하락 국면에서 보수적 매수, 가치/리스크 대비 투자', NULL, '사이클·심리·신중·가치', 'CLAI'),
    (5, 'Benjamin Graham', '워렌 버핏 스승. 가치투자의 아버지', '저PBR/PER 중심의 철저한 분석, 안전마진', NULL, '가치·저평가·철저분석·안전마진', 'CSPD'),
    (6, 'Walter Schloss', '벤저민 그레이엄 제자. 매우 단순 규칙으로 저평가주 매수', '저평가 종목 다수 보유 후 장기 보유', NULL, '가치·저평가·단순 원칙·장타 보유', 'CSPI'),
    (7, 'Joel Greenblatt', '매직 포뮬러 저자. 수익/자본 대비 고수익 기업 투자', 'ROIC·수익성/가치 우량 기업 매수', NULL, '가치·수익성·계량화된 규칙', 'CSAD'),
    (8, 'John Neff', '윈저펀드 매니저. 저PER·저PBR+배당주 집중', '저PER+고배당 기업 위주 장기 보유', NULL, '가치·배당·저평가·장기', 'SAI'),
    (9, 'Peter Lynch', '마젤란펀드 매니저. 생활 속 투자법', '생활 속 친근기업 성장주 발굴·매수', NULL, '성장·생활 속 관찰·적극적 탐구', 'ELAI'),
    (10, 'Philip Fisher', '성장주의 아버지. 질적 분석 중시', '우수 경영진/제품 성장주를 철저히 조사 후 장기 보유', NULL, '성장·질적 분석·경영진 중시', 'ELAI'),
    (11, 'Terry Smith', '펀드스미스 설립자. 20ROCE 초과 성장주 집중', 'ROCE 우량 기업 성장주 장기 보유', NULL, '성장·고ROCE·장기 보유', 'ELPD'),
    (12, 'Ron Baron', '바론캐피털 창립자. 장기·성장주 집중', '성장 기업 장기 보유 전략', NULL, '성장·장기·집중', 'ELPI'),
    (13, 'Carl Icahn', '행동주의 헤지펀드 투자자. 주주 행동주의 전략', '지분 확보→경영 개선 압박→가치 상승 기대', NULL, '행동주의·지분 확보·경영 개입', 'ESAD'),
    (14, 'David Tepper', '앱팔루사 창업자. 경기 순환주/채권 투자', '경기 회복 국면에서 채권/주식 적극 매수', NULL, '경기순환·채권·주식·공격적', 'ESAI'),
    (15, 'Bill Miller', '과거 레전드 펀드매니저. 가치+성장 융합', '장기적 저평가 종목+기술주 결합 투자', NULL, '가치+성장·융합형', 'ESPD'),
    (16, 'George Soros', '퀀텀펀드 설립. 탑다운형 거시/투기적 투자자', '대규모 단기 매매 전략·통화/비정상적 차익거래 활용', NULL, '탑다운·거시·투기적', 'ESPI');
    
    ```
    
    attendance_quiz
    
    ```sql
    INSERT INTO attendance_quiz (quizOX_id, is_correct, question_OX) VALUES
    (1, 1, 'Java는 플랫폼 독립적인 언어이다.'),
    (2, 0, 'Spring Boot는 JSP 기반 웹 프레임워크이다.'),
    (3, 0, 'HTTP GET 요청은 데이터를 서버에 저장한다.'),
    (4, 1, 'JWT는 JSON 기반의 토큰이다.'),
    (5, 0, '데이터베이스에서 Primary Key는 중복이 가능하다.'),
    (6, 1, 'REST API는 상태를 저장하지 않는 Stateless 구조이다.'),
    (7, 0, 'Linux에서 cd .. 는 현재 디렉토리의 하위 폴더로 이동한다.'),
    (8, 1, 'Git은 버전 관리를 위한 분산형 시스템이다.'),
    (9, 1, 'HTML은 프로그래밍 언어이다.'),
    (10, 1, 'IntelliJ는 Java 개발에 사용되는 대표적인 IDE이다.');
    
    ```
    
    test_mater
    
    ```sql
    INSERT INTO test_master
    (id, version, dimension_code, dimension_name, left_label, right_label, left_desc, right_desc, global_no, dm_no, question_text, is_reverse, note)
    VALUES
    (1, 'v1.1', 'A', '리스크 수용성', 'E', 'C', 'Eager(공격적)', 'Cautious(보수적)', 1, 1, '가격이 많이 움직여도, 기회라고 느끼면 살 수 있다.', 0, 'E 정문'),
    (2, 'v1.1', 'A', '리스크 수용성', 'E', 'C', 'Eager(공격적)', 'Cautious(보수적)', 2, 2, '손실이 나도, 다시 들어가서 만회를 시도하는 편이다.', 0, 'E 정문'),
    (3, 'v1.1', 'A', '리스크 수용성', 'E', 'C', 'Eager(공격적)', 'Cautious(보수적)', 3, 3, '손실 가능성이 보이면 웬만하면 시작하지 않는다.', 1, 'C 정문 [역채점]'),
    (4, 'v1.1', 'B', '투자 기간', 'S', 'L', 'Short-term(단기)', 'Long-term(장기)', 4, 1, '몇 주~몇 달 안에 결과가 나오는 투자가 편하다.', 0, 'S 정문'),
    (5, 'v1.1', 'B', '투자 기간', 'S', 'L', 'Short-term(단기)', 'Long-term(장기)', 5, 2, '뉴스나 이슈가 생기면 빠르게 매매한다.', 0, 'S 정문'),
    (6, 'v1.1', 'B', '투자 기간', 'S', 'L', 'Short-term(단기)', 'Long-term(장기)', 6, 3, '회사가치가 커질 때까지 오래 기다리는 편이다.', 1, 'L 정문 [역채점]'),
    (7, 'v1.1', 'C', '투자 스타일', 'A', 'P', 'Active(액티브)', 'Passive(패시브)', 7, 1, '손절/익절 같은 내 규칙을 정하고 자주 실행한다.', 0, 'A 정문'),
    (8, 'v1.1', 'C', '투자 스타일', 'A', 'P', 'Active(액티브)', 'Passive(패시브)', 8, 2, '일정 주기로 비중을 바꾸기보다는 그대로 둔다.', 0, 'A 정문'),
    (9, 'v1.1', 'C', '투자 스타일', 'A', 'P', 'Active(액티브)', 'Passive(패시브)', 9, 3, '시장 평균만 따라가도 안정적이면 충분하다.', 1, 'P 정문 [역채점]'),
    (10, 'v1.1', 'D', '정보 활용', 'I', 'D', 'Intuition(직관)', 'Data(데이터)', 10, 1, '제품을 써보거나 현장 느낌이 중요하다.', 0, 'I 정문'),
    (11, 'v1.1', 'D', '정보 활용', 'I', 'D', 'Intuition(직관)', 'Data(데이터)', 11, 2, '큰 흐름이 맞으면 작은 숫자 차이는 괜찮다.', 0, 'I 정문'),
    (12, 'v1.1', 'D', '정보 활용', 'I', 'D', 'Intuition(직관)', 'Data(데이터)', 12, 3, '데이터가 안 좋으면 과감히 줄이거나 정리한다.', 0, 'D 정문');
    
    ```
  