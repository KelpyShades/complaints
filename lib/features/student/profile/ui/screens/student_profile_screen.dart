import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:complaints/features/auth/providers/auth_provider.dart';

class StudentProfileScreen extends ConsumerWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final theme = ShadTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profile', style: theme.textTheme.h3),
              const SizedBox(height: 32),
              userAsync.when(
                data: (user) {
                  if (user == null) {
                    return const Center(child: Text('User not found'));
                  }
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final maxWidth = constraints.maxWidth;
                      final isMobile = maxWidth < 600;
                      return Center(
                        child: SizedBox(
                          width: isMobile ? double.infinity : 600,
                          child: Column(
                            // crossAxisAlignment: .center,
                            children: [
                              Center(
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: theme.colorScheme.primary,
                                  child: Text(
                                    user.fullName.isNotEmpty
                                        ? user.fullName[0].toUpperCase()
                                        : 'S',
                                    style: theme.textTheme.h1.copyWith(
                                      color:
                                          theme.colorScheme.primaryForeground,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _ProfileInfoCard(
                                icon: LucideIcons.user,
                                label: 'Full Name',
                                value: user.fullName,
                              ),
                              const SizedBox(height: 16),
                              _ProfileInfoCard(
                                icon: LucideIcons.mail,
                                label: 'Email Address',
                                value: user.email,
                              ),
                              const SizedBox(height: 48),
                              SizedBox(
                                width: double.infinity,
                                child: ShadButton.destructive(
                                  onPressed: () {
                                    showShadDialog(
                                      context: context,
                                      builder: (context) => ShadDialog.alert(
                                        title: const Text('Sign Out'),
                                        description: const Padding(
                                          padding: EdgeInsets.only(bottom: 8),
                                          child: Text(
                                            'Are you sure you want to sign out?',
                                          ),
                                        ),
                                        actions: [
                                          ShadButton.outline(
                                            child: const Text('Cancel'),
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                          ),
                                          ShadButton.destructive(
                                            child: const Text('Sign Out'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              ref
                                                  .read(
                                                    signOutProvider.notifier,
                                                  )
                                                  .execute();
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  leading: const Icon(
                                    LucideIcons.logOut,
                                    size: 18,
                                  ),
                                  child: const Text('Sign Out'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 5,
              children: [
                Text(
                  label,
                  style: theme.textTheme.muted.copyWith(fontSize: 12),
                ),
                Text(
                  value,
                  style: theme.textTheme.small.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
