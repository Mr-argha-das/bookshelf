import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/tokens.dart';

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;
  final double radius;
  final Color borderColor;
  final Color foregroundColor;
  final Color backgroundColor;
  final bool fullWidth;
  final EdgeInsetsGeometry? padding;
  final double fontSize;
  final Widget? leading;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 48,
    this.radius = FolioRadius.buttonSm,
    this.borderColor = FolioColors.outline,
    this.foregroundColor = FolioColors.ink,
    this.backgroundColor = Colors.transparent,
    this.fullWidth = true,
    this.padding,
    this.fontSize = 14,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height < FolioSpacing.minTap ? FolioSpacing.minTap : height;
    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        width: fullWidth ? double.infinity : null,
        height: effectiveHeight,
        child: Material(
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: BorderSide(color: borderColor, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        color: foregroundColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
