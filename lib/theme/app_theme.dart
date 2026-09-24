import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryTeal = Color(0xFF005954);
  static const Color primaryTealDark = Color(0xFF003D39);
  static const Color scaffoldBg = Color(0xFFFAFAFC);
  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF23262F);
  static const Color textGrey = Color(0xFF5A6072);
  static const Color correctGreen = Color(0xFFA7D7C5);
  static const Color correctBorder = Color(0xFF2E7D5B);
  static const Color incorrectRed = Color(0xFFF8A5A5);
  static const Color incorrectBorder = Color(0xFFD32F2F);
  static const Color accentBlue = Color(0xFF2563EB);

  static ThemeData get lightTheme {
    final baseFont = GoogleFonts.poppinsTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: scaffoldBg,
      primaryColor: primaryTeal,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        primary: primaryTeal,
        surface: cardBg,
      ),
      textTheme: baseFont.copyWith(
        displayLarge: baseFont.displayLarge?.copyWith(
          color: textDark,
          fontWeight: FontWeight.w800,
        ),
        headlineLarge: baseFont.headlineLarge?.copyWith(
          color: textDark,
          fontWeight: FontWeight.w700,
          fontSize: 32,
        ),
        headlineMedium: baseFont.headlineMedium?.copyWith(
          color: textDark,
          fontWeight: FontWeight.w700,
          fontSize: 26,
        ),
        titleLarge: baseFont.titleLarge?.copyWith(
          color: textDark,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        bodyLarge: baseFont.bodyLarge?.copyWith(
          color: textDark,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: baseFont.bodyMedium?.copyWith(
          color: textGrey,
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: baseFont.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textDark),
      ),
    );
  }
}
