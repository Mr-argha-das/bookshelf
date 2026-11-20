import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dummy_data.dart';
import '../data/models.dart';

final userProvider = Provider<UserProfile>((ref) => kCurrentUser);

class BooksNotifier extends StateNotifier<List<Book>> {
  BooksNotifier() : super(kDummyBooks);

  Book byId(String id) {
    return state.firstWhere(
      (b) => b.id == id,
      orElse: () => state.first,
    );
  }

  void toggleSaved(String id) {
    state = [
      for (final book in state)
        if (book.id == id)
          book.copyWith(
            status: book.status == BookStatus.saved
                ? BookStatus.reading
                : BookStatus.saved,
          )
        else
          book,
    ];
  }

  void addUserBook(Book book) {
    state = [book, ...state];
  }

  void updateProgress(String id, double progress, int chapter) {
    state = [
      for (final book in state)
        if (book.id == id)
          book.copyWith(
            progress: progress.clamp(0.0, 1.0),
            currentChapter: chapter,
            status: progress >= 1.0 ? BookStatus.finished : BookStatus.reading,
          )
        else
          book,
    ];
  }
}

final booksProvider = StateNotifierProvider<BooksNotifier, List<Book>>(
  (ref) => BooksNotifier(),
);

final bookByIdProvider = Provider.family<Book, String>((ref, id) {
  final books = ref.watch(booksProvider);
  return books.firstWhere(
    (b) => b.id == id,
    orElse: () => books.first,
  );
});

final shelfTabProvider = StateProvider<ShelfTab>((ref) => ShelfTab.all);

final shelfViewProvider = StateProvider<ShelfViewMode>(
  (ref) => ShelfViewMode.shelf,
);

final selectedShelfBookIdProvider = StateProvider<String>((ref) => 'salt');

class ReaderSettingsNotifier extends StateNotifier<ReaderSettings> {
  ReaderSettingsNotifier() : super(const ReaderSettings());

  void setTheme(ReaderThemeMode theme) {
    state = state.copyWith(theme: theme);
  }

  void setFontSize(double size) {
    state = state.copyWith(fontSize: size.clamp(14.0, 24.0));
  }

  void setTypeface(ReaderTypeface typeface) {
    state = state.copyWith(typeface: typeface);
  }

  void setLineSpacing(ReaderLineSpacing spacing) {
    state = state.copyWith(lineSpacing: spacing);
  }

  void setKeepScreenOn(bool value) {
    state = state.copyWith(keepScreenOn: value);
  }
}

final readerSettingsProvider =
    StateNotifierProvider<ReaderSettingsNotifier, ReaderSettings>(
  (ref) => ReaderSettingsNotifier(),
);

final isPremiumProvider = StateProvider<bool>((ref) => false);

final selectedPlanProvider = StateProvider<PlanType>((ref) => PlanType.yearly);

class SelectedGenresNotifier extends StateNotifier<Set<String>> {
  SelectedGenresNotifier() : super(<String>{});

  void toggle(String genre) {
    final next = Set<String>.from(state);
    if (next.contains(genre)) {
      next.remove(genre);
    } else {
      next.add(genre);
    }
    state = next;
  }
}

final selectedGenresProvider =
    StateNotifierProvider<SelectedGenresNotifier, Set<String>>(
  (ref) => SelectedGenresNotifier(),
);

final homeDarkModeProvider = StateProvider<bool>((ref) => false);

class ReviewsNotifier extends StateNotifier<List<BookReview>> {
  ReviewsNotifier() : super(kDummyReviews);

  void toggleHelpful(String id) {
    state = [
      for (final r in state)
        if (r.id == id)
          r.copyWith(
            markedHelpful: !r.markedHelpful,
            helpfulCount: r.markedHelpful
                ? r.helpfulCount - 1
                : r.helpfulCount + 1,
          )
        else
          r,
    ];
  }

  void addReview({required int stars, required String text}) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final review = BookReview(
      id: 'r-${DateTime.now().millisecondsSinceEpoch}',
      name: kCurrentUser.name,
      initials: kCurrentUser.initials,
      stars: stars,
      date: 'Just now',
      text: trimmed,
      helpfulCount: 1,
      avatarBg: kCurrentUser.avatarBg,
      avatarFg: kCurrentUser.avatarFg,
      markedHelpful: true,
    );
    state = [review, ...state];
  }
}

final reviewsProvider =
    StateNotifierProvider<ReviewsNotifier, List<BookReview>>(
  (ref) => ReviewsNotifier(),
);

class ManagedChaptersNotifier extends StateNotifier<List<BookChapter>> {
  ManagedChaptersNotifier() : super(kMyBookChapters);

  void reorder(int oldIndex, int newIndex) {
    final list = List<BookChapter>.from(state);
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = [
      for (int i = 0; i < list.length; i++) list[i].copyWith(number: i + 1),
    ];
  }

  void addChapter(String title) {
    final nextNum = state.length + 1;
    state = [
      ...state,
      BookChapter(
        number: nextNum,
        title: title.isEmpty ? 'Untitled chapter $nextNum' : title,
        minutes: 5,
        status: ChapterStatus.unread,
        words: 320,
        isPublished: false,
      ),
    ];
  }
}

final managedChaptersProvider =
    StateNotifierProvider<ManagedChaptersNotifier, List<BookChapter>>(
  (ref) => ManagedChaptersNotifier(),
);

class FamilyMembersNotifier extends StateNotifier<List<FamilyMember>> {
  FamilyMembersNotifier() : super(kInitialFamilyMembers);

  void addKidProfile(String name, String age) {
    if (state.length >= 6) return;
    final cleanName = name.trim().isEmpty ? 'Meera' : name.trim();
    final initials = cleanName
        .split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0].toUpperCase())
        .join();
    state = [
      ...state,
      FamilyMember(
        id: 'fm-${DateTime.now().millisecondsSinceEpoch}',
        name: cleanName,
        initials: initials.isEmpty ? 'K' : initials,
        subtitle: 'Age $age · Under 13 shelf',
        status: FamilyMemberStatus.kids,
        avatarBg: const Color(0xFFE6DCD0),
        avatarFg: const Color(0xFF2A2623),
      ),
    ];
  }

  void inviteEmail(String email) {
    if (state.length >= 6) return;
    final clean = email.trim().isEmpty ? 'reader@example.com' : email.trim();
    final label = clean.split('@').first;
    final display = label.isEmpty
        ? 'Guest'
        : '${label[0].toUpperCase()}${label.substring(1)}';
    state = [
      ...state,
      FamilyMember(
        id: 'fm-${DateTime.now().millisecondsSinceEpoch}',
        name: display,
        initials: display[0].toUpperCase(),
        subtitle: 'Invited · waiting to join',
        status: FamilyMemberStatus.pending,
        avatarBg: const Color(0xFFC9BBF3),
        avatarFg: const Color(0xFF241C4A),
      ),
    ];
  }
}

final familyMembersProvider =
    StateNotifierProvider<FamilyMembersNotifier, List<FamilyMember>>(
  (ref) => FamilyMembersNotifier(),
);
