import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otogapo_core/otogapo_core.dart';

///
class OpstechTextTheme {
  /* Intro Main Text */

  ///
  static TextStyle heading1 = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  /* Pages title */
  ///
  static TextStyle heading2 = GoogleFonts.inter(
    fontSize: 26,
    fontWeight: FontWeight.w600,
  );

  /* Buttons, Category List */
  ///
  static TextStyle heading3 = GoogleFonts.inter(
    color: OpstechColors.black,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  /* Buttons, Category List */
  ///
  static TextStyle heading4 = GoogleFonts.inter(
    color: OpstechColors.black,
    fontSize: 50.sp,
    fontWeight: FontWeight.w700,
  );

  /* Buttons, Category List */
  ///
  static TextStyle heading5 = GoogleFonts.inter(
    color: OpstechColors.black,
    fontSize: 38.sp,
    fontWeight: FontWeight.w700,
  );

  /* Buttons, Category List */
  ///
  static TextStyle regular = GoogleFonts.inter(
    color: OpstechColors.black,
    fontSize: 30.sp,
    fontWeight: FontWeight.w500,
  );

  ///
  static TextStyle regularThin = GoogleFonts.inter(
    color: OpstechColors.black,
    fontSize: 14,
    fontWeight: FontWeight.w200,
  );

  ///
  static TextStyle appbar = GoogleFonts.inter(
    color: OpstechColors.white,
    fontSize: 20,
    fontWeight: FontWeight.w300,
  );

  /// The main text theme for the dark mode of the application.
  static TextTheme get darkTextTheme {
    return TextTheme(
      displayLarge: heading1.copyWith(color: OpstechColors.onPrimary),
      displayMedium: heading2.copyWith(color: OpstechColors.onPrimary),
      displaySmall: heading3.copyWith(color: OpstechColors.onPrimary),
      headlineMedium: heading4.copyWith(color: OpstechColors.onPrimary),
      headlineSmall: heading5.copyWith(color: OpstechColors.onPrimary),
      titleLarge: regular.copyWith(color: OpstechColors.onPrimary),
      bodyLarge: regular.copyWith(color: OpstechColors.onPrimary),
      bodyMedium: regularThin.copyWith(color: OpstechColors.onSecondary),
      labelLarge: heading3.copyWith(color: OpstechColors.onPrimary), // For buttons
    );
  }

  /// The main text theme for the light mode of the application.
  static TextTheme get lightTextTheme {
    const darkGrey = Color(0xFF2C2C2C);
    return TextTheme(
      displayLarge: heading1.copyWith(color: darkGrey),
      displayMedium: heading2.copyWith(color: darkGrey),
      displaySmall: heading3.copyWith(color: darkGrey),
      headlineMedium: heading4.copyWith(color: darkGrey),
      headlineSmall: heading5.copyWith(color: darkGrey),
      titleLarge: regular.copyWith(color: darkGrey),
      bodyLarge: regular.copyWith(color: darkGrey),
      bodyMedium: regularThin.copyWith(color: darkGrey.withOpacity(0.7)),
      labelLarge: heading3.copyWith(color: darkGrey), // For buttons
    );
  }
}
