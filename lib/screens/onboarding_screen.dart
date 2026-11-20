import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/tokens.dart';
import '../widgets/widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _pageIndex = 0;

  static const _slides = [
    (
      title: 'Read slowly.\nWrite short.',
      subtitle:
          'A quiet place for novels you savour over evenings and short books you finish in one sitting.',
    ),
    (
      title: 'A shelf that\nfeels like yours.',
      subtitle:
          'Arrange books by mood, keep your reading streak gentle, and pick up right where you left off.',
    ),
    (
      title: 'Publish your\nown pages.',
      subtitle:
          'Draft a ten-minute essay or a chaptered book in a calm editor made only for words.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_pageIndex];

    return Scaffold(
      backgroundColor: FolioColors.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: FolioSpacing.pageX,
                vertical: 20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top brand mark
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Folio',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: FolioColors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 3 overlapping typographic covers rotated -6, 0, +6 deg
                    GestureDetector(
                      onHorizontalDragEnd: (details) {
                        final v = details.primaryVelocity ?? 0;
                        if (v < -150 && _pageIndex < 2) {
                          setState(() => _pageIndex++);
                        } else if (v > 150 && _pageIndex > 0) {
                          setState(() => _pageIndex--);
                        }
                      },
                      child: SizedBox(
                        width: double.infinity,
                        height: 256,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                            width: 310,
                            height: 256,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Transform.translate(
                                  offset: const Offset(-66, 10),
                                  child: Transform.rotate(
                                    angle: -6 * math.pi / 180,
                                    child: const BookCover(
                                      title: 'Paper Moons',
                                      author: 'Arjun Sen',
                                      bg: FolioColors.coverPlum,
                                      fg: FolioColors.plumText,
                                      width: 128,
                                      height: 190,
                                      elevated: true,
                                    ),
                                  ),
                                ),
                                Transform.translate(
                                  offset: const Offset(66, 12),
                                  child: Transform.rotate(
                                    angle: 6 * math.pi / 180,
                                    child: const BookCover(
                                      title: 'Glass Harbour',
                                      author: 'Julian Vance',
                                      bg: FolioColors.coverForest,
                                      fg: FolioColors.plumText,
                                      width: 128,
                                      height: 190,
                                      elevated: true,
                                    ),
                                  ),
                                ),
                                const BookCover(
                                  title: 'The Salt Orchard',
                                  author: 'Meera Kulkarni',
                                  bg: FolioColors.coverCream,
                                  fg: FolioColors.coverInkWarm,
                                  width: 144,
                                  height: 214,
                                  elevated: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Text + dots + actions
                    Column(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: Column(
                            key: ValueKey(_pageIndex),
                            children: [
                              Text(
                                slide.title,
                                textAlign: TextAlign.center,
                                style: FolioTypography.display(size: 34),
                              ),
                              const SizedBox(height: 14),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 290),
                                child: Text(
                                  slide.subtitle,
                                  textAlign: TextAlign.center,
                                  style: FolioTypography.body(
                                    size: 15,
                                    color: FolioColors.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // 3 page dots (active is 20 x 6 purple pill)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            final active = index == _pageIndex;
                            return Semantics(
                              button: true,
                              label: 'Onboarding page ${index + 1}',
                              child: GestureDetector(
                                onTap: () => setState(() => _pageIndex = index),
                                behavior: HitTestBehavior.opaque,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 12,
                                  ),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 220),
                                    width: active ? 20 : 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: active
                                          ? FolioColors.accent
                                          : FolioColors.outline,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          label: 'Get started',
                          onPressed: () => context.push('/genres'),
                        ),
                        const SizedBox(height: 8),
                        Semantics(
                          button: true,
                          label: 'I already have an account',
                          child: TextButton(
                            onPressed: () => context.push('/login'),
                            style: TextButton.styleFrom(
                              minimumSize: const Size(44, 44),
                              foregroundColor: FolioColors.ink,
                            ),
                            child: Text(
                              'I already have an account',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: FolioColors.ink,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
