import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/account_screen.dart';
import '../screens/book_details_screen.dart';
import '../screens/book_manage_screen.dart';
import '../screens/chapter_list_screen.dart';
import '../screens/checkout_sheet.dart';
import '../screens/explore_screen.dart';
import '../screens/family_checkout_sheet.dart';
import '../screens/family_manage_screen.dart';
import '../screens/family_plan_screen.dart';
import '../screens/genre_select_screen.dart';
import '../screens/home_screen.dart';
import '../screens/library_screen.dart';
import '../screens/login_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/premium_active_screen.dart';
import '../screens/premium_screen.dart';
import '../screens/reader_screen.dart';
import '../screens/reader_settings_sheet.dart';
import '../screens/register_screen.dart';
import '../screens/reviews_screen.dart';
import '../screens/search_results_screen.dart';
import '../screens/short_book_editor_screen.dart';
import '../screens/write_sheet.dart';
import '../widgets/nav_bar.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _homeBranchKey = GlobalKey<NavigatorState>(debugLabel: 'homeBranch');
final _exploreBranchKey = GlobalKey<NavigatorState>(debugLabel: 'exploreBranch');
final _libraryBranchKey = GlobalKey<NavigatorState>(debugLabel: 'libraryBranch');
final _accountBranchKey = GlobalKey<NavigatorState>(debugLabel: 'accountBranch');

CustomTransitionPage<void> _folioPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

CustomTransitionPage<void> _folioSheetPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    opaque: false,
    barrierDismissible: true,
    barrierColor: const Color(0x7A000000),
    barrierLabel: 'Dismiss sheet',
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 210),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      );
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/onboarding',
    routes: [
      // Auth & Onboarding (no nav)
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) =>
            _folioPage(state, const OnboardingScreen()),
      ),
      GoRoute(
        path: '/genres',
        pageBuilder: (context, state) =>
            _folioPage(state, const GenreSelectScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            _folioPage(state, const LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) =>
            _folioPage(state, const RegisterScreen()),
      ),

      // Main bottom-nav shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return FolioNavShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home + Book details, Chapter list, Reviews
          StatefulShellBranch(
            navigatorKey: _homeBranchKey,
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) =>
                    _folioPage(state, const HomeScreen()),
              ),
              GoRoute(
                path: '/book/:id',
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id'] ?? 'salt';
                  return _folioPage(state, BookDetailsScreen(bookId: id));
                },
                routes: [
                  GoRoute(
                    path: 'chapters',
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['id'] ?? 'salt';
                      return _folioPage(state, ChapterListScreen(bookId: id));
                    },
                  ),
                  GoRoute(
                    path: 'reviews',
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['id'] ?? 'salt';
                      return _folioPage(state, ReviewsScreen(bookId: id));
                    },
                  ),
                ],
              ),
            ],
          ),

          // Branch 1: Explore + Search results
          StatefulShellBranch(
            navigatorKey: _exploreBranchKey,
            routes: [
              GoRoute(
                path: '/explore',
                pageBuilder: (context, state) =>
                    _folioPage(state, const ExploreScreen()),
              ),
              GoRoute(
                path: '/search',
                pageBuilder: (context, state) =>
                    _folioPage(state, const SearchResultsScreen()),
              ),
            ],
          ),

          // Branch 2: Library (bookshelf)
          StatefulShellBranch(
            navigatorKey: _libraryBranchKey,
            routes: [
              GoRoute(
                path: '/library',
                pageBuilder: (context, state) =>
                    _folioPage(state, const LibraryScreen()),
              ),
            ],
          ),

          // Branch 3: Account + Family manage (nav visible, no active tab)
          StatefulShellBranch(
            navigatorKey: _accountBranchKey,
            routes: [
              GoRoute(
                path: '/account',
                pageBuilder: (context, state) =>
                    _folioPage(state, const AccountScreen()),
              ),
              GoRoute(
                path: '/family-manage',
                pageBuilder: (context, state) =>
                    _folioPage(state, const FamilyManageScreen()),
              ),
            ],
          ),
        ],
      ),

      // Reader & Reader settings (no nav)
      GoRoute(
        path: '/reader/:id',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? 'salt';
          return _folioPage(state, ReaderScreen(bookId: id));
        },
      ),
      GoRoute(
        path: '/reader-settings',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _folioSheetPage(state, const ReaderSettingsSheet()),
      ),

      // Write sheet & Editors (no nav)
      GoRoute(
        path: '/write',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _folioSheetPage(state, const WriteSheet()),
      ),
      GoRoute(
        path: '/editor/short',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _folioPage(state, const ShortBookEditorScreen()),
      ),
      GoRoute(
        path: '/editor/book',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _folioPage(state, const BookManageScreen(isNewBook: true)),
      ),
      GoRoute(
        path: '/book-manage',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _folioPage(state, const BookManageScreen(isNewBook: false)),
      ),

      // Premium & Family purchase flow (no nav)
      GoRoute(
        path: '/premium',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _folioPage(state, const PremiumScreen()),
      ),
      GoRoute(
        path: '/checkout',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _folioSheetPage(state, const CheckoutSheet()),
      ),
      GoRoute(
        path: '/premium-active',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _folioPage(state, const PremiumActiveScreen()),
      ),
      GoRoute(
        path: '/family',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _folioPage(state, const FamilyPlanScreen()),
      ),
      GoRoute(
        path: '/family-checkout',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _folioSheetPage(state, const FamilyCheckoutSheet()),
      ),
    ],
  );
});
