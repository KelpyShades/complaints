import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:complaints/core/router/admin_adaptive_screens.dart';
import 'package:complaints/core/router/app_router.dart';
import 'package:complaints/features/auth/providers/auth_provider.dart';
import 'package:complaints/features/shared/activity/providers/activity_provider.dart';

/// Desktop sidebar + mobile bottom navigation for admin users (mirrors [StudentShell]).
class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({required this.location, required this.child, super.key});
  final String location;
  final Widget child;

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      syncActivityFeedShellLocation(
        ref,
        previousLocation: '',
        nextLocation: widget.location,
        activityRoutePrefix: AppRoutes.adminNotifications,
        isStillMounted: () => mounted,
      );
    });
  }

  @override
  void didUpdateWidget(covariant AdminShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncActivityFeedShellLocation(
      ref,
      previousLocation: oldWidget.location,
      nextLocation: widget.location,
      activityRoutePrefix: AppRoutes.adminNotifications,
      isStillMounted: () => mounted,
    );
  }

  int get _desktopSelectedIndex {
    if (widget.location.startsWith(AppRoutes.adminDashboard)) return 0;
    if (widget.location.startsWith(AppRoutes.adminComplaints)) return 1;
    if (widget.location.startsWith(AppRoutes.adminNotifications)) return 2;
    if (widget.location.startsWith(AppRoutes.adminReports)) return 3;
    if (widget.location.startsWith(AppRoutes.adminProfile)) return 4;
    return 0;
  }

  int _mobileTabIndex(String loc) {
    if (loc.startsWith(AppRoutes.adminDashboard)) return 0;
    if (loc.startsWith(AppRoutes.adminComplaints)) return 1;
    if (loc.startsWith(AppRoutes.adminNotifications)) return 2;
    if (loc.startsWith(AppRoutes.adminProfile)) return 3;
    return 0;
  }

  void _signOut() => ref.read(signOutProvider.notifier).execute();

  @override
  Widget build(BuildContext context) {
    final isMobile = adminShellIsMobileLayout(context);
    final unreadCount = ref.watch(unreadActivityCountProvider);
    final user = ref.watch(currentUserProvider).valueOrNull;

    if (isMobile) {
      return _AdminMobileLayout(
        selectedIndex: _mobileTabIndex(widget.location),
        unreadCount: unreadCount,
        child: widget.child,
      );
    }

    return _AdminDesktopLayout(
      selectedIndex: _desktopSelectedIndex,
      unreadCount: unreadCount,
      userName: user?.fullName ?? 'Admin',
      onSignOut: _signOut,
      child: widget.child,
    );
  }
}

// ── Desktop: fixed sidebar ─────────────────────────────────────────────────

class _AdminDesktopLayout extends StatelessWidget {
  const _AdminDesktopLayout({
    required this.selectedIndex,
    required this.unreadCount,
    required this.userName,
    required this.onSignOut,
    required this.child,
  });

