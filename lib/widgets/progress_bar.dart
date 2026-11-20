import 'package:flutter/material.dart';
import '../app/tokens.dart';

class FolioProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final Color activeColor;
  final Color trackColor;
  final double radius;

  const FolioProgressBar({
    super.key,
    required this.value,
    this.height = 4,
    this.activeColor = FolioColors.accent,
    this.trackColor = FolioColors.border,
    this.radius = 999,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Positioned.fill(child: ColoredBox(color: trackColor)),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  width: constraints.maxWidth * clamped,
                  height: height,
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(radius),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
