import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// euimin 브랜치 기능들
import 'package:stocker/features/education/domain/education_mock_repository.dart';
import 'package:stocker/features/education/data/education_api.dart';
import 'package:stocker/features/education/domain/education_repository.dart';
import 'package:stocker/features/quiz/domain/quiz_mock_repository.dart';
import 'package:stocker/features/quiz/data/quiz_api.dart';
import 'package:stocker/features/quiz/domain/quiz_repository.dart';
import 'package:stocker/features/wrong_note/data/wrong_note_mock_repository.dart';
import 'package:stocker/app/core/providers/theme_provider.dart';
import 'app/config/app_theme.dart';
import 'app/config/app_router.dart';
import 'features/home/presentation/home_navigation_provider.dart';
import 'features/education/presentation/education_provider.dart';
import 'features/quiz/presentation/quiz_provider.dart';
import 'features/wrong_note/presentation/wrong_note_provider.dart';
import 'features/wrong_note/data/wrong_note_api.dart';
import 'features/wrong_note/domain/wrong_note_repository.dart';

// subin 브랜치 새로운 기능들 (Repository & API)
import 'features/auth/presentation/auth_provider.dart';
import 'features/note/presentation/provider/note_provider.dart';
import 'features/auth/domain/auth_repository.dart';
import 'features/auth/data/source/auth_api.dart';
import 'features/auth/data/repository/auth_api_repository.dart';
import 'features/auth/data/repository/auth_mock_repository.dart';

// 출석 기능 (subin에서 강화)
import 'features/attendance/presentation/provider/attendance_provider.dart';
import 'features/attendance/domain/repository/attendance_repository.dart';
import 'features/attendance/data/source/attendance_api.dart';
import 'features/attendance/data/repository/attendance_api_repository.dart';
import 'features/attendance/data/repository/attendance_mock_repository.dart';

// 성향분석 기능 (subin에서 완전 구현)
import 'features/aptitude/domain/repository/aptitude_repository.dart';
import 'features/aptitude/data/source/aptitude_api.dart';
import 'features/aptitude/data/repository/aptitude_api_repository.dart';
import 'features/aptitude/data/repository/aptitude_mock_repository.dart';
import 'features/aptitude/presentation/provider/aptitude_provider.dart';

// 노트 기능 (subin 새 기능)
import 'features/note/domain/repository/note_repository.dart';
import 'features/note/data/source/note_api.dart';
import 'features/note/data/repository/note_api_repository.dart';
import 'features/note/data/repository/note_mock_repository.dart';

// Network (subin에서 개선)
import 'app/core/network/dio.dart';

/// ✅ 더미(mock) 여부 설정 (euimin 스타일 유지)
const useMock = true; // 실제 API 사용시 false

void main() async {
  await initializeDateFormatting();
  WidgetsFlutterBinding.ensureInitialized();

  // 환경 변수 로드
  debugPrint('🔧 [INIT] Loading environment variables...');
  await dotenv.load(fileName: ".env");
  debugPrint(
      '✅ [INIT] Environment loaded - API_BASE_URL: ${dotenv.env['API_BASE_URL']}');

  await setupDio();
  runApp(const StockerApp());
}

class StockerApp extends StatelessWidget {
  const StockerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // === Repository 계층 (subin 스타일) ===
        Provider<AuthRepository>(
          create: (_) =>
              useMock ? AuthMockRepository() : AuthApiRepository(AuthApi(dio)),
        ),
        Provider<AttendanceRepository>(
          create: (_) => useMock
              ? AttendanceMockRepository()
              : AttendanceApiRepository(AttendanceApi(dio)),
        ),
        Provider<AptitudeRepository>(
          create: (_) => useMock
              ? AptitudeMockRepository()
              : AptitudeApiRepository(AptitudeApi(dio)),
        ),
        Provider<NoteRepository>(
          create: (_) =>
              useMock ? NoteMockRepository() : NoteApiRepository(NoteApi(dio)),
        ),

        // === Provider 계층 ===
        // 테마 상태 관리 (euimin 핵심 기능 유지)
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..initialize(),
        ),

        // 홈 네비게이션 상태 관리
        ChangeNotifierProvider(create: (_) => HomeNavigationProvider()),

        // Auth Provider (subin에서 개선된 버전)
        ChangeNotifierProvider(
          create: (context) {
            debugPrint(
                '🔐 [PROVIDER] Creating AuthProvider (useMock: $useMock)');
            final authProvider = AuthProvider(context.read<AuthRepository>());

            // Mock/Real 환경 모두에서 초기화 실행
            debugPrint('🔄 [PROVIDER] AuthProvider 초기화 시작...');
            authProvider.initialize();

            return authProvider;
          },
        ),

        // Education 상태 관리 (euimin Mock/Real API 분기 패턴 유지)
        ChangeNotifierProvider(
          create: (_) {
            debugPrint(
                '🎯 [PROVIDER] Creating EducationProvider (useMock: $useMock)');
            if (useMock) {
              final mockRepository = EducationMockRepository();
              return EducationProvider.withMock(mockRepository);
            } else {
              const storage = FlutterSecureStorage();
              final educationApi = EducationApi(dio); // 글로벌 dio 사용
              final educationRepository =
                  EducationRepository(educationApi, storage);
              return EducationProvider(educationRepository);
            }
          },
        ),

        // Quiz 상태 관리 (euimin 기능)
        ChangeNotifierProvider(
          create: (_) {
            debugPrint(
                '🎯 [PROVIDER] Creating QuizProvider (useMock: $useMock)');
            if (useMock) {
              final mockRepository = QuizMockRepository();
              return QuizProvider.withMock(mockRepository);
            } else {
              const storage = FlutterSecureStorage();
              final quizApi = QuizApi(dio); // 글로벌 dio 사용
              final quizRepository = QuizRepository(quizApi, storage);
              return QuizProvider(quizRepository);
            }
          },
        ),

        // WrongNote 상태 관리 (euimin 기능)
        ChangeNotifierProvider(
          create: (_) {
            debugPrint(
                '🎯 [PROVIDER] Creating WrongNoteProvider (useMock: $useMock)');
            if (useMock) {
              final mockRepository = WrongNoteMockRepository();
              return WrongNoteProvider.withMock(mockRepository);
            } else {
              const storage = FlutterSecureStorage();
              final wrongNoteApi = WrongNoteApi(dio); // 글로벌 dio 사용
              final wrongNoteRepository =
                  WrongNoteRepository(wrongNoteApi, storage);
              return WrongNoteProvider(wrongNoteRepository);
            }
          },
        ),

        // Attendance Provider (subin 새 기능)
        ChangeNotifierProxyProvider<AuthProvider, AttendanceProvider>(
          create: (context) => AttendanceProvider(
            context.read<AttendanceRepository>(),
            context.read<AuthProvider>(),
          ),
          update: (context, auth, _) =>
              AttendanceProvider(context.read<AttendanceRepository>(), auth),
        ),

        // Aptitude Provider (subin 새 기능)
        ChangeNotifierProvider(
          create: (context) =>
              AptitudeProvider(context.read<AptitudeRepository>()),
        ),

        // Note Provider (subin 새 기능)
        ChangeNotifierProvider(
          create: (context) => NoteProvider(context.read<NoteRepository>()),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(393, 852),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          // euimin의 테마 Provider를 유지하면서 subin의 기능들 통합
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp.router(
                title: 'Stocker',
                debugShowCheckedModeBanner: false,

                // euimin 다크/라이트 테마 유지
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeProvider.themeMode,

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
