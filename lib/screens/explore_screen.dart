import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/tokens.dart';
import '../data/dummy_data.dart';
import '../data/models.dart';
import '../state/providers.dart';
import '../widgets/widgets.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  String _selectedGenre = 'All';

  @override
  Widget build(BuildContext context) {
    final allBooks = ref.watch(booksProvider);
    final genres = ['All', ...kGenres];
    final filtered = _selectedGenre == 'All'
        ? allBooks
        : allBooks.where((b) => b.genre == _selectedGenre).toList();
    final popular = filtered.isEmpty ? allBooks.take(6).toList() : filtered;
    final rising = allBooks.reversed.take(6).toList();
    final shortReads =
        allBooks.where((b) => b.minutesLeft > 0 && b.minutesLeft <= 20).toList();

    return Scaffold(
      backgroundColor: FolioColors.bg,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                FolioSpacing.pageX,
                16,
                FolioSpacing.pageX,
                104,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Explore', style: FolioTypography.h1(size: 28)),
                  const SizedBox(height: 16),
                  // Search field
                  Semantics(
                    button: true,
                    label: 'Search books, authors, genres',
                    child: InkWell(
                      onTap: () => context.push('/search'),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: FolioColors.surface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              size: 20,
                              color: FolioColors.mutedIcon,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Search books, authors, genres',
                              style: FolioTypography.body(
                                size: 15,
                                color: FolioColors.mutedIcon,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Horizontal genre chips (first selected = ink fill)
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: genres.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final genre = genres[index];
                        return FolioChip(
                          label: genre,
                          selected: genre == _selectedGenre,
                          onTap: () => setState(() => _selectedGenre = genre),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: FolioSpacing.sectionGap),

                  // Popular this week
                  SectionHeader(
                    title: 'Popular this week',
                    actionLabel: 'Search',
                    onAction: () => context.push('/search'),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 230,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: popular.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final book = popular[index];
                        return _ExploreBookTile(
                          book: book,
                          onTap: () => context.push('/book/${book.id}'),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: FolioSpacing.sectionGap),

                  // New and rising
                  const SectionHeader(title: 'New and rising'),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 230,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: rising.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final book = rising[index];
                        return _ExploreBookTile(
                          book: book,
                          onTap: () => context.push('/book/${book.id}'),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: FolioSpacing.sectionGap),

                  // Short reads under 20 min
                  const SectionHeader(title: 'Short reads under 20 min'),
                  const SizedBox(height: 10),
                  for (final book in shortReads)
                    _ShortReadRow(
                      book: book,
                      onTap: () => context.push('/book/${book.id}'),
                    ),
                  const SizedBox(height: FolioSpacing.sectionGap),

                  // 2 Genre grids (2 x 2 covers with genre name)
                  const SectionHeader(title: 'Browse by mood'),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _GenreMosaicCard(
                          genre: 'Fiction',
                          books: allBooks.take(4).toList(),
                          onTap: () => setState(() => _selectedGenre = 'Fiction'),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _GenreMosaicCard(
                          genre: 'Mystery',
                          books: allBooks.skip(4).take(4).toList(),
                          onTap: () => setState(() => _selectedGenre = 'Mystery'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: NowReadingBar(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExploreBookTile extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const _ExploreBookTile({required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                height: 1.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              book.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FolioTypography.caption(size: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShortReadRow extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const _ShortReadRow({required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 82),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: FolioColors.border)),
        ),
        child: Row(
          children: [
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
                    style: FolioTypography.cardTitle(size: 16),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${book.author} · ${book.minutesLeft} min read',
                    style: FolioTypography.caption(size: 13),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '★ ${book.rating} · ${book.genre}',
                    style: FolioTypography.caption(size: 12),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: FolioColors.mutedIcon,
            ),
          ],
        ),
      ),
    );
  }
}

class _GenreMosaicCard extends StatelessWidget {
  final String genre;
  final List<Book> books;
  final VoidCallback onTap;

  const _GenreMosaicCard({
    required this.genre,
    required this.books,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FolioColors.surface,
      borderRadius: BorderRadius.circular(FolioRadius.card),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final coverW = (constraints.maxWidth - 8) / 2;
                  final coverH = coverW * 1.35;
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final book in books.take(4))
                        BookCover(
                          title: book.title,
                          author: book.author,
                          bg: book.coverBg,
                          fg: book.coverFg,
                          width: coverW,
                          height: coverH,
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              Text(genre, style: FolioTypography.cardTitle(size: 17)),
              const SizedBox(height: 2),
              Text(
                '${books.length * 14} books',
                style: FolioTypography.caption(size: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
