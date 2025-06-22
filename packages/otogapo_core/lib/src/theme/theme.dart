import 'package:flutter/material.dart';
import 'package:otogapo_core/src/theme/colors.dart';
import 'package:otogapo_core/src/theme/text_theme.dart';

export 'colors.dart';
export 'text_theme.dart';

/// The main theme for the Otogapo application.
class OpstechTheme {
  /// The standard dark theme for the application.
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: OpstechColors.primaryBlack,
      colorScheme: const ColorScheme.dark(
        primary: OpstechColors.primaryBlack,
        secondary: OpstechColors.accentRed,
        surface: OpstechColors.surfaceBlack,
        onPrimary: OpstechColors.onPrimary,
        onSecondary: OpstechColors.onSecondary,
        onError: Colors.white,
        error: Colors.redAccent,
      ),
      scaffoldBackgroundColor: OpstechColors.primaryBlack,
      textTheme: OpstechTextTheme.darkTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: OpstechColors.primaryBlack,
        elevation: 0,
        titleTextStyle: OpstechTextTheme.appbar.copyWith(color: OpstechColors.onPrimary),
        iconTheme: const IconThemeData(color: OpstechColors.onPrimary),
      ),
      cardTheme: CardThemeData(
        color: OpstechColors.surfaceBlack,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: OpstechColors.accentRed,
          foregroundColor: OpstechColors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: OpstechTextTheme.heading3.copyWith(color: OpstechColors.onPrimary),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: OpstechColors.accentRed,
          textStyle: OpstechTextTheme.heading3.copyWith(color: OpstechColors.accentRed),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: OpstechColors.onPrimary,
          side: const BorderSide(color: OpstechColors.accentRed),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: OpstechTextTheme.heading3,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: OpstechColors.surfaceBlack,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: OpstechColors.accentRed, width: 2),
        ),
        labelStyle: const TextStyle(color: OpstechColors.onSecondary),
        hintStyle: const TextStyle(color: OpstechColors.onSecondary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: OpstechColors.primaryBlack,
        selectedItemColor: OpstechColors.accentRed,
        unselectedItemColor: OpstechColors.onSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  /// The light theme for the application with red, dark grey, and white colors.
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: Colors.white,
        secondary: OpstechColors.accentRed,
        surface: Color(0xFFF5F5F5), // Light grey
        onPrimary: Color(0xFF2C2C2C), // Dark grey
        onSecondary: Colors.white,
        onError: Colors.white,
        error: Colors.redAccent,
      ),
      scaffoldBackgroundColor: Colors.white,
      textTheme: OpstechTextTheme.lightTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: OpstechTextTheme.appbar.copyWith(color: const Color(0xFF2C2C2C)),
        iconTheme: const IconThemeData(color: Color(0xFF2C2C2C)),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFF5F5F5),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: OpstechColors.accentRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: OpstechTextTheme.heading3.copyWith(color: Colors.white),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: OpstechColors.accentRed,
          textStyle: OpstechTextTheme.heading3.copyWith(color: OpstechColors.accentRed),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF2C2C2C),
          side: const BorderSide(color: OpstechColors.accentRed),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: OpstechTextTheme.heading3,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: OpstechColors.accentRed, width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFF2C2C2C)),
        hintStyle: const TextStyle(color: Color(0xFF2C2C2C)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: OpstechColors.accentRed,
        unselectedItemColor: const Color(0xFF2C2C2C),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
