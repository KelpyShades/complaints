import 'package:complaints/features/student/complaints/providers/student_complaint_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:complaints/core/router/app_router.dart';
import 'package:complaints/core/widgets/async_value_widget.dart';
import 'package:complaints/features/complaints/models/complaint_model.dart';
import 'package:complaints/features/complaints/ui/widgets/complaint_card.dart';

class StudentComplaintsScreen extends ConsumerWidget {
  const StudentComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(studentFilteredComplaintsProvider);
    final theme = ShadTheme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('My Complaints', style: theme.textTheme.h3)],
          ),
          const SizedBox(height: 16),

          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(label: 'All', value: null),
                const SizedBox(width: 8),
                _FilterChip(label: 'Pending', value: ComplaintStatus.pending),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'In Progress',
                  value: ComplaintStatus.inProgress,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: AsyncValueWidget(
              value: filteredAsync,
              onRetry: () => ref.invalidate(studentFilteredComplaintsProvider),
              data: (complaints) {
                if (complaints.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.inbox,
                          size: 48,
                          color: theme.colorScheme.mutedForeground,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'You have no complaints.',
                          style: theme.textTheme.muted,
                        ),
                      ],
                    ),
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

class _FilterChip extends ConsumerWidget {
  const _FilterChip({required this.label, required this.value});

  final String label;
  final ComplaintStatus? value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(studentComplaintStatusFilterProvider);
    final theme = ShadTheme.of(context);
    final isSelected = current == value;

    return ActionChip(
      label: Text(label),
      backgroundColor: isSelected
          ? theme.colorScheme.primary
          : theme.colorScheme.muted.withValues(alpha: 0.5),
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.primaryForeground
            : theme.colorScheme.foreground,
        fontSize: 12,
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onPressed: () =>
          ref.read(studentComplaintStatusFilterProvider.notifier).state = value,
    );
  }
}
