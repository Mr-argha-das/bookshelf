import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/tokens.dart';
import '../state/providers.dart';
import '../widgets/widgets.dart';

class FamilyCheckoutSheet extends ConsumerStatefulWidget {
  const FamilyCheckoutSheet({super.key});

  @override
  ConsumerState<FamilyCheckoutSheet> createState() =>
      _FamilyCheckoutSheetState();
}

class _FamilyCheckoutSheetState extends ConsumerState<FamilyCheckoutSheet> {
  int _paymentMethod = 0; // 0 = UPI, 1 = Card
  final _upiController = TextEditingController(text: 'priya@okbank');

  @override
  void dispose() {
    _upiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FolioSheetScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Confirm Family plan',
                  style: FolioTypography.h2(size: 24),
                ),
              ),
              FolioIconButton(
                icon: Icons.close_rounded,
                semanticsLabel: 'Close checkout',
                onPressed: () => safePop(context, fallback: '/family'),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Tinted plan tile with 2 overlapping avatars
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: FolioColors.accentTint,
              borderRadius: BorderRadius.circular(FolioRadius.card),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  height: 38,
                  child: Stack(
                    children: const [
                      Positioned(
                        left: 0,
                        child: FolioAvatar(
                          initials: 'P',
                          size: 38,
                          backgroundColor: FolioColors.coverLavender,
                          foregroundColor: FolioColors.coverInkViolet,
                          borderColor: FolioColors.accentTint,
                          borderWidth: 2,
                        ),
                      ),
                      Positioned(
                        left: 22,
                        child: FolioAvatar(
                          initials: 'R',
                          size: 38,
                          backgroundColor: FolioColors.coverCream,
                          foregroundColor: FolioColors.coverInkWarm,
                          borderColor: FolioColors.accentTint,
                          borderWidth: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Folio Family · Yearly',
                        style: FolioTypography.body(
                          size: 15,
                          weight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'You + up to 5 people',
                        style: FolioTypography.caption(size: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text('PAY WITH', style: FolioTypography.label()),
          const SizedBox(height: 10),
          _FamilyPaymentOption(
            title: 'UPI',
            subtitle: 'Instant autopay',
            selected: _paymentMethod == 0,
            onTap: () => setState(() => _paymentMethod = 0),
            child: _paymentMethod == 0
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: SizedBox(
                      height: 48,
                      child: TextField(
                        controller: _upiController,
                        style: FolioTypography.body(size: 14),
                        decoration: InputDecoration(
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
          _FamilyPaymentOption(
            title: 'Debit or credit card',
            subtitle: 'Visa, Mastercard, RuPay',
            selected: _paymentMethod == 1,
            onTap: () => setState(() => _paymentMethod = 1),
          ),
          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.only(top: 14),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: FolioColors.border)),
            ),
            child: Column(
              children: const [
                _FamSummaryLine('Folio Family · Yearly', '₹1,499.00'),
                SizedBox(height: 6),
                _FamSummaryLine(
                  'Free trial (7 days)',
                  '-₹1,499.00',
                  valueColor: FolioColors.success,
                ),
                SizedBox(height: 8),
                _FamSummaryLine('Due today', '₹0.00', bold: true),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Includes GST. Charged ₹1,499.00 on 26 Nov 2026 unless cancelled. You can invite people right after.',
            style: FolioTypography.caption(size: 12),
          ),
          const SizedBox(height: 18),

          PrimaryButton(
            label: 'Start free trial',
            onPressed: () {
              ref.read(isPremiumProvider.notifier).state = true;
              context.go('/family-manage');
            },
          ),
        ],
      ),
    );
  }
}

class _FamilyPaymentOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Widget? child;

  const _FamilyPaymentOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.child,
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
              if (child != null) child!,
            ],
          ),
        ),
      ),
    );
  }
}

class _FamSummaryLine extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  const _FamSummaryLine(
    this.label,
    this.value, {
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
