// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otogapo_core/otogapo_core.dart';

/// Creates a testable widget wrapped with necessary dependencies.
///
/// Provides:
/// - MaterialApp for navigation and theme context
/// - ScreenUtil for responsive sizing
/// - OpstechTheme for consistent styling
/// - MediaQuery with standard test size
///
/// Usage:
/// ```dart
/// await tester.pumpWidget(
///   createTestApp(
///     child: CarWidget(state: mockState),
///   ),
/// );
/// ```
Widget createTestApp({
  required Widget child,
  ThemeMode themeMode = ThemeMode.light,
}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context, _) {
      return MaterialApp(
        theme: OpstechTheme.lightTheme,
        darkTheme: OpstechTheme.darkTheme,
        themeMode: themeMode,
        home: Scaffold(
          body: child,
        ),
      );
    },
  );
}

/// Extension on WidgetTester for common test operations.
extension WidgetTesterX on WidgetTester {
  /// Pumps the widget and waits for all animations to complete.
  ///
  /// This is useful for testing widgets with animations without
  /// checking exact timing, which can be brittle.
  Future<void> pumpAndSettleApp(Widget widget) async {
    await pumpWidget(widget);
    await pumpAndSettle();
  }

  /// Pumps the widget wrapped in test app.
  Future<void> pumpTestApp(Widget child) async {
    await pumpWidget(createTestApp(child: child));
  }

  /// Pumps the widget wrapped in test app and waits for animations.
  Future<void> pumpAndSettleTestApp(Widget child) async {
    await pumpWidget(createTestApp(child: child));
    await pumpAndSettle();
  }
}
