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
import '../../features/aptitude/presentation/screens/aptitude_quiz_screen.dart';
import '../../features/aptitude/presentation/screens/aptitude_result_screen.dart';
import '../../features/note/presentation/screens/note_list_screen.dart';
import '../../features/note/presentation/screens/note_editor_screen.dart';
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
        GoRoute(
          path: AppRoutes.aptitudeQuiz,
          builder: (context, state) => const AptitudeQuizScreen(),
        ),
        // ✅ [수정] 성향 분석 결과 화면 라우트 수정
        GoRoute(
          path: AppRoutes.aptitudeResult,
          builder: (context, state) {
            // extra로 전달된 isMyResult 값을 받음 (없으면 true가 기본값)
            final isMyResult = (state.extra as bool?) ?? true;
            return AptitudeResultScreen(isMyResult: isMyResult);
          },
        ),

        // ✅ [추가] 모든 성향 목록 화면 라우트
        GoRoute(
          path: AppRoutes.aptitudeTypesList,
          builder: (context, state) => const AptitudeTypesListScreen(),
        ),
        // 노트 목록 화면
        GoRoute(
          path: AppRoutes.noteList,
          builder: (context, state) => const NoteListScreen(),
        ),
        // 노트 에디터 화면
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
    errorBuilder: (context, state) => ErrorPage(errorPath: state.matchedLocation),
  );

  static GoRouter get router => _router;
}



// 밑에 코드는 메모장 테스트해보려고 만든거임 실행시키면 바로 메모장 화면 뜸
// // FILE: lib/app/config/app_router.dart

// import 'package:go_router/go_router.dart';
// import 'app_routes.dart';
// import '../core/widgets/error_page.dart';
// import '../../features/home/presentation/home_shell.dart';
// import '../../features/education/presentation/education_screen.dart';
// import '../../features/attendance/presentation/screens/attendance_screen.dart';
// import '../../features/aptitude/presentation/screens/aptitude_initial_screen.dart';
// import '../../features/wrong_note/presentation/wrong_note_screen.dart';
// import '../../features/mypage/presentation/mypage_screen.dart';
// import '../../features/education/presentation/theory_screen.dart';
// import '../../features/auth/presentation/login_screen.dart';
// import '../../features/auth/presentation/signup_screen.dart';
// import '../../features/aptitude/presentation/screens/aptitude_quiz_screen.dart';
// import '../../features/aptitude/presentation/screens/aptitude_result_screen.dart';
// import '../../features/note/presentation/screens/note_list_screen.dart';
// import '../../features/note/presentation/screens/note_editor_screen.dart';

// /// 앱 전체의 라우팅을 관리하는 GoRouter 설정
// class AppRouter {
//   // GoRouter 인스턴스 생성
//   static final GoRouter _router = GoRouter(
//     // =================================================================
//     // ✅ [수정] 초기 화면을 노트 목록 화면으로 임시 변경
//     // 개발 완료 후에는 다시 AppRoutes.login 으로 변경해주세요.
//     // =_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_
//     initialLocation: AppRoutes.noteList,
//     // =================================================================

//     // 에러 발생 시 표시할 화면
//     errorBuilder: (context, state) => const ErrorPage(),

//     // 전체 라우트 정의
//     routes: [
//       // 로그인 화면
//       GoRoute(
//         path: AppRoutes.login,
//         builder: (context, state) => const LoginScreen(),
//       ),
//       // 회원가입 화면
//       GoRoute(
//         path: AppRoutes.register,
//         builder: (context, state) => const SignupScreen(),
//       ),

//       // 하단 네비게이션 바가 있는 메인 화면 (ShellRoute)
//       ShellRoute(
//         builder: (context, state, child) {
//           return HomeShell(child: child);
//         },
//         routes: [
//           // 교육 화면
//           GoRoute(
//             path: AppRoutes.education,
//             pageBuilder: (context, state) =>
//                 const NoTransitionPage(child: EducationScreen()),
//           ),
//           // 출석 화면
//           GoRoute(
//             path: AppRoutes.attendance,
//             pageBuilder: (context, state) =>
//                 const NoTransitionPage(child: AttendanceScreen()),
//           ),
//           // 성향 분석 초기 화면
//           GoRoute(
//             path: AppRoutes.aptitude,
//             pageBuilder: (context, state) =>
//                 const NoTransitionPage(child: AptitudeInitialScreen()),
//           ),
//           // 오답 노트 화면
//           GoRoute(
//             path: AppRoutes.wrongNote,
//             pageBuilder: (context, state) =>
//                 const NoTransitionPage(child: WrongNoteScreen()),
//           ),
//           // 마이페이지 화면
//           GoRoute(
//             path: AppRoutes.mypage,
//             pageBuilder: (context, state) =>
//                 const NoTransitionPage(child: MypageScreen()),
//           ),
//         ],
//       ),

//       // 하단 네비게이션 바가 없는 독립적인 전체 화면들
//       // 이론 학습 화면
//       GoRoute(
//         path: AppRoutes.theory,
//         builder: (context, state) => const TheoryScreen(),
//       ),
//       // 성향 분석 퀴즈 화면
//       GoRoute(
//         path: AppRoutes.aptitudeQuiz,
//         builder: (context, state) => const AptitudeQuizScreen(),
//       ),
//       // 성향 분석 결과 화면
//       GoRoute(
//         path: AppRoutes.aptitudeResult,
//         builder: (context, state) => const AptitudeResultScreen(),
//       ),
//       // 노트 목록 화면
//       GoRoute(
//         path: AppRoutes.noteList,
//         builder: (context, state) => const NoteListScreen(),
//       ),
//       // 노트 에디터(작성/수정) 화면
//       GoRoute(
//         path: AppRoutes.noteEditor,
//         builder: (context, state) {
//           // NoteListScreen에서 extra로 Note(편집 시) 또는 NoteTemplate(생성 시) 객체를 전달받음
//           final initialData = state.extra;
//           return NoteEditorScreen(initialData: initialData);
//         },
//       ),
//     ],
//   );

//   /// 외부에서 라우터 설정에 접근하기 위한 getter
//   static GoRouter get router => _router;
// }