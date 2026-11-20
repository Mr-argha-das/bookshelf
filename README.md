# Folio

A minimal, mobile-first Flutter app for reading books and writing short books. Built with **Flutter 3.x**, **Dart 3**, **Riverpod**, **GoRouter**, and **Google Fonts** using local dummy data only.

## Getting Started

Make sure you have Flutter 3.x installed (`flutter --version`). If platform folders (`android/`, `ios/`, etc.) have not been generated yet in your clone, run `flutter create .` first without overwriting `lib/` or `pubspec.yaml`.

```bash
flutter pub get
flutter run
```

To run the route smoke tests:

```bash
flutter test
```

## Architecture

- `lib/app/` — Exact design tokens (`tokens.dart`), custom Material 3 light/dark themes (`theme.dart`), and GoRouter configuration (`router.dart`) with `StatefulShellRoute.indexedStack` and custom fade/slide & bottom-sheet transitions.
- `lib/data/` — Immutable data models (`models.dart`) and plain `const` local datasets (`dummy_data.dart`): 14 books, 12 genres, 10 reviews, chapter lists, family members, and 9 paragraphs of original Chapter 12 prose.
- `lib/state/` — Riverpod providers (`providers.dart`) holding books, shelf tab/view/selection, reader typography/theme settings, Premium subscription state, selected plan, genres, reviews, chapter reorder state, and family members.
- `lib/widgets/` — Shared UI components (`BookCover` + `BookCover.spine`, `FolioNavShell`/`FolioNavBar`, `NowReadingBar`, `AdSlot`, `PlanCard`, `PrimaryButton`, `SecondaryButton`, `FolioChip`, `FolioAvatar`, `SectionHeader`, `FolioProgressBar`, `FolioSheetScaffold`, and `StatesDemo`).
- `lib/screens/` — All 23 screen/sheet files plus `StatesDemo` system states.

## Notes & Assumptions

- **Local-only dummy data**: All auth, publishing, checkout, review posting, and family invite flows update local Riverpod state only (no backend or network calls).
- **Google Fonts**: Fonts (`Inter`, `Playfair Display`, `Source Serif 4`) load via `google_fonts` at runtime when network access is available, falling back cleanly to system fonts offline.
- **No coin system**: Premium chapters unlock directly with an active Folio Premium or Family plan — there are no coins, wallets, or per-chapter purchases anywhere in the app.
- **No gradients**: Every surface, cover, panel, and button uses flat solid tokens; the only subtle shadows are on elevated covers/selected shelf books and bottom sheets.
- **Dark variants**: `HomeScreen` accepts an optional `themeModeOverride: ThemeMode.dark` parameter (and watches `homeDarkModeProvider`), and `ReaderDark` renders `ReaderScreen` with `ReaderThemeMode.night`.
