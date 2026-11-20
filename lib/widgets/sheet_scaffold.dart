import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app/tokens.dart';

/// Shared bottom sheet wrapper with dimmed tap-to-dismiss barrier,
/// radius 28 top corners, soft shadow, and 40 x 4 grabber handle.
class FolioSheetScaffold extends StatelessWidget {
  final Widget child;
  final VoidCallback? onDismiss;
  final Color backgroundColor;
  final double maxHeightFactor;

  const FolioSheetScaffold({
    super.key,
    required this.child,
    this.onDismiss,
    this.backgroundColor = FolioColors.bg,
    this.maxHeightFactor = 0.88,
  });

  void _handleDismiss(BuildContext context) {
    if (onDismiss != null) {
      onDismiss!();
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _handleDismiss(context),
              child: const SizedBox.expand(),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: screenHeight * maxHeightFactor,
                maxWidth: 460,
              ),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(FolioRadius.sheet),
                  ),
                  boxShadow: FolioShadows.soft,
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: FolioColors.outline,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Flexible(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            FolioSpacing.pageX,
                            8,
                            FolioSpacing.pageX,
                            24 + MediaQuery.viewInsetsOf(context).bottom,
                          ),
                          child: child,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Safe pop helper: pops if possible, else navigates to [fallback].
void safePop(BuildContext context, {String fallback = '/home'}) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(fallback);
  }
}

/// Accessible 44x44 icon button wrapper.
class FolioIconButton extends StatelessWidget {
  final IconData icon;
  final String semanticsLabel;
  final VoidCallback onPressed;
  final Color? color;
  final double size;
  final Color? backgroundColor;
  final Color? borderColor;

  const FolioIconButton({
    super.key,
    required this.icon,
    required this.semanticsLabel,
    required this.onPressed,
    this.color,
    this.size = 22,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = color ?? (isDark ? FolioColors.darkInk : FolioColors.ink);

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: backgroundColor ?? Colors.transparent,
        shape: CircleBorder(
          side: borderColor != null
              ? BorderSide(color: borderColor!, width: 1)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: FolioSpacing.minTap,
            height: FolioSpacing.minTap,
            child: Icon(icon, size: size, color: fg),
          ),
        ),
      ),
    );
  }
}
