import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app/tokens.dart';
import '../widgets/widgets.dart';

class WriteSheet extends StatelessWidget {
  const WriteSheet({super.key});

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
                  'What will you write?',
                  style: FolioTypography.h2(size: 24),
                ),
              ),
              FolioIconButton(
                icon: Icons.close_rounded,
                semanticsLabel: 'Close write menu',
                onPressed: () => safePop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Option 1: Short book
          _WriteOptionCard(
            icon: Icons.description_outlined,
            title: 'Short book',
            subtitle: 'One page, 5 to 20 min read. Ideal for stories and essays.',
            onTap: () {
              context.pop();
              context.push('/editor/short');
            },
          ),
          const SizedBox(height: 12),

          // Option 2: Book with chapters
          _WriteOptionCard(
            icon: Icons.menu_book_outlined,
            title: 'Book with chapters',
            subtitle: 'Organize a longer work and publish chapter by chapter.',
            onTap: () {
              context.pop();
              context.push('/editor/book');
            },
          ),
          const SizedBox(height: 20),

          Text('RESUME DRAFT', style: FolioTypography.label()),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: FolioColors.surface,
              borderRadius: BorderRadius.circular(FolioRadius.cardMd),
              border: Border.all(color: FolioColors.border),
            ),
            child: Row(
              children: [
                const BookCover(
                  title: 'Seventeen Windows',
                  author: 'Priya Nair',
                  bg: FolioColors.coverLinen,
                  fg: FolioColors.coverInkWarm,
                  width: 40,
                  height: 58,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seventeen Windows',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FolioTypography.cardTitle(size: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Edited 2h ago',
                        style: FolioTypography.caption(size: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                PrimaryButton(
                  label: 'Continue',
                  height: 44,
                  radius: 12,
                  fontSize: 13,
                  fullWidth: false,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  onPressed: () {
                    context.pop();
                    context.push('/editor/short');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WriteOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _WriteOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title. $subtitle',
      child: Material(
        color: FolioColors.bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FolioRadius.cardMd),
          side: const BorderSide(color: FolioColors.outline, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: FolioColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 22, color: FolioColors.ink),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: FolioTypography.cardTitle(size: 18),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: FolioTypography.caption(size: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: FolioColors.mutedIcon,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
