import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import '../core/widgets/error_page.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/education/presentation/education_screen.dart';
import '../../features/attendance/presentation/screens/attendance_screen.dart';
import '../../features/aptitude/presentation/screens/aptitude_initial_screen.dart';
import '../../features/wrong_note/presentation/wrong_note_screen.dart';
import '../../features/mypage/presentation/mypage_screen.dart';
import '../../features/education/presentation/theory_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/aptitude/presentation/screens/aptitude_quiz_screen.dart';
import '../../features/aptitude/presentation/screens/aptitude_result_screen.dart';

/// 앱 전체의 라우팅을 관리하는 GoRouter 설정
class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: AppRoutes.login, // 초기 화면을 로그인 화면으로 설정
    routes: [
      // 로그인 화면
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // 회원가입 화면
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const SignupScreen(),
      ),

      // ShellRoute로 BottomNavigationBar를 유지하면서 탭 라우팅
      ShellRoute(
        builder: (context, state, child) {
          return HomeShell(child: child);
        },
        routes: [
          // 교육 탭
          GoRoute(
            path: AppRoutes.education,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: EducationScreen()),
          ),

          // 출석 탭
          GoRoute(
            path: AppRoutes.attendance,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: AttendanceScreen()),
          ),
          // 성향분석 탭
          GoRoute(
            path: AppRoutes.aptitude,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: AptitudeInitialScreen()),
          ),
          // 오답노트 탭
          GoRoute(
            path: AppRoutes.wrongNote,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: WrongNoteScreen()),
          ),
          // 마이페이지 탭
          GoRoute(
            path: AppRoutes.mypage,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: MypageScreen()),
          ),
        ],
      ),

      // 독립적인 전체 화면들 (ShellRoute 외부)
      // 이론 학습 화면
      GoRoute(
        path: AppRoutes.theory,
        builder: (context, state) => const TheoryScreen(),
      ),
      // 성향 분석 퀴즈 화면
        GoRoute(
          path: AppRoutes.aptitudeQuiz,
          builder: (context, state) => const AptitudeQuizScreen(),
        ),

        // 성향 분석 결과 화면
        GoRoute(
          path: AppRoutes.aptitudeResult,
          builder: (context, state) => const AptitudeResultScreen(),
        ),
    ],

    // 에러 페이지 처리
    errorBuilder: (context, state) => ErrorPage(errorPath: state.matchedLocation),
  );

  static GoRouter get router => _router;
}
