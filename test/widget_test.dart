import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/app/router.dart';
import 'package:folio/main.dart';
import 'package:folio/screens/home_screen.dart';
import 'package:folio/screens/reader_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Folio renders all 24 routes at 390x844 without errors',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const FolioApp(),
      ),
    );
    await tester.pumpAndSettle();

    final router = container.read(routerProvider);
    const routes = [
      '/onboarding',
      '/genres',
      '/login',
      '/register',
      '/home',
      '/explore',
      '/search',
      '/library',
      '/book/salt',
      '/book/salt/chapters',
      '/book/salt/reviews',
      '/reader/salt',
      '/reader-settings',
      '/write',
      '/editor/short',
      '/editor/book',
      '/book-manage',
      '/account',
      '/premium',
      '/checkout',
      '/premium-active',
      '/family',
      '/family-checkout',
      '/family-manage',
    ];

    for (final route in routes) {
      router.go(route);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Route $route threw');
    }
  });

  testWidgets('Dark Home and ReaderDark variants render cleanly',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeScreen(themeModeOverride: ThemeMode.dark),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Good evening, Priya'), findsOneWidget);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ReaderDark(bookId: 'salt'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Rain in the Salt Orchard'), findsOneWidget);
  });
}
