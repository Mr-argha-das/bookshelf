import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/tokens.dart';
import '../data/models.dart';
import '../state/providers.dart';
import '../widgets/widgets.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Book> _filterByQuery(List<Book> books) {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return books;
    return books
        .where(
          (b) =>
              b.title.toLowerCase().contains(q) ||
              b.author.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final allBooks = _filterByQuery(ref.watch(booksProvider));
    final tab = ref.watch(shelfTabProvider);
    final view = ref.watch(shelfViewProvider);
    final selectedId = ref.watch(selectedShelfBookIdProvider);
    final selectedBook = ref.watch(bookByIdProvider(selectedId));

    final reading =
        allBooks.where((b) => b.status == BookStatus.reading).toList();
    final saved = allBooks.where((b) => b.status == BookStatus.saved).toList();
    final finished =
        allBooks.where((b) => b.status == BookStatus.finished).toList();
    final mine = allBooks.where((b) => b.status == BookStatus.mine).toList();

    List<Book> visibleForGrid() {
      switch (tab) {
        case ShelfTab.all:
          return allBooks;
        case ShelfTab.reading:
          return reading;
        case ShelfTab.saved:
          return saved;
        case ShelfTab.finished:
          return finished;
        case ShelfTab.mine:
          return mine;
      }
    }

    final gridBooks = visibleForGrid();

    return Scaffold(
      backgroundColor: FolioColors.bg,
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
                    124,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Header: "My shelf" + shelf / grid toggle
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'My shelf',
                              style: FolioTypography.h1(size: 28),
                            ),
                          ),
                          _ViewToggleButton(
                            icon: Icons.view_week_outlined,
                            label: 'Shelf view',
                            active: view == ShelfViewMode.shelf,
                            onTap: () => ref
                                .read(shelfViewProvider.notifier)
                                .state = ShelfViewMode.shelf,
                          ),
                          const SizedBox(width: 6),
                          _ViewToggleButton(
                            icon: Icons.grid_view_outlined,
                            label: 'Grid view',
                            active: view == ShelfViewMode.grid,
                            onTap: () => ref
                                .read(shelfViewProvider.notifier)
                                .state = ShelfViewMode.grid,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Search field
                      SizedBox(
                        height: 48,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          style: FolioTypography.body(size: 15),
                          decoration: InputDecoration(
                            hintText: 'Filter your shelf',
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              size: 20,
                              color: FolioColors.mutedIcon,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    tooltip: 'Clear filter',
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                      color: FolioColors.mutedIcon,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Tab chips: All, Reading, Saved, Finished, My writing
                      SizedBox(
                        height: 44,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _tabChip(ref, ShelfTab.all, 'All', tab),
                            const SizedBox(width: 8),
                            _tabChip(ref, ShelfTab.reading, 'Reading', tab),
                            const SizedBox(width: 8),
                            _tabChip(ref, ShelfTab.saved, 'Saved', tab),
                            const SizedBox(width: 8),
                            _tabChip(ref, ShelfTab.finished, 'Finished', tab),
                            const SizedBox(width: 8),
                            _tabChip(ref, ShelfTab.mine, 'My writing', tab),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (gridBooks.isEmpty)
                        FolioEmptyShelf(
                          onAction: () => context.go('/explore'),
                        )
                      else if (view == ShelfViewMode.grid)
                        _ShelfGridView(
                          books: gridBooks,
                          selectedId: selectedId,
                          onSelect: (id) => ref
                              .read(selectedShelfBookIdProvider.notifier)
                              .state = id,
                        )
                      else ...[
                        if (tab == ShelfTab.all || tab == ShelfTab.reading) ...[
                          _ShelfGroupPanel(
                            label: 'Reading now',
                            books: reading,
                            showFrontCovers: true,
                            selectedId: selectedId,
                            onSelectBook: (id) => ref
                                .read(selectedShelfBookIdProvider.notifier)
                                .state = id,
                            onTapAdd: () => context.go('/explore'),
                            addLabel: 'Explore books',
                          ),
                          const SizedBox(height: 24),
                        ],
                        if (tab == ShelfTab.all || tab == ShelfTab.saved) ...[
                          _ShelfGroupPanel(
                            label: 'Saved',
                            books: saved,
                            showFrontCovers: false,
                            selectedId: selectedId,
                            onSelectBook: (id) => ref
                                .read(selectedShelfBookIdProvider.notifier)
                                .state = id,
                            onTapAdd: () => context.go('/explore'),
                            addLabel: 'Explore books',
                          ),
                          const SizedBox(height: 24),
                        ],
                        if (tab == ShelfTab.all ||
                            tab == ShelfTab.finished) ...[
                          _ShelfGroupPanel(
                            label: 'Finished',
                            books: finished,
                            showFrontCovers: false,
                            selectedId: selectedId,
                            onSelectBook: (id) => ref
                                .read(selectedShelfBookIdProvider.notifier)
                                .state = id,
                            onTapAdd: () => context.go('/explore'),
                            addLabel: 'Explore books',
                          ),
                          const SizedBox(height: 24),
                        ],
                        if (tab == ShelfTab.all || tab == ShelfTab.mine) ...[
                          _ShelfGroupPanel(
                            label: 'My writing',
                            books: mine,
                            showFrontCovers: false,
                            selectedId: selectedId,
                            onSelectBook: (id) => ref
                                .read(selectedShelfBookIdProvider.notifier)
                                .state = id,
                            onTapAdd: () => context.push('/write'),
                            addLabel: 'Write a book',
                          ),
                        ],
                      ],
                    ]),
                  ),
                ),
              ],
            ),

            // Pinned Peek card above the nav
            Positioned(
              left: 16,
              right: 16,
              bottom: 12,
              child: _ShelfPeekCard(
                book: selectedBook,
                onRead: () => context.push('/reader/${selectedBook.id}'),
                onDetails: () => context.push('/book/${selectedBook.id}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabChip(
    WidgetRef ref,
    ShelfTab value,
    String label,
    ShelfTab current,
  ) {
    return FolioChip(
      label: label,
      selected: current == value,
      onTap: () => ref.read(shelfTabProvider.notifier).state = value,
    );
  }
}

class _ViewToggleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ViewToggleButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      label: label,
      child: Material(
        color: active ? FolioColors.ink : FolioColors.surface,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              size: 20,
              color: active ? Colors.white : FolioColors.secondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ShelfGroupPanel extends StatelessWidget {
  final String label;
  final List<Book> books;
  final bool showFrontCovers;
  final String selectedId;
  final ValueChanged<String> onSelectBook;
  final VoidCallback onTapAdd;
  final String addLabel;

  const _ShelfGroupPanel({
    required this.label,
    required this.books,
    required this.showFrontCovers,
    required this.selectedId,
    required this.onSelectBook,
    required this.onTapAdd,
    required this.addLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label.toUpperCase(), style: FolioTypography.label()),
            const Spacer(),
            Text(
              '${books.length} ${books.length == 1 ? 'book' : 'books'}',
              style: FolioTypography.caption(size: 12),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: FolioColors.surface,
            borderRadius: BorderRadius.circular(FolioRadius.card),
          ),
          padding: const EdgeInsets.fromLTRB(14, 24, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final book in books) ...[
                      _ShelfBookItem(
                        book: book,
                        showFrontCover: showFrontCovers,
                        selected: book.id == selectedId,
                        onTap: () => onSelectBook(book.id),
                      ),
                      SizedBox(width: showFrontCovers ? 14 : 8),
                    ],
                    _ShelfAddSlot(
                      height: showFrontCovers ? 136 : 156,
                      width: showFrontCovers ? 80 : 38,
                      label: addLabel,
                      onTap: onTapAdd,
                    ),
                  ],
                ),
              ),
              // Wooden-neutral plank (height 10, #DEDBD3, subtle top highlight)
              Container(
                width: double.infinity,
                height: 10,
                decoration: BoxDecoration(
                  color: FolioColors.plank,
                  borderRadius: BorderRadius.circular(4),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacityCompat(0.55),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShelfBookItem extends StatelessWidget {
  final Book book;
  final bool showFrontCover;
  final bool selected;
  final VoidCallback onTap;

  const _ShelfBookItem({
    required this.book,
    required this.showFrontCover,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '${book.title} by ${book.author}',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, selected ? -14 : 0, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(FolioRadius.cover),
            boxShadow: selected ? FolioShadows.soft : null,
          ),
          child: showFrontCover
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        BookCover(
                          title: book.title,
                          author: book.author,
                          bg: book.coverBg,
                          fg: book.coverFg,
                          width: 92,
                          height: 136,
                        ),
                        // Small purple bookmark ribbon top right
                        Positioned(
                          top: 0,
                          right: 8,
                          child: Container(
                            width: 10,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: FolioColors.accent,
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 92,
                      child: FolioProgressBar(
                        value: book.progress,
                        height: 3,
                        trackColor: FolioColors.outline.withOpacityCompat(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                )
              : BookCover.spine(
                  title: book.title,
                  author: book.author,
                  bg: book.coverBg,
                  fg: book.coverFg,
                  width: book.spineWidth,
                  height: book.spineHeight,
                ),
        ),
      ),
    );
  }
}

class _ShelfAddSlot extends StatelessWidget {
  final double width;
  final double height;
  final String label;
  final VoidCallback onTap;

  const _ShelfAddSlot({
    required this.width,
    required this.height,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          height: height,
          margin: const EdgeInsets.only(bottom: 2),
          decoration: BoxDecoration(
            color: FolioColors.bg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: FolioColors.outline,
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.add_rounded,
            size: 20,
            color: FolioColors.mutedIcon,
          ),
        ),
      ),
    );
  }
}

class _ShelfGridView extends StatelessWidget {
  final List<Book> books;
  final String selectedId;
  final ValueChanged<String> onSelect;

  const _ShelfGridView({
    required this.books,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 14.0;
        final itemW = (constraints.maxWidth - gap * 2) / 3;
        final coverH = itemW * 1.46;

        return Wrap(
          spacing: gap,
          runSpacing: 20,
          children: [
            for (final book in books)
              GestureDetector(
                onTap: () => onSelect(book.id),
                child: SizedBox(
                  width: itemW,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: book.id == selectedId
                              ? Border.all(color: FolioColors.accent, width: 2)
                              : null,
                        ),
                        child: BookCover(
                          title: book.title,
                          author: book.author,
                          bg: book.coverBg,
                          fg: book.coverFg,
                          width: itemW,
                          height: coverH,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        book.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FolioTypography.body(
                          size: 13,
                          weight: FontWeight.w600,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        book.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FolioTypography.caption(size: 11),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ShelfPeekCard extends StatelessWidget {
  final Book book;
  final VoidCallback onRead;
  final VoidCallback onDetails;

  const _ShelfPeekCard({
    required this.book,
    required this.onRead,
    required this.onDetails,
  });

  String _statusLine() {
    switch (book.status) {
      case BookStatus.reading:
        return '${(book.progress * 100).round()}% · ${book.minutesLeft} min left';
      case BookStatus.saved:
        return 'Saved · ${book.chapters} chapters';
      case BookStatus.finished:
        return 'Finished · ★ ${book.rating}';
      case BookStatus.mine:
        return book.isShortBook
            ? 'My writing · Short book'
            : 'My writing · ${book.chapters} chapters';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FolioColors.surface,
        borderRadius: BorderRadius.circular(FolioRadius.cardLg),
        border: Border.all(color: FolioColors.border),
        boxShadow: FolioShadows.soft,
      ),
      child: Row(
        children: [
          BookCover(
            title: book.title,
            author: book.author,
            bg: book.coverBg,
            fg: book.coverFg,
            width: 42,
            height: 60,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FolioTypography.cardTitle(size: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  book.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FolioTypography.caption(size: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  _statusLine(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FolioTypography.caption(
                    size: 11,
                    color: FolioColors.accentText,
                    weight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SecondaryButton(
            label: 'Details',
            height: 44,
            radius: 12,
            fullWidth: false,
            fontSize: 13,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            onPressed: onDetails,
          ),
          const SizedBox(width: 8),
          PrimaryButton(
            label: 'Read',
            height: 44,
            radius: 12,
            fullWidth: false,
            fontSize: 13,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            onPressed: onRead,
          ),
        ],
      ),
    );
  }
}
