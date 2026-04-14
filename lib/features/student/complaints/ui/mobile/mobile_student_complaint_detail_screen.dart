import 'package:complaints/features/shared/complaints/ui/widgets/comment_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:complaints/core/push_notifications/notification_service.dart';
import 'package:complaints/core/router/app_router.dart';
import 'package:complaints/core/widgets/async_value_widget.dart';
import 'package:complaints/features/auth/providers/auth_provider.dart';
import 'package:complaints/features/shared/complaints/models/comment_model.dart';
import 'package:complaints/features/shared/complaints/models/complaint_attachment_model.dart';
import 'package:complaints/features/shared/complaints/models/complaint_model.dart';
import 'package:complaints/features/shared/complaints/providers/complaint_detail_provider.dart';
import 'package:complaints/features/shared/complaints/ui/widgets/complaint_audio_attachment_card.dart';
import 'package:complaints/features/shared/complaints/ui/widgets/complaint_status_badge.dart';

class MobileStudentComplaintDetailScreen extends ConsumerWidget {
  const MobileStudentComplaintDetailScreen({
    required this.complaintId,
    super.key,
  });
  final String complaintId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(complaintDetailProvider(complaintId));
    final commentsAsync = ref.watch(complaintCommentsProvider(complaintId));
    final theme = ShadTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 52,
        title: Align(
          alignment: Alignment.centerLeft,
          child: ShadButton.ghost(
            size: ShadButtonSize.sm,
            onPressed: () => context.go(AppRoutes.studentComplaints),
            leading: Icon(
              LucideIcons.arrowLeft,
              size: 20,
              color: theme.colorScheme.foreground,
            ),
          ),
        ),
      ),
      body: AsyncValueWidget(
        value: detailAsync,
        onRetry: () => ref.invalidate(complaintDetailProvider(complaintId)),
        data: (complaint) {
          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                      sliver: SliverList.list(
                        children: [
                          _DetailHeaderCard(complaint: complaint),
                          const SizedBox(height: 16),
                          _DetailDescriptionCard(complaint: complaint),
                          Consumer(
                            builder: (context, ref, _) {
                              final async = ref.watch(
                                complaintAttachmentsProvider(complaintId),
                              );
                              return async.when(
                                skipError: true,
                                skipLoadingOnReload: true,
                                skipLoadingOnRefresh: true,
                                data: (list) {
                                  ComplaintAttachmentModel? audio;
                                  for (final a in list) {
                                    if (a.type == ComplaintAttachmentType.audio) {
                                      audio = a;
                                      break;
                                    }
                                  }
                                  if (audio == null) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 14),
                                    child: ComplaintAudioAttachmentCard(
                                      attachment: audio,
                                    ),
                                  );
                                },
                                loading: () => const SizedBox.shrink(),
                                error: (_, _) => const SizedBox.shrink(),
                              );
                            },
                          ),
                          Consumer(
                            builder: (context, ref, _) {
                              final isOwner =
                                  ref.watch(currentUserIdProvider) ==
                                  complaint.userId;
                              if (!isOwner ||
                                  complaint.status != ComplaintStatus.pending) {
                                return const SizedBox.shrink();
                              }

                              return Padding(
                                padding: const EdgeInsets.only(top: 14),
                                child: ShadButton.outline(
                                  onPressed: () =>
                                      _delete(context, ref, complaint.id),
                                  size: ShadButtonSize.sm,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        LucideIcons.trash2,
                                        size: 16,
                                        color: theme.colorScheme.destructive,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Withdraw',
                                        style: theme.textTheme.small.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.destructive,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 28),
                          AsyncValueWidget<List<CommentModel>>(
                            value: commentsAsync,
                            onRetry: () => ref.invalidate(
                              complaintCommentsProvider(complaintId),
                            ),
                            data: (comments) =>
                                _UpdatesSection(comments: comments),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // _StickyCommentComposer(complaintId: complaintId),
            ],
          );
        },
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, String id) async {
    final success = await ref
        .read(complaintDetailProvider(id).notifier)
        .delete();
    if (!context.mounted) return;
    if (success) {
      NotificationService.showSuccess(context, 'Request withdrawn.');
      context.go(AppRoutes.studentComplaints);
    } else {
      NotificationService.showError(context, 'Failed to withdraw request.');
    }
  }
}

class _DetailHeaderCard extends StatelessWidget {
  const _DetailHeaderCard({required this.complaint});

  final ComplaintModel complaint;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.border.withValues(alpha: 0.9),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.foreground.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    complaint.title,
                    style: theme.textTheme.h3.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.65,
                      height: 1.08,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ComplaintStatusBadge(status: complaint.status),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _heroMetaLine(complaint),
              style: theme.textTheme.muted.copyWith(fontSize: 13, height: 1.35),
            ),
            const SizedBox(height: 18),
            _StageBar(status: complaint.status),
          ],
        ),
      ),
    );
  }
}

