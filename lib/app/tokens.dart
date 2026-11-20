import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Folio exact design tokens.
abstract final class FolioColors {
  // Light palette
  static const Color bg = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF7F7F5);
  static const Color ink = Color(0xFF191919);
  static const Color secondary = Color(0xFF707070);
  static const Color border = Color(0xFFEAEAEA);
  static const Color outline = Color(0xFFD9D9D6);
  static const Color mutedIcon = Color(0xFF9A9A95);

  // Subtle purple accent
  static const Color accent = Color(0xFF8B6CE8);
  static const Color accentText = Color(0xFF5B3FC4);
  static const Color accentTint = Color(0xFFF4F1FB);
  static const Color accentTintAlt = Color(0xFFF1EDFC);
  static const Color selectedCardBg = Color(0xFFFAF8FF);
  static const Color familyDivider = Color(0xFFDDD5F3);

  // Plum panels (premium cards, hero bands, now-reading bar)
  static const Color plum = Color(0xFF2F2B3A);
  static const Color plumText = Color(0xFFF4F1EA);
  static const Color plumLabel = Color(0xFFC9BBF3);

  // Semantic
  static const Color success = Color(0xFF2F7A52);
  static const Color error = Color(0xFFB3261E);

  // Shelf plank & skeleton
  static const Color plank = Color(0xFFDEDBD3);
  static const Color shimmer = Color(0xFFE6E2D8);

  // Dark palette (Home & Reader night only)
  static const Color darkBg = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1C1C1E);
  static const Color darkInk = Color(0xFFF2F2F2);
  static const Color darkSecondary = Color(0xFFA0A0A0);
  static const Color darkBorder = Color(0xFF2C2C2E);

  // Reader themes
  static const Color paperBg = Color(0xFFFFFFFF);
  static const Color paperInk = Color(0xFF191919);
  static const Color sepiaBg = Color(0xFFF4ECD8);
  static const Color sepiaInk = Color(0xFF3B2F1E);
  static const Color nightBg = Color(0xFF121212);
  static const Color nightInk = Color(0xFFD8D8D8);

  // Cover palette
  static const Color coverPlum = Color(0xFF2F2B3A);
  static const Color coverLavender = Color(0xFFCFC8E8);
  static const Color coverSand = Color(0xFFD8C7B8);
  static const Color coverSlate = Color(0xFF1E2A2F);
  static const Color coverCream = Color(0xFFE8E1D3);
  static const Color coverMist = Color(0xFFDDE3E0);
  static const Color coverLinen = Color(0xFFE6DCD0);
  static const Color coverLilac = Color(0xFFC9BBF3);
  static const Color coverForest = Color(0xFF3A4A3F);
  static const Color coverInkWarm = Color(0xFF2A2623);
  static const Color coverInkViolet = Color(0xFF241C4A);
}

abstract final class FolioRadius {
  static const double cover = 4;
  static const double ad = 10;
  static const double toast = 12;
  static const double button = 16;
  static const double buttonSm = 14;
  static const double navWrite = 15;
  static const double card = 16;
  static const double cardMd = 18;
  static const double cardLg = 20;
  static const double cardXl = 22;
  static const double sheet = 28;
  static const double chip = 999;
}

abstract final class FolioSpacing {
  static const double pageX = 24;
  static const double sectionGap = 28;
  static const double rowMinHeight = 56;
  static const double navHeight = 84;
  static const double minTap = 44;
}

abstract final class FolioShadows {
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x1F000000), // rgba(0, 0, 0, .12)
      blurRadius: 30,
      offset: Offset(0, 8),
    ),
  ];
}

abstract final class FolioTypography {
  static TextStyle display({
    double size = 34,
    Color color = FolioColors.ink,
  }) =>
      GoogleFonts.playfairDisplay(
        fontSize: size,
        fontWeight: FontWeight.w700,
        height: 1.12,
        letterSpacing: -0.01 * size,
        color: color,
      );

  static TextStyle h1({
    double size = 26,
    Color color = FolioColors.ink,
  }) =>
      GoogleFonts.playfairDisplay(
        fontSize: size,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: color,
      );

  static TextStyle h2({
    double size = 22,
    Color color = FolioColors.ink,
  }) =>
      GoogleFonts.playfairDisplay(
        fontSize: size,
        fontWeight: FontWeight.w700,
        height: 1.24,
        color: color,
      );

  static TextStyle cardTitle({
    double size = 18,
    Color color = FolioColors.ink,
  }) =>
      GoogleFonts.playfairDisplay(
        fontSize: size,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: color,
      );

  static TextStyle body({
    double size = 15,
    FontWeight weight = FontWeight.w400,
    Color color = FolioColors.ink,
    double height = 1.5,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        height: height,
        color: color,
      );

  static TextStyle caption({
    double size = 13,
    FontWeight weight = FontWeight.w400,
    Color color = FolioColors.secondary,
    double height = 1.4,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        height: height,
        color: color,
      );

  static TextStyle label({
    double size = 11,
    Color color = FolioColors.secondary,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: FontWeight.w600,
        letterSpacing: size * 0.1,
        height: 1.3,
        color: color,
      );

  static TextStyle reading({
    double size = 18,
    double height = 1.7,
    Color color = FolioColors.paperInk,
    bool serif = true,
  }) =>
      serif
          ? GoogleFonts.sourceSerif4(
              fontSize: size,
              fontWeight: FontWeight.w400,
              height: height,
              color: color,
            )
          : GoogleFonts.inter(
              fontSize: size * 0.92,
              fontWeight: FontWeight.w400,
              height: height,
              color: color,
            );
}

extension FolioColorAlpha on Color {
  Color withOpacityCompat(double opacity) {
    final clamped = opacity.clamp(0.0, 1.0);
    return withAlpha((clamped * 255).round());
  }
}
