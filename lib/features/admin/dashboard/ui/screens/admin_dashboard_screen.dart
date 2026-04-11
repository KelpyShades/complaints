import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:complaints/core/widgets/async_value_widget.dart';
import '../../providers/admin_dashboard_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminDashboardStatsProvider);
    final theme = ShadTheme.of(context);
    final isMobile = MediaQuery.sizeOf(context).width < 768;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('System Overview', style: theme.textTheme.h3),
          const SizedBox(height: 8),
          Text(
            'Real-time metrics for campus complaints.',
            style: theme.textTheme.muted,
          ),
          const SizedBox(height: 24),

          AsyncValueWidget(
            value: statsAsync,
            onRetry: () => ref.invalidate(adminDashboardStatsProvider),
            data: (stats) {
              if (isMobile) {
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _AdminStatCard(
                      title: 'Total',
                      value: stats.total,
                      icon: LucideIcons.layers,
                    ),
                    _AdminStatCard(
                      title: 'Pending',
                      value: stats.pending,
                      icon: LucideIcons.clock,
                      color: Colors.orange,
                    ),
                    _AdminStatCard(
                      title: 'Active',
                      value: stats.inProgress,
                      icon: LucideIcons.activity,
                      color: Colors.blue,
                    ),
                    _AdminStatCard(
                      title: 'Resolved',
                      value: stats.resolved,
                      icon: LucideIcons.circleCheck,
                      color: Colors.green,
                    ),
                  ],
                );
              }
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _AdminStatCard(
                    title: 'Total',
                    value: stats.total,
                    icon: LucideIcons.layers,
                  ),
                  _AdminStatCard(
                    title: 'Pending',
                    value: stats.pending,
                    icon: LucideIcons.clock,
                    color: Colors.orange,
                  ),
                  _AdminStatCard(
                    title: 'In Progress',
                    value: stats.inProgress,
                    icon: LucideIcons.activity,
                    color: Colors.blue,
                  ),
                  _AdminStatCard(
                    title: 'Resolved',
                    value: stats.resolved,
                    icon: LucideIcons.circleCheck,
                    color: Colors.green,
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

class _AdminStatCard extends StatelessWidget {
  const _AdminStatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.color,
  });

  final String title;
  final int value;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.small.copyWith(
                  color: theme.colorScheme.mutedForeground,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, size: 18, color: color ?? theme.colorScheme.primary),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value.toString(),
            style: theme.textTheme.h2.copyWith(fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}
