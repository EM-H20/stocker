import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import 'app/config/app_router.dart';
import 'app/config/app_theme.dart';
import 'features/home/presentation/home_navigation_provider.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/note/presentation/provider/note_provider.dart';

// Repository & API
import 'features/auth/domain/auth_repository.dart';
import 'features/auth/data/source/auth_api.dart';
import 'features/auth/data/repository/auth_api_repository.dart';
import 'features/auth/data/repository/auth_mock_repository.dart';

// 출석
import 'features/attendance/presentation/provider/attendance_provider.dart';
import 'features/attendance/domain/repository/attendance_repository.dart';
import 'features/attendance/data/source/attendance_api.dart';
import 'features/attendance/data/repository/attendance_api_repository.dart';
import 'features/attendance/data/repository/attendance_mock_repository.dart';

// 성향
import 'features/aptitude/domain/repository/aptitude_repository.dart';
import 'features/aptitude/data/source/aptitude_api.dart';
import 'features/aptitude/data/repository/aptitude_api_repository.dart';
import 'features/aptitude/data/repository/aptitude_mock_repository.dart';
import 'features/aptitude/presentation/provider/aptitude_provider.dart';

// 노트
import 'features/note/domain/repository/note_repository.dart';
import 'features/note/data/source/note_api.dart';
import 'features/note/data/repository/note_api_repository.dart';
import 'features/note/data/repository/note_mock_repository.dart';

// Network
import 'app/core/network/dio.dart';

const useMock = true;

void main() async {
  await initializeDateFormatting();
  WidgetsFlutterBinding.ensureInitialized();
  await setupDio();
  runApp(const StockerApp());
}

class StockerApp extends StatelessWidget {
  const StockerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repositories
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

        // Providers
        ChangeNotifierProvider(create: (_) => HomeNavigationProvider()),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(context.read<AuthRepository>()),
        ),
        ChangeNotifierProxyProvider<AuthProvider, AttendanceProvider>(
          create: (context) => AttendanceProvider(
            context.read<AttendanceRepository>(),
            context.read<AuthProvider>(),
          ),
          update: (context, auth, _) =>
              AttendanceProvider(context.read<AttendanceRepository>(), auth),
        ),
        ChangeNotifierProvider(
          create: (context) => AptitudeProvider(
            context.read<AptitudeRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => NoteProvider(context.read<NoteRepository>()),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(393, 852),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp.router(
            title: 'Stocker',
            theme: AppTheme.lightTheme,
            routerConfig: AppRouter.router,
            debugShowCheckedModeBanner: false,

            // ✅ Quill이 요구하는 로캘 설정 (반드시 여기!)
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
          );
        },
      ),
    );
  }
}
