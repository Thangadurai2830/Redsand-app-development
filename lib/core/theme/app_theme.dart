import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.mainPurple,
          onPrimary: AppColors.white,
          primaryContainer: AppColors.lightLavender,
          onPrimaryContainer: AppColors.deepRoyalPurple,
          secondary: AppColors.cyanBlue,
          onSecondary: AppColors.white,
          secondaryContainer: AppColors.softSkyBlue,
          onSecondaryContainer: AppColors.primaryDarkText,
          tertiary: AppColors.mintGreen,
          onTertiary: AppColors.white,
          tertiaryContainer: AppColors.lightMint,
          onTertiaryContainer: AppColors.primaryDarkText,
          error: Color(0xFFB00020),
          onError: AppColors.white,
          errorContainer: Color(0xFFFFDAD6),
          onErrorContainer: Color(0xFF410002),
          background: AppColors.lightGrayBg,
          onBackground: AppColors.primaryDarkText,
          surface: AppColors.white,
          onSurface: AppColors.primaryDarkText,
          surfaceVariant: AppColors.veryLightPurpleBg,
          onSurfaceVariant: AppColors.secondaryGrayText,
          outline: AppColors.borderGray,
          outlineVariant: AppColors.lightLavender,
          shadow: Colors.black,
          scrim: Colors.black,
          inverseSurface: AppColors.primaryDarkText,
          onInverseSurface: AppColors.white,
          inversePrimary: AppColors.lightLavender,
        ),
        scaffoldBackgroundColor: AppColors.lightGrayBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.mainPurple,
          foregroundColor: AppColors.white,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.mainPurple,
          foregroundColor: AppColors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.mainPurple,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: AppColors.primaryDarkText),
          displayMedium: TextStyle(color: AppColors.primaryDarkText),
          displaySmall: TextStyle(color: AppColors.primaryDarkText),
          headlineLarge: TextStyle(color: AppColors.primaryDarkText),
          headlineMedium: TextStyle(
            color: AppColors.primaryDarkText,
            fontWeight: FontWeight.bold,
          ),
          headlineSmall: TextStyle(color: AppColors.primaryDarkText),
          titleLarge: TextStyle(color: AppColors.primaryDarkText),
          titleMedium: TextStyle(color: AppColors.primaryDarkText),
          titleSmall: TextStyle(color: AppColors.secondaryGrayText),
          bodyLarge: TextStyle(color: AppColors.primaryDarkText),
          bodyMedium: TextStyle(color: AppColors.primaryDarkText),
          bodySmall: TextStyle(color: AppColors.secondaryGrayText),
          labelLarge: TextStyle(color: AppColors.white),
          labelMedium: TextStyle(color: AppColors.secondaryGrayText),
          labelSmall: TextStyle(color: AppColors.secondaryGrayText),
        ),
        dividerTheme: const DividerThemeData(color: AppColors.borderGray),
        cardTheme: const CardTheme(
          color: AppColors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderGray),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderGray),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.mainPurple, width: 2),
          ),
          labelStyle: const TextStyle(color: AppColors.secondaryGrayText),
          hintStyle: const TextStyle(color: AppColors.secondaryGrayText),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.mainPurple,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.veryLightPurpleBg,
          labelStyle: const TextStyle(color: AppColors.mainPurple),
          side: const BorderSide(color: AppColors.lightLavender),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
}
