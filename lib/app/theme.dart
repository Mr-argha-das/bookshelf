import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tokens.dart';

/// Custom Material 3 themes for Folio — zero default M3 seed colours.
abstract final class FolioTheme {
  static ThemeData light() {
    final baseTextTheme = GoogleFonts.interTextTheme();
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: FolioColors.ink,
      onPrimary: Colors.white,
      secondary: FolioColors.accent,
      onSecondary: Colors.white,
      error: FolioColors.error,
      onError: Colors.white,
      surface: FolioColors.bg,
      onSurface: FolioColors.ink,
      outline: FolioColors.outline,
      outlineVariant: FolioColors.border,
      surfaceContainerHighest: FolioColors.surface,
      onSurfaceVariant: FolioColors.secondary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: FolioColors.bg,
      canvasColor: FolioColors.bg,
      dividerColor: FolioColors.border,
      splashColor: FolioColors.ink.withOpacityCompat(0.05),
      highlightColor: Colors.transparent,
      textTheme: baseTextTheme.apply(
        bodyColor: FolioColors.ink,
        displayColor: FolioColors.ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: FolioColors.bg,
        foregroundColor: FolioColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(
        color: FolioColors.border,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(
        color: FolioColors.ink,
        size: 22,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return FolioColors.accent;
          }
          return FolioColors.outline;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: FolioColors.accent,
        inactiveTrackColor: FolioColors.border,
        thumbColor: FolioColors.ink,
        overlayColor: FolioColors.accent.withOpacityCompat(0.14),
        trackHeight: 3,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FolioColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: FolioTypography.body(
          size: 15,
          color: FolioColors.mutedIcon,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FolioRadius.buttonSm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FolioRadius.buttonSm),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FolioRadius.buttonSm),
          borderSide: const BorderSide(color: FolioColors.accent, width: 1.5),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final baseTextTheme = GoogleFonts.interTextTheme();
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: FolioColors.darkInk,
      onPrimary: FolioColors.darkBg,
      secondary: FolioColors.accent,
      onSecondary: Colors.white,
      error: FolioColors.error,
      onError: Colors.white,
      surface: FolioColors.darkBg,
      onSurface: FolioColors.darkInk,
      outline: FolioColors.darkBorder,
      outlineVariant: FolioColors.darkBorder,
      surfaceContainerHighest: FolioColors.darkSurface,
      onSurfaceVariant: FolioColors.darkSecondary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: FolioColors.darkBg,
      canvasColor: FolioColors.darkBg,
      dividerColor: FolioColors.darkBorder,
      splashColor: Colors.white.withOpacityCompat(0.06),
      highlightColor: Colors.transparent,
      textTheme: baseTextTheme.apply(
        bodyColor: FolioColors.darkInk,
        displayColor: FolioColors.darkInk,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: FolioColors.darkBg,
        foregroundColor: FolioColors.darkInk,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(
        color: FolioColors.darkBorder,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(
        color: FolioColors.darkInk,
        size: 22,
      ),
    );
  }
}
