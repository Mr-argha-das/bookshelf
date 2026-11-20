import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/tokens.dart';

class BookCover extends StatelessWidget {
  final String title;
  final String author;
  final Color bg;
  final Color fg;
  final double width;
  final double height;
  final bool spine;
  final bool elevated;

  const BookCover({
    super.key,
    required this.title,
    required this.author,
    required this.bg,
    required this.fg,
    required this.width,
    required this.height,
    this.spine = false,
    this.elevated = false,
  });

  const BookCover.spine({
    super.key,
    required this.title,
    this.author = '',
    required this.bg,
    required this.fg,
    this.width = 36,
    this.height = 170,
    this.elevated = false,
  }) : spine = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(FolioRadius.cover),
        boxShadow: elevated ? FolioShadows.soft : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (spine) _buildSpineContent() else _buildFrontContent(),
          // Inset left edge 3px lighter spine highlight (white 14%)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 3,
            child: ColoredBox(
              color: Colors.white.withOpacityCompat(0.14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrontContent() {
    final isTiny = width <= 52;
    final padX = (width * 0.11).clamp(4.0, 16.0);
    final padY = (height * 0.08).clamp(4.0, 16.0);
    final circleDiameter = width * 0.45;
    final titleSize = (width * 0.145).clamp(7.0, 22.0);
    final authorSize = (titleSize * 0.55).clamp(5.5, 11.0);

    return Padding(
      padding: EdgeInsets.fromLTRB(padX + 2, padY, padX, padY),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: isTiny ? 1 : height * 0.03),
          Container(
            width: circleDiameter,
            height: circleDiameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: fg.withOpacityCompat(0.35),
                width: isTiny ? 1.0 : 1.5,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: isTiny ? 2 : 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.playfairDisplay(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w700,
                  height: 1.12,
                  color: fg,
                ),
              ),
            ),
          ),
          if (!isTiny && author.isNotEmpty)
            Text(
              author.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: authorSize,
                fontWeight: FontWeight.w600,
                letterSpacing: authorSize * 0.14,
                color: fg.withOpacityCompat(0.78),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSpineContent() {
    final fontSize = (width * 0.34).clamp(10.0, 14.0);
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 10, 4, 10),
      child: Column(
        children: [
          Container(
            width: (width * 0.42).clamp(10.0, 16.0),
            height: (width * 0.42).clamp(10.0, 16.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: fg.withOpacityCompat(0.35),
                width: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: RotatedBox(
                quarterTurns: 1,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    color: fg,
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
