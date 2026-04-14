import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:complaints/core/utils/user_facing_error_message.dart';
import 'package:complaints/features/auth/providers/auth_provider.dart';

/// Mirrors [MobileStudentProfileScreen] for admin shell.
class MobileAdminProfileScreen extends ConsumerWidget {
  const MobileAdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final theme = ShadTheme.of(context);

    return ColoredBox(
      color: theme.colorScheme.background,
      child: SafeArea(
        child: userAsync.when(
          skipError: true,
          skipLoadingOnReload: true,
          skipLoadingOnRefresh: true,
          data: (user) {
            if (user == null) {
              return _EmptyProfileState(theme: theme);
            }
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: 220,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.07),
                            theme.colorScheme.accent.withValues(alpha: 0.05),
                            theme.colorScheme.background,
                          ],
                          stops: const [0.0, 0.42, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Profile',
                          style: theme.textTheme.h3.copyWith(
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 28),
                        _ProfileIdentityHeader(
                          theme: theme,
                          initials: user.fullName.isNotEmpty
                              ? user.fullName[0].toUpperCase()
                              : 'A',
                          fullName: user.fullName,
                          email: user.email,
                        ),
                        const SizedBox(height: 36),
                        _SectionHeading(theme: theme, title: 'Account'),
                        const SizedBox(height: 10),
                        _InsetGroup(
                          theme: theme,
                          children: [
                            _InsetInfoRow(
                              theme: theme,
                              icon: LucideIcons.user,
                              label: 'Full name',
                              value: user.fullName,
                              showDivider: true,
                            ),
                            _InsetInfoRow(
                              theme: theme,
                              icon: LucideIcons.mail,
                              label: 'Email',
                              value: user.email,
                              showDivider: false,
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        _SectionHeading(theme: theme, title: 'Session'),
                        const SizedBox(height: 10),
                        _SignOutTile(
                          theme: theme,
                          onTap: () => _showSignOutDialog(context, ref),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => _ProfileLoadingState(theme: theme),
          error: (err, stack) => _ProfileErrorState(
            theme: theme,
            message: userFacingErrorMessage(err),
          ),
        ),
      ),
    );
  }
}

void _showSignOutDialog(BuildContext context, WidgetRef ref) {
  showShadDialog(
    context: context,
    builder: (dialogContext) => ShadDialog.alert(
      title: const Text('Sign out'),
      description: const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Text('Are you sure you want to sign out?'),
      ),
      actions: [
        ShadButton.outline(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(dialogContext).pop(),
        ),
        ShadButton.destructive(
          child: const Text('Sign Out'),
          onPressed: () {
            Navigator.of(dialogContext).pop();
            ref.read(signOutProvider.notifier).execute();
          },
        ),
      ],
    ),
  );
}

class _ProfileIdentityHeader extends StatelessWidget {
  const _ProfileIdentityHeader({
    required this.theme,
    required this.initials,
    required this.fullName,
    required this.email,
  });

  final ShadThemeData theme;
  final String initials;
  final String fullName;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.18),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.card, width: 3),
            ),
            child: CircleAvatar(
              radius: 46,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                initials,
                style: theme.textTheme.h1.copyWith(
                  fontSize: 36,
                  height: 1,
                  color: theme.colorScheme.primaryForeground,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          fullName,
          textAlign: TextAlign.center,
          style: theme.textTheme.large.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.35,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          textAlign: TextAlign.center,
          style: theme.textTheme.muted.copyWith(fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.theme, required this.title});

  final ShadThemeData theme;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.small.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 11,
          letterSpacing: 1.1,
          color: theme.colorScheme.mutedForeground,
        ),
      ),
    );
  }
}

class _InsetGroup extends StatelessWidget {
  const _InsetGroup({required this.theme, required this.children});

  final ShadThemeData theme;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.border),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.foreground.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(children: children),
      ),
    );
  }
}

class _InsetInfoRow extends StatelessWidget {
  const _InsetInfoRow({
    required this.theme,
    required this.icon,
    required this.label,
    required this.value,
    required this.showDivider,
  });

  final ShadThemeData theme;
  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.muted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    icon,
                    size: 20,
                    color: theme.colorScheme.foreground.withValues(alpha: 0.85),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.muted.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: theme.textTheme.p.copyWith(
                        fontWeight: FontWeight.w400,
                        height: 1.25,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: 72,
            color: theme.colorScheme.border.withValues(alpha: 0.85),
          ),
      ],
    );
  }
}

class _SignOutTile extends StatelessWidget {
  const _SignOutTile({required this.theme, required this.onTap});

  final ShadThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.colorScheme.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(
                LucideIcons.logOut,
                size: 20,
                color: theme.colorScheme.destructive,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Sign out',
                  style: theme.textTheme.p.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.destructive,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: theme.colorScheme.mutedForeground.withValues(
                  alpha: 0.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileLoadingState extends StatelessWidget {
  const _ProfileLoadingState({required this.theme});

  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading profile…',
              style: theme.textTheme.muted.copyWith(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileErrorState extends StatelessWidget {
  const _ProfileErrorState({required this.theme, required this.message});

  final ShadThemeData theme;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.circleAlert,
                  size: 40,
                  color: theme.colorScheme.destructive.withValues(alpha: 0.9),
                ),
                const SizedBox(height: 12),
                Text(
                  'Something went wrong',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.large.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.muted.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyProfileState extends StatelessWidget {
  const _EmptyProfileState({required this.theme});

  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.userX,
              size: 48,
              color: theme.colorScheme.mutedForeground.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No profile found',
              style: theme.textTheme.large.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in again to load your account.',
              textAlign: TextAlign.center,
              style: theme.textTheme.muted,
            ),
          ],
        ),
      ),
    );
  }
}
