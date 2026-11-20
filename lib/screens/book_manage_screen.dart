import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/tokens.dart';
import '../data/dummy_data.dart';
import '../data/models.dart';
import '../state/providers.dart';
import '../widgets/widgets.dart';

class BookManageScreen extends ConsumerStatefulWidget {
  final bool isNewBook;

  const BookManageScreen({super.key, this.isNewBook = false});

  @override
  ConsumerState<BookManageScreen> createState() => _BookManageScreenState();
}

class _BookManageScreenState extends ConsumerState<BookManageScreen> {
  late final TextEditingController _newTitleController;
  late List<BookChapter> _localNewChapters;
  bool _published = false;

  @override
  void initState() {
    super.initState();
    _newTitleController = TextEditingController(
      text: widget.isNewBook ? 'Untitled book' : 'Notes from the Orchard',
    );
    _localNewChapters = [];
    _published = !widget.isNewBook;
  }

  @override
  void dispose() {
    _newTitleController.dispose();
    super.dispose();
  }

  void _addChapter() {
    if (widget.isNewBook) {
      setState(() {
        final next = _localNewChapters.length + 1;
        _localNewChapters.add(
          BookChapter(
            number: next,
            title: 'Chapter $next draft',
            minutes: 6,
            status: ChapterStatus.unread,
            words: 420,
            isPublished: false,
          ),
        );
      });
    } else {
      ref.read(managedChaptersProvider.notifier).addChapter('');
    }
    showFolioToast(context, 'New draft chapter added');
  }

  @override
  Widget build(BuildContext context) {
    final chapters = widget.isNewBook
        ? _localNewChapters
        : ref.watch(managedChaptersProvider);
    final bookTitle = widget.isNewBook
        ? (_newTitleController.text.trim().isEmpty
            ? 'Untitled book'
            : _newTitleController.text.trim())
        : 'Notes from the Orchard';

    return Scaffold(
      backgroundColor: FolioColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, FolioSpacing.pageX, 8),
              child: Row(
                children: [
                  FolioIconButton(
                    icon: Icons.arrow_back_rounded,
                    semanticsLabel: 'Back',
                    onPressed: () => safePop(context, fallback: '/account'),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.isNewBook ? 'New book' : 'Manage book',
                      style: FolioTypography.h2(size: 20),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _published
                          ? FolioColors.accentTint
                          : FolioColors.surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: _published
                            ? FolioColors.accent
                            : FolioColors.outline,
                      ),
                    ),
                    child: Text(
                      _published ? 'Published' : 'Draft',
                      style: FolioTypography.caption(
                        size: 12,
                        weight: FontWeight.w600,
                        color: _published
                            ? FolioColors.accentText
                            : FolioColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Header with cover, title, stats
            Padding(
              padding: const EdgeInsets.fromLTRB(
                FolioSpacing.pageX,
                10,
                FolioSpacing.pageX,
                16,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: FolioColors.surface,
                  borderRadius: BorderRadius.circular(FolioRadius.cardMd),
                ),
                child: Row(
                  children: [
                    BookCover(
                      title: bookTitle,
                      author: kCurrentUser.name,
                      bg: widget.isNewBook
                          ? FolioColors.coverCream
                          : FolioColors.coverLilac,
                      fg: widget.isNewBook
                          ? FolioColors.coverInkWarm
                          : FolioColors.coverInkViolet,
                      width: 64,
                      height: 94,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.isNewBook)
                            TextField(
                              controller: _newTitleController,
                              onChanged: (_) => setState(() {}),
                              style: FolioTypography.cardTitle(size: 20),
                              decoration: const InputDecoration(
                                hintText: 'Book title',
                                filled: false,
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            )
                          else
                            Text(
                              bookTitle,
                              style: FolioTypography.cardTitle(size: 20),
                            ),
                          const SizedBox(height: 6),
                          Text(
                            widget.isNewBook
                                ? '${chapters.length} chapters · 0 reads'
                                : '${chapters.length} chapters · 3.2k reads',
                            style: FolioTypography.caption(size: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: FolioSpacing.pageX,
              ),
              child: Row(
                children: [
                  Text('CHAPTERS', style: FolioTypography.label()),
                  const Spacer(),
                  Text(
                    'Drag to reorder',
                    style: FolioTypography.caption(size: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ReorderableListView
            Expanded(
              child: chapters.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(FolioSpacing.pageX),
                      child: FolioEmptyShelf(
                        title: 'No chapters yet',
                        subtitle:
                            'Start your book with Chapter 1. You can reorder chapters anytime.',
                        actionLabel: 'Add chapter',
                        onAction: _addChapter,
                      ),
                    )
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: FolioSpacing.pageX,
                      ),
                      buildDefaultDragHandles: false,
                      itemCount: chapters.length,
                      onReorder: (oldIndex, newIndex) {
                        if (widget.isNewBook) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex -= 1;
                            final item = _localNewChapters.removeAt(oldIndex);
                            _localNewChapters.insert(newIndex, item);
                            _localNewChapters = [
                              for (int i = 0; i < _localNewChapters.length; i++)
                                _localNewChapters[i].copyWith(number: i + 1),
                            ];
                          });
                        } else {
                          ref
                              .read(managedChaptersProvider.notifier)
                              .reorder(oldIndex, newIndex);
                        }
                      },
                      itemBuilder: (context, index) {
                        final ch = chapters[index];
                        return Container(
                          key: ValueKey('${ch.number}-${ch.title}-$index'),
                          decoration: const BoxDecoration(
                            color: FolioColors.bg,
                            border: Border(
                              bottom: BorderSide(color: FolioColors.border),
                            ),
                          ),
                          child: InkWell(
                            onTap: () => context.push('/editor/short'),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 62),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  children: [
                                    ReorderableDragStartListener(
                                      index: index,
                                      child: const SizedBox(
                                        width: 36,
                                        height: 44,
                                        child: Icon(
                                          Icons.drag_indicator_rounded,
                                          size: 20,
                                          color: FolioColors.mutedIcon,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${ch.number}. ${ch.title}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: FolioTypography.body(
                                              size: 15,
                                              weight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${ch.words} words',
                                            style: FolioTypography.caption(
                                              size: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: ch.isPublished
                                            ? FolioColors.surface
                                            : FolioColors.accentTint,
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        ch.isPublished ? 'Published' : 'Draft',
                                        style: FolioTypography.caption(
                                          size: 11,
                                          weight: FontWeight.w600,
                                          color: ch.isPublished
                                              ? FolioColors.success
                                              : FolioColors.accentText,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Bottom action buttons: Add chapter (primary) + Publish book (secondary)
            Container(
              padding: const EdgeInsets.fromLTRB(
                FolioSpacing.pageX,
                12,
                FolioSpacing.pageX,
                16,
              ),
              decoration: const BoxDecoration(
                color: FolioColors.bg,
                border: Border(top: BorderSide(color: FolioColors.border)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PrimaryButton(
                    label: 'Add chapter',
                    onPressed: _addChapter,
                  ),
                  const SizedBox(height: 10),
                  SecondaryButton(
                    label: _published ? 'Update published book' : 'Publish book',
                    height: 50,
                    radius: FolioRadius.button,
                    onPressed: () {
                      setState(() => _published = true);
                      showFolioToast(context, '"$bookTitle" is now published');
                    },
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
