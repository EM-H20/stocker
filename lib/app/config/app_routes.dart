/// 앱 전체에서 사용할 라우팅 경로 상수 정의
///
/// 🎯 정보구조 설계 원칙:
/// 1. Direct Access: 앱 시작 시 바로 학습 화면으로 진입
/// 2. Bottom Navigation: 4개 주요 기능 탭 (Education, Attendance, WrongNote, Mypage)
/// 3. Linear Learning Path: 학습자가 순차적으로 진행할 수 있는 경로
/// 4. Clear Hierarchy: 현재 위치를 명확히 알 수 있는 depth 구조
class AppRoutes {
  // ============= 기본 경로 =============
  static const String home = '/'; // (Deprecated - Education으로 리다이렉트)
  static const String splash = '/splash';

  // ============= 인증 관련 =============
  static const String login = '/login';
  static const String register = '/signup';

  // ============= 메인 학습 경로 (Linear Path) =============
  /// 🎓 학습 메인 - 전체 커리큘럼 및 진도 확인
  static const String learningPath = '/learning';

  /// 📚 챕터별 학습 플로우 (연속적 진행)
  static const String learningChapter = '/learning/chapter'; // + ?id=1
  static const String learningTheory =
      '/learning/chapter/theory'; // + ?chapterId=1
  static const String learningQuiz = '/learning/chapter/quiz'; // + ?chapterId=1
  static const String learningResult =
      '/learning/chapter/result'; // + ?chapterId=1

  /// 🏆 단원 완료 및 다음 단계 안내
  static const String learningComplete =
      '/learning/chapter/complete'; // + ?chapterId=1

  // ============= 메인 탭 경로들 (개선된 4개 탭) =============
  static const String education = '/education'; // 📚 전체 학습 자료 (기존 유지)
  static const String attendance = '/attendance'; // 📅 출석 체크
  static const String wrongNote = '/wrong-note'; // 📝 오답노트 & 개인 기록
  static const String mypage = '/mypage'; // 👤 프로필 & 설정

  // ============= 레거시 교육 경로 (호환성 유지) =============
  static const String chapter = '/education/chapter';
  static const String quiz = '/education/quiz';
  static const String quizResult = '/education/quiz-result';
  static const String theory = '/education/theory';

  // ============= 성향 분석 플로우 =============
  static const String aptitude = '/aptitude'; // 🧠 성향분석 메인
  static const String aptitudeQuiz = '/aptitude/quiz';
  static const String aptitudeResult = '/aptitude/result';
  static const String aptitudeTypesList = '/aptitude/types';

  // ============= 개인 기록 관리 =============
  static const String noteList = '/notes'; // 📝 노트 목록
  static const String noteEditor = '/notes/editor';

  // ============= 설정 관련 =============
  static const String settings = '/settings';
  static const String profile = '/profile';

  // ============= 유틸리티 메서드 =============

  /// 🔗 학습 플로우 내 다음 단계로 이동하는 헬퍼
  static String getNextLearningStep({
    required int chapterId,
    required String currentStep, // 'theory', 'quiz', 'result'
  }) {
    switch (currentStep) {
      case 'theory':
        return '$learningQuiz?chapterId=$chapterId';
      case 'quiz':
        return '$learningResult?chapterId=$chapterId';
      case 'result':
        return '$learningComplete?chapterId=$chapterId';
      default:
        return '$learningTheory?chapterId=$chapterId';
    }
  }

  /// 📈 현재 챕터의 진도율 표시용 헬퍼
  static double getLearningProgress({
    required String currentStep,
  }) {
    switch (currentStep) {
      case 'theory':
        return 0.33; // 33%
      case 'quiz':
        return 0.66; // 66%
      case 'result':
      case 'complete':
        return 1.0; // 100%
      default:
        return 0.0;
    }
  }
}
