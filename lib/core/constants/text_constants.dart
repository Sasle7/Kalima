import 'package:flutter/material.dart';

class Range {
  final int start;
  final int end;

  const Range(this.start, this.end);

  bool contains(int codePoint) => codePoint >= start && codePoint <= end;
}

class TextConstants {
  TextConstants._();

  // Arabic Unicode ranges
  static const Range arabicRange = Range(0x0600, 0x06FF);
  static const Range arabicSupplementRange = Range(0x0750, 0x077F);
  static const Range arabicExtendedARange = Range(0x08A0, 0x08FF);

  // Tashkeel (diacritical) markers
  static const String fathatan = '\u064B';
  static const String dammatan = '\u064C';
  static const String kasratan = '\u064D';
  static const String fatha = '\u064E';
  static const String damma = '\u064F';
  static const String kasra = '\u0650';
  static const String shadda = '\u0651';
  static const String sukun = '\u0652';
  static const String maddah = '\u0653';
  static const String hamzaAbove = '\u0654';
  static const String hamzaBelow = '\u0655';

  static const String allTashkeel =
      '\u064B\u064C\u064D\u064E\u064F\u0650\u0651\u0652\u0653\u0654\u0655';

  static const String tashkeelPattern =
      '[\u064B-\u0655]';

  // Arabic-Indic digits (used in Arabic-speaking countries)
  static const List<String> arabicIndicDigits = [
    '\u0660', // 0
    '\u0661', // 1
    '\u0662', // 2
    '\u0663', // 3
    '\u0664', // 4
    '\u0665', // 5
    '\u0666', // 6
    '\u0667', // 7
    '\u0668', // 8
    '\u0669', // 9
  ];

  // Eastern Arabic-Indic digits (used in Iran, Pakistan)
  static const List<String> easternArabicIndicDigits = [
    '\u06F0', // 0
    '\u06F1', // 1
    '\u06F2', // 2
    '\u06F3', // 3
    '\u06F4', // 4
    '\u06F5', // 5
    '\u06F6', // 6
    '\u06F7', // 7
    '\u06F8', // 8
    '\u06F9', // 9
  ];

  // Default paragraph styles
  static const Map<String, _StyleDefaults> defaultStyles = {
    'heading1': _StyleDefaults(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      lineHeight: 1.4,
      paragraphSpacing: 12.0,
    ),
    'heading2': _StyleDefaults(
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
      lineHeight: 1.4,
      paragraphSpacing: 10.0,
    ),
    'heading3': _StyleDefaults(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      lineHeight: 1.4,
      paragraphSpacing: 8.0,
    ),
    'body': _StyleDefaults(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      lineHeight: 1.8,
      paragraphSpacing: 8.0,
    ),
    'quote': _StyleDefaults(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.italic,
      lineHeight: 1.8,
      paragraphSpacing: 8.0,
    ),
  };

  // Line spacing presets
  static const Map<String, double> lineSpacingPresets = {
    'single': 1.0,
    '1.15': 1.15,
    '1.5': 1.5,
    'double': 2.0,
  };

  // List bullet characters for different levels
  static const List<String> listBullets = [
    '\u2022', // Level 0: bullet
    '\u25CB', // Level 1: hollow circle
    '\u25A0', // Level 2: solid square
    '\u2726', // Level 3: diamond
  ];

  // Arabic-specific list bullets
  static const List<String> arabicListBullets = [
    '\u2022',
    '\u25E6',
    '\u25AA',
    '\u25CF',
  ];

  // Default paragraph spacing
  static const double paragraphSpacing = 8.0;
  static const double headingSpacing = 12.0;
}

class _StyleDefaults {
  final double fontSize;
  final FontWeight fontWeight;
  final FontStyle? fontStyle;
  final double lineHeight;
  final double paragraphSpacing;

  const _StyleDefaults({
    required this.fontSize,
    required this.fontWeight,
    this.fontStyle,
    required this.lineHeight,
    this.paragraphSpacing = 8.0,
  });
}
