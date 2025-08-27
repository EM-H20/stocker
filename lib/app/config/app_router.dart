import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import '../core/widgets/error_page.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/education/presentation/education_screen.dart';
import '../../features/attendance/presentation/screens/attendance_screen.dart';
import '../../features/aptitude/presentation/screens/aptitude_initial_screen.dart';
import '../../features/aptitude/presentation/screens/aptitude_types_list_screen.dart';
import '../../features/wrong_note/presentation/wrong_note_screen.dart';
import '../../features/mypage/presentation/mypage_screen.dart';
import '../../features/education/presentation/theory_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/quiz/presentation/quiz_screen.dart';
import '../../features/quiz/presentation/quiz_result_screen.dart';
import '../../features/aptitude/presentation/screens/aptitude_quiz_screen.dart';
import '../../features/aptitude/presentation/screens/aptitude_result_screen.dart';
import '../../features/note/presentation/screens/note_list_screen.dart';
import '../../features/note/presentation/screens/note_editor_screen.dart';
import '../../features/home/presentation/main_dashboard_screen.dart';
/// 앱 전체의 라우팅을 관리하는 GoRouter 설정
class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: AppRoutes.main, // 새로운 메인 대시보드를 초기 화면으로
    routes: [
      // 로그인 화면 (merge 브랜치에서 추가된 기능)
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // 회원가입 화면 (merge 브랜치에서 추가된 기능)
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const SignupScreen(),
      ),

      // 메인 대시보드 화면
      GoRoute(
        path: AppRoutes.main,
        builder: (context, state) => const MainDashboardScreen(),
      ),

      // ShellRoute로 BottomNavigationBar를 유지하면서 탭 라우팅 (4개 탭)
      ShellRoute(
        builder: (context, state, child) {
          return HomeShell(child: child);
        },
        routes: [
          // 교육 탭 (euimin 기능 유지)
          GoRoute(
            path: AppRoutes.education,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: EducationScreen()),
          ),

          // 출석 탭 (subin에서 강화된 버전)
          GoRoute(
            path: AppRoutes.attendance,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: AttendanceScreen()),
          ),
          
          // 오답노트 탭 (euimin 기능 유지)
          GoRoute(
            path: AppRoutes.wrongNote,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: WrongNoteScreen()),
          ),
          
          // 마이페이지 탭 (euimin 기능 유지)
          GoRoute(
            path: AppRoutes.mypage,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: MypageScreen()),
          ),
        ],
      ),

      // 이론 학습 화면
      GoRoute(
        path: AppRoutes.theory,
        builder: (context, state) {
          final chapterIdStr = state.uri.queryParameters['chapterId'];
          final chapterId = int.tryParse(chapterIdStr ?? '') ?? 1;
          return TheoryScreen(chapterId: chapterId);
        },
      ),

      // === euimin 브랜치 기능들 ===
      // 퀴즈 화면
      GoRoute(
        path: AppRoutes.quiz,
        builder: (context, state) {
          final chapterIdStr = state.uri.queryParameters['chapterId'];
          final chapterId = int.tryParse(chapterIdStr ?? '') ?? 1;
          return QuizScreen(chapterId: chapterId);
        },
      ),

      // 퀴즈 결과 화면
      GoRoute(
        path: AppRoutes.quizResult,
        builder: (context, state) {
          final chapterIdStr = state.uri.queryParameters['chapterId'];
          final chapterId = int.tryParse(chapterIdStr ?? '') ?? 1;
          return QuizResultScreen(chapterId: chapterId);
        },
      ),

      // === subin 브랜치 새로운 기능들 ===
      // 성향 분석 메인 화면 (독립적인 라우트)
      GoRoute(
        path: AppRoutes.aptitude,
        builder: (context, state) => const AptitudeInitialScreen(),
      ),
      
      // 성향 분석 퀴즈 화면
      GoRoute(
        path: AppRoutes.aptitudeQuiz,
        builder: (context, state) => const AptitudeQuizScreen(),
      ),

      // 성향 분석 결과 화면
      GoRoute(
        path: AppRoutes.aptitudeResult,
        builder: (context, state) {
          // extra로 전달된 isMyResult 값을 받음 (없으면 true가 기본값)
          final isMyResult = (state.extra as bool?) ?? true;
          return AptitudeResultScreen(isMyResult: isMyResult);
        },
      ),

      // 모든 성향 목록 화면
      GoRoute(
        path: AppRoutes.aptitudeTypesList,
        builder: (context, state) => const AptitudeTypesListScreen(),
      ),

      // 노트 목록 화면 (subin 새 기능)
      GoRoute(
        path: AppRoutes.noteList,
        builder: (context, state) => const NoteListScreen(),
      ),

      // 노트 에디터 화면 (subin 새 기능)
      GoRoute(
        path: AppRoutes.noteEditor,
        builder: (context, state) {
          // extra로 Note(편집) 또는 NoteTemplate(생성) 객체를 전달받음
          final initialData = state.extra;
          return NoteEditorScreen(initialData: initialData);
        },
      ),
    ],
  

    // 에러 페이지 처리
    errorBuilder:
        (context, state) => ErrorPage(errorPath: state.matchedLocation),
  );

  static GoRouter get router => _router;
}