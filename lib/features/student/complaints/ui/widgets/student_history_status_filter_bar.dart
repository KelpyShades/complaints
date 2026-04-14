import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:complaints/features/shared/complaints/models/complaint_model.dart';
import 'package:complaints/features/student/complaints/providers/student_complaint_list_provider.dart';

/// Horizontally scrollable status chips for the student History views.
class StudentHistoryStatusFilterBar extends ConsumerWidget {
  const StudentHistoryStatusFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final selected = ref.watch(studentHistoryStatusFilterProvider);
    final all = ref.watch(studentRawComplaintsProvider).valueOrNull;

    int countFor(ComplaintStatus? status) {
      if (all == null) return 0;
      if (status == null) return all.length;
      return all.where((c) => c.status == status).length;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _HistoryFilterChip(
            theme: theme,
            label: 'All',
            count: countFor(null),
            selected: selected == null,
            onTap: () =>
                ref.read(studentHistoryStatusFilterProvider.notifier).state =
                    null,
          ),
          for (final status in ComplaintStatus.values) ...[
            const SizedBox(width: 8),
            _HistoryFilterChip(
              theme: theme,
              label: status.label,
              count: countFor(status),
              selected: selected == status,
              onTap: () => ref
                  .read(studentHistoryStatusFilterProvider.notifier)
                  .state = status,
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryFilterChip extends StatelessWidget {
  const _HistoryFilterChip({
    required this.theme,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final ShadThemeData theme;
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.card,
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.border,
              width: 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.22),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: theme.colorScheme.foreground.withValues(
                        alpha: 0.04,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.small.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                  color: selected
                      ? theme.colorScheme.primaryForeground
                      : theme.colorScheme.foreground,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: selected
                        ? theme.colorScheme.primaryForeground.withValues(
                            alpha: 0.2,
                          )
                        : theme.colorScheme.muted,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$count',
                    style: theme.textTheme.muted.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? theme.colorScheme.primaryForeground
                          : theme.colorScheme.mutedForeground,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
