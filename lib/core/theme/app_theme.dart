import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Paper and UI surface colors
  static const Color paperWhite = Color(0xFFFFFFFF);
  static const Color paperOffWhite = Color(0xFFFAFAFA);
  static const Color canvasBackground = Color(0xFFE8E8E8);
  static const Color rulerBackground = Color(0xFFF5F5F5);
  static const Color ribbonBackground = Color(0xFFF0F0F0);
  static const Color sidebarBackground = Color(0xFFF8F9FA);

  // Text colors
  static const Color textPrimary = Color(0xFF1D1D1D);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color textHint = Color(0xFF9AA0A6);

  // UI element colors
  static const Color dividerColor = Color(0xFFDADCE0);
  static const Color borderColor = Color(0xFFC4C7C9);
  static const Color hoverColor = Color(0xFFE8EAED);
  static const Color selectedColor = Color(0xFFD3E3FD);
  static const Color focusColor = Color(0xFF1A73E8);
  static const Color iconColor = Color(0xFF5F6368);
  static const Color iconActiveColor = Color(0xFF1A73E8);

  // Ribbon tab colors
  static const Color ribbonTabActive = Color(0xFF1A73E8);
  static const Color ribbonTabInactive = Color(0xFF5F6368);

  // Ruler colors
  static const Color rulerTickColor = Color(0xFF9AA0A6);
  static const Color rulerIndicatorColor = Color(0xFF1A73E8);

  // Semantic colors
  static const Color success = Color(0xFF34A853);
  static const Color warning = Color(0xFFFBBC04);
  static const Color error = Color(0xFFEA4335);

  // Responsive breakpoints
  static const double tabletBreakpoint = 600.0;
  static const double desktopBreakpoint = 1024.0;
  static const double wideBreakpoint = 1440.0;

  // Layout constants
  static const double ribbonHeight = 48.0;
  static const double rulerHeight = 28.0;
  static const double sidebarWidth = 300.0;
  static const double minTouchTarget = 48.0;
  static const double toolbarIconSize = 24.0;
  static const double documentPadding = 24.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: focusColor,

      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1A73E8),
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFD3E3FD),
        onPrimaryContainer: Color(0xFF041E49),
        secondary: Color(0xFF5F6368),
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFE8EAED),
        onSecondaryContainer: Color(0xFF1D1D1D),
        surface: paperWhite,
        onSurface: textPrimary,
        surfaceVariant: Color(0xFFF0F0F0),
        onSurfaceVariant: textSecondary,
        outline: borderColor,
        outlineVariant: dividerColor,
        error: error,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: canvasBackground,

      platform: TargetPlatform.android,

      appBarTheme: const AppBarTheme(
        backgroundColor: ribbonBackground,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleSpacing: 0,
        toolbarHeight: ribbonHeight,
        iconTheme: IconThemeData(
          color: iconColor,
          size: toolbarIconSize,
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: paperWhite,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),

      cardTheme: CardThemeData(
        color: paperWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: borderColor, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),

      checkboxTheme: CheckboxThemeData(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF0F0F0),
        selectedColor: const Color(0xFFD3E3FD),
        labelStyle: const TextStyle(fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),

      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 0.5,
        space: 0,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: focusColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(minTouchTarget, minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: focusColor,
          minimumSize: const Size(minTouchTarget, minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          side: const BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: paperOffWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: focusColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: error),
        ),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
        hintStyle: const TextStyle(color: textHint, fontSize: 14),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: iconColor,
          minimumSize: const Size(minTouchTarget, minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        horizontalTitleGap: 12,
        minLeadingWidth: 24,
        dense: true,
        titleTextStyle: TextStyle(
          fontSize: 14,
          color: textPrimary,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 12,
          color: textSecondary,
        ),
      ),

      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(paperWhite),
          elevation: WidgetStatePropertyAll(4),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: borderColor, width: 0.5),
            ),
          ),
        ),
      ),

      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: sidebarBackground,
        indicatorColor: selectedColor,
        labelType: NavigationRailLabelType.none,
        minExtendedWidth: sidebarWidth,
        groupAlignment: 0,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: focusColor,
              size: toolbarIconSize,
            );
          }
          return const IconThemeData(color: iconColor, size: toolbarIconSize);
        }),
        selectedIconTheme: const IconThemeData(
          color: focusColor,
          size: toolbarIconSize,
        ),
        unselectedIconTheme: const IconThemeData(
          color: iconColor,
          size: toolbarIconSize,
        ),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: paperWhite,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(fontSize: 14, color: textPrimary),
      ),

      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(dividerColor),
        thickness: WidgetStatePropertyAll(6),
        radius: const Radius.circular(8),
        minThumbLength: 48,
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: focusColor,
        inactiveTrackColor: borderColor,
        thumbColor: focusColor,
        overlayColor: focusColor.withOpacity(0.12),
        valueIndicatorColor: focusColor,
        valueIndicatorTextStyle: const TextStyle(color: Colors.white),
        trackHeight: 2,
        minTouchTargetSize: minTouchTarget,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      tabBarTheme: const TabBarTheme(
        labelColor: textPrimary,
        unselectedLabelColor: textSecondary,
        indicatorColor: focusColor,
        labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(fontSize: 14),
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: textPrimary.withOpacity(0.9),
          borderRadius: BorderRadius.circular(4),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        preferBelow: false,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: paperWhite,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          color: textSecondary,
        ),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          height: 1.4,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          height: 1.4,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          height: 1.4,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          height: 1.4,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: 1.4,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: 1.4,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          height: 1.4,
        ),
        titleSmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimary,
          height: 1.8,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textPrimary,
          height: 1.8,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: textSecondary,
          height: 1.6,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          height: 1.4,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          height: 1.4,
        ),
      ),
    );
  }
}
