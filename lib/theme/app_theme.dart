// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// DocForge Design System
/// Aesthetic direction: "Refined Utilitarian" — crisp, editorial, intelligent.
/// Primary accent: Deep Indigo (#4F46E5) — trustworthy, modern, premium.
/// Neutrals: Warm Slate — softer than pure grey, warmer than cool grey.

abstract class AppColors {
  // --- Primary Palette ---
  static const primary = Color(0xFF4F46E5); // Indigo
  static const primaryLight = Color(0xFF818CF8); // Indigo 400
  static const primaryContainer = Color(0xFFEEF2FF); // Indigo 50
  static const primaryDark = Color(0xFF3730A3); // Indigo 700

  // --- Neutral Palette (Warm Slate) ---
  static const neutral50 = Color(0xFFF8FAFC);
  static const neutral100 = Color(0xFFF1F5F9);
  static const neutral200 = Color(0xFFE2E8F0);
  static const neutral300 = Color(0xFFCBD5E1);
  static const neutral400 = Color(0xFF94A3B8);
  static const neutral500 = Color(0xFF64748B);
  static const neutral600 = Color(0xFF475569);
  static const neutral700 = Color(0xFF334155);
  static const neutral800 = Color(0xFF1E293B);
  static const neutral900 = Color(0xFF0F172A);

  // --- Semantic Colors ---
  static const success = Color(0xFF10B981);
  static const successContainer = Color(0xFFD1FAE5);
  static const warning = Color(0xFFF59E0B);
  static const warningContainer = Color(0xFFFEF3C7);
  static const error = Color(0xFFEF4444);
  static const errorContainer = Color(0xFFFEE2E2);

  // --- Format Colors (for document type chips) ---
  static const pdfColor = Color(0xFFEF4444);
  static const docxColor = Color(0xFF2563EB);
  static const txtColor = Color(0xFF059669);
  static const jpegColor = Color(0xFFFBBF24);
  static const pngColor = Color(0xFF10B981);
  static const jpgColor = Color(0xFFFBBF24);
  static const docColor = Color(0xFF2563EB);

  // --- Dark Mode Surfaces ---
  static const darkSurface = Color(0xFF0F172A);
  static const darkSurface2 = Color(0xFF1E293B);
  static const darkSurface3 = Color(0xFF334155);
}

abstract class AppRadius {
  static const xs = Radius.circular(6);
  static const sm = Radius.circular(8);
  static const md = Radius.circular(12);
  static const lg = Radius.circular(16);
  static const xl = Radius.circular(20);
  static const xxl = Radius.circular(28);
  static const full = Radius.circular(999);

  static const borderXs = BorderRadius.all(xs);
  static const borderSm = BorderRadius.all(sm);
  static const borderMd = BorderRadius.all(md);
  static const borderLg = BorderRadius.all(lg);
  static const borderXl = BorderRadius.all(xl);
  static const borderXxl = BorderRadius.all(xxl);
  static const borderFull = BorderRadius.all(full);
}

