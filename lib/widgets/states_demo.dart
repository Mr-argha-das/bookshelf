import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/tokens.dart';
import 'primary_button.dart';
import 'secondary_button.dart';

/// Standard Folio toast / SnackBar (ink bg, white text, radius 12).
void showFolioToast(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: FolioColors.ink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FolioRadius.toast),
        ),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        duration: const Duration(seconds: 2),
      ),
    );
}

/// Pulsing skeleton shimmer box (#E6E2D8, 1.6s opacity pulse 0.55 to 1.0).
class FolioSkeleton extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;

  const FolioSkeleton({
    super.key,
    this.width,
    required this.height,
    this.radius = 10,
  });

  @override
  State<FolioSkeleton> createState() => _FolioSkeletonState();
}

class _FolioSkeletonState extends State<FolioSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: FolioColors.shimmer,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

/// Empty library shelf state: dashed shelf + "Your shelf is empty" + button.
class FolioEmptyShelf extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const FolioEmptyShelf({
    super.key,
    this.title = 'Your shelf is empty',
    this.subtitle = 'Save books you want to read slowly or start writing your own.',
    this.actionLabel = 'Find a book',
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: FolioColors.surface,
        borderRadius: BorderRadius.circular(FolioRadius.card),
        border: Border.all(color: FolioColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              _DashedBookOutline(width: 28, height: 68),
              SizedBox(width: 8),
              _DashedBookOutline(width: 34, height: 82),
              SizedBox(width: 8),
              _DashedBookOutline(width: 26, height: 60),
            ],
          ),
          Container(
            width: 168,
            height: 8,
            decoration: BoxDecoration(
              color: FolioColors.plank,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: FolioTypography.cardTitle(size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: FolioTypography.caption(size: 13),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: actionLabel,
            onPressed: onAction,
            height: 46,
            fullWidth: false,
            fontSize: 14,
            padding: const EdgeInsets.symmetric(horizontal: 24),
          ),
        ],
      ),
    );
  }
}

class _DashedBookOutline extends StatelessWidget {
  final double width;
  final double height;

  const _DashedBookOutline({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: FolioColors.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        border: Border.all(color: FolioColors.outline, width: 1.2),
      ),
    );
  }
}

/// Error card with "Try again" action.
class FolioErrorCard extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;

  const FolioErrorCard({
    super.key,
    this.title = 'Something went quiet',
    this.message = 'We could not load this shelf right now. Please try again.',
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FolioColors.bg,
        borderRadius: BorderRadius.circular(FolioRadius.card),
        border: Border.all(color: FolioColors.error.withOpacityCompat(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: FolioColors.error.withOpacityCompat(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: FolioColors.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: FolioTypography.cardTitle(size: 17),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: FolioTypography.caption(size: 13),
          ),
          const SizedBox(height: 16),
          SecondaryButton(
            label: 'Try again',
            onPressed: onRetry,
            height: 44,
            fullWidth: false,
          ),
        ],
      ),
    );
  }
}

/// Reusable showcase/container of all Folio system states.
class StatesDemo extends StatelessWidget {
  final VoidCallback onFindBook;
  final VoidCallback onRetry;

  const StatesDemo({
    super.key,
    required this.onFindBook,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('LOADING SKELETON', style: FolioTypography.label()),
        const SizedBox(height: 10),
        Row(
          children: const [
            FolioSkeleton(width: 64, height: 96, radius: 6),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FolioSkeleton(height: 16, radius: 6),
                  SizedBox(height: 8),
                  FolioSkeleton(width: 140, height: 12, radius: 6),
                  SizedBox(height: 14),
                  FolioSkeleton(width: 96, height: 10, radius: 6),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('EMPTY STATE', style: FolioTypography.label()),
        const SizedBox(height: 10),
        FolioEmptyShelf(onAction: onFindBook),
        const SizedBox(height: 24),
        Text('ERROR STATE', style: FolioTypography.label()),
        const SizedBox(height: 10),
        FolioErrorCard(onRetry: onRetry),
      ],
    );
  }
}
