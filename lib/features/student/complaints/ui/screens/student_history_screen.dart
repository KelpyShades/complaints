import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:complaints/core/router/app_router.dart';
import 'package:complaints/core/widgets/async_value_widget.dart';
import 'package:complaints/features/complaints/models/complaint_model.dart';
import 'package:complaints/features/complaints/ui/widgets/complaint_card.dart';
import 'package:complaints/features/student/complaints/providers/student_complaint_list_provider.dart';

class StudentHistoryScreen extends ConsumerWidget {
  const StudentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(studentHistoryComplaintsProvider);
    final theme = ShadTheme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('History', style: theme.textTheme.h3),
          const SizedBox(height: 8),
          Text(
            'Your resolved or rejected complaints.',
            style: theme.textTheme.muted,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: AsyncValueWidget<List<ComplaintModel>>(
              value: historyAsync,
              onRetry: () => ref.invalidate(studentHistoryComplaintsProvider),
              data: (complaints) {
                if (complaints.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.history,
                          size: 48,
                          color: theme.colorScheme.mutedForeground,
                        ),
                        const SizedBox(height: 12),
                        Text('No history found.', style: theme.textTheme.muted),
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
