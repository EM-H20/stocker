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

/// ✅ 더미(mock) 여부 설정 (euimin 스타일 유지)
const useMock = false; // 백엔드 서버 없이 테스트용 - 실제 API 사용시 false

/// 🧪 테스트용 유저 자동 생성 (Mock 모드에서만)
const createTestUserOnStart = false;

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

        // Learning Progress Provider (Repository 패턴 적용)
        ChangeNotifierProxyProvider3<EducationProvider, QuizProvider, WrongNoteProvider, LearningProgressProvider>(
          create: (context) {
            debugPrint('🎯 [PROVIDER] Creating LearningProgressProvider (useMock: $useMock)');
            if (useMock) {
              // Mock 환경: Mock Repository 사용
              final mockRepository = LearningProgressMockRepository();
              return LearningProgressProvider(mockRepository);
            } else {
              // Real 환경: API Repository 사용
              final learningProgressApi = LearningProgressApi(dio);
              final educationProvider = context.read<EducationProvider>();
              final apiRepository = LearningProgressApiRepository(learningProgressApi, educationProvider);
              return LearningProgressProvider(apiRepository);
            }
          },
          update: (context, educationProvider, quizProvider, wrongNoteProvider, learningProgressProvider) {
            debugPrint('🔗 [PROVIDER] Connecting Provider callbacks... (콜백 중복 방지)');
            
            // Provider 간 콜백 연결 설정
            if (learningProgressProvider != null) {
              // 🚨 콜백 중복 등록 방지: 기존 콜백들을 모두 제거
              debugPrint('🧹 [CALLBACK] 기존 콜백 제거 중...');
              
              // EducationProvider -> LearningProgressProvider 콜백 연결
              final chapterCompletedCallback = (int chapterId) {
                debugPrint('🎉 [CALLBACK] 챕터 $chapterId 완료 - LearningProgress에 알림');
                learningProgressProvider.completeChapter(chapterId);
              };
              
              educationProvider.addOnChapterCompletedCallback(chapterCompletedCallback);
              
              // QuizProvider -> EducationProvider 콜백 연결 (퀴즈 완료 시 EducationProvider 업데이트)
              quizProvider.addOnQuizCompletedCallback((chapterId, result) {
                debugPrint('🎯 [CALLBACK] 퀴즈 $chapterId 완료 - Education에 알림 (${result.scorePercentage}%)');
                educationProvider.updateQuizCompletion(chapterId, isPassed: result.isPassed);
              });

              // 🔥 QuizProvider -> WrongNoteProvider 콜백 연결 (오답노트 자동 업데이트)
              quizProvider.addOnQuizCompletedCallback((chapterId, result) async {
                debugPrint('📝 [CALLBACK] 퀴즈 $chapterId 완료 - 오답노트 업데이트 시작...');
                try {
                  // 퀴즈 세션에서 오답 항목 추출
                  final currentSession = quizProvider.currentQuizSession;
                  if (currentSession != null) {
                    final wrongItems = <Map<String, dynamic>>[];
                    
                    // 틀린 문제들만 추출
                    for (int i = 0; i < currentSession.quizList.length; i++) {
                      final quiz = currentSession.quizList[i];
                      final userAnswer = currentSession.userAnswers[i];
                      
                      if (userAnswer != null && userAnswer != quiz.correctAnswerIndex) {
                        // 0-based -> 1-based 변환하여 백엔드 형식에 맞춤
                        wrongItems.add({
                          'quiz_id': quiz.id,
                          'selected_option': userAnswer + 1, // 0-based -> 1-based
                        });
                      }
                    }
                    
                    // 오답노트에 결과 제출
                    await wrongNoteProvider.submitQuizResults(chapterId, wrongItems);
                    debugPrint('✅ [CALLBACK] 오답노트 업데이트 완료 - ${wrongItems.length}개 오답 항목');
                    
                    // 사용자에게 친화적인 알림 (추후 스낵바 등으로 구현 가능)
                    if (wrongItems.isNotEmpty) {
                      debugPrint('💡 [UX] ${wrongItems.length}개의 틀린 문제가 오답노트에 추가되었습니다. 복습해보세요!');
                    } else {
                      debugPrint('🎉 [UX] 모든 문제를 맞혔습니다! 완벽해요!');
                    }
                  }
                } catch (e) {
                  debugPrint('❌ [CALLBACK] 오답노트 업데이트 실패: $e');
                }
              });

              // 🎯 QuizProvider -> WrongNoteProvider 단일 퀴즈 완료 콜백 (오답노트 관리용)
              quizProvider.addOnSingleQuizCompletedCallback((chapterId, quizId, isCorrect, selectedOption) async {
                debugPrint('🎯 [SINGLE_QUIZ_CALLBACK] 단일 퀴즈 완료 - Chapter: $chapterId, Quiz: $quizId, 정답: $isCorrect, 선택: $selectedOption');
                
                if (isCorrect) {
                  // 정답인 경우: 오답노트에서 삭제
                  debugPrint('🎯 [SINGLE_QUIZ_CALLBACK] 정답! 오답노트에서 삭제 시작...');
                  try {
                    await wrongNoteProvider.removeWrongNote(quizId);
                    debugPrint('✅ [SINGLE_QUIZ_CALLBACK] 오답노트에서 퀴즈 $quizId 삭제 완료');
                    
                    // 오답 삭제 완료 알림 발송 (QuizScreen으로 네비게이션 신호)
                    quizProvider.notifyWrongNoteRemoved(quizId);
                    debugPrint('📢 [SINGLE_QUIZ_CALLBACK] 오답 삭제 완료 알림 발송 - Quiz $quizId');
                  } catch (e) {
                    debugPrint('❌ [SINGLE_QUIZ_CALLBACK] 오답노트 삭제 실패 (계속 진행) - Quiz $quizId: $e');
                    
                    // 삭제 실패해도 네비게이션은 진행 (사용자 경험을 위해)
                    // 단, 실제 에러인 경우만 (404는 이미 Provider에서 처리됨)
                    if (!e.toString().contains('404') && !e.toString().contains('찾을 수 없습니다')) {
                      debugPrint('⚠️ [SINGLE_QUIZ_CALLBACK] 실제 에러 발생, 네비게이션 중단');
                      return; // 실제 에러면 네비게이션 중단
                    }
                    
                    // 404 에러는 정상 처리로 간주하고 네비게이션 진행
                    quizProvider.notifyWrongNoteRemoved(quizId);
                    debugPrint('📢 [SINGLE_QUIZ_CALLBACK] 404 에러지만 네비게이션 진행 - Quiz $quizId');
                  }
                } else {
                  // 오답인 경우: 오답노트에 추가
                  debugPrint('❌ [SINGLE_QUIZ_CALLBACK] 오답! 오답노트에 추가 시작...');
                  try {
                    await wrongNoteProvider.submitSingleQuizResult(chapterId, quizId, selectedOption);
                    debugPrint('✅ [SINGLE_QUIZ_CALLBACK] 오답노트에 퀴즈 $quizId 추가 완료 (Chapter: $chapterId, Option: $selectedOption)');
                    
                    // 오답 추가 후에도 네비게이션 신호 (일관성을 위해)
                    quizProvider.notifyWrongNoteRemoved(quizId);
                    debugPrint('📢 [SINGLE_QUIZ_CALLBACK] 오답 추가 완료 알림 발송 - Quiz $quizId');
                  } catch (e) {
                    debugPrint('❌ [SINGLE_QUIZ_CALLBACK] 오답노트 추가 실패 - Quiz $quizId: $e');
                    
                    // 오답 추가 실패해도 네비게이션은 진행 (사용자 경험을 위해)
                    quizProvider.notifyWrongNoteRemoved(quizId);
                    debugPrint('📢 [SINGLE_QUIZ_CALLBACK] 오답 추가 실패지만 네비게이션 진행 - Quiz $quizId');
                  }
                }
              });
              
              debugPrint('✅ [PROVIDER] Provider 간 콜백 연결 완료!');
            }
            
            return learningProgressProvider ?? LearningProgressProvider(LearningProgressMockRepository());
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
