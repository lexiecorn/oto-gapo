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
}
