import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/tokens.dart';

class FolioAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  const FolioAvatar({
    super.key,
    required this.initials,
    this.size = 40,
    this.backgroundColor = FolioColors.coverLavender,
    this.foregroundColor = FolioColors.coverInkViolet,
    this.borderColor,
    this.borderWidth = 0,
    this.onTap,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = (size * 0.36).clamp(11.0, 26.0);
    final circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: borderColor != null && borderWidth > 0
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.playfairDisplay(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: foregroundColor,
          height: 1.0,
        ),
      ),
    );

    if (onTap == null) return circle;

    return Semantics(
      button: true,
      label: semanticsLabel ?? 'Account',
      child: InkResponse(
        onTap: onTap,
        radius: (size / 2).clamp(22.0, 40.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: FolioSpacing.minTap,
            minHeight: FolioSpacing.minTap,
          ),
          child: Center(child: circle),
        ),
      ),
    );
  }
}
