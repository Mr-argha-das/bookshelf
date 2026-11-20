import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/tokens.dart';
import '../state/providers.dart';

/// Determines whether the bottom navigation bar should be visible for [location].
bool shouldShowNavBar(String location) {
  final path = Uri.tryParse(location)?.path ?? location;
  if (path == '/home' ||
      path == '/explore' ||
      path == '/search' ||
      path == '/library' ||
      path == '/account' ||
      path == '/family-manage') {
    return true;
  }
  if (path.startsWith('/book/')) {
    return true;
  }
  return false;
}

/// Returns the active bottom tab index (0=Home, 1=Explore, 2=Library, -1=none).
int activeNavIndexForPath(String location) {
  final path = Uri.tryParse(location)?.path ?? location;
  if (path == '/home' || path.startsWith('/book/')) {
    return 0;
  }
  if (path == '/explore' || path == '/search') {
    return 1;
  }
  if (path == '/library') {
    return 2;
  }
  // Account and Family manage have the nav with no active tab.
  return -1;
}

class FolioNavShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const FolioNavShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final showNav = shouldShowNavBar(location);
    final activeIndex = activeNavIndexForPath(location);
    final isHomeDark = location == '/home' && ref.watch(homeDarkModeProvider);

    return Scaffold(
      backgroundColor: isHomeDark ? FolioColors.darkBg : FolioColors.bg,
      body: navigationShell,
      bottomNavigationBar: showNav
          ? FolioNavBar(
              activeIndex: activeIndex,
              darkMode: isHomeDark,
              onSelectTab: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
              onTapWrite: () => context.push('/write'),
            )
          : null,
    );
  }
}

class FolioNavBar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onSelectTab;
  final VoidCallback onTapWrite;
  final bool darkMode;

  const FolioNavBar({
    super.key,
    required this.activeIndex,
    required this.onSelectTab,
    required this.onTapWrite,
    this.darkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = darkMode ? FolioColors.darkBg : FolioColors.bg;
    final border = darkMode ? FolioColors.darkBorder : FolioColors.border;
    final activeColor = darkMode ? FolioColors.darkInk : FolioColors.ink;
    final inactiveColor =
        darkMode ? FolioColors.darkSecondary : FolioColors.secondary;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: FolioSpacing.navHeight,
          child: Padding(
            padding: const EdgeInsets.only(top: 10, left: 12, right: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _NavTabItem(
                    label: 'Home',
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    active: activeIndex == 0,
                    activeColor: activeColor,
                    inactiveColor: inactiveColor,
                    onTap: () => onSelectTab(0),
                  ),
                ),
                Expanded(
                  child: _NavTabItem(
                    label: 'Explore',
                    icon: Icons.explore_outlined,
                    activeIcon: Icons.explore_rounded,
                    active: activeIndex == 1,
                    activeColor: activeColor,
                    inactiveColor: inactiveColor,
                    onTap: () => onSelectTab(1),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Semantics(
                      button: true,
                      label: 'Write a new book or short story',
                      child: Transform.translate(
                        offset: const Offset(0, -2),
                        child: Material(
                          color: FolioColors.accent,
                          borderRadius:
                              BorderRadius.circular(FolioRadius.navWrite),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: onTapWrite,
                            child: const SizedBox(
                              width: 48,
                              height: 48,
                              child: Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _NavTabItem(
                    label: 'Library',
                    icon: Icons.collections_bookmark_outlined,
                    activeIcon: Icons.collections_bookmark_rounded,
                    active: activeIndex == 2,
                    activeColor: activeColor,
                    inactiveColor: inactiveColor,
                    onTap: () => onSelectTab(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTabItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool active;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavTabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.active,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : inactiveColor;
    return Semantics(
      button: true,
      selected: active,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 44),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                active ? activeIcon : icon,
                size: 24,
                color: color,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
