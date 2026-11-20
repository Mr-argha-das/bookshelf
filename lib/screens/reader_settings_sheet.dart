import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/tokens.dart';
import '../data/models.dart';
import '../state/providers.dart';
import '../widgets/widgets.dart';

class ReaderSettingsSheet extends ConsumerWidget {
  const ReaderSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(readerSettingsProvider);
    final notifier = ref.read(readerSettingsProvider.notifier);

    return FolioSheetScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Reading settings',
                  style: FolioTypography.h2(size: 22),
                ),
              ),
              FolioIconButton(
                icon: Icons.close_rounded,
                semanticsLabel: 'Close reading settings',
                onPressed: () => safePop(context),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Theme row: Paper, Sepia, Night
          Text('THEME', style: FolioTypography.label()),
          const SizedBox(height: 12),
          Row(
            children: [
              _ThemeSwatch(
                label: 'Paper',
                fill: FolioColors.paperBg,
                ink: FolioColors.paperInk,
                selected: settings.theme == ReaderThemeMode.paper,
                onTap: () => notifier.setTheme(ReaderThemeMode.paper),
              ),
              const SizedBox(width: 18),
              _ThemeSwatch(
                label: 'Sepia',
                fill: FolioColors.sepiaBg,
                ink: FolioColors.sepiaInk,
                selected: settings.theme == ReaderThemeMode.sepia,
                onTap: () => notifier.setTheme(ReaderThemeMode.sepia),
              ),
              const SizedBox(width: 18),
              _ThemeSwatch(
                label: 'Night',
                fill: FolioColors.nightBg,
                ink: FolioColors.nightInk,
                selected: settings.theme == ReaderThemeMode.night,
                onTap: () => notifier.setTheme(ReaderThemeMode.night),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Font size slider with A / A labels + live preview line
          Row(
            children: [
              Text('FONT SIZE', style: FolioTypography.label()),
              const Spacer(),
              Text(
                '${settings.fontSize.round()} pt',
                style: FolioTypography.caption(
                  size: 12,
                  weight: FontWeight.w600,
                  color: FolioColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('A', style: FolioTypography.body(size: 13)),
              Expanded(
                child: Slider(
                  min: 14,
                  max: 24,
                  divisions: 10,
                  value: settings.fontSize,
                  onChanged: notifier.setFontSize,
                ),
              ),
              Text('A', style: FolioTypography.body(size: 22)),
            ],
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: FolioColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'The sea wind carried a fine crust of salt into the lime trees.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: FolioTypography.reading(
                size: settings.fontSize,
                height: settings.lineHeight,
                color: FolioColors.ink,
                serif: settings.typeface == ReaderTypeface.serif,
              ),
            ),
          ),
          const SizedBox(height: 22),

          // Typeface segmented (Serif, Sans)
          Text('TYPEFACE', style: FolioTypography.label()),
          const SizedBox(height: 10),
          _SegmentedRow<ReaderTypeface>(
            value: settings.typeface,
            items: const [
              (ReaderTypeface.serif, 'Serif'),
              (ReaderTypeface.sans, 'Sans'),
            ],
            onChanged: notifier.setTypeface,
          ),
          const SizedBox(height: 20),

          // Line spacing segmented (Tight, Normal, Relaxed)
          Text('LINE SPACING', style: FolioTypography.label()),
          const SizedBox(height: 10),
          _SegmentedRow<ReaderLineSpacing>(
            value: settings.lineSpacing,
            items: const [
              (ReaderLineSpacing.tight, 'Tight'),
              (ReaderLineSpacing.normal, 'Normal'),
              (ReaderLineSpacing.relaxed, 'Relaxed'),
            ],
            onChanged: notifier.setLineSpacing,
          ),
          const SizedBox(height: 20),

          // Keep screen on switch
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: FolioColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Keep screen on',
                        style: FolioTypography.body(
                          size: 15,
                          weight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Prevent sleep while reading',
                        style: FolioTypography.caption(size: 12),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: settings.keepScreenOn,
                  onChanged: notifier.setKeepScreenOn,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  final String label;
  final Color fill;
  final Color ink;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeSwatch({
    required this.label,
    required this.fill,
    required this.ink,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '$label reading theme',
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? FolioColors.accent : FolioColors.outline,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: fill,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: FolioColors.border.withOpacityCompat(0.6),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Aa',
                  style: FolioTypography.cardTitle(size: 14, color: ink),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: FolioTypography.caption(
                size: 12,
                weight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? FolioColors.ink : FolioColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentedRow<T> extends StatelessWidget {
  final T value;
  final List<(T, String)> items;
  final ValueChanged<T> onChanged;

  const _SegmentedRow({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: FolioColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final item in items)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(item.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 40,
                  decoration: BoxDecoration(
                    color: item.$1 == value ? FolioColors.bg : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: item.$1 == value
                        ? Border.all(color: FolioColors.border)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    item.$2,
                    style: FolioTypography.body(
                      size: 14,
                      weight: item.$1 == value
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: item.$1 == value
                          ? FolioColors.ink
                          : FolioColors.secondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
