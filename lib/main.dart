import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart' as legacy_provider; // 🔥 Provider에 prefix 추가 (공존 기간)
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 🔥 Riverpod 추가!
// import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 🔥 Riverpod Repository Providers에서 사용
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// euimin 브랜치 기능들
// import 'package:stocker/features/education/domain/education_mock_repository.dart'; // 🔥 Riverpod으로 이동됨
// import 'package:stocker/features/education/data/education_api.dart'; // 🔥 Riverpod으로 이동됨
// import 'package:stocker/features/education/domain/education_repository.dart'; // 🔥 Riverpod으로 이동됨
// import 'package:stocker/features/quiz/domain/quiz_mock_repository.dart'; // 🔥 Riverpod으로 이동됨
// import 'package:stocker/features/quiz/data/quiz_api.dart'; // 🔥 Riverpod으로 이동됨
// import 'package:stocker/features/quiz/domain/quiz_repository.dart'; // 🔥 Riverpod으로 이동됨
// import 'package:stocker/features/wrong_note/data/wrong_note_mock_repository.dart'; // 🔥 Riverpod으로 이동됨
// import 'package:stocker/app/core/providers/theme_provider.dart'; // 🔥 Riverpod으로 교체됨
import 'package:stocker/app/core/providers/riverpod/theme_notifier.dart'; // 🔥 Riverpod ThemeNotifier
import 'app/config/app_theme.dart';
import 'app/config/app_router.dart';
// import 'features/home/presentation/home_navigation_provider.dart'; // 🔥 Riverpod으로 교체됨
// import 'features/education/presentation/education_provider.dart'; // 🔥 Riverpod으로 교체됨
// import 'features/quiz/presentation/quiz_provider.dart'; // 🔥 Riverpod으로 교체됨
// import 'features/wrong_note/presentation/wrong_note_provider.dart'; // 🔥 Riverpod으로 이동됨
// import 'features/wrong_note/data/wrong_note_api.dart'; // 🔥 Riverpod으로 이동됨
// import 'features/wrong_note/domain/wrong_note_repository.dart'; // 🔥 Riverpod으로 이동됨

// subin 브랜치 새로운 기능들 (Repository & API)
// import 'features/auth/presentation/auth_provider.dart'; // 🔥 Riverpod으로 교체됨
// import 'features/auth/presentation/riverpod/auth_notifier.dart'; // 🔥 Riverpod AuthNotifier (UI에서 직접 사용)
// import 'features/note/presentation/provider/note_provider.dart'; // 🔥 Riverpod으로 교체됨
// import 'features/auth/domain/auth_repository.dart'; // 🔥 Riverpod으로 이동됨
// import 'features/auth/data/source/auth_api.dart'; // 🔥 Riverpod으로 이동됨
// import 'features/auth/data/repository/auth_api_repository.dart'; // 🔥 Riverpod으로 이동됨
// import 'features/auth/data/repository/auth_mock_repository.dart'; // 🔥 Riverpod으로 이동됨

// 출석 기능 (subin에서 강화)
// import 'features/attendance/presentation/provider/attendance_provider.dart'; // 🔥 Riverpod으로 교체됨
// import 'features/attendance/domain/repository/attendance_repository.dart'; // 🔥 Riverpod으로 이동됨
// import 'features/attendance/data/source/attendance_api.dart'; // 🔥 Riverpod으로 이동됨
// import 'features/attendance/data/repository/attendance_api_repository.dart'; // 🔥 Riverpod으로 이동됨
// import 'features/attendance/data/repository/attendance_mock_repository.dart'; // 🔥 Riverpod으로 이동됨

// 성향분석 기능 (subin에서 완전 구현)
// import 'features/aptitude/domain/repository/aptitude_repository.dart'; // 🔥 Riverpod으로 이동됨
// import 'features/aptitude/data/source/aptitude_api.dart'; // 🔥 Riverpod으로 이동됨
// import 'features/aptitude/data/repository/aptitude_api_repository.dart'; // 🔥 Riverpod으로 이동됨
// import 'features/aptitude/data/repository/aptitude_mock_repository.dart'; // 🔥 Riverpod으로 이동됨
// import 'features/aptitude/presentation/provider/aptitude_provider.dart'; // 🔥 Riverpod으로 이동됨
// import 'features/learning/presentation/provider/learning_progress_provider.dart'; // 🔥 Riverpod으로 교체됨
// import 'features/learning/data/repository/learning_progress_mock_repository.dart'; // 🔥 Riverpod으로 이동됨
// import 'features/learning/data/repository/learning_progress_api_repository.dart'; // 🔥 Riverpod으로 이동됨
// import 'features/learning/data/source/learning_progress_api.dart'; // 🔥 Riverpod으로 이동됨

