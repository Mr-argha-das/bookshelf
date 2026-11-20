import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/tokens.dart';
import '../data/models.dart';
import '../state/providers.dart';
import '../widgets/widgets.dart';

class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPlan = ref.watch(selectedPlanProvider);

    String ctaLabel;
    String ctaNote;
    String ctaTarget;

    switch (selectedPlan) {
      case PlanType.yearly:
        ctaLabel = 'Start 7-day free trial';
        ctaNote =
            'Then ₹999 a year. Cancel anytime before Nov 26 and pay nothing.';
        ctaTarget = '/checkout';
      case PlanType.family:
        ctaLabel = 'Start Family · 7 days free';
        ctaNote = 'Then ₹1,499 a year for up to 6 people. Cancel anytime.';
        ctaTarget = '/family-checkout';
      case PlanType.monthly:
        ctaLabel = 'Subscribe for ₹149 a month';
        ctaNote = 'Billed monthly. Cancel anytime in Account.';
        ctaTarget = '/checkout';
    }

    return Scaffold(
      backgroundColor: FolioColors.bg,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plum hero band
                  Container(
                    width: double.infinity,
                    color: FolioColors.plum,
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          14,
                          8,
                          FolioSpacing.pageX,
                          28,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                FolioIconButton(
                                  icon: Icons.close_rounded,
                                  semanticsLabel: 'Close',
                                  color: FolioColors.plumText,
                                  onPressed: () =>
                                      safePop(context, fallback: '/account'),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () => showFolioToast(
                                    context,
                                    'No previous purchase found',
                                  ),
                                  style: TextButton.styleFrom(
                                    minimumSize: const Size(44, 44),
                                    foregroundColor: FolioColors.plumText,
                                  ),
                                  child: Text(
                                    'Restore',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: FolioColors.plumText
                                          .withOpacityCompat(0.85),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10, top: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'FOLIO PREMIUM',
                                    style: FolioTypography.label(
                                      color: FolioColors.plumLabel,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Read without\ninterruption.',
                                    style: FolioTypography.display(
                                      size: 34,
                                      color: FolioColors.plumText,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'No ads. Offline books. Early chapters.',
                                    style: FolioTypography.body(
                                      size: 15,
                                      color: FolioColors.plumText
                                          .withOpacityCompat(0.76),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // White sheet with radius 28 top over plum hero band
                  ColoredBox(
                    color: FolioColors.plum,
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: FolioColors.bg,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(FolioRadius.sheet),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(
                        FolioSpacing.pageX,
                        26,
                        FolioSpacing.pageX,
                        24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose your plan',
                            style: FolioTypography.h2(size: 22),
                          ),
                          const SizedBox(height: 16),

                          // 1. Yearly
                          PlanCard(
                            title: 'Yearly',
                            price: '₹83',
                            priceSuffix: '/ month',
                            subtitle: '7 days free, then ₹999 a year',
                            badge: 'BEST VALUE · SAVE 44%',
                            selected: selectedPlan == PlanType.yearly,
                            onTap: () => ref
                                .read(selectedPlanProvider.notifier)
                                .state = PlanType.yearly,
                          ),
                          const SizedBox(height: 14),

                          // 2. Family
                          PlanCard(
                            title: 'Family',
                            price: '₹1,499',
                            priceSuffix: '/ year',
                            subtitle:
                                'Up to 6 people, one bill. ₹250 each a year',
                            badge: 'SHARE WITH 5 OTHERS',
                            selected: selectedPlan == PlanType.family,
                            onTap: () => ref
                                .read(selectedPlanProvider.notifier)
                                .state = PlanType.family,
                          ),
                          const SizedBox(height: 14),

                          // 3. Monthly
                          PlanCard(
                            title: 'Monthly',
                            price: '₹149',
                            priceSuffix: '/ month',
                            subtitle: 'Cancel anytime',
                            selected: selectedPlan == PlanType.monthly,
                            onTap: () => ref
                                .read(selectedPlanProvider.notifier)
                                .state = PlanType.monthly,
                          ),
                          const SizedBox(height: 14),

                          // Link: See how Family works
                          Semantics(
                            button: true,
                            label: 'See how Family works',
                            child: InkWell(
                              onTap: () => context.push('/family'),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'See how Family works',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: FolioColors.accentText,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 16,
                                      color: FolioColors.accentText,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),

                          // What you get (5 rows with 40px purple-tint icon tiles)
                          Text(
                            'What you get',
                            style: FolioTypography.h2(size: 22),
                          ),
                          const SizedBox(height: 14),
                          const _PerkRow(
                            icon: Icons.block_rounded,
                            title: 'Zero ads',
                            subtitle:
                                'Quiet shelves and distraction-free chapter endings.',
                          ),
                          const _PerkRow(
                            icon: Icons.download_outlined,
                            title: 'Offline books',
                            subtitle:
                                'Download unlimited books for flights and slow trains.',
                          ),
                          const _PerkRow(
                            icon: Icons.schedule_outlined,
                            title: 'Early chapters',
                            subtitle:
                                'Read newly released chapters before public drop.',
                          ),
                          const _PerkRow(
                            icon: Icons.palette_outlined,
                            title: 'All reading themes',
                            subtitle:
                                'Full access to paper, sepia, night, and fine typography.',
                          ),
                          const _PerkRow(
                            icon: Icons.auto_stories_outlined,
                            title: 'Premium chapters',
                            subtitle:
                                'Read every premium chapter, no unlocking needed.',
                          ),
                          const SizedBox(height: 24),

                          // Free and Premium table
                          Text(
                            'Free and Premium',
                            style: FolioTypography.h2(size: 22),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(FolioRadius.card),
                              border: Border.all(color: FolioColors.border),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: const [
                                _CompareHeaderRow(),
                                _CompareRow('Read free books', 'Yes', 'Yes'),
                                _CompareRow(
                                  'Ads while reading',
                                  'Some',
                                  'None',
                                ),
                                _CompareRow(
                                  'Offline downloads',
                                  'No',
                                  'Unlimited',
                                ),
                                _CompareRow('Reading themes', '3', 'All'),
                                _CompareRow(
                                  'Early chapters',
                                  'No',
                                  'Yes',
                                  isLast: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Footer links: Terms, Privacy, Restore purchase
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                _FooterLink('Terms', () {
                                  showFolioToast(
                                    context,
                                    'Folio Terms of Service',
                                  );
                                }),
                                const Text(' · '),
                                _FooterLink('Privacy', () {
                                  showFolioToast(
                                    context,
                                    'Folio Privacy Policy',
                                  );
                                }),
                                const Text(' · '),
                                _FooterLink('Restore purchase', () {
                                  showFolioToast(
                                    context,
                                    'Checked for existing purchases',
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sticky CTA
          Container(
            padding: const EdgeInsets.fromLTRB(
              FolioSpacing.pageX,
              14,
              FolioSpacing.pageX,
              14,
            ),
            decoration: const BoxDecoration(
              color: FolioColors.bg,
              border: Border(top: BorderSide(color: FolioColors.border)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PrimaryButton(
                    label: ctaLabel,
                    onPressed: () => context.push(ctaTarget),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ctaNote,
                    textAlign: TextAlign.center,
                    style: FolioTypography.caption(size: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PerkRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PerkRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: FolioColors.accentTint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: FolioColors.accentText),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: FolioTypography.body(
                    size: 15,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: FolioTypography.caption(size: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompareHeaderRow extends StatelessWidget {
  const _CompareHeaderRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FolioColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text('FEATURE', style: FolioTypography.label()),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'FREE',
              textAlign: TextAlign.center,
              style: FolioTypography.label(),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'PREMIUM',
              textAlign: TextAlign.center,
              style: FolioTypography.label(color: FolioColors.accentText),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  final String feature;
  final String freeVal;
  final String premiumVal;
  final bool isLast;

  const _CompareRow(
    this.feature,
    this.freeVal,
    this.premiumVal, {
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: FolioColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(feature, style: FolioTypography.body(size: 13)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              freeVal,
              textAlign: TextAlign.center,
              style: FolioTypography.caption(size: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              premiumVal,
              textAlign: TextAlign.center,
              style: FolioTypography.body(
                size: 13,
                weight: FontWeight.w600,
                color: FolioColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterLink(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Text(
          label,
          style: FolioTypography.caption(size: 12),
        ),
      ),
    );
  }
}
