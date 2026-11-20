import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/tokens.dart';
import '../data/dummy_data.dart';
import '../data/models.dart';
import '../state/providers.dart';
import '../widgets/widgets.dart';

class ChapterListScreen extends ConsumerWidget {
  final String bookId;

  const ChapterListScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(bookByIdProvider(bookId));
    final isPremium = ref.watch(isPremiumProvider);
    final chapters = chaptersForBook(book);

    return Scaffold(
      backgroundColor: FolioColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header with cover chip + title
            Container(
              padding: const EdgeInsets.fromLTRB(
                14,
                10,
                FolioSpacing.pageX,
                14,
              ),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: FolioColors.border)),
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
                  BookCover(
                    title: book.title,
                    author: book.author,
                    bg: book.coverBg,
                    fg: book.coverFg,
                    width: 34,
                    height: 48,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: FolioTypography.cardTitle(size: 18),
                        ),
                        Text(
                          '${chapters.length} chapters',
                          style: FolioTypography.caption(size: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: chapters.length,
                itemBuilder: (context, index) {
                  final ch = chapters[index];
                  final isCurrent = ch.status == ChapterStatus.current;
                  final isLocked =
                      ch.status == ChapterStatus.premium && !isPremium;

                  return Material(
                    color: isCurrent
                        ? FolioColors.selectedCardBg
                        : FolioColors.bg,
                    child: InkWell(
                      onTap: () {
                        if (isLocked) {
                          context.push('/premium');
                        } else {
                          context.push('/reader/${book.id}');
                        }
                      },
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 64),
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: isCurrent
                                  ? FolioColors.accent
                                  : Colors.transparent,
                              width: 3,
                            ),
                            bottom: const BorderSide(
                              color: FolioColors.border,
                              width: 1,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 21,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 30,
                              child: Text(
                                '${ch.number}'.padLeft(2, '0'),
                                style: FolioTypography.caption(
                                  size: 13,
                                  weight: FontWeight.w600,
                                  color: isCurrent
                                      ? FolioColors.accentText
                                      : FolioColors.secondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ch.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: FolioTypography.body(
                                      size: 15,
                                      weight: isCurrent
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: isLocked
                                          ? FolioColors.secondary
                                          : FolioColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isLocked
                                        ? '${ch.minutes} min · Premium early access'
                                        : isCurrent
                                            ? '${ch.minutes} min · Reading now'
                                            : '${ch.minutes} min read',
                                    style: FolioTypography.caption(
                                      size: 12,
                                      color: isCurrent
                                          ? FolioColors.accentText
                                          : FolioColors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildStatusIcon(ch.status, isPremium),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(ChapterStatus status, bool isPremium) {
    if (status == ChapterStatus.premium && !isPremium) {
      return Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(
          color: FolioColors.accentTint,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.lock_outline_rounded,
          size: 16,
          color: FolioColors.accentText,
        ),
      );
    }
    switch (status) {
      case ChapterStatus.read:
        return Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: FolioColors.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
        );
      case ChapterStatus.current:
        return Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: FolioColors.accent, width: 2.5),
          ),
          alignment: Alignment.center,
          child: Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: FolioColors.accent,
              shape: BoxShape.circle,
            ),
          ),
        );
      case ChapterStatus.unread:
      case ChapterStatus.premium:
        return Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: FolioColors.outline, width: 1.5),
          ),
        );
    }
  }
}
