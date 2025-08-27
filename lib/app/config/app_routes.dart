/// 앱 전체에서 사용할 라우팅 경로 상수 정의
// 사용 예시
// context.go(AppRoutes.mypage);
// 이동
class AppRoutes {
  // 기본 경로
  static const String home = '/';
  static const String main = '/main'; // 새로운 메인 대시보드
  static const String splash = '/splash';

  // 인증 관련
  static const String login = '/login';
  static const String register = '/signup';

  // 메인 탭 경로들 (4개 탭)
  static const String education = '/education';
  static const String attendance = '/attendance';
  static const String aptitude = '/aptitude';
  static const String wrongNote = '/wrong-note';
  static const String mypage = '/mypage';

  // 교육 관련 세부 경로
  static const String chapter = '/education/chapter';
  static const String quiz = '/education/quiz';
  static const String quizResult = '/education/quiz-result';
  static const String theory = '/education/theory';

  // 메모 관련
  static const String memo = '/memo';
  static const String memoDetail = '/memo/detail';

  // 설정 관련
  static const String settings = '/settings';
  static const String profile = '/profile';

  // 성향 분석 세부 경로
  static const String aptitudeQuiz = '/aptitude/quiz';
  static const String aptitudeResult = '/aptitude/result';
  static const String aptitudeTypesList = '/aptitude/types';

  // 노트 관련 경로
  static const String noteList = '/notes';
  static const String noteEditor = '/notes/editor';
}
