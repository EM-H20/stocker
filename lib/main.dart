
// import 'package:intl/date_symbol_data_local.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';

// import 'app/config/app_router.dart';
// import 'app/config/app_theme.dart';
// import 'features/home/presentation/home_navigation_provider.dart';
// import 'features/auth/presentation/auth_provider.dart';

// // Repository & API
// import 'features/auth/domain/auth_repository.dart';
// import 'features/auth/data/source/auth_api.dart';
// import 'features/auth/data/repository/auth_api_repository.dart';
// import 'features/auth/data/repository/auth_mock_repository.dart';

// // ✅ [추가] 출석 기능 관련 import
// import 'features/attendance/presentation/provider/attendance_provider.dart';
// import 'features/attendance/domain/repository/attendance_repository.dart';
// import 'features/attendance/data/source/attendance_api.dart';
// import 'features/attendance/data/repository/attendance_api_repository.dart';
// import 'features/attendance/data/repository/attendance_mock_repository.dart';

// // Network & Token
// import 'app/core/network/dio.dart';

// /// ✅ 더미(mock) 여부 설정
// const useMock = true; // 더미데이터 사용 시 true, 실제 API 사용 시 false

// void main() async {
//   await initializeDateFormatting();
//   WidgetsFlutterBinding.ensureInitialized();
//   await setupDio();
//   runApp(const StockerApp());
// }

// class StockerApp extends StatelessWidget {
//   const StockerApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // ✅ [수정] MultiProvider를 앱의 최상단으로 이동시킵니다.
//     // 이렇게 하면 모든 Repository와 Provider가 앱 전체에서 일관되게 접근 가능해집니다.
//     return MultiProvider(
//       providers: [
//         // --- 1. Repository 등록 ---
//         // 앱의 상태와 상관없이 존재해야 하는 데이터 소스를 먼저 등록합니다.
//         Provider<AuthRepository>(
//           create: (_) => useMock
//               ? AuthMockRepository()
//               : AuthApiRepository(AuthApi(dio)),
//         ),
//         Provider<AttendanceRepository>(
//           create: (_) => useMock
//               ? AttendanceMockRepository()
//               : AttendanceApiRepository(AttendanceApi(dio)),
//         ),

//         // --- 2. Provider 등록 (Repository에 의존) ---
//         // 위에서 등록한 Repository를 사용하여 상태를 관리하는 Provider들을 등록합니다.
//         ChangeNotifierProvider(create: (_) => HomeNavigationProvider()),
//         ChangeNotifierProvider(
//           create: (context) => AuthProvider(
//             context.read<AuthRepository>(),
//           ),
//         ),
//         ChangeNotifierProxyProvider<AuthProvider, AttendanceProvider>(
//           create: (context) => AttendanceProvider(
//             context.read<AttendanceRepository>(),
//             context.read<AuthProvider>(),
//           ),
//           update: (context, authProvider, previous) => AttendanceProvider(
//             context.read<AttendanceRepository>(),
//             authProvider,
//           ),
//         ),
//       ],
//       // ✅ [수정] 실제 앱 화면은 MultiProvider의 자식으로 위치시킵니다.
//       child: ScreenUtilInit(
//         designSize: const Size(393, 852),
//         minTextAdapt: true,
//         splitScreenMode: true,
//         builder: (context, child) {
//           return MaterialApp.router(
//             title: 'Stocker',
//             theme: AppTheme.lightTheme,
//             routerConfig: AppRouter.router,
//             debugShowCheckedModeBanner: false,
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:intl/date_symbol_data_local.dart';
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

//출석 기능 관련 import
import 'features/attendance/presentation/provider/attendance_provider.dart';      
import 'features/attendance/domain/repository/attendance_repository.dart';     
import 'features/attendance/data/source/attendance_api.dart';                   
import 'features/attendance/data/repository/attendance_api_repository.dart';   
import 'features/attendance/data/repository/attendance_mock_repository.dart';  

//성향 분석 기능 관련 import
import 'features/aptitude/domain/repository/aptitude_repository.dart';          
import 'features/aptitude/data/source/aptitude_api.dart';                     
import 'features/aptitude/data/repository/aptitude_api_repository.dart';      
import 'features/aptitude/data/repository/aptitude_mock_repository.dart';        
import 'features/aptitude/presentation/provider/aptitude_provider.dart';         

// Network & Token
import 'app/core/network/dio.dart';
 
/// ✅ 더미(mock) 여부 설정       
const useMock = true; // 더미데이터 사용 시 true, 실제 API 사용 시 false        

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
    // ✅ [수정] MultiProvider를 앱의 최상단으로 이동시킵니다.
    // 이렇게 하면 모든 Repository와 Provider가 앱 전체에서 일관되게 접근 가능해집니다.
    return MultiProvider(
      providers: [
        // --- 1. Repository 등록 ---
        // 앱의 상태와 상관없이 존재해야 하는 데이터 소스를 먼저 등록합니다.
        Provider<AuthRepository>(
          create: (_) => useMock
              ? AuthMockRepository()
              : AuthApiRepository(AuthApi(dio)),
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

        // --- 2. Provider 등록 (Repository에 의존) ---
        // 위에서 등록한 Repository를 사용하여 상태를 관리하는 Provider들을 등록합니다.
        ChangeNotifierProvider(create: (_) => HomeNavigationProvider()),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            context.read<AuthRepository>(),
          ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, AttendanceProvider>(
          create: (context) => AttendanceProvider(
            context.read<AttendanceRepository>(),
            context.read<AuthProvider>(),
          ),
          update: (context, authProvider, previous) => AttendanceProvider(
            context.read<AttendanceRepository>(),
            authProvider,
          ),
        ),
        // ✅ [수정] AptitudeProvider 등록
        ChangeNotifierProvider(
          create: (context) => AptitudeProvider(
            context.read<AptitudeRepository>(),
          ),
        ),
      ],

      
      // ✅ [수정] 실제 앱 화면은 MultiProvider의 자식으로 위치시킵니다.
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
          );
        },
      ),
    );
  }
}