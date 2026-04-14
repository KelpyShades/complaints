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

class StudentHistoryScreen extends ConsumerWidget {
  const StudentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final filteredAsync = ref.watch(studentFilteredHistoryComplaintsProvider);
    final allList = ref.watch(studentRawComplaintsProvider).valueOrNull;
    final statusFilter = ref.watch(studentHistoryStatusFilterProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'History',
            style: theme.textTheme.h3.copyWith(letterSpacing: -0.4),
          ),
          const SizedBox(height: 8),
          Text(
            'Every complaint, with optional status filters.',
            style: theme.textTheme.muted,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
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
          const SizedBox(height: 20),
          Expanded(
            child: AsyncValueWidget<List<ComplaintModel>>(
              value: filteredAsync,
              onRetry: () => ref.invalidate(studentRawComplaintsProvider),
              data: (complaints) {
                if (complaints.isEmpty) {
                  return _DesktopHistoryEmpty(
                    theme: theme,
                    hasAnyComplaints: (allList ?? []).isNotEmpty,
                    filterActive: statusFilter != null,
                  );
                }

                return ListView.separated(
                  itemCount: complaints.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
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
    );
  }
}

class _DesktopHistoryEmpty extends StatelessWidget {
  const _DesktopHistoryEmpty({
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
        ? 'Try another status or choose All.'
        : 'File a complaint from the Complaints tab to see it here.';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  filterActive && hasAnyComplaints
                      ? LucideIcons.listX
                      : LucideIcons.inbox,
                  size: 40,
                  color: theme.colorScheme.mutedForeground.withValues(
                    alpha: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.large.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.muted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
