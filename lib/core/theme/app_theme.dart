import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // Dark background layers
  static const Color _darkBg = Color(0xFF0F0F13);
  static const Color _darkSurface = Color(0xFF1C1C27);
  static const Color _darkSurfaceVariant = Color(0xFF252535);
  static const Color _darkOnSurface = Color(0xFFEAE6F0);
  static const Color _darkOnSurfaceVariant = Color(0xFFB8B3C8);
  static const Color _darkOutline = Color(0xFF5A5570);

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: AppColors.softLavender,
          onPrimary: Color(0xFF22005D),
          primaryContainer: Color(0xFF3D2B7A),
          onPrimaryContainer: Color(0xFFE6DEFF),
          secondary: AppColors.cyanBlue,
          onSecondary: Color(0xFF003355),
          secondaryContainer: Color(0xFF004A7A),
          onSecondaryContainer: Color(0xFFD6EEFF),
          tertiary: AppColors.mintGreen,
          onTertiary: Color(0xFF003730),
          tertiaryContainer: Color(0xFF005048),
          onTertiaryContainer: Color(0xFFD0FFF4),
          error: Color(0xFFFFB4AB),
          onError: Color(0xFF690005),
          errorContainer: Color(0xFF93000A),
          onErrorContainer: Color(0xFFFFDAD6),
          background: _darkBg,
          onBackground: _darkOnSurface,
          surface: _darkSurface,
          onSurface: _darkOnSurface,
          surfaceVariant: _darkSurfaceVariant,
          onSurfaceVariant: _darkOnSurfaceVariant,
          outline: _darkOutline,
          outlineVariant: Color(0xFF3A3550),
          shadow: Colors.black,
          scrim: Colors.black,
          inverseSurface: Color(0xFFEAE6F0),
          onInverseSurface: Color(0xFF313033),
          inversePrimary: AppColors.deepRoyalPurple,
        ),
        scaffoldBackgroundColor: _darkBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: _darkSurface,
          foregroundColor: _darkOnSurface,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.softLavender,
          foregroundColor: Color(0xFF22005D),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.softLavender,
            foregroundColor: const Color(0xFF22005D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: _darkOnSurface),
          displayMedium: TextStyle(color: _darkOnSurface),
          displaySmall: TextStyle(color: _darkOnSurface),
          headlineLarge: TextStyle(color: _darkOnSurface),
          headlineMedium: TextStyle(color: _darkOnSurface, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(color: _darkOnSurface),
          titleLarge: TextStyle(color: _darkOnSurface),
          titleMedium: TextStyle(color: _darkOnSurface),
          titleSmall: TextStyle(color: _darkOnSurfaceVariant),
          bodyLarge: TextStyle(color: _darkOnSurface),
          bodyMedium: TextStyle(color: _darkOnSurface),
          bodySmall: TextStyle(color: _darkOnSurfaceVariant),
          labelLarge: TextStyle(color: Color(0xFF22005D)),
          labelMedium: TextStyle(color: _darkOnSurfaceVariant),
          labelSmall: TextStyle(color: _darkOnSurfaceVariant),
        ),
        dividerTheme: const DividerThemeData(color: Color(0xFF3A3550)),
        cardTheme: const CardTheme(
          color: _darkSurface,
          elevation: 2,
          shadowColor: Colors.black54,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _darkSurfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _darkOutline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _darkOutline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.softLavender, width: 2),
          ),
          labelStyle: const TextStyle(color: _darkOnSurfaceVariant),
          hintStyle: const TextStyle(color: _darkOnSurfaceVariant),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.softLavender,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: _darkSurfaceVariant,
          labelStyle: const TextStyle(color: AppColors.softLavender),
          side: const BorderSide(color: _darkOutline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return AppColors.softLavender;
            }
            return _darkOnSurfaceVariant;
          }),
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return AppColors.softLavender.withOpacity(0.35);
            }
            return _darkSurfaceVariant;
          }),
        ),
        listTileTheme: const ListTileThemeData(
          tileColor: Colors.transparent,
          textColor: _darkOnSurface,
          iconColor: _darkOnSurfaceVariant,
        ),
      );

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
