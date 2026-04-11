import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:complaints/features/auth/providers/auth_provider.dart';
import 'package:complaints/features/notifications/providers/activity_provider.dart';
import 'package:complaints/core/router/app_router.dart';

/// Desktop sidebar + mobile drawer shell for admin users.
///
/// Visual language: dark slate, monochromatic, high-density — feels like a
/// professional management console, not a student portal.
class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({required this.location, required this.child, super.key});
  final String location;
  final Widget child;

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  int get _selectedIndex {
    if (widget.location.startsWith(AppRoutes.adminDashboard)) return 0;
    if (widget.location.startsWith(AppRoutes.adminComplaints)) return 1;
    if (widget.location.startsWith(AppRoutes.adminNotifications)) return 2;
    if (widget.location.startsWith(AppRoutes.adminReports)) return 3;
    return 0;
  }

  void _signOut() => ref.read(signOutProvider.notifier).execute();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 768;
    final unreadCount = ref.watch(unreadActivityCountProvider);
    final user = ref.watch(currentUserProvider).valueOrNull;

    if (isMobile) {
      return _AdminMobileLayout(
        scaffoldKey: _scaffoldKey,
        selectedIndex: _selectedIndex,
        unreadCount: unreadCount,
        userName: user?.fullName ?? 'Admin',
        onSignOut: _signOut,
        child: widget.child,
      );
    }

    return _AdminDesktopLayout(
      selectedIndex: _selectedIndex,
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
        // Sidebar
        Container(
          width: 260,
          decoration: BoxDecoration(
            color: theme.colorScheme.card,
            border: Border(right: BorderSide(color: theme.colorScheme.border)),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
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

                // Nav items
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
                  icon: LucideIcons.activity,
                  label: 'Reports',
                  isSelected: selectedIndex == 3,
                  onTap: () => context.go(AppRoutes.adminReports),
                ),

                const Spacer(),
                Divider(color: theme.colorScheme.border, height: 1),

                // User chip + logout
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

// ── Mobile: top bar + drawer ───────────────────────────────────────────────

class _AdminMobileLayout extends StatelessWidget {
  const _AdminMobileLayout({
    required this.scaffoldKey,
    required this.selectedIndex,
    required this.unreadCount,
    required this.userName,
    required this.onSignOut,
    required this.child,
  });

  final GlobalKey<ScaffoldState> scaffoldKey;
  final int selectedIndex;
  final int unreadCount;
  final String userName;
  final VoidCallback onSignOut;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.card,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.menu, color: theme.colorScheme.foreground),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          'Admin Panel',
          style: theme.textTheme.small.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.foreground,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  LucideIcons.bell,
                  color: theme.colorScheme.foreground,
                  size: 20,
                ),
                onPressed: () => context.go(AppRoutes.adminNotifications),
              ),
              if (unreadCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.destructive,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        unreadCount > 9 ? '9+' : '$unreadCount',
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: theme.colorScheme.border),
        ),
      ),
      drawer: _AdminDrawer(
        selectedIndex: selectedIndex,
        userName: userName,
        unreadCount: unreadCount,
        onSignOut: onSignOut,
      ),
      body: child,
    );
  }
}

class _AdminDrawer extends StatelessWidget {
  const _AdminDrawer({
    required this.selectedIndex,
    required this.userName,
    required this.unreadCount,
    required this.onSignOut,
  });

  final int selectedIndex;
  final String userName;
  final int unreadCount;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Drawer(
      backgroundColor: theme.colorScheme.card,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.card),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    LucideIcons.shieldCheck,
                    color: theme.colorScheme.primaryForeground,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  userName,
                  style: theme.textTheme.p.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.foreground,
                  ),
                ),
              ],
            ),
          ),
          _AdminNavItem(
            icon: LucideIcons.layoutDashboard,
            label: 'Dashboard',
            isSelected: selectedIndex == 0,
            onTap: () {
              Navigator.of(context).pop();
              context.go(AppRoutes.adminDashboard);
            },
          ),
          _AdminNavItem(
            icon: LucideIcons.clipboardList,
            label: 'All Complaints',
            isSelected: selectedIndex == 1,
            onTap: () {
              Navigator.of(context).pop();
              context.go(AppRoutes.adminComplaints);
            },
          ),
          _AdminNavItem(
            icon: LucideIcons.bell,
            label: 'Activity Feed',
            isSelected: selectedIndex == 2,
            badge: unreadCount > 0 ? unreadCount : null,
            onTap: () {
              Navigator.of(context).pop();
              context.go(AppRoutes.adminNotifications);
            },
          ),
          _AdminNavItem(
            icon: LucideIcons.chartLine,
            label: 'Reports',
            isSelected: selectedIndex == 3,
            onTap: () {
              Navigator.of(context).pop();
              context.go(AppRoutes.adminReports);
            },
          ),
          const Spacer(),
          Divider(color: theme.colorScheme.border),
          ListTile(
            leading: Icon(
              LucideIcons.logOut,
              color: theme.colorScheme.destructive,
              size: 18,
            ),
            title: Text(
              'Sign Out',
              style: theme.textTheme.small.copyWith(
                color: theme.colorScheme.destructive,
              ),
            ),
            onTap: () {
              Navigator.of(context).pop();
              onSignOut();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
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
