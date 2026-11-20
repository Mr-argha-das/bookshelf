import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/tokens.dart';
import '../data/dummy_data.dart';
import '../data/models.dart';
import '../state/providers.dart';
import '../widgets/widgets.dart';

class ShortBookEditorScreen extends ConsumerStatefulWidget {
  const ShortBookEditorScreen({super.key});

  @override
  ConsumerState<ShortBookEditorScreen> createState() =>
      _ShortBookEditorScreenState();
}

class _ShortBookEditorScreenState extends ConsumerState<ShortBookEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  final List<String> _undoStack = [];
  Color _selectedCover = kEditorCoverDots.first;
  String _selectedGenre = 'Short stories';
  String _saveStatus = 'Draft saved';
  bool _previewMode = false;

  static const _editorGenres = [
    'Short stories',
    'Fiction',
    'Poetry',
    'Philosophy',
    'Romance',
    'Non-fiction',
  ];

  static const _initialDraft =
      'Across the courtyard, seventeen rectangular windows catch the last slant of October light before the streetlamps flicker on. From the third-floor landing I have learned the quiet timetable of each room without ever knowing the names on the letterboxes below.\n\n'
      'At six o’clock, the corner kitchen fills with steam and the brief clatter of a steel lid. Two floors down, someone waters a row of terracotta pots along the sill, pausing whenever a pigeon settles on the railing. By seven, a yellow reading lamp opens like a match struck in the corner flat, illuminating the curved spine of a cello resting against a bookcase.\n\n'
      'We imagine city buildings as walls built to divide strangers, yet dusk softens every boundary. A curtain lifts in the breeze; the scent of cardamom drifts upward; a radio lowers its volume when the rain begins. For ten minutes every evening, the whole block shares the same unhurried silence, each lit square holding a private chapter of a book nobody planned to write together.';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: 'Seventeen Windows');
    _bodyController = TextEditingController(text: _initialDraft);
    _undoStack.add(_initialDraft);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  int get _wordCount {
    final text = _bodyController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  int get _readMinutes => (_wordCount / 200).ceil().clamp(1, 60);

  void _onChanged() {
    setState(() {
      _saveStatus = 'Draft saved';
      if (_undoStack.isEmpty || _undoStack.last != _bodyController.text) {
        _undoStack.add(_bodyController.text);
        if (_undoStack.length > 20) _undoStack.removeAt(0);
      }
    });
  }

  void _insertMarkdown(String snippet) {
    final text = _bodyController.text;
    final selection = _bodyController.selection;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    final updated = text.replaceRange(start, end, snippet);
    _bodyController.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: start + snippet.length),
    );
    _onChanged();
  }

  void _undo() {
    if (_undoStack.length > 1) {
      _undoStack.removeLast();
      _bodyController.text = _undoStack.last;
      _bodyController.selection = TextSelection.collapsed(
        offset: _bodyController.text.length,
      );
      setState(() {});
    }
  }

  void _publish() {
    final title = _titleController.text.trim().isEmpty
        ? 'Untitled short book'
        : _titleController.text.trim();
    final newBook = Book(
      id: 'draft-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      author: kCurrentUser.name,
      genre: _selectedGenre,
      rating: 5.0,
      reads: '1',
      chapters: 1,
      currentChapter: 1,
      minutesLeft: _readMinutes,
      progress: 1.0,
      status: BookStatus.mine,
      blurb: _bodyController.text.trim(),
      coverBg: _selectedCover,
      coverFg: foregroundForCover(_selectedCover),
      isShortBook: true,
      spineWidth: 32,
      spineHeight: 158,
    );
    ref.read(booksProvider.notifier).addUserBook(newBook);
    showFolioToast(context, 'Published "$title" to My writing');
    context.go('/library');
  }

  @override
  Widget build(BuildContext context) {
    final titlePreview = _titleController.text.trim().isEmpty
        ? 'Untitled'
        : _titleController.text.trim();

    return Scaffold(
      backgroundColor: FolioColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar: close, "Draft saved", "Preview", primary compact "Publish"
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 16, 10),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: FolioColors.border)),
              ),
              child: Row(
                children: [
                  FolioIconButton(
                    icon: Icons.close_rounded,
                    semanticsLabel: 'Close editor',
                    onPressed: () => safePop(context, fallback: '/library'),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _saveStatus,
                      style: FolioTypography.caption(size: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        setState(() => _previewMode = !_previewMode),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(44, 44),
                      foregroundColor: FolioColors.ink,
                    ),
                    child: Text(
                      _previewMode ? 'Edit' : 'Preview',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: FolioColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  PrimaryButton(
                    label: 'Publish',
                    height: 44,
                    radius: 12,
                    fontSize: 13,
                    fullWidth: false,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onPressed: _publish,
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  FolioSpacing.pageX,
                  20,
                  FolioSpacing.pageX,
                  32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cover colour picker (6 dots) + live mini BookCover
                    Row(
                      children: [
                        BookCover(
                          title: titlePreview,
                          author: kCurrentUser.name,
                          bg: _selectedCover,
                          fg: foregroundForCover(_selectedCover),
                          width: 58,
                          height: 86,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('COVER COLOUR', style: FolioTypography.label()),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  for (final color in kEditorCoverDots)
                                    Semantics(
                                      button: true,
                                      label: 'Select cover colour',
                                      child: GestureDetector(
                                        onTap: () => setState(
                                          () => _selectedCover = color,
                                        ),
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: _selectedCover == color
                                                  ? FolioColors.accent
                                                  : FolioColors.outline,
                                              width: _selectedCover == color
                                                  ? 2
                                                  : 1,
                                            ),
                                          ),
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: color,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Title field (Playfair 28, hint "Title")
                    if (_previewMode)
                      Text(
                        titlePreview,
                        style: FolioTypography.h1(size: 28),
                      )
                    else
                      TextField(
                        controller: _titleController,
                        onChanged: (_) => _onChanged(),
                        style: FolioTypography.h1(size: 28),
                        decoration: InputDecoration(
                          hintText: 'Title',
                          hintStyle: FolioTypography.h1(
                            size: 28,
                            color: FolioColors.outline,
                          ),
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    const SizedBox(height: 14),

                    // Genre chip row
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _editorGenres.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final g = _editorGenres[index];
                          return FolioChip(
                            label: g,
                            selected: _selectedGenre == g,
                            onTap: () => setState(() => _selectedGenre = g),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Large multiline body field (Source Serif 4 18)
                    if (_previewMode)
                      Text(
                        _bodyController.text,
                        style: FolioTypography.reading(size: 18),
                      )
                    else
                      TextField(
                        controller: _bodyController,
                        onChanged: (_) => _onChanged(),
                        maxLines: null,
                        minLines: 14,
                        keyboardType: TextInputType.multiline,
                        style: FolioTypography.reading(size: 18),
                        decoration: InputDecoration(
                          hintText: 'Begin writing slowly…',
                          hintStyle: FolioTypography.reading(
                            size: 18,
                            color: FolioColors.mutedIcon,
                          ),
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Bottom formatting toolbar + word count
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: const BoxDecoration(
                color: FolioColors.surface,
                border: Border(top: BorderSide(color: FolioColors.border)),
              ),
              child: Row(
                children: [
                  _ToolBtn(
                    label: 'B',
                    bold: true,
                    semantics: 'Bold',
                    onTap: () => _insertMarkdown('**bold** '),
                  ),
                  _ToolBtn(
                    label: 'I',
                    italic: true,
                    semantics: 'Italic',
                    onTap: () => _insertMarkdown('*italic* '),
                  ),
                  _ToolIconBtn(
                    icon: Icons.format_quote_rounded,
                    semantics: 'Quote',
                    onTap: () => _insertMarkdown('\n“'),
                  ),
                  _ToolBtn(
                    label: 'H',
                    bold: true,
                    semantics: 'Heading',
                    onTap: () => _insertMarkdown('\n## '),
                  ),
                  _ToolIconBtn(
                    icon: Icons.undo_rounded,
                    semantics: 'Undo',
                    onTap: _undo,
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      '$_wordCount words · $_readMinutes min read',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FolioTypography.caption(size: 12),
                    ),
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

class _ToolBtn extends StatelessWidget {
  final String label;
  final bool bold;
  final bool italic;
  final String semantics;
  final VoidCallback onTap;

  const _ToolBtn({
    required this.label,
    required this.semantics,
    required this.onTap,
    this.bold = false,
    this.italic = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semantics,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 40,
          height: 44,
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                fontStyle: italic ? FontStyle.italic : FontStyle.normal,
                color: FolioColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolIconBtn extends StatelessWidget {
  final IconData icon;
  final String semantics;
  final VoidCallback onTap;

  const _ToolIconBtn({
    required this.icon,
    required this.semantics,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semantics,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 40,
          height: 44,
          child: Icon(icon, size: 19, color: FolioColors.ink),
        ),
      ),
    );
  }
}
