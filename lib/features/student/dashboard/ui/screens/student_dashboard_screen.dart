import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:complaints/core/widgets/async_value_widget.dart';
import '../../providers/student_dashboard_provider.dart';

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(studentDashboardStatsProvider);
    final theme = ShadTheme.of(context);

    // Assuming we want a welcoming, user-centric layout
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                  theme.colorScheme.primary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back!',
                  style: theme.textTheme.h2.copyWith(
                    color: theme.colorScheme.primaryForeground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Track your requests or submit a new one.',
                  style: theme.textTheme.large.copyWith(
                    color: theme.colorScheme.primaryForeground.withValues(
                      alpha: 0.9,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          Text('Your Status', style: theme.textTheme.h4),
          const SizedBox(height: 16),

          AsyncValueWidget(
            value: statsAsync,
            onRetry: () => ref.invalidate(studentDashboardStatsProvider),
            data: (stats) {
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.4,
                children: [
                  _StudentStatCard(
                    title: 'Active',
                    value: stats.pending + stats.inProgress,
                    icon: LucideIcons.activity,
                  ),
                  _StudentStatCard(
                    title: 'Resolved',
                    value: stats.resolved,
                    icon: LucideIcons.circleCheck,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StudentStatCard extends StatelessWidget {
  const _StudentStatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 24),
          const Spacer(),
          Text(value.toString(), style: theme.textTheme.h2),
          Text(title, style: theme.textTheme.muted),
        ],
      ),
    );
  }
}
