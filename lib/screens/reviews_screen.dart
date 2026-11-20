import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/tokens.dart';
import '../data/models.dart';
import '../state/providers.dart';
import '../widgets/widgets.dart';

class ReviewsScreen extends ConsumerWidget {
  final String bookId;

  const ReviewsScreen({super.key, required this.bookId});

  void _openWriteReviewSheet(BuildContext context, WidgetRef ref) {
    int stars = 5;
    final controller = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: FolioColors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(FolioRadius.sheet),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                FolioSpacing.pageX,
                14,
                FolioSpacing.pageX,
                24 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 16),
                  Text('Write a review', style: FolioTypography.h2()),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final idx = i + 1;
                      return IconButton(
                        tooltip: '$idx stars',
                        onPressed: () => setModalState(() => stars = idx),
                        icon: Icon(
                          idx <= stars
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 32,
                          color: idx <= stars
                              ? FolioColors.ink
                              : FolioColors.outline,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    maxLines: 4,
                    style: FolioTypography.body(size: 15),
                    decoration: const InputDecoration(
                      hintText: 'Share what stayed with you…',
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Post review',
                    onPressed: () {
                      final text = controller.text.trim();
                      if (text.isNotEmpty) {
                        ref
                            .read(reviewsProvider.notifier)
                            .addReview(stars: stars, text: text);
                        Navigator.of(sheetContext).pop();
                        showFolioToast(context, 'Review published');
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(bookByIdProvider(bookId));
    final reviews = ref.watch(reviewsProvider);

    const distribution = [
      (5, 0.74),
      (4, 0.18),
      (3, 0.05),
      (2, 0.02),
      (1, 0.01),
    ];

    return Scaffold(
      backgroundColor: FolioColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(
                14,
                10,
                FolioSpacing.pageX,
                8,
              ),
              child: Row(
                children: [
                  FolioIconButton(
                    icon: Icons.arrow_back_rounded,
                    semanticsLabel: 'Back',
                    onPressed: () =>
                        safePop(context, fallback: '/book/${book.id}'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reviews', style: FolioTypography.h2(size: 22)),
                        Text(
                          book.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: FolioTypography.caption(size: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  FolioSpacing.pageX,
                  14,
                  FolioSpacing.pageX,
                  24,
                ),
                children: [
                  // Header with average 4.7 Playfair 44 + 5-row star distribution
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: FolioColors.surface,
                      borderRadius: BorderRadius.circular(FolioRadius.cardMd),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '4.7',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 44,
                                fontWeight: FontWeight.w700,
                                height: 1.0,
                                color: FolioColors.ink,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '★★★★★',
                              style: FolioTypography.caption(
                                size: 13,
                                color: FolioColors.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${reviews.length} reviews',
                              style: FolioTypography.caption(size: 12),
                            ),
                          ],
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            children: [
                              for (final row in distribution) ...[
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 14,
                                      child: Text(
                                        '${row.$1}',
                                        style: FolioTypography.caption(size: 12),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: FolioProgressBar(
                                        value: row.$2,
                                        height: 5,
                                        activeColor: FolioColors.ink,
                                        trackColor: FolioColors.border,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Review cards
                  for (final review in reviews)
                    _ReviewCard(
                      review: review,
                      onToggleHelpful: () => ref
                          .read(reviewsProvider.notifier)
                          .toggleHelpful(review.id),
                    ),
                ],
              ),
            ),

            // Sticky bar above nav
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
                label: 'Write a review',
                onPressed: () => _openWriteReviewSheet(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final BookReview review;
  final VoidCallback onToggleHelpful;

  const _ReviewCard({
    required this.review,
    required this.onToggleHelpful,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: FolioColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FolioAvatar(
                initials: review.initials,
                size: 38,
                backgroundColor: review.avatarBg,
                foregroundColor: review.avatarFg,
              ),
              const SizedBox(width: 12),
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
          const SizedBox(height: 10),
          Semantics(
            button: true,
            label: 'Helpful ${review.helpfulCount}',
            child: InkWell(
              onTap: onToggleHelpful,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: review.markedHelpful
                      ? FolioColors.accentTint
                      : FolioColors.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: review.markedHelpful
                        ? FolioColors.accent
                        : FolioColors.border,
                  ),
                ),
                child: Text(
                  'Helpful (${review.helpfulCount})',
                  style: FolioTypography.caption(
                    size: 12,
                    weight: FontWeight.w500,
                    color: review.markedHelpful
                        ? FolioColors.accentText
                        : FolioColors.secondary,
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
