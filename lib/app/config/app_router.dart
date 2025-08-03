// import 'package:go_router/go_router.dart';
// import 'app_routes.dart';
// import '../core/widgets/error_page.dart';
// import '../../features/home/presentation/home_shell.dart';
// import '../../features/education/presentation/education_screen.dart';
// import '../../features/attendance/presentation/attendance_screen.dart';
// import '../../features/aptitude/presentation/aptitude_screen.dart';
// import '../../features/wrong_note/presentation/wrong_note_screen.dart';
// import '../../features/mypage/presentation/mypage_screen.dart';
// import '../../features/education/presentation/theory_screen.dart';
// import '../../features/auth/presentation/login_screen.dart';
// import '../../features/auth/presentation/signup_screen.dart';

// /// 앱 전체의 라우팅을 관리하는 GoRouter 설정
// class AppRouter {
//   // GoRouter 인스턴스는 앱 전체에서 사용할 수 있도록 static으로 선언
//   static final GoRouter _router = GoRouter(
//     initialLocation: AppRoutes.education,
//     routes: [
//       // ShellRoute로 BottomNavigationBar를 유지하면서 탭 라우팅
//       ShellRoute(
//         builder: (context, state, child) {
//           return HomeShell(child: child);
//         },
//         routes: [
//           // app_routes.dart에 정의된 경로들을 app_router에서 경로로 사용함.
//           // 아래 코드는 builder를 통해 화면을 렌더링 함.
//           // 사용 법은 home_shell에 나와 있음

//           // 교육 탭
//           GoRoute(
//             path: AppRoutes.education,
//             pageBuilder:
//                 (context, state) =>
//                     NoTransitionPage(child: const EducationScreen()),
//           ),

//           // 출석 탭
//           GoRoute(
//             path: AppRoutes.attendance,
//             pageBuilder:
//                 (context, state) =>
//                     NoTransitionPage(child: const AttendanceScreen()),
//           ),
//           // 성향분석 탭
//           GoRoute(
//             path: AppRoutes.aptitude,
//             pageBuilder:
//                 (context, state) =>
//                     NoTransitionPage(child: const AptitudeScreen()),
//           ),
//           // 오답노트 탭
//           GoRoute(
//             path: AppRoutes.wrongNote,
//             pageBuilder:
//                 (context, state) =>
//                     NoTransitionPage(child: const WrongNoteScreen()),
//           ),
//           // 마이페이지 탭
//           GoRoute(
//             path: AppRoutes.mypage,
//             pageBuilder:
//                 (context, state) =>
//                     NoTransitionPage(child: const MypageScreen()),
//           ),
//         ],
//       ),

//       // 독립적인 전체 화면들 (ShellRoute 외부)
//       // 이론 학습 화면
//       GoRoute(
//         path: AppRoutes.theory,
//         builder: (context, state) => const TheoryScreen(),
//       ),

//       // TODO: 추후 추가될 라우트들
//       // - 로그인/회원가입 화면
//       // - 스플래시 화면
//       // - 온보딩 화면
//     ],

//     // 에러 페이지 처리
//     errorBuilder:
//         (context, state) => ErrorPage(errorPath: state.matchedLocation),
//   );

//   /// GoRouter 인스턴스 반환
//   static GoRouter get router => _router;
// }


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
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';

/// 앱 전체의 라우팅을 관리하는 GoRouter 설정
class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: AppRoutes.login, // 초기 화면을 로그인 화면으로 설정
    routes: [
      // 로그인 화면
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => LoginScreen(),
      ),

      // 회원가입 화면
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => SignupScreen(),
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
                NoTransitionPage(child: const EducationScreen()),
          ),

          // 출석 탭
          GoRoute(
            path: AppRoutes.attendance,
            pageBuilder: (context, state) =>
                NoTransitionPage(child: const AttendanceScreen()),
          ),
          // 성향분석 탭
          GoRoute(
            path: AppRoutes.aptitude,
            pageBuilder: (context, state) =>
                NoTransitionPage(child: const AptitudeScreen()),
          ),
          // 오답노트 탭
          GoRoute(
            path: AppRoutes.wrongNote,
            pageBuilder: (context, state) =>
                NoTransitionPage(child: const WrongNoteScreen()),
          ),
          // 마이페이지 탭
          GoRoute(
            path: AppRoutes.mypage,
            pageBuilder: (context, state) =>
                NoTransitionPage(child: const MypageScreen()),
          ),
        ],
      ),

      // 독립적인 전체 화면들 (ShellRoute 외부)
      // 이론 학습 화면
      GoRoute(
        path: AppRoutes.theory,
        builder: (context, state) => const TheoryScreen(),
      ),
    ],

    // 에러 페이지 처리
    errorBuilder: (context, state) => ErrorPage(errorPath: state.matchedLocation),
  );

  static GoRouter get router => _router;
}
