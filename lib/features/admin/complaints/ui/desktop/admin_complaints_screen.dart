import 'package:complaints/features/admin/complaints/providers/admin_complaint_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:complaints/core/router/app_router.dart';
import 'package:complaints/core/widgets/async_value_widget.dart';
import 'package:complaints/features/shared/complaints/models/complaint_model.dart';
import 'package:complaints/features/shared/complaints/ui/widgets/complaint_card.dart';

class AdminComplaintsScreen extends ConsumerWidget {
  const AdminComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(adminFilteredComplaintsProvider);
    final theme = ShadTheme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('All Complaints', style: theme.textTheme.h3),
          const SizedBox(height: 16),

          // Search and Filters
          Row(
            children: [
              Expanded(
                child: ShadInput(
                  placeholder: const Text(
                    'Search by title, desc or category...',
                  ),
                  leading: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(LucideIcons.search, size: 16),
                  ),
                  onChanged: (v) =>
                      ref
                              .read(adminComplaintSearchQueryProvider.notifier)
                              .state =
                          v,
                ),
              ),
              const SizedBox(width: 16),
              ShadSelect<ComplaintStatus?>(
                placeholder: const Text('Status'),
                options: [
                  ShadOption<ComplaintStatus?>(
                    value: null,
                    child: const Text('All Statuses'),
                  ),
                  ...ComplaintStatus.values.map(
                    (s) => ShadOption<ComplaintStatus?>(
                      value: s,
                      child: Text(s.label),
                    ),
                  ),
                ],
                selectedOptionBuilder: (context, value) {
                  if (value == null) return const Text('All Statuses');
                  return Text(value.label);
                },
                onChanged: (v) =>
                    ref
                            .read(adminComplaintStatusFilterProvider.notifier)
                            .state =
                        v,
              ),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: Material(
              color: Colors.transparent,
              child: AsyncValueWidget(
                value: filteredAsync,
                onRetry: () => ref.invalidate(adminFilteredComplaintsProvider),
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
                            'No complaints match your filters.',
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
                          AppRoutes.adminComplaintDetailPath(complaint.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
