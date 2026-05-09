import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:complaints/core/router/app_router.dart';
import 'package:complaints/core/widgets/async_value_widget.dart';
import 'package:complaints/features/auth/providers/auth_provider.dart';
import 'package:complaints/features/shared/complaints/models/complaint_model.dart';
import 'package:complaints/features/shared/complaints/ui/widgets/complaint_card.dart';
import 'package:complaints/features/shared/complaints/ui/widgets/dashboard_stat_cards.dart';
import 'package:complaints/features/student/complaints/providers/student_complaint_list_provider.dart';

class StudentComplaintsScreen extends ConsumerWidget {
  const StudentComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final statsAsync = ref.watch(studentDashboardStatsProvider);
    final rawAsync = ref.watch(studentRawComplaintsProvider);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DashboardWelcomeBlock(
                  theme: theme,
                  name: currentUser?.fullName ?? 'Student',
                ),
              ),
              ShadButton(
                onPressed: () => context.go(AppRoutes.studentComplaintNew),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.plus, size: 16),
                    const SizedBox(width: 8),
                    const Text('New Complaint'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          AsyncValueWidget<StudentDashboardStats>(
            value: statsAsync,
            onRetry: () => ref.invalidate(studentRawComplaintsProvider),
            data: (stats) {
              final open = stats.pending + stats.inProgress;
              return SizedBox(
                height: 180,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 2,
                      child: DashboardBentoHeroTotalCard(
                        theme: theme,
                        total: stats.total,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 1,
                      child: DashboardBentoAccentStatCard(
                        theme: theme,
                        label: 'Resolved',
                        value: stats.resolved,
                        icon: LucideIcons.circleCheck,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 1,
                      child: DashboardBentoSurfaceStatCard(
                        theme: theme,
                        label: 'Open',
                        caption: 'Pending & in progress',
                        value: open,
                        icon: LucideIcons.clock,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              'RECENT',
              style: theme.textTheme.small.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                letterSpacing: 1.05,
                color: theme.colorScheme.mutedForeground,
              ),
            ),
          ),
          const SizedBox(height: 16),
          AsyncValueWidget<List<ComplaintModel>>(
            value: rawAsync,
            onRetry: () => ref.invalidate(studentRawComplaintsProvider),
            data: (complaints) {
              final recent = complaints.take(5).toList();
              if (recent.isEmpty) {
                return DashboardRecentEmptyState(theme: theme);
              }
              return Column(
                children: [
                  for (var i = 0; i < recent.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    ComplaintCard(
                      complaint: recent[i],
                      onTap: () => context.go(
                        AppRoutes.studentComplaintDetailPath(recent[i].id),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
