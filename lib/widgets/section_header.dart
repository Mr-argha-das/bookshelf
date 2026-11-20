import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/tokens.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? titleColor;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = titleColor ?? (isDark ? FolioColors.darkInk : FolioColors.ink);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: FolioTypography.h2(color: ink),
          ),
        ),
        if (actionLabel != null && onAction != null)
          Semantics(
            button: true,
            label: '$actionLabel $title',
            child: InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: FolioSpacing.minTap,
                  minWidth: FolioSpacing.minTap,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      actionLabel!,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? FolioColors.plumLabel
                            : FolioColors.accentText,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
