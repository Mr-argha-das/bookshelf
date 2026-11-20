import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/tokens.dart';
import '../data/dummy_data.dart';
import '../data/models.dart';
import '../state/providers.dart';
import '../widgets/widgets.dart';

class BookDetailsScreen extends ConsumerStatefulWidget {
  final String bookId;

  const BookDetailsScreen({super.key, required this.bookId});

  @override
  ConsumerState<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends ConsumerState<BookDetailsScreen> {
  bool _expandedAbout = false;

  @override
  Widget build(BuildContext context) {
    final book = ref.watch(bookByIdProvider(widget.bookId));
    final isPremium = ref.watch(isPremiumProvider);
    final allBooks = ref.watch(booksProvider);
    final reviews = ref.watch(reviewsProvider);
    final chapters = chaptersForBook(book);
    final previewChapters = chapters.take(5).toList();
    final related = allBooks.where((b) => b.id != book.id).take(6).toList();
    final isSaved = book.status == BookStatus.saved;

    return Scaffold(
      backgroundColor: FolioColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero band + overlapping floating stats strip
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: double.infinity,
                          color: FolioColors.surface,
                          padding: const EdgeInsets.fromLTRB(
                            14,
                            10,
                            14,
                            56,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  FolioIconButton(
                                    icon: Icons.arrow_back_rounded,
                                    semanticsLabel: 'Back',
                                    onPressed: () => safePop(context),
                                  ),
                                  const Spacer(),
                                  FolioIconButton(
                                    icon: isSaved
                                        ? Icons.bookmark_rounded
                                        : Icons.bookmark_border_rounded,
                                    semanticsLabel: 'Bookmark book',
                                    onPressed: () {
                                      ref
                                          .read(booksProvider.notifier)
                                          .toggleSaved(book.id);
                                      showFolioToast(
                                        context,
                                        isSaved
                                            ? 'Removed from Saved'
                                            : 'Saved to your shelf',
                                      );
                                    },
                                  ),
                                  FolioIconButton(
                                    icon: Icons.ios_share_outlined,
                                    semanticsLabel: 'Share book',
                                    onPressed: () => showFolioToast(
                                      context,
                                      'Link copied for "${book.title}"',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              BookCover(
                                title: book.title,
                                author: book.author,
                                bg: book.coverBg,
                                fg: book.coverFg,
                                width: 160,
                                height: 236,
                                elevated: true,
                              ),
                              const SizedBox(height: 22),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Text(
                                  book.title,
                                  textAlign: TextAlign.center,
                                  style: FolioTypography.h1(size: 28),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                book.author,
                                style: FolioTypography.body(
                                  size: 15,
                                  color: FolioColors.secondary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                alignment: WrapAlignment.center,
                                children: [
                                  _GenrePill(book.genre),
                                  if (book.isShortBook)
                                    const _GenrePill('Short book'),
                                  if (book.hasPremiumChapters)
                                    const _GenrePill('Early chapters'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Floating stats strip overlapping bottom by 28
                        Positioned(
                          left: FolioSpacing.pageX,
                          right: FolioSpacing.pageX,
                          bottom: -28,
                          child: Container(
                            height: 68,
                            decoration: BoxDecoration(
                              color: FolioColors.bg,
                              borderRadius:
                                  BorderRadius.circular(FolioRadius.card),
                              border: Border.all(color: FolioColors.border),
                              boxShadow: FolioShadows.soft,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _StatColumn(
                                    value: '${book.rating}',
                                    label: 'Rating',
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 32,
                                  color: FolioColors.border,
                                ),
                                Expanded(
                                  child: _StatColumn(
                                    value: book.reads,
                                    label: 'Reads',
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 32,
                                  color: FolioColors.border,
                                ),
                                Expanded(
                                  child: _StatColumn(
                                    value: '${book.chapters}',
                                    label: 'Chapters',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 50),

                    // Action circles (44px): Save, Download (locks to Premium), Share
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: FolioSpacing.pageX,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ActionCircle(
                            icon: isSaved
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            label: isSaved ? 'Saved' : 'Save',
                            onTap: () {
                              ref
                                  .read(booksProvider.notifier)
                                  .toggleSaved(book.id);
                              showFolioToast(
                                context,
                                isSaved
                                    ? 'Removed from Saved'
                                    : 'Saved to your shelf',
                              );
                            },
                          ),
                          _ActionCircle(
                            icon: isPremium
                                ? Icons.download_done_rounded
                                : Icons.lock_outline_rounded,
                            label: isPremium ? 'Download' : 'Offline · Pro',
                            accentRing: !isPremium,
                            onTap: () {
                              if (!isPremium) {
                                context.push('/premium');
                              } else {
                                showFolioToast(
                                  context,
                                  'Downloaded "${book.title}" for offline reading',
                                );
                              }
                            },
                          ),
                          _ActionCircle(
                            icon: Icons.share_outlined,
                            label: 'Share',
                            onTap: () => showFolioToast(
                              context,
                              'Share link copied',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: FolioSpacing.sectionGap),

                    // About with Playfair drop cap + "Read more"
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: FolioSpacing.pageX,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('About', style: FolioTypography.h2()),
                          const SizedBox(height: 12),
                          _AboutDropCapText(
                            text: _expandedAbout
                                ? '${book.blurb} Written for slow evening reading, every chapter closes on a quiet turning point you can finish in under twenty minutes.'
                                : book.blurb,
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () => setState(
                              () => _expandedAbout = !_expandedAbout,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Text(
                                _expandedAbout ? 'Show less' : 'Read more',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: FolioColors.accentText,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: FolioSpacing.sectionGap),

                    // Chapters (first 5 rows with status dots + See all N chapters)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: FolioSpacing.pageX,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(
                            title: 'Chapters',
                            actionLabel: 'See all',
                            onAction: () =>
                                context.push('/book/${book.id}/chapters'),
                          ),
                          const SizedBox(height: 8),
                          for (final ch in previewChapters)
                            _ChapterPreviewRow(
                              chapter: ch,
                              isPremiumUser: isPremium,
                              onTap: () {
                                if (ch.status == ChapterStatus.premium &&
                                    !isPremium) {
                                  context.push('/premium');
                                } else {
                                  context.push('/reader/${book.id}');
                                }
                              },
                            ),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () =>
                                context.push('/book/${book.id}/chapters'),
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  Text(
                                    'See all ${book.chapters} chapters',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: FolioColors.accentText,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 16,
                                    color: FolioColors.accentText,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: FolioSpacing.sectionGap),

                    // Readers say (2 review cards + All reviews)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: FolioSpacing.pageX,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(
                            title: 'Readers say',
                            actionLabel: 'All reviews',
                            onAction: () =>
                                context.push('/book/${book.id}/reviews'),
                          ),
                          const SizedBox(height: 12),
                          for (final review in reviews.take(2)) ...[
                            _MiniReviewCard(review: review),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // If you loved this
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: FolioSpacing.pageX,
                      ),
                      child: const SectionHeader(title: 'If you loved this'),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 224,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: FolioSpacing.pageX,
                        ),
                        scrollDirection: Axis.horizontal,
                        itemCount: related.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final item = related[index];
                          return GestureDetector(
                            onTap: () => context.push('/book/${item.id}'),
                            child: SizedBox(
                              width: 112,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BookCover(
                                    title: item.title,
                                    author: item.author,
                                    bg: item.coverBg,
                                    fg: item.coverFg,
                                    width: 112,
                                    height: 164,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: FolioTypography.body(
                                      size: 13,
                                      weight: FontWeight.w600,
                                      height: 1.25,
                                    ),
                                  ),
                                  Text(
                                    item.author,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: FolioTypography.caption(size: 11),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Sticky CTA above nav
            Container(
              padding: const EdgeInsets.fromLTRB(
                FolioSpacing.pageX,
                12,
                FolioSpacing.pageX,
                12,
              ),
              decoration: const BoxDecoration(
                color: FolioColors.bg,
                border: Border(top: BorderSide(color: FolioColors.border)),
              ),
              child: PrimaryButton(
                label: book.progress > 0
                    ? 'Continue reading · Chapter ${book.currentChapter}'
                    : 'Start reading · Chapter 1',
                onPressed: () => context.push('/reader/${book.id}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenrePill extends StatelessWidget {
  final String label;

  const _GenrePill(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: FolioColors.bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: FolioColors.border),
      ),
      child: Text(
        label,
        style: FolioTypography.caption(size: 12, color: FolioColors.ink),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;

  const _StatColumn({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: GoogleFonts.playfairDisplay(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: FolioColors.ink,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: FolioTypography.caption(size: 11),
        ),
      ],
    );
  }
}

class _ActionCircle extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool accentRing;

  const _ActionCircle({
    required this.icon,
    required this.label,
    required this.onTap,
    this.accentRing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accentRing ? FolioColors.accentTint : FolioColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentRing ? FolioColors.accent : FolioColors.border,
                ),
              ),
              child: Icon(
                icon,
                size: 20,
                color: accentRing ? FolioColors.accentText : FolioColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: FolioTypography.caption(size: 12, color: FolioColors.ink),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutDropCapText extends StatelessWidget {
  final String text;

  const _AboutDropCapText({required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    final firstChar = text[0];
    final rest = text.substring(1);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8, top: 2),
          child: Text(
            firstChar,
            style: GoogleFonts.playfairDisplay(
              fontSize: 44,
              fontWeight: FontWeight.w700,
              height: 0.88,
              color: FolioColors.ink,
            ),
          ),
        ),
        Expanded(
          child: Text(
            rest,
            style: FolioTypography.body(
              size: 15,
              color: FolioColors.ink,
              height: 1.55,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChapterPreviewRow extends StatelessWidget {
  final BookChapter chapter;
  final bool isPremiumUser;
  final VoidCallback onTap;

  const _ChapterPreviewRow({
    required this.chapter,
    required this.isPremiumUser,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: FolioColors.border)),
        ),
        child: Row(
          children: [
            _ChapterStatusDot(
              status: chapter.status,
              isPremiumUser: isPremiumUser,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chapter ${chapter.number} · ${chapter.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FolioTypography.body(
                      size: 14,
                      weight: chapter.status == ChapterStatus.current
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${chapter.minutes} min read',
                    style: FolioTypography.caption(size: 12),
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

class _ChapterStatusDot extends StatelessWidget {
  final ChapterStatus status;
  final bool isPremiumUser;

  const _ChapterStatusDot({
    required this.status,
    required this.isPremiumUser,
  });

  @override
  Widget build(BuildContext context) {
    if (status == ChapterStatus.premium && !isPremiumUser) {
      return const Icon(
        Icons.lock_outline_rounded,
        size: 18,
        color: FolioColors.accentText,
      );
    }
    switch (status) {
      case ChapterStatus.read:
        return Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: FolioColors.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, size: 13, color: Colors.white),
        );
      case ChapterStatus.current:
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: FolioColors.accent, width: 2.5),
          ),
          alignment: Alignment.center,
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: FolioColors.accent,
              shape: BoxShape.circle,
            ),
          ),
        );
      case ChapterStatus.unread:
      case ChapterStatus.premium:
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: FolioColors.outline, width: 1.5),
          ),
        );
    }
  }
}

class _MiniReviewCard extends StatelessWidget {
  final BookReview review;

  const _MiniReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FolioColors.surface,
        borderRadius: BorderRadius.circular(FolioRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FolioAvatar(
                initials: review.initials,
                size: 36,
                backgroundColor: review.avatarBg,
                foregroundColor: review.avatarFg,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.name,
                      style: FolioTypography.body(
                        size: 14,
                        weight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${'★' * review.stars}${'☆' * (5 - review.stars)} · ${review.date}',
                      style: FolioTypography.caption(size: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.text,
            style: FolioTypography.body(size: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}
