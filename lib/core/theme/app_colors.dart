import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color deepRoyalPurple = Color(0xFF5B3FD6);
  static const Color mainPurple = Color(0xFF6C63FF);
  static const Color softLavender = Color(0xFF8B7BFF);
  static const Color lightLavender = Color(0xFFCFC7FF);
  static const Color veryLightPurpleBg = Color(0xFFF3F0FF);

  // Secondary Accent Colors
  static const Color cyanBlue = Color(0xFF4DA8FF);
  static const Color softSkyBlue = Color(0xFFDDEEFF);
  static const Color mintGreen = Color(0xFF37D6B5);
  static const Color lightMint = Color(0xFFDFFAF4);

  // Supporting UI Colors
  static const Color softPink = Color(0xFFFFD9E8);
  static const Color warmCream = Color(0xFFFFF4E8);
  static const Color lightGrayBg = Color(0xFFF7F8FC);
  static const Color borderGray = Color(0xFFE5E7EB);

  // Text Colors
  static const Color primaryDarkText = Color(0xFF1F2937);
  static const Color secondaryGrayText = Color(0xFF6B7280);
  static const Color white = Color(0xFFFFFFFF);

  // Gradients
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.45, 1.0],
    colors: [deepRoyalPurple, mainPurple, softLavender],
  );

  static const LinearGradient ctaGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [mainPurple, cyanBlue],
  );
}
