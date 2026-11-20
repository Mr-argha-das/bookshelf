import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/tokens.dart';
import '../data/models.dart';
import '../state/providers.dart';
import '../widgets/widgets.dart';

class FamilyManageScreen extends ConsumerWidget {
  const FamilyManageScreen({super.key});

  void _showAddByEmailDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: FolioColors.bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Invite by email', style: FolioTypography.h2(size: 20)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'name@example.com'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: FolioTypography.body(
                  size: 14,
                  color: FolioColors.secondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(familyMembersProvider.notifier)
                    .inviteEmail(controller.text);
                Navigator.of(dialogContext).pop();
                showFolioToast(context, 'Invitation sent');
              },
              child: Text(
                'Send invite',
                style: FolioTypography.body(
                  size: 14,
                  weight: FontWeight.w600,
                  color: FolioColors.accentText,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddKidDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final ageCtrl = TextEditingController(text: '8');
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: FolioColors.bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Add a kids profile',
            style: FolioTypography.h2(size: 20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(hintText: 'Child’s name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: ageCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Age (under 13)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: FolioTypography.body(
                  size: 14,
                  color: FolioColors.secondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(familyMembersProvider.notifier)
                    .addKidProfile(nameCtrl.text, ageCtrl.text);
                Navigator.of(dialogContext).pop();
                showFolioToast(context, 'Kids profile added');
              },
              child: Text(
                'Create',
                style: FolioTypography.body(
                  size: 14,
                  weight: FontWeight.w600,
                  color: FolioColors.accentText,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: FolioColors.bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Cancel Family plan?',
            style: FolioTypography.h2(size: 20),
          ),
          content: Text(
            'Everyone in your family keeps Premium until 26 Nov 2026. All reading shelves and progress stay saved.',
            style: FolioTypography.body(size: 14, color: FolioColors.secondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Keep plan',
                style: FolioTypography.body(
                  size: 14,
                  weight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(isPremiumProvider.notifier).state = false;
                Navigator.of(dialogContext).pop();
                showFolioToast(context, 'Family plan cancelled');
                context.go('/account');
              },
              child: Text(
                'Cancel plan',
                style: FolioTypography.body(
                  size: 14,
                  weight: FontWeight.w600,
                  color: FolioColors.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(familyMembersProvider);
    final used = members.length.clamp(0, 6);
    final left = (6 - used).clamp(0, 6);

    return Scaffold(
      backgroundColor: FolioColors.bg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            FolioSpacing.pageX,
            10,
            FolioSpacing.pageX,
            32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header "Family"
              Row(
                children: [
                  FolioIconButton(
                    icon: Icons.arrow_back_rounded,
                    semanticsLabel: 'Back',
                    onPressed: () => safePop(context, fallback: '/account'),
                  ),
                  const SizedBox(width: 6),
                  Text('Family', style: FolioTypography.h1(size: 26)),
                ],
              ),
              const SizedBox(height: 18),

              // Plum card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: FolioColors.plum,
                  borderRadius: BorderRadius.circular(FolioRadius.cardXl),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FOLIO FAMILY',
                      style: FolioTypography.label(color: FolioColors.plumLabel),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Trial until 26 Nov',
                      style: FolioTypography.h1(
                        size: 26,
                        color: FolioColors.plumText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Then ₹1,499 a year · renews 26 Nov 2027',
                      style: FolioTypography.caption(
                        size: 13,
                        color: FolioColors.plumText.withOpacityCompat(0.75),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Text(
                          'Seats used',
                          style: FolioTypography.caption(
                            size: 12,
                            color: FolioColors.plumText.withOpacityCompat(0.75),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$used of 6',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: FolioColors.plumText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(6, (index) {
                        final filled = index < used;
                        return Expanded(
                          child: Container(
                            height: 6,
                            margin: EdgeInsets.only(right: index < 5 ? 6 : 0),
                            decoration: BoxDecoration(
                              color: filled
                                  ? FolioColors.accent
                                  : FolioColors.plumText.withOpacityCompat(0.25),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: FolioSpacing.sectionGap),

              // Members list
              Text('Members', style: FolioTypography.h2(size: 22)),
              const SizedBox(height: 10),
              for (final member in members) _FamilyMemberRow(member: member),
              const SizedBox(height: FolioSpacing.sectionGap),

              // Invite someone
              Text('Invite someone', style: FolioTypography.h2(size: 22)),
              const SizedBox(height: 4),
              Text(
                '$left ${left == 1 ? 'seat' : 'seats'} left. The link works for 7 days.',
                style: FolioTypography.caption(size: 13),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
                decoration: BoxDecoration(
                  color: FolioColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: FolioColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'folio.app/join/priya-4f9k',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FolioTypography.body(size: 14),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PrimaryButton(
                      label: 'Copy',
                      height: 44,
                      radius: 10,
                      fontSize: 13,
                      fullWidth: false,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      onPressed: () {
                        Clipboard.setData(
                          const ClipboardData(
                            text: 'https://folio.app/join/priya-4f9k',
                          ),
                        );
                        showFolioToast(context, 'Invite link copied');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Share by WhatsApp',
                      height: 46,
                      fontSize: 13,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      onPressed: () =>
                          showFolioToast(context, 'Opening WhatsApp invite…'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SecondaryButton(
                      label: 'Add by email',
                      height: 46,
                      fontSize: 13,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      onPressed: left > 0
                          ? () => _showAddByEmailDialog(context, ref)
                          : () => showFolioToast(context, 'All 6 seats used'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: Material(
                  color: FolioColors.accentTint,
                  borderRadius: BorderRadius.circular(14),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: left > 0
                        ? () => _showAddKidDialog(context, ref)
                        : () => showFolioToast(context, 'All 6 seats used'),
                    child: Center(
                      child: Text(
                        'Add a kids profile',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: FolioColors.accentText,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: FolioSpacing.sectionGap),

              // Plan rows
              Text('PLAN', style: FolioTypography.label()),
              const SizedBox(height: 8),
              _PlanDetailRow(
                label: 'Payment method',
                value: 'UPI · priya@okbank',
                onTap: () => showFolioToast(context, 'UPI autopay active'),
              ),
              _PlanDetailRow(
                label: 'Kids profile limits',
                value: 'Under 13',
                onTap: () => showFolioToast(
                  context,
                  'Kids shelves hide mature categories and ads',
                ),
              ),
              const SizedBox(height: 22),

              SecondaryButton(
                label: 'Cancel Family plan',
                height: 52,
                radius: FolioRadius.button,
                borderColor: FolioColors.error,
                foregroundColor: FolioColors.error,
                onPressed: () => _showCancelDialog(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FamilyMemberRow extends StatelessWidget {
  final FamilyMember member;

  const _FamilyMemberRow({required this.member});

  @override
  Widget build(BuildContext context) {
    Widget badge;
    switch (member.status) {
      case FamilyMemberStatus.organizer:
        badge = Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: FolioColors.ink,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'Organizer',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        );
      case FamilyMemberStatus.member:
        badge = Text(
          'Member',
          style: FolioTypography.caption(size: 12),
        );
      case FamilyMemberStatus.pending:
        badge = Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: FolioColors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: FolioColors.outline),
          ),
          child: Text(
            'Pending',
            style: FolioTypography.caption(size: 11, weight: FontWeight.w500),
          ),
        );
      case FamilyMemberStatus.kids:
        badge = Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: FolioColors.accentTint,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'Kids profile',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: FolioColors.accentText,
            ),
          ),
        );
    }

    return Container(
      constraints: const BoxConstraints(minHeight: 70),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: FolioColors.border)),
      ),
      child: Row(
        children: [
          FolioAvatar(
            initials: member.initials,
            size: 48,
            backgroundColor: member.avatarBg,
            foregroundColor: member.avatarFg,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FolioTypography.body(
                    size: 15,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  member.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FolioTypography.caption(size: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          badge,
        ],
      ),
    );
  }
}

class _PlanDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _PlanDetailRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: FolioSpacing.rowMinHeight),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: FolioColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: FolioTypography.body(size: 15, weight: FontWeight.w500),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: FolioTypography.caption(size: 13),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: FolioColors.mutedIcon,
            ),
          ],
        ),
      ),
    );
  }
}
