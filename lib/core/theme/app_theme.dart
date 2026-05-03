import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Theme Colors
  static const Color backgroundColor = Color(0xFFF5F5F5); // Off White (#F5F5F5)
  static const Color primaryColor = Color(0xFFFF6EB4);    // Pink (#FF6EB4)
  static const Color secondaryColor = Color(0xFF3B82F6);  // Blue (#3B82F6)
  static const Color errorColor = Color(0xFFE57373);      // Light Red
  static const Color successColor = Color(0xFF81C784);    // Light Green
  static const Color warningColor = Color(0xFFFFB74D);    // Light Orange

  // Dark Theme Colors - keeping original accent colors as requested
  static const Color darkBackgroundColor = Color(0xFF121212); // Dark Grey (#121212)
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);    // Slightly lighter dark surface
  static const Color darkPrimaryColor = Color(0xFFFF6EB4);    // Same Pink (#FF6EB4)
  static const Color darkSecondaryColor = Color(0xFF3B82F6);  // Same Blue (#3B82F6)
  static const Color darkTextColor = Color(0xFFF5F5F5);       // Off White text (#F5F5F5)

  // Additional shades for better UI variety
  static const Color primaryLight = Color(0xFFFC6BB8);
  static const Color primaryDark = Color(0xFFE6298F);
  static const Color secondaryLight = Color(0xFF6B9BFF);
  static const Color secondaryDark = Color(0xFF2E6EFF);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: Colors.white,
        error: errorColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: _getSafeTextTheme(),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.black87,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: darkPrimaryColor,
        brightness: Brightness.dark,
        primary: darkPrimaryColor,
        secondary: darkSecondaryColor,
        surface: darkSurfaceColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: darkBackgroundColor,
      textTheme: _getSafeDarkTextTheme(),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimaryColor,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkPrimaryColor,
          side: const BorderSide(color: darkPrimaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkPrimaryColor,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkPrimaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardThemeData(
        color: darkSurfaceColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackgroundColor,
        foregroundColor: darkTextColor,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkTextColor,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: darkPrimaryColor,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurfaceColor,
        selectedItemColor: darkPrimaryColor,
        unselectedItemColor: darkTextColor.withValues(alpha: 0.8),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static TextTheme _getSafeTextTheme() {
    try {
      return GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.w300),
        displayMedium: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.w400),
        displaySmall: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w400),
        headlineLarge: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600),
        headlineMedium: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
        titleSmall: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400),
        bodyMedium: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400),
        bodySmall: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w400),
        labelLarge: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        labelMedium: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500),
        labelSmall: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w500),
      );
    } catch (e) {
      // Fallback to default Material theme if Google Fonts fails
      return ThemeData.light().textTheme.copyWith(
        displayLarge: const TextStyle(fontSize: 48, fontWeight: FontWeight.w300),
        displayMedium: const TextStyle(fontSize: 40, fontWeight: FontWeight.w400),
        displaySmall: const TextStyle(fontSize: 32, fontWeight: FontWeight.w400),
        headlineLarge: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        headlineMedium: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        headlineSmall: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        titleLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        titleSmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        bodyLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        bodyMedium: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        bodySmall: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
        labelLarge: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        labelMedium: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
        labelSmall: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
      );
    }
  }

  static TextTheme _getSafeDarkTextTheme() {
    try {
      return GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.w300, color: darkTextColor),
        displayMedium: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.w400, color: darkTextColor),
        displaySmall: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w400, color: darkTextColor),
        headlineLarge: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600, color: darkTextColor),
        headlineMedium: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, color: darkTextColor),
        headlineSmall: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: darkTextColor),
        titleLarge: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: darkTextColor),
        titleMedium: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: darkTextColor),
        titleSmall: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: darkTextColor),
        bodyLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400, color: darkTextColor.withValues(alpha: 0.87)),
        bodyMedium: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400, color: darkTextColor.withValues(alpha: 0.87)),
        bodySmall: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w400, color: darkTextColor.withValues(alpha: 0.87)),
        labelLarge: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: darkTextColor),
        labelMedium: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: darkTextColor),
        labelSmall: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w500, color: darkTextColor),
      );
    } catch (e) {
      // Fallback to default dark Material theme if Google Fonts fails
      return ThemeData.dark().textTheme.copyWith(
        displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.w300, color: darkTextColor),
        displayMedium: TextStyle(fontSize: 40, fontWeight: FontWeight.w400, color: darkTextColor),
        displaySmall: TextStyle(fontSize: 32, fontWeight: FontWeight.w400, color: darkTextColor),
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: darkTextColor),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: darkTextColor),
        headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: darkTextColor),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: darkTextColor),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: darkTextColor),
        titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: darkTextColor),
        bodyLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: darkTextColor.withValues(alpha: 0.87)),
        bodyMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: darkTextColor.withValues(alpha: 0.87)),
        bodySmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: darkTextColor.withValues(alpha: 0.87)),
        labelLarge: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: darkTextColor),
        labelMedium: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: darkTextColor),
        labelSmall: TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: darkTextColor),
      );
    }
  }
}