class _DetailDescriptionCard extends StatelessWidget {
  const _DetailDescriptionCard({required this.complaint});

  final ComplaintModel complaint;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.border.withValues(alpha: 0.9),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Complaint details',
              style: theme.textTheme.small.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: theme.colorScheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 12),
            SelectableText(
              complaint.description,
              style: theme.textTheme.p.copyWith(
                height: 1.55,
                letterSpacing: -0.04,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpdatesSection extends StatelessWidget {
  const _UpdatesSection({required this.comments});

  final List<CommentModel> comments;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'Updates',
              style: theme.textTheme.large.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.35,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.muted,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${comments.length}',
                style: theme.textTheme.small.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'All review notes will show up here.',
          style: theme.textTheme.muted.copyWith(height: 1.35),
        ),
        const SizedBox(height: 14),
        CommentList(comments: comments),
      ],
    );
  }
}

// class _StickyCommentComposer extends StatelessWidget {
//   const _StickyCommentComposer({required this.complaintId});

//   final String complaintId;

//   @override
//   Widget build(BuildContext context) {
//     final theme = ShadTheme.of(context);

//     return DecoratedBox(
//       decoration: BoxDecoration(
//         color: theme.colorScheme.background,
//         border: Border(
//           top: BorderSide(
//             color: theme.colorScheme.border.withValues(alpha: 0.9),
//           ),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: theme.colorScheme.foreground.withValues(alpha: 0.03),
//             blurRadius: 18,
//             offset: const Offset(0, -6),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         top: false,
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
//           child: CommentInput(complaintId: complaintId),
//         ),
//       ),
//     );
//   }
// }

String _heroMetaLine(ComplaintModel complaint) {
  final date = complaint.createdAt;
  final dateStr = date == null
      ? ''
      : DateFormat.yMMMd().add_jm().format(date.toLocal());
  final parts = <String>[complaint.category];
  if (dateStr.isNotEmpty) parts.add(dateStr);
  return parts.join(' · ');
}

class _StageBar extends StatelessWidget {
  const _StageBar({required this.status});
  final ComplaintStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    final fill = switch (status) {
      ComplaintStatus.pending => 1 / 3,
      ComplaintStatus.inProgress => 2 / 3,
      ComplaintStatus.resolved => 1.0,
      ComplaintStatus.rejected => 1.0,
    };

    final barColor = status == ComplaintStatus.rejected
        ? theme.colorScheme.destructive
        : theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: fill,
            minHeight: 4,
            backgroundColor: theme.colorScheme.border.withValues(alpha: 0.55),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _stageCaption(status),
          style: theme.textTheme.muted.copyWith(fontSize: 12, height: 1.3),
        ),
      ],
    );
  }
}

String _stageCaption(ComplaintStatus status) {
  return switch (status) {
    ComplaintStatus.pending => 'Received — we will pick this up soon.',
    ComplaintStatus.inProgress => 'In progress — the team is working on it.',
    ComplaintStatus.resolved => 'Resolved — no further action needed.',
    ComplaintStatus.rejected => 'This request was not accepted.',
  };
}
