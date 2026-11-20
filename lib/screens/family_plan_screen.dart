import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/tokens.dart';
import '../widgets/widgets.dart';

class FamilyPlanScreen extends StatelessWidget {
  const FamilyPlanScreen({super.key});

  static const _heroAvatars = [
    ('P', Color(0xFFCFC8E8), Color(0xFF241C4A)),
    ('R', Color(0xFFE8E1D3), Color(0xFF2A2623)),
    ('A', Color(0xFFD8C7B8), Color(0xFF2A2623)),
    ('M', Color(0xFFDDE3E0), Color(0xFF1E2A2F)),
    ('K', Color(0xFFE6DCD0), Color(0xFF2A2623)),
    ('+', Color(0xFFF4F1FB), Color(0xFF5B3FC4)),
  ];

  static const _perks = [
    (
      Icons.collections_bookmark_outlined,
      'A private shelf for each person',
      'Everyone keeps their own books, highlights, and reading streak.',
    ),
    (
      Icons.child_care_outlined,
      'Kids profiles',
      'Age-appropriate books only, no mature categories, no ads.',
    ),
    (
      Icons.block_rounded,
      'Zero ads for everyone',
      'Every member reads cleanly without banner or chapter ads.',
    ),
    (
      Icons.download_outlined,
      'Offline books for all',
      'Save entire reading lists to any phone or tablet.',
    ),
    (
      Icons.receipt_long_outlined,
      'One bill, one organizer',
      'Manage invites and seats cleanly from one Account page.',
    ),
  ];

  static const _steps = [
    ('1', 'Start the Family plan', 'Begin with 7 days free — cancel anytime.'),
    (
      '2',
      'Invite up to 5 people',
      'Share an invite link or add a kids profile directly.',
    ),
    (
      '3',
      'Everyone joins',
      'Each member gets instant Premium access on their own shelf.',
    ),
  ];

  static const _faqs = [
    (
      'Do family members need to live together?',
      'No. You can invite family or close readers anywhere in the country.',
    ),
    (
      'Can I add a child?',
      'Yes. Create a Kids profile with age-appropriate books only and zero ads.',
    ),
    (
      'What happens if I cancel?',
      'Everyone keeps Premium until the end of the billing year, and all shelves stay intact.',
    ),
    (
      'What if I already have a Yearly plan?',
      'Switching from Yearly automatically credits your unused time toward Family.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FolioColors.bg,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plum hero
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
                          52,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FolioIconButton(
                              icon: Icons.arrow_back_rounded,
                              semanticsLabel: 'Back',
                              color: FolioColors.plumText,
                              onPressed: () =>
                                  safePop(context, fallback: '/premium'),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10, top: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 6 overlapping avatars (52px, 3px plum border, -10 overlap)
                                  SizedBox(
                                    height: 54,
                                    width: 52 + 5 * 42.0,
                                    child: Stack(
                                      children: [
                                        for (int i = 0;
                                            i < _heroAvatars.length;
                                            i++)
                                          Positioned(
                                            left: i * 42.0,
                                            child: FolioAvatar(
                                              initials: _heroAvatars[i].$1,
                                              size: 52,
                                              backgroundColor:
                                                  _heroAvatars[i].$2,
                                              foregroundColor:
                                                  _heroAvatars[i].$3,
                                              borderColor: FolioColors.plum,
                                              borderWidth: 3,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'FOLIO FAMILY',
                                    style: FolioTypography.label(
                                      color: FolioColors.plumLabel,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'One plan.\nSix readers.',
                                    style: FolioTypography.display(
                                      size: 36,
                                      color: FolioColors.plumText,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Everyone gets their own shelf, progress and recommendations. You pay once.',
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

                  // White sheet overlapping hero by 24
                  Transform.translate(
                    offset: const Offset(0, -24),
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
                        16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Price card (radius 20, bg #F4F1FB)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: FolioColors.accentTint,
                              borderRadius:
                                  BorderRadius.circular(FolioRadius.cardLg),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '₹1,499',
                                            style: GoogleFonts.playfairDisplay(
                                              fontSize: 38,
                                              fontWeight: FontWeight.w700,
                                              height: 1.0,
                                              color: FolioColors.ink,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'per year, up to 6 people',
                                            style: FolioTypography.caption(
                                              size: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '₹250',
                                          style: GoogleFonts.playfairDisplay(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                            color: FolioColors.accentText,
                                          ),
                                        ),
                                        Text(
                                          'each',
                                          style: FolioTypography.caption(
                                            size: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Divider(
                                    color: FolioColors.familyDivider,
                                    height: 1,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '6 separate yearly plans',
                                        style: FolioTypography.caption(size: 13),
                                      ),
                                    ),
                                    Text(
                                      '₹5,994',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: FolioColors.secondary,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'You save',
                                        style: FolioTypography.body(
                                          size: 14,
                                          weight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '₹4,495 (75%)',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: FolioColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: FolioSpacing.sectionGap),

                          // Everything in Premium, for everyone
                          Text(
                            'Everything in Premium, for everyone',
                            style: FolioTypography.h2(size: 22),
                          ),
                          const SizedBox(height: 16),
                          for (final perk in _perks) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: FolioColors.accentTint,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    perk.$1,
                                    size: 20,
                                    color: FolioColors.accentText,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        perk.$2,
                                        style: FolioTypography.body(
                                          size: 15,
                                          weight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        perk.$3,
                                        style: FolioTypography.caption(size: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                          ],
                          const SizedBox(height: 14),

                          // How it works (numbered black circles 1 to 3)
                          Text(
                            'How it works',
                            style: FolioTypography.h2(size: 22),
                          ),
                          const SizedBox(height: 16),
                          for (final step in _steps) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                    color: FolioColors.ink,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    step.$1,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        step.$2,
                                        style: FolioTypography.body(
                                          size: 15,
                                          weight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        step.$3,
                                        style: FolioTypography.caption(size: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                          ],
                          const SizedBox(height: 14),

                          // Good to know FAQ (4 items, static)
                          Text(
                            'Good to know',
                            style: FolioTypography.h2(size: 22),
                          ),
                          const SizedBox(height: 12),
                          for (final faq in _faqs)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: FolioColors.border),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    faq.$1,
                                    style: FolioTypography.body(
                                      size: 14,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    faq.$2,
                                    style: FolioTypography.caption(size: 13),
                                  ),
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
                    label: 'Start Family · 7 days free',
                    onPressed: () => context.push('/family-checkout'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Then ₹1,499 a year. Cancel anytime.',
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
