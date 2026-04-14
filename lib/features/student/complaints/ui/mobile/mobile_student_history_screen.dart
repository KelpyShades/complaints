import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:complaints/core/router/app_router.dart';
import 'package:complaints/core/widgets/async_value_widget.dart';
import 'package:complaints/features/shared/complaints/models/complaint_model.dart';
import 'package:complaints/features/shared/complaints/ui/widgets/complaint_card.dart';
import 'package:complaints/features/student/complaints/providers/student_complaint_list_provider.dart';
import 'package:complaints/features/student/complaints/ui/widgets/student_history_status_filter_bar.dart';

class MobileStudentHistoryScreen extends ConsumerWidget {
  const MobileStudentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final filteredAsync = ref.watch(studentFilteredHistoryComplaintsProvider);
    final allList = ref.watch(studentRawComplaintsProvider).valueOrNull;
    final statusFilter = ref.watch(studentHistoryStatusFilterProvider);

    return ColoredBox(
      color: theme.colorScheme.background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'History',
              style: theme.textTheme.h3.copyWith(
                letterSpacing: -0.5,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Every complaint in one place. Filter by status when you need to focus.',
              style: theme.textTheme.muted.copyWith(height: 1.35),
            ),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 6),
              child: Text(
                'STATUS',
                style: theme.textTheme.small.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  letterSpacing: 1.05,
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ),
            const StudentHistoryStatusFilterBar(),
            const SizedBox(height: 18),
            Expanded(
              child: AsyncValueWidget<List<ComplaintModel>>(
                value: filteredAsync,
                onRetry: () => ref.invalidate(studentRawComplaintsProvider),
                data: (complaints) {
                  if (complaints.isEmpty) {
                    return _HistoryEmptyState(
                      theme: theme,
                      hasAnyComplaints: (allList ?? []).isNotEmpty,
                      filterActive: statusFilter != null,
                    );
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: complaints.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final complaint = complaints[index];
                      return ComplaintCard(
                        complaint: complaint,
                        onTap: () => context.go(
                          AppRoutes.studentComplaintDetailPath(complaint.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryEmptyState extends StatelessWidget {
  const _HistoryEmptyState({
    required this.theme,
    required this.hasAnyComplaints,
    required this.filterActive,
  });

  final ShadThemeData theme;
  final bool hasAnyComplaints;
  final bool filterActive;

  @override
  Widget build(BuildContext context) {
    final title = filterActive && hasAnyComplaints
        ? 'Nothing in this filter'
        : 'No complaints yet';
    final subtitle = filterActive && hasAnyComplaints
        ? 'Try another status or choose All to see everything.'
        : 'When you file a complaint, it will appear here.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.colorScheme.border),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.foreground.withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  filterActive && hasAnyComplaints
                      ? LucideIcons.listX
                      : LucideIcons.inbox,
                  size: 44,
                  color: theme.colorScheme.mutedForeground.withValues(
                    alpha: 0.55,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.large.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.muted.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
