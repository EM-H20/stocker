// Stocker App Widget Tests
//
// This file contains unit and widget tests for the Stocker investment education app.
// Tests focus on individual components without complex dependencies to ensure
// reliable CI/CD pipeline execution.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:stocker/features/home/presentation/home_navigation_provider.dart'; // 🔥 Riverpod으로 교체됨
import 'package:stocker/features/home/presentation/riverpod/home_navigation_notifier.dart';
import 'package:stocker/features/home/presentation/tap_item.dart';
// import 'package:stocker/app/core/providers/theme_provider.dart'; // 🔥 Riverpod으로 교체됨
import 'package:stocker/app/core/providers/riverpod/theme_notifier.dart';
import 'package:stocker/app/config/app_theme.dart';

void main() {
  group('Stocker App Component Tests', () {
    setUpAll(() async {
      // Load environment variables for testing
      try {
        await dotenv.load(fileName: ".env");
      } catch (e) {
        // Ignore if .env file doesn't exist in test environment
        debugPrint('Environment file not found, using defaults');
      }
    });

    test('Theme notifier initializes correctly', () async {
      // 🔥 Riverpod: ProviderContainer를 사용한 테스트
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Verify theme notifier has valid initial state (기본값은 system)
      final themeState = container.read(themeNotifierProvider);
      expect(themeState, equals(AppThemeMode.system)); // 기본값 확인
      expect(AppThemeMode.values.contains(themeState), isTrue);

      // Test theme mode conversion
      final themeMode = container.read(themeModeProvider);
      expect(themeMode, equals(ThemeMode.system)); // 기본값 확인
      expect(
          [ThemeMode.light, ThemeMode.dark, ThemeMode.system]
              .contains(themeMode),
          isTrue);

      // Test theme change
      final notifier = container.read(themeNotifierProvider.notifier);
      await notifier.setThemeMode(AppThemeMode.dark);
      expect(container.read(themeNotifierProvider), equals(AppThemeMode.dark));
      expect(container.read(themeModeProvider), equals(ThemeMode.dark));
    });

    test('Navigation notifier works correctly', () {
      // 🔥 Riverpod: ProviderContainer를 사용한 테스트
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(homeNavigationNotifierProvider.notifier);

      // Verify initial state
      expect(container.read(homeNavigationNotifierProvider),
          equals(TabItem.education));
      expect(notifier.currentIndex, equals(0));

      // Test navigation
      notifier.changeTabByIndex(1);
      expect(container.read(homeNavigationNotifierProvider),
          equals(TabItem.attendance));
      expect(notifier.currentIndex, equals(1));

      // Test bounds checking
      notifier.changeTabByIndex(999);
      expect(notifier.currentIndex, equals(1)); // Should not change

      notifier.changeTabByIndex(-1);
      expect(notifier.currentIndex, equals(1)); // Should not change

      // Test isCurrentTab
      expect(notifier.isCurrentTab(TabItem.attendance), isTrue);
      expect(notifier.isCurrentTab(TabItem.education), isFalse);

      // Test changeTab directly
      notifier.changeTab(TabItem.wrongNote);
      expect(container.read(homeNavigationNotifierProvider),
          equals(TabItem.wrongNote));
    });

    test('App themes are properly configured', () {
      // Test that themes are not null and have expected properties
      expect(AppTheme.lightTheme, isNotNull);
      expect(AppTheme.darkTheme, isNotNull);

      expect(AppTheme.lightTheme.brightness, equals(Brightness.light));
      expect(AppTheme.darkTheme.brightness, equals(Brightness.dark));

      // Test that themes have basic required properties
      expect(AppTheme.lightTheme.colorScheme, isNotNull);
      expect(AppTheme.darkTheme.colorScheme, isNotNull);
    });

    testWidgets('ScreenUtil integration works', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          builder: (context, child) {
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Text(
                    'Test',
                    style: TextStyle(fontSize: 16.sp), // Using ScreenUtil
                  ),
                ),
              ),
            );
          },
        ),
      );

      await tester.pump();

      // Verify app doesn't crash with ScreenUtil
      expect(find.text('Test'), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Basic Material App structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          title: 'Stocker Test',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const Scaffold(
            body: Center(
              child: Text('Hello Stocker'),
            ),
          ),
        ),
      );

      // Verify basic app structure
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('Hello Stocker'), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
