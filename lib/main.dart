import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:stocker/app/core/providers/riverpod/theme_notifier.dart';
import 'app/config/app_theme.dart';
import 'app/config/app_router.dart';
import 'app/core/network/dio.dart';
import 'app/core/services/token_storage.dart';

const useMock =
    String.fromEnvironment('USE_MOCK', defaultValue: 'false') == 'true';

const createTestUserOnStart =
    String.fromEnvironment('CREATE_TEST_USER', defaultValue: 'false') == 'true';

void main() async {
  await initializeDateFormatting();
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('[INIT] Loading environment variables...');
  await dotenv.load(fileName: ".env");
  debugPrint(
      '[INIT] Environment loaded - API_BASE_URL: ${dotenv.env['API_BASE_URL']}');

  await setupDio();

  if (useMock && createTestUserOnStart) {
    debugPrint('[INIT] Mock mode - creating test user...');
    await TokenStorage.createTestUser();
  }

  runApp(
    ProviderScope(
      child: const StockerApp(),
    ),
  );
}

class StockerApp extends ConsumerWidget {
  const StockerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        final currentThemeMode = ref.watch(themeModeProvider);

        return MaterialApp.router(
          title: 'Stocker',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentThemeMode,
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
          routerConfig: AppRouter.createRouter(ref),
        );
      },
    );
  }
}
