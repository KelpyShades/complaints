import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:complaints/core/router/app_router.dart';
import 'package:complaints/core/widgets/async_value_widget.dart';
import 'package:complaints/features/auth/providers/auth_provider.dart';
import 'package:complaints/features/shared/activity/providers/activity_provider.dart';
import 'package:complaints/features/shared/activity/models/activity_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class StudentActivityScreen extends ConsumerStatefulWidget {
  const StudentActivityScreen({super.key});

  @override
  ConsumerState<StudentActivityScreen> createState() =>
      _StudentActivityScreenState();
}

class _StudentActivityScreenState extends ConsumerState<StudentActivityScreen> {
  @override
  Widget build(BuildContext context) {
    final activitiesAsync = ref.watch(activityListProvider);
    final theme = ShadTheme.of(context);
    final user = ref.watch(currentUserProvider).valueOrNull;
    final browsingFeed = ref.watch(activityFeedOnScreenProvider);

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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(LucideIcons.bell, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Text('History & Updates', style: theme.textTheme.h3),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Timeline of actions on your complaints.',
              style: theme.textTheme.muted,
            ),
            const SizedBox(height: 32),

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
                            LucideIcons.mailX,
                            size: 48,
                            color: theme.colorScheme.mutedForeground.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No updates yet.',
                            style: theme.textTheme.large.copyWith(
                              color: theme.colorScheme.mutedForeground,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'We will notify you when there is progress.',
                            style: theme.textTheme.muted,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: activities.length,
                    itemBuilder: (context, index) {
                      final activity = activities[index];
                      return _StudentActivityTimelineItem(
                        activity: activity,
                        isLast: index == activities.length - 1,
                        lastSeenActivitiesAt: user?.lastSeenActivitiesAt,
                        browsingFeed: browsingFeed,
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

class _StudentActivityTimelineItem extends StatelessWidget {
  const _StudentActivityTimelineItem({
    required this.activity,
    required this.isLast,
    required this.lastSeenActivitiesAt,
    required this.browsingFeed,
  });
  final ActivityModel activity;
  final bool isLast;
  final DateTime? lastSeenActivitiesAt;
  final bool browsingFeed;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final isStatus = activity.type == 'status_changed';
    final isSubmitted = activity.type == 'complaint_submitted';
    final isUnread = activityAppearsUnread(
      activity,
      lastSeenActivitiesAt,
      browsingFeed: browsingFeed,
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline line + icon
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isStatus
                        ? theme.colorScheme.primary
                        : theme.colorScheme.card,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isStatus
                          ? Colors.transparent
                          : theme.colorScheme.border,
                    ),
                  ),
                  child: Icon(
                    isStatus
                        ? LucideIcons.refreshCw
                        : isSubmitted
                            ? LucideIcons.send
                            : LucideIcons.messageCircle,
                    size: 14,
                    color: isStatus
                        ? theme.colorScheme.primaryForeground
                        : theme.colorScheme.foreground,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: theme.colorScheme.border),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: GestureDetector(
                onTap: () => context.go(
                  AppRoutes.studentComplaintDetailPath(activity.complaintId),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.card,
                    borderRadius: BorderRadius.circular(16),
                    border: isUnread
                        ? Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.5,
                            ),
                            width: 1.5,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              activity.complaintTitle,
                              style: theme.textTheme.small.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (activity.createdAt != null)
                            Text(
                              timeago.format(activity.createdAt!),
                              style: theme.textTheme.muted.copyWith(
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(activity.message, style: theme.textTheme.p),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
