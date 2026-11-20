import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/tokens.dart';

class PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String priceSuffix;
  final String subtitle;
  final String? badge;
  final bool selected;
  final VoidCallback onTap;

  const PlanCard({
    super.key,
    required this.title,
    required this.price,
    required this.priceSuffix,
    required this.subtitle,
    this.badge,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '$title plan, $price $priceSuffix',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: EdgeInsets.only(top: badge != null ? 12 : 0),
            child: Material(
              color: selected ? FolioColors.selectedCardBg : FolioColors.bg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FolioRadius.cardMd),
                side: BorderSide(
                  color: selected ? FolioColors.accent : FolioColors.outline,
                  width: selected ? 2 : 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    badge != null ? 20 : 16,
                    16,
                    16,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: _RadioIndicator(selected: selected),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: FolioTypography.cardTitle(size: 19),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  price,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: FolioColors.ink,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  priceSuffix,
                                  style: FolioTypography.caption(size: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              subtitle,
                              style: FolioTypography.caption(
                                size: 13,
                                color: FolioColors.secondary,
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
          ),
          if (badge != null)
            Positioned(
              top: 0,
              left: 16,
              child: Container(
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: FolioColors.ink,
                  borderRadius: BorderRadius.circular(FolioRadius.chip),
                ),
                alignment: Alignment.center,
                child: Text(
                  badge!,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RadioIndicator extends StatelessWidget {
  final bool selected;

  const _RadioIndicator({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? FolioColors.accent : FolioColors.outline,
          width: selected ? 2 : 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: FolioColors.accent,
              ),
            )
          : null,
    );
  }
}
