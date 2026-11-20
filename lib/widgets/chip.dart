import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/tokens.dart';

class FolioChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool showCheckWhenSelected;
  final VoidCallback? onTap;
  final double height;
  final Color? selectedBg;
  final Color? selectedFg;
  final Color? unselectedBg;
  final Color? unselectedFg;
  final Color? borderColor;

  const FolioChip({
    super.key,
    required this.label,
    this.selected = false,
    this.showCheckWhenSelected = false,
    this.onTap,
    this.height = 44,
    this.selectedBg,
    this.selectedFg,
    this.unselectedBg,
    this.unselectedFg,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = selected
        ? (selectedBg ?? (isDark ? FolioColors.darkInk : FolioColors.ink))
        : (unselectedBg ?? Colors.transparent);
    final fg = selected
        ? (selectedFg ?? (isDark ? FolioColors.darkBg : Colors.white))
        : (unselectedFg ?? (isDark ? FolioColors.darkInk : FolioColors.ink));
    final border = selected
        ? Colors.transparent
        : (borderColor ?? (isDark ? FolioColors.darkBorder : FolioColors.outline));

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: height),
        child: Material(
          color: bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FolioRadius.chip),
            side: BorderSide(color: border, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected && showCheckWhenSelected) ...[
                    Icon(Icons.check_rounded, size: 16, color: fg),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: fg,
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
