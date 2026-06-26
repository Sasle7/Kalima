import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // Route names
  static const String homeRoute = '/';
  static const String documentRoute = '/document';
  static const String settingsRoute = '/settings';

  // Asset paths
  static const String iconsPath = 'assets/icons';
  static const String imagesPath = 'assets/images';
  static const String fontsPath = 'assets/fonts';

  // Default document settings (in points, 1pt = 1/72 inch)
  static const double defaultPageWidth = 595.28;
  static const double defaultPageHeight = 841.89;
  static const double defaultMarginTop = 72.0;
  static const double defaultMarginBottom = 72.0;
  static const double defaultMarginLeft = 72.0;
  static const double defaultMarginRight = 72.0;
  static const double defaultFontSize = 14.0;

  // Animation durations
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  static const Duration pageTransitionDuration = Duration(milliseconds: 350);

  // Page size presets (width x height in points)
  static const Map<String, Size> pageSizePresets = {
    'A4': Size(595.28, 841.89),
    'Letter': Size(612.0, 792.0),
    'A5': Size(419.53, 595.28),
    'Legal': Size(612.0, 1008.0),
  };

  // Supported font families (must match pubspec.yaml)
  static const List<String> supportedFontFamilies = [
    'Traditional Arabic',
    'Amiri',
    'Cairo',
    'Sakkal Majalla',
  ];

  // Supported file extensions
  static const List<String> supportedExtensions = [
    '.kdoc',
    '.docx',
    '.pdf',
  ];

  // Importable file extensions
  static const List<String> importableExtensions = [
    '.docx',
  ];

  // Exportable file extensions
  static const List<String> exportableExtensions = [
    '.pdf',
    '.docx',
  ];

  // Selection and cursor colors
  static const Color selectionColor = Color(0x663A76F7);
  static const Color cursorColor = Color(0xFF1A73E8);

  // Maximum file size (50 MB)
  static const int maxFileSize = 50 * 1024 * 1024;
}
