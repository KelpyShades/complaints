import 'package:complaints/features/auth/providers/auth_provider.dart';
import 'package:complaints/features/student/complaints/providers/student_complaint_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:complaints/core/router/app_router.dart';
import 'package:complaints/core/widgets/async_value_widget.dart';
import 'package:complaints/features/shared/complaints/models/complaint_model.dart';
import 'package:complaints/features/shared/complaints/ui/widgets/complaint_card.dart';
import 'package:complaints/features/shared/complaints/ui/widgets/dashboard_stat_cards.dart';

class MobileStudentComplaintsScreen extends ConsumerWidget {
  const MobileStudentComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final statsAsync = ref.watch(studentDashboardStatsProvider);
    final rawAsync = ref.watch(studentRawComplaintsProvider);

    return ColoredBox(
      color: theme.colorScheme.background,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DashboardWelcomeBlock(
                theme: theme,
                name: currentUser?.fullName ?? 'Student',
              ),
              const SizedBox(height: 28),
              AsyncValueWidget<StudentDashboardStats>(
                value: statsAsync,
                onRetry: () => ref.invalidate(studentRawComplaintsProvider),
                data: (stats) {
                  final open = stats.pending + stats.inProgress;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DashboardBentoHeroTotalCard(theme: theme, total: stats.total),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 158,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: DashboardBentoAccentStatCard(
                                theme: theme,
                                label: 'Resolved',
                                value: stats.resolved,
                                icon: LucideIcons.circleCheck,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
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
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
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
              const SizedBox(height: 12),
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
                        if (i > 0) const SizedBox(height: 10),
                        ComplaintCard(
                          complaint: recent[i],
                          onTap: () => context.go(
                            AppRoutes.studentComplaintDetailPath(
                              recent[i].id,
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


