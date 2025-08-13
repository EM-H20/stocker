import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'app/config/app_router.dart';
import 'app/config/app_theme.dart';
import 'features/home/presentation/home_navigation_provider.dart';
import 'features/education/presentation/education_provider.dart';
import 'features/education/domain/education_repository.dart';
import 'features/education/domain/education_mock_repository.dart';
import 'features/education/data/education_api.dart';
import 'features/quiz/presentation/quiz_provider.dart';
import 'features/quiz/domain/quiz_repository.dart';
import 'features/quiz/domain/quiz_mock_repository.dart';
import 'features/quiz/data/quiz_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// ✅ 더미(mock) 여부 설정
const useMock = true; // 실제 API 사용시 false

void main() {
  runApp(const StockerApp());
}

/// Stocker 앱의 메인 엔트리 포인트
class StockerApp extends StatelessWidget {
  const StockerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // 디자인 기준 화면 크기 (iPhone 14 Pro 기준)
      designSize: const Size(393, 852),
      // 최소 텍스트 어댑터 비율
      minTextAdapt: true,
      // 분할 화면 지원
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            // 홈 네비게이션 상태 관리
            ChangeNotifierProvider(create: (_) => HomeNavigationProvider()),

            // Education 상태 관리 (Mock/Real API 분기)
            ChangeNotifierProvider(
              create: (_) {
                if (useMock) {
                  // Mock Repository 사용
                  final mockRepository = EducationMockRepository();
                  return EducationProvider.withMock(mockRepository);
                } else {
                  // 실제 API Repository 사용
                  final dio = Dio();
                  const storage = FlutterSecureStorage();
                  final educationApi = EducationApi(dio);
                  final educationRepository = EducationRepository(
                    educationApi,
                    storage,
                  );
                  return EducationProvider(educationRepository);
                }
              },
            ),

            // Quiz 상태 관리 (Mock/Real API 분기)
            ChangeNotifierProvider(
              create: (_) {
                if (useMock) {
                  // Mock Repository 사용
                  final mockRepository = QuizMockRepository();
                  return QuizProvider.withMock(mockRepository);
                } else {
                  // 실제 API Repository 사용
                  final dio = Dio();
                  const storage = FlutterSecureStorage();
                  final quizApi = QuizApi(dio);
                  final quizRepository = QuizRepository(quizApi, storage);
                  return QuizProvider(quizRepository);
                }
              },
            ),
          ],
          child: MaterialApp.router(
            title: 'Stocker',
            debugShowCheckedModeBanner: false,

            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,

            // GoRouter 설정했다.
            routerConfig: AppRouter.router,
          ),
        );
      },
    );
  }
}