// 노트 기능 (subin 새 기능)
// import 'features/note/domain/repository/note_repository.dart'; // 🔥 Riverpod으로 이동됨
// import 'features/note/data/source/note_api.dart'; // 🔥 Riverpod으로 이동됨
// import 'features/note/data/repository/note_api_repository.dart'; // 🔥 Riverpod으로 이동됨
// import 'features/note/data/repository/note_mock_repository.dart'; // 🔥 Riverpod으로 이동됨

// 🔥 Riverpod Repository Providers (각 Notifier 파일에서 직접 import)
// import 'app/core/providers/riverpod/repository_providers.dart'; // main.dart에서는 불필요

// Network (subin에서 개선)
import 'app/core/network/dio.dart';
import 'app/core/services/token_storage.dart';

/// ✅ 더미(mock) 여부 설정 - launch.json에서 --dart-define으로 제어
const useMock =
    String.fromEnvironment('USE_MOCK', defaultValue: 'false') == 'true';

/// 🧪 테스트용 유저 자동 생성 - launch.json에서 --dart-define으로 제어
const createTestUserOnStart =
    String.fromEnvironment('CREATE_TEST_USER', defaultValue: 'false') == 'true';

void main() async {
  await initializeDateFormatting();
  WidgetsFlutterBinding.ensureInitialized();

  // 환경 변수 로드
  debugPrint('🔧 [INIT] Loading environment variables...');
  await dotenv.load(fileName: ".env");
  debugPrint(
      '✅ [INIT] Environment loaded - API_BASE_URL: ${dotenv.env['API_BASE_URL']}');

  await setupDio();

  // 🧪 Mock 모드에서 테스트 유저 자동 생성
  if (useMock && createTestUserOnStart) {
    debugPrint('🧪 [INIT] Mock 모드 - 테스트 유저 자동 생성...');
    await TokenStorage.createTestUser();
  }

  // 🔥 Riverpod ProviderScope로 앱 전체 감싸기
  runApp(
    ProviderScope(
      child: const StockerApp(),
    ),
  );
}

