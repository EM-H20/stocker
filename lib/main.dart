import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'app/config/app_router.dart';
import 'app/config/app_theme.dart';
import 'features/home/presentation/home_navigation_provider.dart';
// TODO: 추후 추가할 Provider들
import 'features/auth/presentation/auth_provider.dart';
// import 'features/education/presentation/education_provider.dart';

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
            // TODO: 추후 추가할 Provider들
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            // ChangeNotifierProvider(create: (_) => EducationProvider()),
            // ChangeNotifierProvider(create: (_) => AttendanceProvider()),
            // ChangeNotifierProvider(create: (_) => AptitudeProvider()),
          ],
          child: MaterialApp.router(
            title: 'Stocker',
            debugShowCheckedModeBanner: false,

            // 테마 설정
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,

            // GoRouter 설정
            routerConfig: AppRouter.router,
          ),
        );
      },
    );
  }
}
