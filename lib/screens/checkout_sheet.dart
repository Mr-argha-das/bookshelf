import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/tokens.dart';
import '../data/models.dart';
import '../state/providers.dart';
import '../widgets/widgets.dart';

class CheckoutSheet extends ConsumerStatefulWidget {
  const CheckoutSheet({super.key});

  @override
  ConsumerState<CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends ConsumerState<CheckoutSheet> {
  int _paymentMethod = 0; // 0 = UPI, 1 = Card, 2 = Google Play
  final _upiController = TextEditingController(text: 'priya@okbank');
  final _promoController = TextEditingController();
  bool _showPromo = false;

  @override
  void dispose() {
    _upiController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plan = ref.watch(selectedPlanProvider);
    final isMonthly = plan == PlanType.monthly;
    final planTitle = isMonthly
        ? 'Folio Premium · Monthly'
        : 'Folio Premium · Yearly';
    final planSub = isMonthly
        ? '₹149 a month · cancel anytime'
        : '7 days free, then ₹999 a year';
    final planPrice = isMonthly ? '₹149.00' : '₹999.00';

    return FolioSheetScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Confirm plan',
                  style: FolioTypography.h2(size: 24),
                ),
              ),
              FolioIconButton(
                icon: Icons.close_rounded,
                semanticsLabel: 'Close checkout',
                onPressed: () => safePop(context, fallback: '/premium'),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Plan summary tile (tint #F4F1FB)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: FolioColors.accentTint,
              borderRadius: BorderRadius.circular(FolioRadius.card),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: FolioColors.plum,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_outlined,
                    size: 20,
                    color: FolioColors.plumText,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        planTitle,
                        style: FolioTypography.body(
                          size: 15,
                          weight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        planSub,
                        style: FolioTypography.caption(size: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Pay with radio list
          Text('PAY WITH', style: FolioTypography.label()),
          const SizedBox(height: 10),
          _PaymentOptionTile(
            title: 'UPI',
            subtitle: 'Instant autopay',
            selected: _paymentMethod == 0,
            onTap: () => setState(() => _paymentMethod = 0),
            expandedChild: _paymentMethod == 0
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: SizedBox(
                      height: 48,
                      child: TextField(
                        controller: _upiController,
                        style: FolioTypography.body(size: 14),
                        decoration: InputDecoration(
                          hintText: 'yourname@bank',
                          filled: true,
                          fillColor: FolioColors.bg,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: FolioColors.accent,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: FolioColors.accent,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 8),
          _PaymentOptionTile(
            title: 'Debit or credit card',
            subtitle: 'Visa, Mastercard, RuPay',
            selected: _paymentMethod == 1,
            onTap: () => setState(() => _paymentMethod = 1),
          ),
          const SizedBox(height: 8),
          _PaymentOptionTile(
            title: 'Google Play',
            subtitle: 'Pay via Play Store billing',
            selected: _paymentMethod == 2,
            onTap: () => setState(() => _paymentMethod = 2),
          ),
          const SizedBox(height: 14),

          // Promo code row
          InkWell(
            onTap: () => setState(() => _showPromo = !_showPromo),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_offer_outlined,
                    size: 18,
                    color: FolioColors.accentText,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Have a promo code?',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: FolioColors.accentText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_showPromo) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: TextField(
                      controller: _promoController,
                      style: FolioTypography.body(size: 14),
                      decoration: const InputDecoration(
                        hintText: 'Enter code',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SecondaryButton(
                  label: 'Apply',
                  height: 46,
                  fullWidth: false,
                  onPressed: () =>
                      showFolioToast(context, 'Promo code checked'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),

          // Summary lines
          Container(
            padding: const EdgeInsets.only(top: 14),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: FolioColors.border)),
            ),
            child: Column(
              children: [
                _SummaryRow(label: planTitle, value: planPrice),
                const SizedBox(height: 6),
                if (!isMonthly) ...[
                  _SummaryRow(
                    label: 'Free trial (7 days)',
                    value: '-$planPrice',
                    valueColor: FolioColors.success,
                  ),
                  const SizedBox(height: 8),
                ],
                _SummaryRow(
                  label: 'Due today',
                  value: isMonthly ? '₹149.00' : '₹0.00',
                  bold: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isMonthly
                ? 'Includes GST. Renews monthly unless cancelled in Account.'
                : 'Includes GST. You will be charged ₹999.00 on 26 Nov 2026 unless you cancel beforehand.',
            style: FolioTypography.caption(size: 12),
          ),
          const SizedBox(height: 18),

          PrimaryButton(
            label: isMonthly ? 'Subscribe for ₹149' : 'Start free trial',
            onPressed: () {
              ref.read(isPremiumProvider.notifier).state = true;
              context.go('/premium-active');
            },
          ),
        ],
      ),
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Widget? expandedChild;

  const _PaymentOptionTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.expandedChild,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? FolioColors.selectedCardBg : FolioColors.bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected ? FolioColors.accent : FolioColors.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            selected ? FolioColors.accent : FolioColors.outline,
                        width: selected ? 2 : 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: selected
                        ? Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: FolioColors.accent,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: FolioTypography.body(
                            size: 14,
                            weight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: FolioTypography.caption(size: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (expandedChild != null) expandedChild!,
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: FolioTypography.body(
              size: bold ? 15 : 13,
              weight: bold ? FontWeight.w600 : FontWeight.w400,
              color: bold ? FolioColors.ink : FolioColors.secondary,
            ),
          ),
        ),
        Text(
          value,
          style: FolioTypography.body(
            size: bold ? 15 : 13,
            weight: bold ? FontWeight.w700 : FontWeight.w500,
            color: valueColor ?? FolioColors.ink,
          ),
        ),
      ],
    );
  }
}
