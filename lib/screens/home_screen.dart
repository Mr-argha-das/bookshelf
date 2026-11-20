import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/theme.dart';
import '../app/tokens.dart';
import '../data/models.dart';
import '../state/providers.dart';
import '../widgets/widgets.dart';

class HomeScreen extends ConsumerWidget {
  final ThemeMode? themeModeOverride;

  const HomeScreen({super.key, this.themeModeOverride});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerDark = ref.watch(homeDarkModeProvider);
    final isDark = themeModeOverride != null
        ? themeModeOverride == ThemeMode.dark
        : providerDark;

    final theme = isDark ? FolioTheme.dark() : FolioTheme.light();
    final bg = isDark ? FolioColors.darkBg : FolioColors.bg;
    final surface = isDark ? FolioColors.darkSurface : FolioColors.surface;
    final ink = isDark ? FolioColors.darkInk : FolioColors.ink;
    final secondary = isDark ? FolioColors.darkSecondary : FolioColors.secondary;
    final border = isDark ? FolioColors.darkBorder : FolioColors.border;

    final user = ref.watch(userProvider);
    final books = ref.watch(booksProvider);
    final salt = ref.watch(bookByIdProvider('salt'));
    final bookOfWeek = books.firstWhere(
      (b) => b.id == 'glass-harbour',
      orElse: () => books.first,
    );
    final picked = books.take(14).toList();
    final trending = books.where((b) => b.isTrending).take(10).toList();
    final finishTonight = books
        .where((b) => b.status == BookStatus.reading)
        .toList();
    final newChapters = books.where((b) => b.isNewChapterToday).toList();

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      FolioSpacing.pageX,
                      16,
                      FolioSpacing.pageX,
                      104,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // 1. Header
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Good evening, Priya',
                                style: FolioTypography.h1(
                                  size: 24,
                                  color: ink,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Streak chip
                            Semantics(
                              button: true,
                              label: '${user.streakDays} day reading streak',
                              child: InkWell(
                                onTap: () => showFolioToast(
                                  context,
                                  '${user.streakDays}-day reading streak kept alive',
                                ),
                                borderRadius:
                                    BorderRadius.circular(FolioRadius.chip),
                                child: Container(
                                  height: 36,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: surface,
                                    borderRadius:
                                        BorderRadius.circular(FolioRadius.chip),
                                    border: Border.all(color: border),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.local_fire_department_outlined,
                                        size: 16,
                                        color: ink,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${user.streakDays}',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: ink,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            FolioAvatar(
                              initials: user.initials,
                              size: 40,
                              backgroundColor: user.avatarBg,
                              foregroundColor: user.avatarFg,
                              semanticsLabel: 'Open Account',
                              onTap: () => context.push('/account'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // 2. Search field
                        Semantics(
                          button: true,
                          label: 'Search books, authors',
                          child: InkWell(
                            onTap: () => context.push('/search'),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDark ? border : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search_rounded,
                                    size: 20,
                                    color: isDark
                                        ? FolioColors.darkSecondary
                                        : FolioColors.mutedIcon,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Search books, authors',
                                      style: FolioTypography.body(
                                        size: 15,
                                        color: isDark
                                            ? FolioColors.darkSecondary
                                            : FolioColors.mutedIcon,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // 3. Continue reading hero
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: FolioColors.plum,
                            borderRadius: BorderRadius.circular(FolioRadius.cardXl),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () => context.push('/book/${salt.id}'),
                                child: BookCover(
                                  title: salt.title,
                                  author: salt.author,
                                  bg: salt.coverBg,
                                  fg: salt.coverFg,
                                  width: 84,
                                  height: 124,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'CONTINUE READING',
                                      style: FolioTypography.label(
                                        color: FolioColors.plumLabel,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      salt.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: FolioTypography.h2(
                                        size: 22,
                                        color: FolioColors.plumText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Chapter ${salt.currentChapter} · ${salt.minutesLeft} min left',
                                      style: FolioTypography.caption(
                                        size: 13,
                                        color: FolioColors.plumText
                                            .withOpacityCompat(0.72),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    FolioProgressBar(
                                      value: salt.progress,
                                      height: 4,
                                      activeColor: FolioColors.accent,
                                      trackColor: FolioColors.plumText
                                          .withOpacityCompat(0.20),
                                    ),
                                    const SizedBox(height: 14),
                                    PrimaryButton(
                                      label: 'Resume',
                                      height: 44,
                                      radius: 12,
                                      fontSize: 14,
                                      fullWidth: false,
                                      backgroundColor: FolioColors.plumText,
                                      foregroundColor: FolioColors.plum,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      onPressed: () =>
                                          context.push('/reader/${salt.id}'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 4. Goal ring card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(FolioRadius.cardMd),
                            border: Border.all(
                              color: isDark ? border : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 56,
                                height: 56,
                                child: CustomPaint(
                                  painter: _GoalRingPainter(
                                    progress: user.dailyProgress,
                                    trackColor: border,
                                    activeColor: FolioColors.accent,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${(user.dailyProgress * 100).round()}%',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: ink,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${user.minutesReadToday} of ${user.dailyGoalMinutes} minutes today',
                                      style: FolioTypography.body(
                                        size: 15,
                                        weight: FontWeight.w600,
                                        color: ink,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Keep your ${user.streakDays}-day streak',
                                      style: FolioTypography.caption(
                                        size: 13,
                                        color: secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: FolioSpacing.sectionGap),

                        // 5. Book of the week
                        SectionHeader(
                          title: 'Book of the week',
                          titleColor: ink,
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(FolioRadius.cardLg),
                            border: Border.all(color: border),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    context.push('/book/${bookOfWeek.id}'),
                                child: BookCover(
                                  title: bookOfWeek.title,
                                  author: bookOfWeek.author,
                                  bg: bookOfWeek.coverBg,
                                  fg: bookOfWeek.coverFg,
                                  width: 120,
                                  height: 176,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      bookOfWeek.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: FolioTypography.cardTitle(
                                        size: 20,
                                        color: ink,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${bookOfWeek.author} · ★ ${bookOfWeek.rating}',
                                      style: FolioTypography.caption(
                                        size: 13,
                                        color: secondary,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      bookOfWeek.blurb,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: FolioTypography.body(
                                        size: 13,
                                        color: secondary,
                                        height: 1.45,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: PrimaryButton(
                                            label: 'Read',
                                            height: 44,
                                            radius: 12,
                                            fontSize: 13,
                                            backgroundColor: isDark
                                                ? FolioColors.darkInk
                                                : FolioColors.ink,
                                            foregroundColor: isDark
                                                ? FolioColors.darkBg
                                                : Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                            ),
                                            onPressed: () => context.push(
                                              '/reader/${bookOfWeek.id}',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: SecondaryButton(
                                            label: bookOfWeek.status ==
                                                    BookStatus.saved
                                                ? 'Saved'
                                                : 'Save',
                                            height: 44,
                                            radius: 12,
                                            fontSize: 13,
                                            foregroundColor: ink,
                                            borderColor: isDark
                                                ? FolioColors.darkBorder
                                                : FolioColors.outline,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                            ),
                                            onPressed: () {
                                              ref
                                                  .read(booksProvider.notifier)
                                                  .toggleSaved(bookOfWeek.id);
                                              showFolioToast(
                                                context,
                                                'Updated shelf for ${bookOfWeek.title}',
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: FolioSpacing.sectionGap),

                        // 6. Picked for you
                        SectionHeader(
                          title: 'Picked for you',
                          actionLabel: 'See all',
                          titleColor: ink,
                          onAction: () => context.go('/explore'),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 232,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: picked.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 14),
                            itemBuilder: (context, index) {
                              final book = picked[index];
                              return _CoverColumnCard(
                                book: book,
                                ink: ink,
                                secondary: secondary,
                                onTap: () => context.push('/book/${book.id}'),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: FolioSpacing.sectionGap),

                        // 7. Trending top 10
                        SectionHeader(
                          title: 'Trending top 10',
                          titleColor: ink,
                        ),
                        const SizedBox(height: 10),
                        for (int i = 0; i < trending.length; i++)
                          _TrendingRow(
                            rank: i + 1,
                            book: trending[i],
                            ink: ink,
                            secondary: secondary,
                            border: border,
                            isDark: isDark,
                            onTap: () =>
                                context.push('/book/${trending[i].id}'),
                          ),
                        const SizedBox(height: 22),

                        // 8. Ad slot (between Picked/Trending and Finish tonight)
                        const AdSlot(),
                        const SizedBox(height: FolioSpacing.sectionGap),

                        // 9. Finish tonight
                        SectionHeader(
                          title: 'Finish tonight',
                          titleColor: ink,
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 196,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: finishTonight.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 14),
                            itemBuilder: (context, index) {
                              final book = finishTonight[index];
                              return _FinishTonightCard(
                                book: book,
                                surface: surface,
                                ink: ink,
                                secondary: secondary,
                                border: border,
                                onTap: () => context.push('/reader/${book.id}'),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: FolioSpacing.sectionGap),

                        // 10. New chapters
                        SectionHeader(
                          title: 'New chapters',
                          titleColor: ink,
                        ),
                        const SizedBox(height: 10),
                        for (final book in newChapters)
                          _NewChapterRow(
                            book: book,
                            ink: ink,
                            secondary: secondary,
                            border: border,
                            onTap: () =>
                                context.push('/book/${book.id}/chapters'),
                          ),
                      ]),
                    ),
                  ),
                ],
              ),
              // 11. Pinned Now-reading bar above nav
              const Positioned(
                left: 0,
                right: 0,
                bottom: 12,
                child: NowReadingBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color activeColor;

  const _GoalRingPainter({
    required this.progress,
    required this.trackColor,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 5.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GoalRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.activeColor != activeColor;
  }
}

class _CoverColumnCard extends StatelessWidget {
  final Book book;
  final Color ink;
  final Color secondary;
  final VoidCallback onTap;

  const _CoverColumnCard({
    required this.book,
    required this.ink,
    required this.secondary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${book.title} by ${book.author}',
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookCover(
                title: book.title,
                author: book.author,
                bg: book.coverBg,
                fg: book.coverFg,
                width: 120,
                height: 176,
              ),
              const SizedBox(height: 8),
              Text(
                book.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: FolioTypography.body(
                  size: 13,
                  weight: FontWeight.w600,
                  color: ink,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                book.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: FolioTypography.caption(
                  size: 12,
                  color: secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrendingRow extends StatelessWidget {
  final int rank;
  final Book book;
  final Color ink;
  final Color secondary;
  final Color border;
  final bool isDark;
  final VoidCallback onTap;

  const _TrendingRow({
    required this.rank,
    required this.book,
    required this.ink,
    required this.secondary,
    required this.border,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 88),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: border, width: 1)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 34,
              child: Text(
                '$rank',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: isDark ? FolioColors.darkBorder : FolioColors.outline,
                  height: 1.0,
                ),
              ),
            ),
            const SizedBox(width: 10),
            BookCover(
              title: book.title,
              author: book.author,
              bg: book.coverBg,
              fg: book.coverFg,
              width: 48,
              height: 72,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FolioTypography.cardTitle(size: 16, color: ink),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FolioTypography.caption(size: 13, color: secondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '★ ${book.rating} · ${book.reads} reads',
                    style: FolioTypography.caption(size: 12, color: secondary),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: secondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _FinishTonightCard extends StatelessWidget {
  final Book book;
  final Color surface;
  final Color ink;
  final Color secondary;
  final Color border;
  final VoidCallback onTap;

  const _FinishTonightCard({
    required this.book,
    required this.surface,
    required this.ink,
    required this.secondary,
    required this.border,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(FolioRadius.card),
      child: Container(
        width: 236,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(FolioRadius.card),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            BookCover(
              title: book.title,
              author: book.author,
              bg: book.coverBg,
              fg: book.coverFg,
              width: 72,
              height: 108,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: FolioTypography.cardTitle(size: 16, color: ink),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${book.minutesLeft} min left',
                    style: FolioTypography.caption(size: 12, color: secondary),
                  ),
                  const SizedBox(height: 12),
                  FolioProgressBar(
                    value: book.progress,
                    height: 4,
                    trackColor: border,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${(book.progress * 100).round()}% read',
                    style: FolioTypography.caption(size: 11, color: secondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewChapterRow extends StatelessWidget {
  final Book book;
  final Color ink;
  final Color secondary;
  final Color border;
  final VoidCallback onTap;

  const _NewChapterRow({
    required this.book,
    required this.ink,
    required this.secondary,
    required this.border,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 78),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: border, width: 1)),
        ),
        child: Row(
          children: [
            BookCover(
              title: book.title,
              author: book.author,
              bg: book.coverBg,
              fg: book.coverFg,
              width: 44,
              height: 66,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FolioTypography.cardTitle(size: 16, color: ink),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Chapter ${book.currentChapter + 1} · today',
                    style: FolioTypography.caption(
                      size: 13,
                      color: FolioColors.accentText,
                      weight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: secondary,
            ),
          ],
        ),
      ),
    );
  }
}