class StockerApp extends StatelessWidget {
  const StockerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return legacy_provider.MultiProvider(
      providers: [
        // 🔥 Repository 계층은 Riverpod으로 이동됨
        // === Repository 계층 (subin 스타일) ===
        // legacy_provider.Provider<AuthRepository>(
        //   create: (_) =>
        //       useMock ? AuthMockRepository() : AuthApiRepository(AuthApi(dio)),
        // ),
        // legacy_provider.Provider<AttendanceRepository>(
        //   create: (_) => useMock
        //       ? AttendanceMockRepository()
        //       : AttendanceApiRepository(AttendanceApi(dio)),
        // ),
        // legacy_provider.Provider<AptitudeRepository>(
        //   create: (_) => useMock
        //       ? AptitudeMockRepository()
        //       : AptitudeApiRepository(AptitudeApi(dio)),
        // ),
        // legacy_provider.Provider<NoteRepository>(
        //   create: (_) =>
        //       useMock ? NoteMockRepository() : NoteApiRepository(NoteApi(dio)),
        // ),

        // === Provider 계층 ===
        // 🔥 테마 상태 관리는 Riverpod으로 이동됨 (ThemeNotifier)
        // legacy_provider.ChangeNotifierProvider(
        //   create: (_) => ThemeProvider()..initialize(),
        // ),

        // 🔥 홈 네비게이션 상태 관리는 Riverpod으로 이동됨 (HomeNavigationNotifier)
        // legacy_provider.ChangeNotifierProvider(create: (_) => HomeNavigationProvider()),

        // 🔥 Auth Provider는 Riverpod으로 이동됨 (AuthNotifier)
        // AuthNotifier는 AsyncNotifier로 build() 메서드에서 자동 초기화됨
        // legacy_provider.ChangeNotifierProvider(
        //   create: (context) {
        //     debugPrint(
        //         '🔐 [PROVIDER] Creating AuthProvider (useMock: $useMock)');
        //     final authProvider = AuthProvider(context.read<AuthRepository>());
        //
        //     // Mock/Real 환경 모두에서 초기화 실행
        //     debugPrint('🔄 [PROVIDER] AuthProvider 초기화 시작...');
        //     authProvider.initialize().then((_) {
        //       // 🔧 [수정] 강제 자동 로그인 비활성화 - 첫 화면을 로그인 화면으로 복원
        //       // 나중에 사용자 설정에 따른 선택적 자동 로그인 구현 가능
        //       // if (!authProvider.isLoggedIn && !useMock) {
        //       //   debugPrint('🚨 [PROVIDER] 로그인되지 않음 - 테스트 로그인 수행');
        //       //   authProvider.quickTestLogin();
        //       // }
        //       debugPrint('ℹ️ [PROVIDER] 초기화 완료 - 로그인 화면부터 시작');
        //     });
        //
        //     return authProvider;
        //   },
        // ),

        // 🔥 Education Provider는 Riverpod으로 이동됨 (EducationNotifier)
        // legacy_provider.ChangeNotifierProvider(
        //   create: (_) {
        //     debugPrint(
        //         '🎯 [PROVIDER] Creating EducationProvider (useMock: $useMock)');
        //     if (useMock) {
        //       final mockRepository = EducationMockRepository();
        //       return EducationProvider.withMock(mockRepository);
        //     } else {
        //       const storage = FlutterSecureStorage();
        //       final educationApi = EducationApi(dio); // 글로벌 dio 사용
        //       final educationRepository =
        //           EducationRepository(educationApi, storage);
        //       return EducationProvider(educationRepository);
        //     }
        //   },
        // ),

        // 🔥 Quiz Provider는 Riverpod으로 이동됨 (QuizNotifier)
        // legacy_provider.ChangeNotifierProvider(
        //   create: (_) {
        //     debugPrint(
        //         '🎯 [PROVIDER] Creating QuizProvider (useMock: $useMock)');
        //     if (useMock) {
        //       final mockRepository = QuizMockRepository();
        //       return QuizProvider.withMock(mockRepository);
        //     } else {
        //       const storage = FlutterSecureStorage();
        //       final quizApi = QuizApi(dio); // 글로벌 dio 사용
        //       final quizRepository = QuizRepository(quizApi, storage);
        //       return QuizProvider(quizRepository);
        //     }
        //   },
        // ),

        // 🔥 WrongNote Provider는 Riverpod으로 이동됨 (WrongNoteNotifier)
        // legacy_provider.ChangeNotifierProvider(
        //   create: (_) {
        //     debugPrint(
        //         '🎯 [PROVIDER] Creating WrongNoteProvider (useMock: $useMock)');
        //     if (useMock) {
        //       final mockRepository = WrongNoteMockRepository();
        //       return WrongNoteProvider.withMock(mockRepository);
        //     } else {
        //       final wrongNoteApi = WrongNoteApi(dio); // 글로벌 dio 사용
        //       final wrongNoteRepository = WrongNoteRepository(wrongNoteApi);
        //       return WrongNoteProvider(wrongNoteRepository);
        //     }
        //   },
        // ),

        // 🔥 Attendance Provider는 Riverpod으로 이동됨 (AttendanceNotifier)
        // legacy_provider.ChangeNotifierProvider(
        //   create: (context) => AttendanceProvider(
        //     context.read<AttendanceRepository>(),
        //   ),
        // ),

        // 🔥 Aptitude Provider는 Riverpod으로 이동됨 (AptitudeNotifier)
        // legacy_provider.ChangeNotifierProvider(
        //   create: (context) =>
        //       AptitudeProvider(context.read<AptitudeRepository>()),
        // ),

        // 🔥 Note Provider는 Riverpod으로 이동됨 (NoteNotifier)
        // legacy_provider.ChangeNotifierProvider(
        //   create: (context) => NoteProvider(context.read<NoteRepository>()),
        // ),

        // 🔥 [RIVERPOD] LearningProgressNotifier - Repository 패턴으로 Riverpod 변환 완료!
        // LearningProgressProvider는 더 이상 사용되지 않음 (Riverpod으로 교체됨)
        // Repository Provider는 app/core/providers/riverpod/repository_providers.dart 참고
        // 사용법: ref.read(learningProgressNotifierProvider.notifier).completeChapter(chapterId)

        // 🔥 콜백 시스템은 모든 Provider → Notifier 변환 완료 후 재활성화 예정
        // 현재 비활성화된 콜백들:
        // - EducationNotifier → LearningProgressNotifier: completeChapter
        // - QuizNotifier → EducationNotifier: updateQuizCompletion
        // - QuizNotifier → WrongNoteNotifier: submitWrongAnswers

        // 🔥 TODO: 모든 Provider → Notifier 변환 완료 후 콜백 시스템 재활성화 필요
        // 주석 처리된 콜백들:
        // - QuizProvider -> EducationProvider: updateQuizCompletion
        // - QuizProvider -> WrongNoteProvider: 일반 퀴즈 오답 제출
        // - QuizProvider -> WrongNoteProvider: 단일 퀴즈 오답 처리
      ],
      child: ScreenUtilInit(
        designSize: const Size(393, 852),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          // 🔥 Riverpod Consumer로 변환!
          return Consumer(
            builder: (context, ref, child) {
              // 🔥 Riverpod: ref.watch()로 테마 모드 구독
              final currentThemeMode = ref.watch(themeModeProvider);

              return MaterialApp.router(
                title: 'Stocker',
                debugShowCheckedModeBanner: false,

                // euimin 다크/라이트 테마 유지
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: currentThemeMode, // 🔥 Riverpod에서 가져온 테마

                // subin의 Quill 로캘 설정 추가
                locale: const Locale('ko'),
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  quill.FlutterQuillLocalizations.delegate,
                ],
                supportedLocales: [
                  const Locale('en'),
                  const Locale('ko'),
                  ...quill.FlutterQuillLocalizations.supportedLocales,
                ],

                routerConfig: AppRouter.router,
              );
            },
          );
        },
      ),
    );
  }
}
