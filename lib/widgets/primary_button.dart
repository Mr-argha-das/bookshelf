import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/tokens.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final double height;
  final double radius;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool fullWidth;
  final EdgeInsetsGeometry? padding;
  final double fontSize;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.height = 56,
    this.radius = FolioRadius.button,
    this.backgroundColor = FolioColors.ink,
    this.foregroundColor = Colors.white,
    this.fullWidth = true,
    this.padding,
    this.fontSize = 16,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = enabled && onPressed != null;
    final effectiveHeight = height < FolioSpacing.minTap ? FolioSpacing.minTap : height;

    final button = Opacity(
      opacity: isActive ? 1.0 : 0.4,
      child: SizedBox(
        width: fullWidth ? double.infinity : null,
        height: effectiveHeight,
        child: Material(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(radius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: isActive ? onPressed : null,
            child: Padding(
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: foregroundColor),
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

    return Semantics(
      button: true,
      enabled: isActive,
      label: label,
      child: button,
    );
  }
}
