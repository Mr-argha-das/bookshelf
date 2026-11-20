import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app/tokens.dart';
import '../widgets/widgets.dart';

class PremiumActiveScreen extends StatelessWidget {
  const PremiumActiveScreen({super.key});

  static const _perks = [
    'Ads are now hidden across Home and Reader',
    'Offline downloads unlocked on every book',
    'Early chapters open immediately',
    'All reading themes and typography ready',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FolioColors.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                FolioSpacing.pageX,
                32,
                FolioSpacing.pageX,
                28,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 60,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                            color: FolioColors.accentTint,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 36,
                            color: FolioColors.accentText,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          "You're Premium",
                          textAlign: TextAlign.center,
                          style: FolioTypography.h1(size: 28),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your 7-day free trial is active. Enjoy quiet, uninterrupted reading.',
                          textAlign: TextAlign.center,
                          style: FolioTypography.caption(size: 14),
                        ),
                        const SizedBox(height: 28),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: FolioColors.surface,
                            borderRadius:
                                BorderRadius.circular(FolioRadius.cardMd),
                          ),
                          child: Column(
                            children: [
                              for (int i = 0; i < _perks.length; i++) ...[
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline_rounded,
                                      size: 20,
                                      color: FolioColors.success,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _perks[i],
                                        style: FolioTypography.body(size: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                if (i < _perks.length - 1)
                                  const SizedBox(height: 14),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Column(
                      children: [
                        PrimaryButton(
                          label: 'Start reading',
                          onPressed: () => context.go('/home'),
                        ),
                        const SizedBox(height: 12),
                        SecondaryButton(
                          label: 'Manage plan',
                          height: 52,
                          radius: FolioRadius.button,
                          onPressed: () => context.go('/account'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
