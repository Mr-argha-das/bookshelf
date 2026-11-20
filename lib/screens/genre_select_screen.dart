import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/tokens.dart';
import '../data/dummy_data.dart';
import '../state/providers.dart';
import '../widgets/widgets.dart';

class GenreSelectScreen extends ConsumerWidget {
  const GenreSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedGenresProvider);
    final canContinue = selected.length >= 3;

    return Scaffold(
      backgroundColor: FolioColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  FolioSpacing.pageX,
                  12,
                  FolioSpacing.pageX,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FolioIconButton(
                      icon: Icons.arrow_back_rounded,
                      semanticsLabel: 'Back',
                      onPressed: () => safePop(context, fallback: '/onboarding'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'What do you like to read?',
                      style: FolioTypography.h1(size: 28),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selected.isEmpty
                          ? 'Pick at least 3'
                          : 'Pick at least 3 · ${selected.length} selected',
                      style: FolioTypography.caption(size: 14),
                    ),
                    const SizedBox(height: 28),
                    Wrap(
                      spacing: 10,
                      runSpacing: 12,
                      children: [
                        for (final genre in kGenres)
                          FolioChip(
                            label: genre,
                            selected: selected.contains(genre),
                            showCheckWhenSelected: true,
                            onTap: () => ref
                                .read(selectedGenresProvider.notifier)
                                .toggle(genre),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(
                FolioSpacing.pageX,
                14,
                FolioSpacing.pageX,
                16,
              ),
              decoration: const BoxDecoration(
                color: FolioColors.bg,
                border: Border(
                  top: BorderSide(color: FolioColors.border, width: 1),
                ),
              ),
              child: PrimaryButton(
                label: 'Continue',
                enabled: canContinue,
                onPressed: canContinue ? () => context.push('/register') : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
