// Stocker App Widget Tests
//
// This file contains unit and widget tests for the Stocker investment education app.
// Tests focus on individual components without complex dependencies to ensure
// reliable CI/CD pipeline execution.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:stocker/features/home/presentation/home_navigation_provider.dart';
import 'package:stocker/app/core/providers/theme_provider.dart';
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

    test('Theme provider initializes correctly', () async {
      final themeProvider = ThemeProvider();
      await themeProvider.initialize();
      
      // Verify theme provider has valid theme modes
      expect(themeProvider.themeMode, isA<ThemeMode>());
      expect([ThemeMode.light, ThemeMode.dark, ThemeMode.system].contains(themeProvider.themeMode), isTrue);
    });

    test('Navigation provider works correctly', () {
      final navProvider = HomeNavigationProvider();
      
      // Verify initial state
      expect(navProvider.currentIndex, equals(0));
      
      // Test navigation
      navProvider.changeTabByIndex(1);
      expect(navProvider.currentIndex, equals(1));
      
      // Test bounds checking
      navProvider.changeTabByIndex(999);
      expect(navProvider.currentIndex, equals(1)); // Should not change
      
      navProvider.changeTabByIndex(-1);
      expect(navProvider.currentIndex, equals(1)); // Should not change
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
