import 'package:flutter/material.dart';

enum BookStatus { reading, saved, finished, mine }

enum ChapterStatus { read, current, unread, premium }

enum ShelfTab { all, reading, saved, finished, mine }

enum ShelfViewMode { shelf, grid }

enum ReaderThemeMode { paper, sepia, night }

enum ReaderTypeface { serif, sans }

enum ReaderLineSpacing { tight, normal, relaxed }

enum PlanType { yearly, family, monthly }

enum FamilyMemberStatus { organizer, member, pending, kids }

class UserProfile {
  final String name;
  final String handle;
  final String initials;
  final Color avatarBg;
  final Color avatarFg;
  final int streakDays;
  final int dailyGoalMinutes;
  final int minutesReadToday;

  const UserProfile({
    required this.name,
    required this.handle,
    required this.initials,
    required this.avatarBg,
    required this.avatarFg,
    required this.streakDays,
    required this.dailyGoalMinutes,
    required this.minutesReadToday,
  });

  double get dailyProgress =>
      (minutesReadToday / dailyGoalMinutes).clamp(0.0, 1.0);
}

class Book {
  final String id;
  final String title;
  final String author;
  final String genre;
  final double rating;
  final String reads;
  final int chapters;
  final int currentChapter;
  final int minutesLeft;
  final double progress;
  final BookStatus status;
  final String blurb;
  final Color coverBg;
  final Color coverFg;
  final bool hasPremiumChapters;
  final bool isShortBook;
  final bool isTrending;
  final bool isNewChapterToday;
  final double spineWidth;
  final double spineHeight;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.rating,
    required this.reads,
    required this.chapters,
    required this.currentChapter,
    required this.minutesLeft,
    required this.progress,
    required this.status,
    required this.blurb,
    required this.coverBg,
    required this.coverFg,
    this.hasPremiumChapters = false,
    this.isShortBook = false,
    this.isTrending = false,
    this.isNewChapterToday = false,
    this.spineWidth = 36,
    this.spineHeight = 168,
  });

  Book copyWith({
    String? title,
    String? author,
    String? genre,
    double? rating,
    String? reads,
    int? chapters,
    int? currentChapter,
    int? minutesLeft,
    double? progress,
    BookStatus? status,
    String? blurb,
    Color? coverBg,
    Color? coverFg,
    bool? hasPremiumChapters,
    bool? isShortBook,
  }) {
    return Book(
      id: id,
      title: title ?? this.title,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      rating: rating ?? this.rating,
      reads: reads ?? this.reads,
      chapters: chapters ?? this.chapters,
      currentChapter: currentChapter ?? this.currentChapter,
      minutesLeft: minutesLeft ?? this.minutesLeft,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      blurb: blurb ?? this.blurb,
      coverBg: coverBg ?? this.coverBg,
      coverFg: coverFg ?? this.coverFg,
      hasPremiumChapters: hasPremiumChapters ?? this.hasPremiumChapters,
      isShortBook: isShortBook ?? this.isShortBook,
      isTrending: isTrending,
      isNewChapterToday: isNewChapterToday,
      spineWidth: spineWidth,
      spineHeight: spineHeight,
    );
  }
}

class BookChapter {
  final int number;
  final String title;
  final int minutes;
  final ChapterStatus status;
  final int words;
  final bool isPublished;

  const BookChapter({
    required this.number,
    required this.title,
    required this.minutes,
    required this.status,
    this.words = 1450,
    this.isPublished = true,
  });

  BookChapter copyWith({
    int? number,
    String? title,
    int? minutes,
    ChapterStatus? status,
    int? words,
    bool? isPublished,
  }) {
    return BookChapter(
      number: number ?? this.number,
      title: title ?? this.title,
      minutes: minutes ?? this.minutes,
      status: status ?? this.status,
      words: words ?? this.words,
      isPublished: isPublished ?? this.isPublished,
    );
  }
}

class BookReview {
  final String id;
  final String name;
  final String initials;
  final int stars;
  final String date;
  final String text;
  final int helpfulCount;
  final Color avatarBg;
  final Color avatarFg;
  final bool markedHelpful;

  const BookReview({
    required this.id,
    required this.name,
    required this.initials,
    required this.stars,
    required this.date,
    required this.text,
    required this.helpfulCount,
    required this.avatarBg,
    required this.avatarFg,
    this.markedHelpful = false,
  });

  BookReview copyWith({
    int? helpfulCount,
    bool? markedHelpful,
  }) {
    return BookReview(
      id: id,
      name: name,
      initials: initials,
      stars: stars,
      date: date,
      text: text,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      avatarBg: avatarBg,
      avatarFg: avatarFg,
      markedHelpful: markedHelpful ?? this.markedHelpful,
    );
  }
}

class ReaderSettings {
  final ReaderThemeMode theme;
  final double fontSize;
  final ReaderTypeface typeface;
  final ReaderLineSpacing lineSpacing;
  final bool keepScreenOn;

  const ReaderSettings({
    this.theme = ReaderThemeMode.paper,
    this.fontSize = 18,
    this.typeface = ReaderTypeface.serif,
    this.lineSpacing = ReaderLineSpacing.normal,
    this.keepScreenOn = true,
  });

  double get lineHeight {
    switch (lineSpacing) {
      case ReaderLineSpacing.tight:
        return 1.45;
      case ReaderLineSpacing.normal:
        return 1.7;
      case ReaderLineSpacing.relaxed:
        return 1.95;
    }
  }

  String get summaryLabel {
    final face = typeface == ReaderTypeface.serif ? 'Serif' : 'Sans';
    return '$face · ${fontSize.round()}';
  }

  ReaderSettings copyWith({
    ReaderThemeMode? theme,
    double? fontSize,
    ReaderTypeface? typeface,
    ReaderLineSpacing? lineSpacing,
    bool? keepScreenOn,
  }) {
    return ReaderSettings(
      theme: theme ?? this.theme,
      fontSize: fontSize ?? this.fontSize,
      typeface: typeface ?? this.typeface,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
    );
  }
}

class FamilyMember {
  final String id;
  final String name;
  final String initials;
  final String subtitle;
  final FamilyMemberStatus status;
  final Color avatarBg;
  final Color avatarFg;

  const FamilyMember({
    required this.id,
    required this.name,
    required this.initials,
    required this.subtitle,
    required this.status,
    required this.avatarBg,
    required this.avatarFg,
  });
}
