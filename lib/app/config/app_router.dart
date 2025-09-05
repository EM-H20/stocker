import 'package:flutter/foundation.dart';
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
    initialLocation: AppRoutes.home, // 홈(메인 대시보드)을 초기 화면으로
    debugLogDiagnostics: true, // ✅ GoRouter 내부 디버깅 로그 활성화
    routes: [
      // 메인 대시보드 화면 (홈)
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) {
          debugPrint('🏠 [ROUTER] 홈(메인 대시보드) 페이지 로드');
          return const MainDashboardScreen();
        },
      ),

      // 로그인 화면 (완전한 애니메이션 제거)
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) {
          debugPrint('🔐 [ROUTER] 로그인 페이지 로드 (완전한 애니메이션 제거)');
          return CustomTransitionPage(
            key: state.pageKey,
            child: const LoginScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              // 뒤로가기 포함 모든 애니메이션 완전 제거
              return child;
            },
          );
        },
      ),

      // 회원가입 화면 (완전한 애니메이션 제거)
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (context, state) {
          debugPrint('📝 [ROUTER] 회원가입 페이지 로드 (완전한 애니메이션 제거)');
          return CustomTransitionPage(
            key: state.pageKey,
            child: const SignupScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              // 뒤로가기 포함 모든 애니메이션 완전 제거
              return child;
            },
          );
        },
      ),

      // ShellRoute로 BottomNavigationBar를 유지하면서 탭 라우팅 (4개 탭)
      ShellRoute(
        builder: (context, state, child) {
          return HomeShell(child: child);
        },
        routes: [
          // 교육 탭 (완전한 애니메이션 제거)
          GoRoute(
            path: AppRoutes.education,
            pageBuilder: (context, state) {
              debugPrint('🎓 [ROUTER] 교육 탭 로드 (완전한 애니메이션 제거)');
              return CustomTransitionPage(
                key: state.pageKey,
                child: const EducationScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  // 애니메이션 완전 제거: 항상 child를 그대로 반환
                  return child;
                },
              );
            },
          ),

          // 출석 탭 (완전한 애니메이션 제거)
          GoRoute(
            path: AppRoutes.attendance,
            pageBuilder: (context, state) {
              debugPrint('📅 [ROUTER] 출석 탭 로드 (완전한 애니메이션 제거)');
              return CustomTransitionPage(
                key: state.pageKey,
                child: const AttendanceScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  // 애니메이션 완전 제거: 항상 child를 그대로 반환
                  return child;
                },
              );
            },
          ),

          // 오답노트 탭 (완전한 애니메이션 제거)
          GoRoute(
            path: AppRoutes.wrongNote,
            pageBuilder: (context, state) {
              debugPrint('📝 [ROUTER] 오답노트 탭 로드 (완전한 애니메이션 제거)');
              return CustomTransitionPage(
                key: state.pageKey,
                child: const WrongNoteScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  // 애니메이션 완전 제거: 항상 child를 그대로 반환
                  return child;
                },
              );
            },
          ),

          // 마이페이지 탭 (완전한 애니메이션 제거)
          GoRoute(
            path: AppRoutes.mypage,
            pageBuilder: (context, state) {
              debugPrint('👤 [ROUTER] 마이페이지 탭 로드 (완전한 애니메이션 제거)');
              return CustomTransitionPage(
                key: state.pageKey,
                child: const MypageScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  // 애니메이션 완전 제거: 항상 child를 그대로 반환
                  return child;
                },
              );
            },
          ),
        ],
      ),

      // 이론 학습 화면 (애니메이션 없음)
      GoRoute(
        path: AppRoutes.theory,
        pageBuilder: (context, state) {
          final chapterIdStr = state.uri.queryParameters['chapterId'];
          final chapterId = int.tryParse(chapterIdStr ?? '') ?? 1;
          debugPrint(
              '📚 [ROUTER] 이론 학습 페이지 로드 (애니메이션 없음) - Chapter $chapterId');
          return NoTransitionPage(
            child: TheoryScreen(chapterId: chapterId),
          );
        },
      ),

      // === euimin 브랜치 기능들 ===
      // 퀴즈 화면 (애니메이션 없음)
      GoRoute(
        path: AppRoutes.quiz,
        pageBuilder: (context, state) {
          final chapterIdStr = state.uri.queryParameters['chapterId'];
          final chapterId = int.tryParse(chapterIdStr ?? '') ?? 1;
          debugPrint('🎯 [ROUTER] 퀴즈 페이지 로드 (애니메이션 없음) - Chapter $chapterId');
          return NoTransitionPage(
            child: QuizScreen(chapterId: chapterId),
          );
        },
      ),

      // 퀴즈 결과 화면 (애니메이션 없음)
      GoRoute(
        path: AppRoutes.quizResult,
        pageBuilder: (context, state) {
          final chapterIdStr = state.uri.queryParameters['chapterId'];
          final chapterId = int.tryParse(chapterIdStr ?? '') ?? 1;
          debugPrint(
              '📊 [ROUTER] 퀴즈 결과 페이지 로드 (애니메이션 없음) - Chapter $chapterId');
          return NoTransitionPage(
            child: QuizResultScreen(chapterId: chapterId),
          );
        },
      ),

      // === subin 브랜치 새로운 기능들 ===
      // 성향 분석 메인 화면 (완전한 애니메이션 제거)
      GoRoute(
        path: AppRoutes.aptitude,
        pageBuilder: (context, state) {
          debugPrint('🧠 [ROUTER] 성향분석 메인 페이지 로드 (완전한 애니메이션 제거)');
          return CustomTransitionPage(
            key: state.pageKey,
            child: const AptitudeInitialScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              // 애니메이션 완전 제거: 항상 child를 그대로 반환
              return child;
            },
          );
        },
      ),

      // 성향 분석 퀴즈 화면 (애니메이션 없음)
      GoRoute(
        path: AppRoutes.aptitudeQuiz,
        pageBuilder: (context, state) {
          debugPrint('📝 [ROUTER] 성향분석 퀴즈 페이지 로드 (애니메이션 없음)');
          return const NoTransitionPage(child: AptitudeQuizScreen());
        },
      ),

      // 성향 분석 결과 화면 (애니메이션 없음)
      GoRoute(
        path: AppRoutes.aptitudeResult,
        pageBuilder: (context, state) {
          debugPrint('📊 [ROUTER] 성향분석 결과 페이지 로드 (애니메이션 없음)');
          // extra로 전달된 isMyResult 값을 받음 (없으면 true가 기본값)
          final isMyResult = (state.extra as bool?) ?? true;
          return NoTransitionPage(
            child: AptitudeResultScreen(isMyResult: isMyResult),
          );
        },
      ),

      // 모든 성향 목록 화면 (애니메이션 없음)
      GoRoute(
        path: AppRoutes.aptitudeTypesList,
        pageBuilder: (context, state) {
          debugPrint('📋 [ROUTER] 성향분석 목록 페이지 로드 (애니메이션 없음)');
          return const NoTransitionPage(child: AptitudeTypesListScreen());
        },
      ),

      // 노트 목록 화면 (subin 새 기능, 애니메이션 없음)
      GoRoute(
        path: AppRoutes.noteList,
        pageBuilder: (context, state) {
          debugPrint('📝 [ROUTER] 노트 목록 페이지 로드 (애니메이션 없음)');
          return const NoTransitionPage(child: NoteListScreen());
        },
      ),

      // 노트 에디터 화면 (subin 새 기능, 애니메이션 없음)
      GoRoute(
        path: AppRoutes.noteEditor,
        pageBuilder: (context, state) {
          debugPrint('✏️ [ROUTER] 노트 에디터 페이지 로드 (애니메이션 없음)');
          // extra로 Note(편집) 또는 NoteTemplate(생성) 객체를 전달받음
          final initialData = state.extra;
          return NoTransitionPage(
            child: NoteEditorScreen(initialData: initialData),
          );
        },
      ),
    ],

    // 에러 페이지 처리
    errorBuilder: (context, state) =>
        ErrorPage(errorPath: state.matchedLocation),
  );

  static GoRouter get router => _router;
}
