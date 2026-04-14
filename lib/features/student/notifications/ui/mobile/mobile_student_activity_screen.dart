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

class MobileStudentActivityScreen extends ConsumerStatefulWidget {
  const MobileStudentActivityScreen({super.key});

  @override
  ConsumerState<MobileStudentActivityScreen> createState() =>
      _MobileStudentActivityScreenState();
}

class _MobileStudentActivityScreenState
    extends ConsumerState<MobileStudentActivityScreen> {
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
            Text('History & Updates', style: theme.textTheme.h3),
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
                      return _MobileStudentActivityTimelineItem(
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

class _MobileStudentActivityTimelineItem extends StatelessWidget {
  const _MobileStudentActivityTimelineItem({
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
    final isUnread = activityAppearsUnread(
      activity,
      lastSeenActivitiesAt,
      browsingFeed: browsingFeed,
    );
    final isStatusChange = activity.type == 'status_changed';
    final isSubmitted = activity.type == 'complaint_submitted';

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Material(
        color: isUnread
            ? Color.alphaBlend(
                theme.colorScheme.primary.withValues(alpha: 0.06),
                theme.colorScheme.card,
              )
            : theme.colorScheme.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isUnread
                ? theme.colorScheme.primary.withValues(alpha: 0.22)
                : theme.colorScheme.border,
          ),
        ),
        child: InkWell(
          onTap: () => context.go(
            AppRoutes.studentComplaintDetailPath(activity.complaintId),
          ),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: isStatusChange
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : theme.colorScheme.muted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      isStatusChange
                          ? LucideIcons.activity
                          : isSubmitted
                              ? LucideIcons.send
                              : LucideIcons.messageSquare,
                      size: 15,
                      color: isStatusChange
                          ? theme.colorScheme.primary
                          : theme.colorScheme.mutedForeground,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              activity.complaintTitle,
                              style: theme.textTheme.small.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (activity.createdAt != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              timeago.format(activity.createdAt!),
                              style: theme.textTheme.muted.copyWith(
                                fontSize: 11,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        activity.message,
                        style: theme.textTheme.muted.copyWith(
                          fontSize: 13,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4, top: 2),
                  child: Icon(
                    LucideIcons.chevronRight,
                    size: 18,
                    color: theme.colorScheme.mutedForeground.withValues(
                      alpha: 0.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
