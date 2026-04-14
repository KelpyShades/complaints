import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:complaints/core/router/app_router.dart';
import 'package:complaints/core/widgets/async_value_widget.dart';
import 'package:complaints/features/admin/complaints/providers/admin_complaint_list_provider.dart';
import 'package:complaints/features/shared/complaints/models/complaint_model.dart';
import 'package:complaints/features/shared/complaints/ui/widgets/complaint_card.dart';

/// Mobile admin complaints — filters + [ComplaintCard] list (student-style tiles).
class MobileAdminComplaintsScreen extends ConsumerWidget {
  const MobileAdminComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(adminFilteredComplaintsProvider);
    final theme = ShadTheme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All complaints',
            style: theme.textTheme.h3.copyWith(
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Search and filter every submission.',
            style: theme.textTheme.muted.copyWith(fontSize: 13, height: 1.35),
          ),
          const SizedBox(height: 20),
          ShadInput(
            placeholder: const Text('Search by title, description or category…'),
            leading: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(LucideIcons.search, size: 16),
            ),
            onChanged: (v) =>
                ref.read(adminComplaintSearchQueryProvider.notifier).state = v,
          ),
          const SizedBox(height: 12),
          ShadSelect<ComplaintStatus?>(
            placeholder: const Text('Status'),
            options: [
              ShadOption<ComplaintStatus?>(
                value: null,
                child: const Text('All statuses'),
              ),
              ...ComplaintStatus.values.map(
                (s) => ShadOption<ComplaintStatus?>(
                  value: s,
                  child: Text(s.label),
                ),
              ),
            ],
            selectedOptionBuilder: (context, value) {
              if (value == null) return const Text('All statuses');
              return Text(value.label);
            },
            onChanged: (v) =>
                ref.read(adminComplaintStatusFilterProvider.notifier).state = v,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: AsyncValueWidget<List<ComplaintModel>>(
                value: filteredAsync,
                onRetry: () => ref.invalidate(adminFilteredComplaintsProvider),
                data: (complaints) {
                  if (complaints.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: theme.colorScheme.border),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 40,
                              horizontal: 20,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.inbox,
                                  size: 44,
                                  color: theme.colorScheme.mutedForeground
                                      .withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'No matches',
                                  style: theme.textTheme.large.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Try a different search or status filter.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.muted.copyWith(
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: complaints.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
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