  final int selectedIndex;
  final int unreadCount;
  final String userName;
  final VoidCallback onSignOut;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Row(
      children: [
        Container(
          width: 260,
          decoration: BoxDecoration(
            color: theme.colorScheme.card,
            border: Border(right: BorderSide(color: theme.colorScheme.border)),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          LucideIcons.shieldCheck,
                          size: 18,
                          color: theme.colorScheme.primaryForeground,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin Panel',
                            style: theme.textTheme.small.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.foreground,
                            ),
                          ),
                          Text(
                            'Complaints System',
                            style: theme.textTheme.muted.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(color: theme.colorScheme.border, height: 1),
                const SizedBox(height: 8),

                _AdminNavItem(
                  icon: LucideIcons.layoutDashboard,
                  label: 'Dashboard',
                  isSelected: selectedIndex == 0,
                  onTap: () => context.go(AppRoutes.adminDashboard),
                ),
                _AdminNavItem(
                  icon: LucideIcons.clipboardList,
                  label: 'All Complaints',
                  isSelected: selectedIndex == 1,
                  onTap: () => context.go(AppRoutes.adminComplaints),
                ),
                _AdminNavItem(
                  icon: LucideIcons.bell,
                  label: 'Activity Feed',
                  isSelected: selectedIndex == 2,
                  badge: unreadCount > 0 ? unreadCount : null,
                  onTap: () => context.go(AppRoutes.adminNotifications),
                ),
                _AdminNavItem(
                  icon: LucideIcons.chartColumnIncreasing,
                  label: 'Reports',
                  isSelected: selectedIndex == 3,
                  onTap: () => context.go(AppRoutes.adminReports),
                ),
                _AdminNavItem(
                  icon: LucideIcons.user,
                  label: 'Profile',
                  isSelected: selectedIndex == 4,
                  onTap: () => context.go(AppRoutes.adminProfile),
                ),

                const Spacer(),
                Divider(color: theme.colorScheme.border, height: 1),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 24,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.muted,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            userName.isNotEmpty
                                ? userName[0].toUpperCase()
                                : 'A',
                            style: theme.textTheme.small.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.foreground,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 10,
                          children: [
                            Text(
                              userName,
                              style: theme.textTheme.small.copyWith(
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.foreground,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'ADMIN',
                                style: theme.textTheme.muted.copyWith(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          LucideIcons.logOut,
                          size: 16,
                          color: theme.colorScheme.mutedForeground,
                        ),
                        onPressed: onSignOut,
                        tooltip: 'Sign Out',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Material(
            color: theme.colorScheme.background,
            child: Padding(
              padding: const EdgeInsets.only(top: 50, left: 20),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Mobile: bottom navigation (no app bar, no drawer) ─────────────────────

class _AdminMobileLayout extends StatelessWidget {
  const _AdminMobileLayout({
    required this.selectedIndex,
    required this.unreadCount,
    required this.child,
  });

  final int selectedIndex;
  final int unreadCount;
  final Widget child;

  static Widget _navBarIcon({required int index, required int unreadCount}) {
    final icon = Icon(_destinations[index].icon);
    if (index != 2 || unreadCount <= 0) return icon;
    return Badge(
      label: Text(
        unreadCount > 99 ? '99+' : '$unreadCount',
        style: const TextStyle(fontSize: 10),
      ),
      child: icon,
    );
  }

  static const _destinations = <_AdminMobileNavSpec>[
    _AdminMobileNavSpec(
      label: 'Dashboard',
      icon: LucideIcons.layoutDashboard,
      path: AppRoutes.adminDashboard,
    ),
    _AdminMobileNavSpec(
      label: 'Complaints',
      icon: LucideIcons.clipboardList,
      path: AppRoutes.adminComplaints,
    ),
    _AdminMobileNavSpec(
      label: 'Activity',
      icon: LucideIcons.bell,
      path: AppRoutes.adminNotifications,
    ),
    _AdminMobileNavSpec(
      label: 'Profile',
      icon: LucideIcons.user,
      path: AppRoutes.adminProfile,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(top: true, bottom: false, child: child),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: theme.colorScheme.accent,
          backgroundColor: theme.colorScheme.card,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return theme.textTheme.muted.copyWith(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected
                  ? theme.colorScheme.accentForeground
                  : theme.colorScheme.mutedForeground,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              size: 22,
              color: selected
                  ? theme.colorScheme.accentForeground
                  : theme.colorScheme.mutedForeground,
            );
          }),
        ),
        child: NavigationBar(
          height: 64,
          selectedIndex: selectedIndex.clamp(0, _destinations.length - 1),
          onDestinationSelected: (i) {
            final spec = _destinations[i];
            context.go(spec.path);
          },
          destinations: [
            for (var i = 0; i < _destinations.length; i++)
              NavigationDestination(
                icon: _navBarIcon(index: i, unreadCount: unreadCount),
                selectedIcon: _navBarIcon(index: i, unreadCount: unreadCount),
                label: _destinations[i].label,
              ),
          ],
        ),
      ),
    );
  }
}

class _AdminMobileNavSpec {
  const _AdminMobileNavSpec({
    required this.label,
    required this.icon,
    required this.path,
  });

  final String label;
  final IconData icon;
  final String path;
}

class _AdminNavItem extends StatelessWidget {
  const _AdminNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? theme.colorScheme.accent : Colors.transparent,
          border: isSelected
              ? Border(
                  left: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2.5,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? theme.colorScheme.accentForeground
                  : theme.colorScheme.mutedForeground,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.small.copyWith(
                  color: isSelected
                      ? theme.colorScheme.accentForeground
                      : theme.colorScheme.mutedForeground,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.destructive,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge! > 99 ? '99+' : '$badge',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
