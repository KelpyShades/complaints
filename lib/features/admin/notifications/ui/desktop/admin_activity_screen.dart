import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:complaints/core/router/app_router.dart';
import 'package:complaints/core/widgets/async_value_widget.dart';
import 'package:complaints/features/shared/activity/providers/activity_provider.dart';
import 'package:complaints/features/shared/activity/models/activity_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class AdminActivityScreen extends ConsumerStatefulWidget {
  const AdminActivityScreen({super.key});

  @override
  ConsumerState<AdminActivityScreen> createState() =>
      _AdminActivityScreenState();
}

class _AdminActivityScreenState extends ConsumerState<AdminActivityScreen> {
  @override
  Widget build(BuildContext context) {
    final activitiesAsync = ref.watch(activityListProvider);
    final theme = ShadTheme.of(context);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) return;
        ref.read(activityFeedOnScreenProvider.notifier).state = false;
        unawaited(
          persistActivityFeedLastSeen(ref, () => context.mounted),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('System Activity Log', style: theme.textTheme.h3),
            const SizedBox(height: 8),
            Text(
              'All actions performed across the entire system.',
              style: theme.textTheme.muted,
            ),
            const SizedBox(height: 24),

            Expanded(
              child: AsyncValueWidget(
                value: activitiesAsync,
                onRetry: () => ref.invalidate(activityListProvider),
                data: (activities) {
                  if (activities.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.bellOff,
                            size: 48,
                            color: theme.colorScheme.mutedForeground,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No activity recorded yet.',
                            style: theme.textTheme.muted,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: activities.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final activity = activities[index];
                      return _AdminActivityTile(activity: activity);
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

class _AdminActivityTile extends StatelessWidget {
  const _AdminActivityTile({required this.activity});
  final ActivityModel activity;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final isStatusChange = activity.type == 'status_changed';
    final isSubmitted = activity.type == 'complaint_submitted';

    return InkWell(
      onTap: () =>
          context.go(AppRoutes.adminComplaintDetailPath(activity.complaintId)),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.card,
          border: Border.all(color: theme.colorScheme.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isStatusChange
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : theme.colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isStatusChange
                    ? LucideIcons.activity
                    : isSubmitted
                        ? LucideIcons.send
                        : LucideIcons.messageSquare,
                size: 16,
                color: isStatusChange
                    ? theme.colorScheme.primary
                    : theme.colorScheme.secondaryForeground,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.complaintTitle,
                    style: theme.textTheme.small.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.message,
                    style: theme.textTheme.muted.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
            if (activity.createdAt != null)
              Text(
                timeago.format(activity.createdAt!),
                style: theme.textTheme.muted.copyWith(fontSize: 11),
              ),
          ],
        ),
      ),
    );
  }
}
