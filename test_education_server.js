// 간단한 Education API 테스트 서버 (8080 포트) - Node.js 내장 모듈만 사용
const http = require('http');
const url = require('url');
const PORT = 8080;

const server = http.createServer((req, res) => {
  // CORS 헤더 설정
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, x-refresh-token');
  res.setHeader('Content-Type', 'application/json');

  const parsedUrl = url.parse(req.url, true);
  const path = parsedUrl.pathname;
  const method = req.method;

  console.log(`📝 [EDUCATION_API] ${method} ${path}`);
  console.log(`🔐 [EDUCATION_API] Authorization: ${req.headers.authorization}`);

  // OPTIONS 요청 처리 (CORS preflight)
  if (method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  // 챕터 목록 API
  if (path === '/api/chapters' && method === 'GET') {
    console.log('✅ [EDUCATION_API] 챕터 목록 요청 받음');
    
    const chapters = [
      {
        chapterId: 1,
        title: "🚀 주식 기초 이해하기 (실제 API 데이터!)",
        isTheoryCompleted: false,
        isQuizCompleted: false
      },
      {
        chapterId: 2,
        title: "📊 차트 분석의 기초 (백엔드에서 온 데이터)",
        isTheoryCompleted: true,
        isQuizCompleted: false
      },
      {
        chapterId: 3,
        title: "💼 재무제표 읽는 방법 (Real API!)",
        isTheoryCompleted: false,
        isQuizCompleted: false
      },
      {
        chapterId: 4,
        title: "💡 투자 전략 수립하기 (Live Data)",
        isTheoryCompleted: false,
        isQuizCompleted: false
      }
    ];

    console.log(`📊 [EDUCATION_API] ${chapters.length}개 챕터 반환`);
    res.writeHead(200);
    res.end(JSON.stringify(chapters));
    return;
  }

  // 이론 진입 API
  if (path === '/api/theory/enter' && method === 'POST') {
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
    });
    
    req.on('end', () => {
      console.log('📚 [EDUCATION_API] 이론 진입 요청:', body);
      
      const { chapterId } = JSON.parse(body);
      
      // 샘플 이론 데이터
      const theoryResponse = {
        chapterId: chapterId,
        chapterTitle: `챕터 ${chapterId} 이론 (실제 백엔드 데이터!)`,
        currentTheoryId: 101,
        theories: [
          {
            id: 101,
            title: "기초 개념",
            content: "이것은 실제 백엔드에서 온 이론 내용입니다! 🎉"
          },
          {
            id: 102,
            title: "심화 내용",
            content: "더 자세한 설명이 여기에 들어갑니다. Mock이 아닌 진짜 API!"
          }
        ]
      };

      console.log('✅ [EDUCATION_API] 이론 데이터 반환');
      res.writeHead(200);
      res.end(JSON.stringify(theoryResponse));
    });
    return;
  }

  // 404 Not Found
  console.log(`❌ [EDUCATION_API] 경로를 찾을 수 없음: ${path}`);
  res.writeHead(404);
  res.end(JSON.stringify({ error: 'Not Found' }));
});

// 서버 시작
server.listen(PORT, () => {
  console.log(`🚀 [EDUCATION_API] 테스트 서버가 포트 ${PORT}에서 실행 중입니다!`);
  console.log(`📍 [EDUCATION_API] http://localhost:${PORT}/api/chapters 에서 테스트 가능`);
  console.log(`🎯 [EDUCATION_API] 이제 Flutter 앱에서 실제 API 데이터를 볼 수 있습니다!`);
});