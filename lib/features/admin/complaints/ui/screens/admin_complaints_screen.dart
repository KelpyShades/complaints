import 'package:complaints/features/admin/complaints/providers/admin_complaint_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:complaints/core/router/app_router.dart';
import 'package:complaints/core/widgets/async_value_widget.dart';
import 'package:complaints/features/complaints/models/complaint_model.dart';

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
                    separatorBuilder: (_, _) =>
                        Divider(color: theme.colorScheme.border),
                    itemBuilder: (context, index) {
                      final complaint = complaints[index];
                      return InkWell(
                        onTap: () => context.go(
                          AppRoutes.adminComplaintDetailPath(complaint.id),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      complaint.title,
                                      style: theme.textTheme.p.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      complaint.id.split('-').first,
                                      style: theme.textTheme.muted.copyWith(
                                        fontSize: 10,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  complaint.category,
                                  style: theme.textTheme.small,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  complaint.createdAt != null
                                      ? '${complaint.createdAt!.day}/${complaint.createdAt!.month}/${complaint.createdAt!.year}'
                                      : '',
                                  style: theme.textTheme.small.copyWith(
                                    color: theme.colorScheme.mutedForeground,
                                  ),
                                ),
                              ),
                              _AdminStatusBadge(status: complaint.status),
                            ],
                          ),
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

class _AdminStatusBadge extends StatelessWidget {
  const _AdminStatusBadge({required this.status});
  final ComplaintStatus status;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (status) {
      case ComplaintStatus.pending:
        bg = Colors.orange.withValues(alpha: 0.2);
        fg = Colors.orange;
      case ComplaintStatus.inProgress:
        bg = Colors.blue.withValues(alpha: 0.2);
        fg = Colors.blue;
      case ComplaintStatus.resolved:
        bg = Colors.green.withValues(alpha: 0.2);
        fg = Colors.green;
      case ComplaintStatus.rejected:
        bg = Colors.red.withValues(alpha: 0.2);
        fg = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