abstract class AppShadows {
  static const xs = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const sm = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x05000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static const md = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static const lg = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const primary = [
    BoxShadow(
      color: Color(0x404F46E5),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];
}

class AppTheme {
  AppTheme._();

  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      // Display
      displayLarge: GoogleFonts.fraunces(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        letterSpacing: -2,
        color: primary,
      ),
      displayMedium: GoogleFonts.fraunces(
        fontSize: 45,
        fontWeight: FontWeight.w600,
        letterSpacing: -1.5,
        color: primary,
      ),
      displaySmall: GoogleFonts.fraunces(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        letterSpacing: -1,
        color: primary,
      ),
      // Headline
      headlineLarge: GoogleFonts.fraunces(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: primary,
      ),
      headlineMedium: GoogleFonts.fraunces(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        color: primary,
      ),
      headlineSmall: GoogleFonts.fraunces(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: primary,
      ),
      // Title
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        color: primary,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: primary,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: primary,
      ),
      // Body
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.6,
        color: secondary,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.6,
        color: secondary,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.5,
        color: secondary,
      ),
      // Label
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: primary,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: primary,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: secondary,
      ),
    );
  }

  static ThemeData get light {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.neutral600,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.neutral100,
      onSecondaryContainer: AppColors.neutral800,
      surface: Colors.white,
      onSurface: AppColors.neutral900,
      surfaceContainerHighest: AppColors.neutral100,
      onSurfaceVariant: AppColors.neutral500,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.error,
      outline: AppColors.neutral200,
      outlineVariant: AppColors.neutral100,
      shadow: Color(0x1A000000),
      scrim: Color(0x80000000),
      inverseSurface: AppColors.neutral900,
      onInverseSurface: AppColors.neutral50,
      inversePrimary: AppColors.primaryLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(AppColors.neutral900, AppColors.neutral600),
      scaffoldBackgroundColor: AppColors.neutral50,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.neutral50,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.neutral900,
          letterSpacing: -0.25,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.neutral700,
          size: 22,
        ),
      ),
      cardTheme: const CardTheme(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderLg,
          side: BorderSide(color: AppColors.neutral200, width: 1),
        ),
        margin: EdgeInsets.zero,
      ).data,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.neutral100,
        border: const OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: AppColors.neutral200, width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.neutral400,
          fontSize: 14,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.borderMd,
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(52),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.borderMd,
          ),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.borderMd,
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.neutral100,
        selectedColor: AppColors.primaryContainer,
        labelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13, fontWeight: FontWeight.w500),
        side: const BorderSide(color: AppColors.neutral200),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderFull),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.neutral100,
        thickness: 1,
        space: 0,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        minVerticalPadding: 8,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.neutral400,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        indicatorColor: AppColors.primaryContainer,
        indicatorShape: const RoundedRectangleBorder(
          borderRadius: AppRadius.borderMd,
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            );
          }
          return GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.neutral400,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.neutral900,
        contentTextStyle: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 14,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.borderMd,
        ),
        behavior: SnackBarBehavior.floating,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData get dark {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryLight,
      onPrimary: AppColors.neutral900,
      primaryContainer: Color(0xFF312E81),
      onPrimaryContainer: AppColors.primaryLight,
      secondary: AppColors.neutral400,
      onSecondary: AppColors.neutral900,
      secondaryContainer: AppColors.darkSurface3,
      onSecondaryContainer: AppColors.neutral200,
      surface: AppColors.darkSurface,
      onSurface: AppColors.neutral50,
      surfaceContainerHighest: AppColors.darkSurface2,
      onSurfaceVariant: AppColors.neutral400,
      error: Color(0xFFF87171),
      onError: AppColors.neutral900,
      errorContainer: Color(0xFF7F1D1D),
      onErrorContainer: Color(0xFFFCA5A5),
      outline: AppColors.darkSurface3,
      outlineVariant: AppColors.darkSurface2,
      shadow: Color(0x40000000),
      scrim: Color(0x80000000),
      inverseSurface: AppColors.neutral100,
      onInverseSurface: AppColors.neutral800,
      inversePrimary: AppColors.primary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(AppColors.neutral50, AppColors.neutral400),
      scaffoldBackgroundColor: AppColors.darkSurface,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.neutral50,
          letterSpacing: -0.25,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.neutral300,
          size: 22,
        ),
      ),
      cardTheme: const CardTheme(
        color: AppColors.darkSurface2,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderLg,
          side: BorderSide(color: AppColors.darkSurface3, width: 1),
        ),
        margin: EdgeInsets.zero,
      ).data,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface2,
        border: const OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: AppColors.darkSurface3, width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: AppColors.primaryLight, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.neutral600,
          fontSize: 14,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.neutral900,
          minimumSize: const Size.fromHeight(52),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.borderMd,
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface2,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        indicatorColor: const Color(0xFF312E81),
        indicatorShape: const RoundedRectangleBorder(
          borderRadius: AppRadius.borderMd,
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryLight,
            );
          }
          return GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.neutral500,
          );
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkSurface3,
        thickness: 1,
        space: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.neutral100,
        contentTextStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.neutral900,
          fontSize: 14,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.borderMd,
        ),
        behavior: SnackBarBehavior.floating,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
