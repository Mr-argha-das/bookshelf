import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Editorial drop cap paragraph: first letter sits 3 lines tall in Playfair
/// Display while lines 1-3 wrap neatly beside it and line 4+ flows full width.
class DropCapText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color dropCapColor;
  final int dropCapLines;

  const DropCapText({
    super.key,
    required this.text,
    required this.style,
    required this.dropCapColor,
    this.dropCapLines = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    final firstChar = text[0];
    final rest = text.substring(1);
    if (rest.isEmpty) {
      return Text(firstChar, style: style);
    }

    final baseFontSize = style.fontSize ?? 16.0;
    final lineHeight = style.height ?? 1.6;
    final dropCapSize = baseFontSize * lineHeight * (dropCapLines - 0.35);
    final dropCapStyle = GoogleFonts.playfairDisplay(
      fontSize: dropCapSize,
      fontWeight: FontWeight.w700,
      height: 0.86,
      color: dropCapColor,
    );
    final textScaler = MediaQuery.textScalerOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        if (!maxW.isFinite || maxW <= 80) {
          return Text(text, textAlign: TextAlign.left, style: style);
        }

        final capPainter = TextPainter(
          text: TextSpan(text: firstChar, style: dropCapStyle),
          textDirection: TextDirection.ltr,
          textScaler: textScaler,
        )..layout();

        const capGap = 10.0;
        final topWidth = (maxW - capPainter.width - capGap).clamp(60.0, maxW);

        final restPainter = TextPainter(
          text: TextSpan(text: rest, style: style),
          textDirection: TextDirection.ltr,
          textScaler: textScaler,
        )..layout(maxWidth: topWidth);

        final metrics = restPainter.computeLineMetrics();
        if (metrics.length <= dropCapLines) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: capGap, top: 3),
                child: Text(firstChar, style: dropCapStyle),
              ),
              Expanded(
                child: Text(
                  rest,
                  textAlign: TextAlign.left,
                  style: style,
                ),
              ),
            ],
          );
        }

        double y = 0;
        for (int i = 0; i < dropCapLines - 1; i++) {
          y += metrics[i].height;
        }
        y += metrics[dropCapLines - 1].height * 0.5;

        final endPos = restPainter.getPositionForOffset(Offset(topWidth, y));
        var split = endPos.offset.clamp(0, rest.length);
        if (split > 0 &&
            split < rest.length &&
            rest[split] != ' ' &&
            rest[split - 1] != ' ') {
          final prevSpace = rest.lastIndexOf(' ', split);
          if (prevSpace > 0) {
            split = prevSpace + 1;
          }
        }

        final topPart = rest.substring(0, split).trimRight();
        final bottomPart = rest.substring(split).trimLeft();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: capGap, top: 3),
                  child: Text(firstChar, style: dropCapStyle),
                ),
                Expanded(
                  child: Text(
                    topPart,
                    textAlign: TextAlign.left,
                    style: style,
                  ),
                ),
              ],
            ),
            if (bottomPart.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(
                  bottomPart,
                  textAlign: TextAlign.left,
                  style: style,
                ),
              ),
          ],
        );
      },
    );
  }
}
