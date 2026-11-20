import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/tokens.dart';
import '../data/dummy_data.dart';
import '../data/models.dart';
import '../state/providers.dart';
import '../widgets/widgets.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  final String bookId;
  final ReaderThemeMode? themeOverride;

  const ReaderScreen({
    super.key,
    required this.bookId,
    this.themeOverride,
  });

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

/// Convenience night-mode Reader variant passing theme night.
class ReaderDark extends StatelessWidget {
  final String bookId;

  const ReaderDark({super.key, this.bookId = 'salt'});

  @override
  Widget build(BuildContext context) {
    return ReaderScreen(
      bookId: bookId,
      themeOverride: ReaderThemeMode.night,
    );
  }
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  bool _chromeVisible = true;
  bool _likedChapter = false;
  bool _bookmarkedChapter = false;

  @override
  Widget build(BuildContext context) {
    final book = ref.watch(bookByIdProvider(widget.bookId));
    final settings = ref.watch(readerSettingsProvider);
    final activeTheme = widget.themeOverride ?? settings.theme;

    final Color bg;
    final Color ink;
    final Color secondary;
    final Color surface;
    final Color border;

    switch (activeTheme) {
      case ReaderThemeMode.paper:
        bg = FolioColors.paperBg;
        ink = FolioColors.paperInk;
        secondary = FolioColors.secondary;
        surface = FolioColors.surface;
        border = FolioColors.border;
      case ReaderThemeMode.sepia:
        bg = FolioColors.sepiaBg;
        ink = FolioColors.sepiaInk;
        secondary = FolioColors.sepiaInk.withOpacityCompat(0.66);
        surface = const Color(0xFFECE2CA);
        border = FolioColors.sepiaInk.withOpacityCompat(0.14);
      case ReaderThemeMode.night:
        bg = FolioColors.nightBg;
        ink = FolioColors.nightInk;
        secondary = FolioColors.darkSecondary;
        surface = FolioColors.darkSurface;
        border = FolioColors.darkBorder;
    }

    final isSerif = settings.typeface == ReaderTypeface.serif;
    final readingStyle = FolioTypography.reading(
      size: settings.fontSize,
      height: settings.lineHeight,
      color: ink,
      serif: isSerif,
    );

    final chapterNum = book.currentChapter > 0 ? book.currentChapter : 12;
    final totalChapters = book.chapters;
    final pct = (book.progress * 100).round();

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable reading text
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => setState(() => _chromeVisible = !_chromeVisible),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  FolioSpacing.pageX,
                  72,
                  FolioSpacing.pageX,
                  96,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CHAPTER $chapterNum',
                      style: FolioTypography.label(color: secondary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rain in the Salt Orchard',
                      style: FolioTypography.h1(size: 28, color: ink),
                    ),
                    const SizedBox(height: 26),

                    // First paragraph with 3-line Playfair drop cap (accent-free ink)
                    _DropCapParagraph(
                      text: kChapter12Paragraphs.first,
                      style: readingStyle,
                      ink: ink,
                    ),
                    const SizedBox(height: 18),

                    // Remaining paragraphs
                    for (int i = 1; i < kChapter12Paragraphs.length; i++) ...[
                      Text(
                        kChapter12Paragraphs[i],
                        textAlign: TextAlign.left,
                        style: readingStyle,
                      ),
                      const SizedBox(height: 18),
                    ],

                    const SizedBox(height: 18),

                    // END OF CHAPTER divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: border)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'END OF CHAPTER',
                            style: FolioTypography.label(color: secondary),
                          ),
                        ),
                        Expanded(child: Divider(color: border)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Reactions row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ReaderReactionChip(
                          icon: _likedChapter
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          label: _likedChapter ? 'Loved (49)' : 'Love (48)',
                          active: _likedChapter,
                          surface: surface,
                          ink: ink,
                          border: border,
                          onTap: () =>
                              setState(() => _likedChapter = !_likedChapter),
                        ),
                        const SizedBox(width: 10),
                        _ReaderReactionChip(
                          icon: _bookmarkedChapter
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          label: _bookmarkedChapter ? 'Saved' : 'Bookmark',
                          active: _bookmarkedChapter,
                          surface: surface,
                          ink: ink,
                          border: border,
                          onTap: () => setState(
                            () => _bookmarkedChapter = !_bookmarkedChapter,
                          ),
                        ),
                        const SizedBox(width: 10),
                        _ReaderReactionChip(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: 'Reviews',
                          active: false,
                          surface: surface,
                          ink: ink,
                          border: border,
                          onTap: () => context.push('/book/${book.id}/reviews'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),

                    // AdSlot (300 x 250) hidden automatically for Premium users
                    const AdSlot(large: true),
                    const SizedBox(height: 26),

                    // Up next card for Chapter 13
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(FolioRadius.cardMd),
                        border: Border.all(color: border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'UP NEXT',
                            style: FolioTypography.label(color: secondary),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Chapter ${chapterNum + 1} · The Tin Box Under the Stairs',
                            style: FolioTypography.cardTitle(
                              size: 19,
                              color: ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '15 min read',
                            style: FolioTypography.caption(
                              size: 13,
                              color: secondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          PrimaryButton(
                            label: 'Continue to Chapter ${chapterNum + 1}',
                            height: 48,
                            radius: 14,
                            fontSize: 14,
                            backgroundColor: activeTheme == ReaderThemeMode.night
                                ? FolioColors.darkInk
                                : FolioColors.ink,
                            foregroundColor: activeTheme == ReaderThemeMode.night
                                ? FolioColors.darkBg
                                : Colors.white,
                            onPressed: () {
                              ref.read(booksProvider.notifier).updateProgress(
                                    book.id,
                                    (book.progress + 0.05).clamp(0.0, 1.0),
                                    (chapterNum + 1).clamp(1, totalChapters),
                                  );
                              showFolioToast(
                                context,
                                'Opening Chapter ${chapterNum + 1}',
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Top sticky toolbar (fades on tap)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                ignoring: !_chromeVisible,
                child: AnimatedOpacity(
                  opacity: _chromeVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: bg.withOpacityCompat(0.96),
                      border: Border(bottom: BorderSide(color: border)),
                    ),
                    child: Row(
                      children: [
                        FolioIconButton(
                          icon: Icons.arrow_back_rounded,
                          semanticsLabel: 'Back',
                          color: ink,
                          onPressed: () => safePop(context),
                        ),
                        Expanded(
                          child: Text(
                            'Chapter $chapterNum · ${book.title}',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FolioTypography.caption(
                              size: 13,
                              weight: FontWeight.w500,
                              color: secondary,
                            ),
                          ),
                        ),
                        Semantics(
                          button: true,
                          label: 'Reader typography and theme settings',
                          child: InkWell(
                            onTap: () => context.push('/reader-settings'),
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 44,
                              height: 44,
                              child: Center(
                                child: Text(
                                  'Aa',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: ink,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom sticky progress strip
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  FolioSpacing.pageX,
                  10,
                  FolioSpacing.pageX,
                  12,
                ),
                decoration: BoxDecoration(
                  color: bg.withOpacityCompat(0.96),
                  border: Border(top: BorderSide(color: border)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Chapter $chapterNum of $totalChapters · $pct%',
                          style: FolioTypography.caption(
                            size: 12,
                            color: secondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${book.minutesLeft} min left',
                          style: FolioTypography.caption(
                            size: 12,
                            color: secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    FolioProgressBar(
                      value: book.progress,
                      height: 3,
                      activeColor: FolioColors.accent,
                      trackColor: border,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropCapParagraph extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color ink;

  const _DropCapParagraph({
    required this.text,
    required this.style,
    required this.ink,
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    final firstLetter = text[0];
    final remainder = text.substring(1);
    final dropCapSize = (style.fontSize ?? 18) * 3.1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 10, top: 4),
          child: Text(
            firstLetter,
            style: GoogleFonts.playfairDisplay(
              fontSize: dropCapSize,
              fontWeight: FontWeight.w700,
              height: 0.86,
              color: ink,
            ),
          ),
        ),
        Expanded(
          child: Text(
            remainder,
            textAlign: TextAlign.left,
            style: style,
          ),
        ),
      ],
    );
  }
}

class _ReaderReactionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color surface;
  final Color ink;
  final Color border;
  final VoidCallback onTap;

  const _ReaderReactionChip({
    required this.icon,
    required this.label,
    required this.active,
    required this.surface,
    required this.ink,
    required this.border,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: active ? FolioColors.accentTint : surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(
            color: active ? FolioColors.accent : border,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: active ? FolioColors.accentText : ink,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: FolioTypography.caption(
                      size: 12,
                      weight: FontWeight.w500,
                      color: active ? FolioColors.accentText : ink,
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
