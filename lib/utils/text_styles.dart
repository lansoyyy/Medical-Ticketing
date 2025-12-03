import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  // Font Family Names
  static const String fontRegular = 'Regular';
  static const String fontMedium = 'Medium';
  static const String fontBold = 'Bold';

  // Heading Styles
  static TextStyle h1 = const TextStyle(
    fontFamily: fontBold,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle h2 = const TextStyle(
    fontFamily: fontBold,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle h3 = const TextStyle(
    fontFamily: fontBold,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle h4 = const TextStyle(
    fontFamily: fontMedium,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle h5 = const TextStyle(
    fontFamily: fontMedium,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle h6 = const TextStyle(
    fontFamily: fontMedium,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Body Styles
  static TextStyle bodyLarge = const TextStyle(
    fontFamily: fontRegular,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyMedium = const TextStyle(
    fontFamily: fontRegular,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static TextStyle bodySmall = const TextStyle(
    fontFamily: fontRegular,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Button Styles
  static TextStyle buttonLarge = const TextStyle(
    fontFamily: fontMedium,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );

  static TextStyle buttonMedium = const TextStyle(
    fontFamily: fontMedium,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );

  static TextStyle buttonSmall = const TextStyle(
    fontFamily: fontMedium,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );

  // Input Styles
  static TextStyle inputText = const TextStyle(
    fontFamily: fontRegular,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.inputText,
  );

  static TextStyle inputHint = const TextStyle(
    fontFamily: fontRegular,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.inputHint,
  );

  static TextStyle inputLabel = const TextStyle(
    fontFamily: fontMedium,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Link Styles
  static TextStyle link = const TextStyle(
    fontFamily: fontRegular,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.primary,
    decoration: TextDecoration.none,
  );

  static TextStyle linkSmall = const TextStyle(
    fontFamily: fontRegular,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.primary,
    decoration: TextDecoration.none,
  );

  // Caption Styles
  static TextStyle caption = const TextStyle(
    fontFamily: fontRegular,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static TextStyle overline = const TextStyle(
    fontFamily: fontMedium,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    color: AppColors.textSecondary,
  );
}
