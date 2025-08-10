import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import '../core/widgets/error_page.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/education/presentation/education_screen.dart';
import '../../features/attendance/presentation/attendance_screen.dart';
import '../../features/aptitude/presentation/aptitude_screen.dart';
import '../../features/wrong_note/presentation/wrong_note_screen.dart';
import '../../features/mypage/presentation/mypage_screen.dart';
import '../../features/education/presentation/theory_screen.dart';
import '../../features/quiz/presentation/quiz_screen.dart';
import '../../features/quiz/presentation/quiz_result_screen.dart';

/// 앱 전체의 라우팅을 관리하는 GoRouter 설정
class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: AppRoutes.education,
    routes: [
      // 로그인 화면
      // GoRoute(
      //   path: AppRoutes.login,
      //   builder: (context, state) => LoginScreen(),
      // ),

      // // 회원가입 화면
      // GoRoute(
      //   path: AppRoutes.register,
      //   builder: (context, state) => SignupScreen(),
      // ),

      // ShellRoute로 BottomNavigationBar를 유지하면서 탭 라우팅
      ShellRoute(
        builder: (context, state, child) {
          return HomeShell(child: child);
        },
        routes: [
          // 교육 탭
          GoRoute(
            path: AppRoutes.education,
            pageBuilder:
                (context, state) =>
                    NoTransitionPage(child: const EducationScreen()),
          ),

          // 출석 탭
          GoRoute(
            path: AppRoutes.attendance,
            pageBuilder:
                (context, state) =>
                    NoTransitionPage(child: const AttendanceScreen()),
          ),
          // 성향분석 탭
          GoRoute(
            path: AppRoutes.aptitude,
            pageBuilder:
                (context, state) =>
                    NoTransitionPage(child: const AptitudeScreen()),
          ),
          // 오답노트 탭
          GoRoute(
            path: AppRoutes.wrongNote,
            pageBuilder:
                (context, state) =>
                    NoTransitionPage(child: const WrongNoteScreen()),
          ),
          // 마이페이지 탭
          GoRoute(
            path: AppRoutes.mypage,
            pageBuilder:
                (context, state) =>
                    NoTransitionPage(child: const MypageScreen()),
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

      // TODO: 추후 추가될 라우트들
      // - 로그인/회원가입 화면
      // - 스플래시 화면
      // - 온보딩 화면
    ],

    // 에러 페이지 처리
    errorBuilder:
        (context, state) => ErrorPage(errorPath: state.matchedLocation),
  );

  static GoRouter get router => _router;
}
