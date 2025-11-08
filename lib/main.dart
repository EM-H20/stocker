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
import 'features/learning/presentation/provider/learning_progress_provider.dart';
import 'features/learning/data/repository/learning_progress_mock_repository.dart';
import 'features/learning/data/repository/learning_progress_api_repository.dart';
import 'features/learning/data/source/learning_progress_api.dart';

// 노트 기능 (subin 새 기능)
import 'features/note/domain/repository/note_repository.dart';
import 'features/note/data/source/note_api.dart';
import 'features/note/data/repository/note_api_repository.dart';
import 'features/note/data/repository/note_mock_repository.dart';

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
            authProvider.initialize().then((_) {
              // 🔧 [수정] 강제 자동 로그인 비활성화 - 첫 화면을 로그인 화면으로 복원
              // 나중에 사용자 설정에 따른 선택적 자동 로그인 구현 가능
              // if (!authProvider.isLoggedIn && !useMock) {
              //   debugPrint('🚨 [PROVIDER] 로그인되지 않음 - 테스트 로그인 수행');
              //   authProvider.quickTestLogin();
              // }
              debugPrint('ℹ️ [PROVIDER] 초기화 완료 - 로그인 화면부터 시작');
            });

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
              final wrongNoteApi = WrongNoteApi(dio); // 글로벌 dio 사용
              final wrongNoteRepository = WrongNoteRepository(wrongNoteApi);
              return WrongNoteProvider(wrongNoteRepository);
            }
          },
        ),

        // Attendance Provider (subin 새 기능)
        ChangeNotifierProvider(
          create: (context) => AttendanceProvider(
            context.read<AttendanceRepository>(),
          ),
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

        // Learning Progress Provider (Repository 패턴 적용) - 🚀 새로운 안전한 구조
        ChangeNotifierProvider(
          create: (context) {
            debugPrint(
                '🎯 [PROVIDER] Creating LearningProgressProvider (useMock: $useMock)');

            LearningProgressProvider learningProgressProvider;
            if (useMock) {
              // Mock 환경: Mock Repository 사용
              final mockRepository = LearningProgressMockRepository();
              learningProgressProvider =
                  LearningProgressProvider(mockRepository);
            } else {
              // Real 환경: API Repository 사용
              final learningProgressApi = LearningProgressApi(dio);
              final educationProvider = context.read<EducationProvider>();
              final apiRepository = LearningProgressApiRepository(
                  learningProgressApi, educationProvider);
              learningProgressProvider =
                  LearningProgressProvider(apiRepository);
            }

            // 🔥 단 한 번만 실행되는 콜백 등록 로직을 여기에 배치!
            debugPrint(
                '🔗 [PROVIDER] Setting up one-time Provider callbacks...');

            final educationProvider = context.read<EducationProvider>();
            final quizProvider = context.read<QuizProvider>();
            final wrongNoteProvider = context.read<WrongNoteProvider>();

            // 🎯 콜백 등록 (create에서 단 한 번만 실행됨!)

            // 1. EducationProvider -> LearningProgressProvider 콜백
            educationProvider.addOnChapterCompletedCallback((int chapterId) {
              debugPrint(
                  '🎉 [CALLBACK] 챕터 $chapterId 완료 - LearningProgress에 알림');
              learningProgressProvider.completeChapter(chapterId);
            });

            // 2. QuizProvider -> EducationProvider 콜백
            quizProvider.addOnQuizCompletedCallback((chapterId, result) {
              debugPrint(
                  '🎯 [CALLBACK] 퀴즈 $chapterId 완료 - Education에 알림 (${result.scorePercentage}%)');
              educationProvider.updateQuizCompletion(chapterId,
                  isPassed: result.isPassed);
            });

            // 3. 🔥 QuizProvider -> WrongNoteProvider 일반 퀴즈 콜백
            quizProvider.addOnQuizCompletedCallback((chapterId, result) async {
              debugPrint(
                  '📝 [GENERAL_QUIZ_CALLBACK] 일반 퀴즈 $chapterId 완료 - 오답노트 업데이트 시작...');
              try {
                final currentSession = quizProvider.currentQuizSession;
                if (currentSession != null &&
                    !currentSession.isSingleQuizMode) {
                  debugPrint(
                      '✅ [GENERAL_QUIZ_CALLBACK] 일반 퀴즈 모드 확인됨. 계속 진행...');

                  final wrongItems = <Map<String, dynamic>>[];
                  for (int i = 0; i < currentSession.quizList.length; i++) {
                    final quiz = currentSession.quizList[i];
                    final userAnswer = currentSession.userAnswers[i];

                    if (userAnswer != null &&
                        userAnswer != quiz.correctAnswerIndex) {
                      wrongItems.add({
                        'quiz_id': quiz.id,
                        'selected_option': userAnswer + 1, // 0-based -> 1-based
                      });
                    }
                  }

                  await wrongNoteProvider.submitQuizResults(
                      chapterId, wrongItems);
                  debugPrint(
                      '✅ [GENERAL_QUIZ_CALLBACK] 오답노트 업데이트 완료 - ${wrongItems.length}개 오답 항목');
                }
              } catch (e) {
                debugPrint('❌ [GENERAL_QUIZ_CALLBACK] 오답노트 업데이트 실패: $e');
              }
            });

            // 4. 🎯 QuizProvider -> WrongNoteProvider 단일 퀴즈 콜백 (핵심!)
            quizProvider.addOnSingleQuizCompletedCallback(
                (chapterId, quizId, isCorrect, selectedOption) async {
              final isReadOnlyMode = quizProvider.isReadOnlyMode;
              debugPrint(
                  '🎯 [SINGLE_QUIZ_CALLBACK] 단일 퀴즈 완료 - Chapter: $chapterId, Quiz: $quizId, 정답: $isCorrect, ReadOnly: $isReadOnlyMode');

              if (isReadOnlyMode) {
                // 📖 읽기 전용 모드: DB 수정 없이 프론트엔드 상태만 업데이트
                debugPrint(
                    '📖 [SINGLE_QUIZ_CALLBACK] 읽기 전용 모드 - DB 수정 없이 프론트엔드 상태만 업데이트');
                if (isCorrect) {
                  // 🛡️ ReadOnly 모드에서는 로컬 상태만 업데이트하고 절대 삭제하지 않음
                  wrongNoteProvider.markAsRetriedLocally(quizId);
                  debugPrint(
                      '✅ [SINGLE_QUIZ_CALLBACK] Quiz $quizId 로컬 재시도 마크 완료 (DB 수정 없음, 삭제 없음!)');
                } else {
                  // ReadOnly 모드에서 오답일 경우도 DB에 추가하지 않음
                  debugPrint(
                      '📖 [SINGLE_QUIZ_CALLBACK] ReadOnly 모드에서 오답 - DB 추가 없음');
                }
                return; // 읽기 전용 모드에서는 여기서 완전 종료
              }

              // 🔄 일반 모드: 기존 로직 유지 (DB 수정 포함)
              if (isCorrect) {
                // ✅ 정답: 오답노트에서 삭제하지 않고 재시도 마크만 업데이트
                try {
                  await wrongNoteProvider.markAsRetried(quizId);
                  debugPrint(
                      '✅ [SINGLE_QUIZ_CALLBACK] Quiz $quizId 재시도 완료 마크 - 복습용으로 유지됨');
                } catch (e) {
                  debugPrint(
                      '❌ [SINGLE_QUIZ_CALLBACK] Quiz $quizId 재시도 마크 실패: $e');
                }
              } else {
                // ❌ 오답: 오답노트에 추가 (기존과 동일)
                try {
                  await wrongNoteProvider.submitSingleQuizResult(
                      chapterId, quizId, selectedOption);
                  debugPrint(
                      '✅ [SINGLE_QUIZ_CALLBACK] 오답노트에 Quiz $quizId 추가 완료');
                } catch (e) {
                  debugPrint('❌ [SINGLE_QUIZ_CALLBACK] Quiz $quizId 추가 실패: $e');
                }
              }
            });

            debugPrint('✅ [PROVIDER] 모든 콜백 등록 완료 (단 한 번만 실행됨!)');

            return learningProgressProvider;
          },
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
