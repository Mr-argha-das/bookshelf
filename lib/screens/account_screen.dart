import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/tokens.dart';
import '../state/providers.dart';
import '../widgets/widgets.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final readerSettings = ref.watch(readerSettingsProvider);
    final isPremium = ref.watch(isPremiumProvider);

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
              // Back + title "Account"
              Row(
                children: [
                  FolioIconButton(
                    icon: Icons.arrow_back_rounded,
                    semanticsLabel: 'Back',
                    onPressed: () => safePop(context, fallback: '/home'),
                  ),
                  const SizedBox(width: 6),
                  Text('Account', style: FolioTypography.h1(size: 26)),
                ],
              ),
              const SizedBox(height: 20),

              // Profile row
              Row(
                children: [
                  FolioAvatar(
                    initials: user.initials,
                    size: 68,
                    backgroundColor: user.avatarBg,
                    foregroundColor: user.avatarFg,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: FolioTypography.h1(size: 24)),
                        const SizedBox(height: 2),
                        Text(
                          user.handle,
                          style: FolioTypography.caption(size: 14),
                        ),
                      ],
                    ),
                  ),
                  SecondaryButton(
                    label: 'Edit',
                    height: 44,
                    radius: 12,
                    fullWidth: false,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onPressed: () =>
                        showFolioToast(context, 'Profile editing saved locally'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Plum premium card (radius 22)
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
                      isPremium ? 'FOLIO PREMIUM · ACTIVE' : 'FOLIO PREMIUM',
                      style: FolioTypography.label(color: FolioColors.plumLabel),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isPremium
                          ? 'Enjoy ad-free reading and offline shelves.'
                          : 'Read without ads. Try 7 days free.',
                      style: FolioTypography.h2(
                        size: 22,
                        color: FolioColors.plumText,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            label: isPremium ? 'Manage plan' : 'See plans',
                            height: 46,
                            radius: 14,
                            fontSize: 14,
                            backgroundColor: FolioColors.plumText,
                            foregroundColor: FolioColors.plum,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            onPressed: () => context.push(
                              isPremium ? '/premium-active' : '/premium',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SecondaryButton(
                            label: 'Family plan',
                            height: 46,
                            radius: 14,
                            fontSize: 14,
                            foregroundColor: FolioColors.plumText,
                            borderColor:
                                FolioColors.plumText.withOpacityCompat(0.45),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            onPressed: () => context.push('/family'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: FolioSpacing.sectionGap),

              // Reading group
              Text('READING', style: FolioTypography.label()),
              const SizedBox(height: 8),
              _AccountRow(
                icon: Icons.text_fields_rounded,
                label: 'Reading settings',
                value: readerSettings.summaryLabel,
                onTap: () => context.push('/reader-settings'),
              ),
              _AccountRow(
                icon: Icons.track_changes_outlined,
                label: 'Daily goal',
                value: '${user.dailyGoalMinutes} min',
                onTap: () => showFolioToast(
                  context,
                  'Daily reading goal set to ${user.dailyGoalMinutes} min',
                ),
              ),
              _AccountRow(
                icon: Icons.download_outlined,
                label: 'Downloads',
                value: isPremium ? 'Unlimited' : 'Premium',
                onTap: () => context.push('/premium'),
              ),
              const SizedBox(height: 24),

              // Writing group
              Text('WRITING', style: FolioTypography.label()),
              const SizedBox(height: 8),
              _AccountRow(
                icon: Icons.menu_book_outlined,
                label: 'My books',
                value: '2',
                onTap: () => context.push('/book-manage'),
              ),
              _AccountRow(
                icon: Icons.edit_outlined,
                label: 'Write a new book',
                value: '',
                onTap: () => context.push('/write'),
              ),
              const SizedBox(height: 24),

              // Support group
              Text('SUPPORT', style: FolioTypography.label()),
              const SizedBox(height: 8),
              _AccountRow(
                icon: Icons.help_outline_rounded,
                label: 'Help and contact',
                value: '',
                onTap: () =>
                    showFolioToast(context, 'Support: hello@folio.app'),
              ),
              _AccountRow(
                icon: Icons.shield_outlined,
                label: 'Privacy and terms',
                value: '',
                onTap: () => showFolioToast(
                  context,
                  'All data is stored locally in this demo',
                ),
              ),
              const SizedBox(height: 28),

              // Red outlined Sign out button
              SecondaryButton(
                label: 'Sign out',
                height: 52,
                radius: FolioRadius.button,
                borderColor: FolioColors.error,
                foregroundColor: FolioColors.error,
                onPressed: () => context.go('/login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _AccountRow({
    required this.icon,
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
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: FolioColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 19, color: FolioColors.ink),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: FolioTypography.body(size: 15, weight: FontWeight.w500),
              ),
            ),
            if (value.isNotEmpty) ...[
              Text(
                value,
                style: FolioTypography.caption(size: 13),
              ),
              const SizedBox(width: 6),
            ],
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
