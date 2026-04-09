import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:herafy/core/resourses/app_colors.dart';

class AppTheme {
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: Color(AppColors.primaryColor),
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Cairo',
    textTheme: TextTheme(
      bodyLarge: GoogleFonts.cairo(color: Colors.black87),
      bodyMedium: GoogleFonts.cairo(color: Colors.black87),
      bodySmall: GoogleFonts.cairo(color: Colors.black54),
      headlineLarge: GoogleFonts.cairo(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      headlineMedium: GoogleFonts.cairo(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      titleLarge: GoogleFonts.cairo(
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(AppColors.primaryColor),
      elevation: 0,
      titleTextStyle: GoogleFonts.cairo(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: Colors.white),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: Color(AppColors.primaryColor),
    scaffoldBackgroundColor: Color(0xFF1a1a2e),
    fontFamily: 'Cairo',
    textTheme: TextTheme(
      bodyLarge: GoogleFonts.cairo(color: Colors.white),
      bodyMedium: GoogleFonts.cairo(color: Colors.white),
      bodySmall: GoogleFonts.cairo(color: Colors.white70),
      headlineLarge: GoogleFonts.cairo(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineMedium: GoogleFonts.cairo(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      titleLarge: GoogleFonts.cairo(
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(AppColors.primaryColor),
      elevation: 0,
      titleTextStyle: GoogleFonts.cairo(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF262641)),
  );
}
