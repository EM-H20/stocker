// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'app/config/app_router.dart';
import 'app/config/app_theme.dart';
import 'features/home/presentation/home_navigation_provider.dart';
import 'features/auth/presentation/auth_provider.dart';

// Repository & API
import 'features/auth/domain/auth_repository.dart';
import 'features/auth/data/source/auth_api.dart';
import 'features/auth/data/repository/auth_api_repository.dart';
import 'features/auth/data/repository/auth_mock_repository.dart';

// Network & Token
import 'app/core/network/dio.dart';

/// ✅ 더미(mock) 여부 설정
//const useMock = true;  //더미데이터 사용시
final useMock=false;  //실제 API 사용시

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dio 및 기타 네트워크 설정 초기화
  await setupDio();

  runApp(const StockerApp());
}

class StockerApp extends StatelessWidget {
  const StockerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Repository 인스턴스 결정 (Mock vs 실제 API)
    final AuthRepository authRepository = useMock
        ? AuthMockRepository()
        : AuthApiRepository(AuthApi(dio));

    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => HomeNavigationProvider()),
            ChangeNotifierProvider(create: (_) => AuthProvider(authRepository)),
          ],
          child: MaterialApp.router(
            title: 'Stocker',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: AppRouter.router,
          ),
        );
      },
    );
  }
}
