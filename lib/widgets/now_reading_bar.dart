import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/tokens.dart';
import '../state/providers.dart';
import 'book_cover.dart';

class NowReadingBar extends ConsumerWidget {
  const NowReadingBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(bookByIdProvider('salt'));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: FolioColors.plum,
        borderRadius: BorderRadius.circular(FolioRadius.cardMd),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/reader/${book.id}'),
          child: SizedBox(
            height: 64,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                  child: Row(
                    children: [
                      BookCover(
                        title: book.title,
                        author: book.author,
                        bg: book.coverBg,
                        fg: book.coverFg,
                        width: 36,
                        height: 48,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: FolioColors.plumText,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Chapter ${book.currentChapter} · ${book.minutesLeft} min left',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: FolioColors.plumText.withOpacityCompat(0.70),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Semantics(
                        button: true,
                        label: 'Resume reading ${book.title}',
                        child: GestureDetector(
                          onTap: () => context.push('/reader/${book.id}'),
                          child: Container(
                            height: 36,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: FolioColors.accent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Resume',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 2px progress line along the bottom at 64% in #8B6CE8
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 2,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: ColoredBox(
                              color: FolioColors.plumText.withOpacityCompat(0.15),
                            ),
                          ),
                          Container(
                            width: constraints.maxWidth *
                                book.progress.clamp(0.0, 1.0),
                            height: 2,
                            color: FolioColors.accent,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
