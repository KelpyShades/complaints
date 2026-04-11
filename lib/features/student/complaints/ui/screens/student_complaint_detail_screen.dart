import 'package:complaints/features/complaints/ui/widgets/comment_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:complaints/core/notifications/notification_service.dart';
import 'package:complaints/core/router/app_router.dart';
import 'package:complaints/core/widgets/async_value_widget.dart';
import 'package:complaints/features/auth/providers/auth_provider.dart';
import 'package:complaints/features/complaints/models/complaint_model.dart';
import 'package:complaints/features/complaints/providers/complaint_detail_provider.dart';
import 'package:complaints/features/complaints/ui/widgets/comment_input.dart';

class StudentComplaintDetailScreen extends ConsumerWidget {
  const StudentComplaintDetailScreen({required this.complaintId, super.key});
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
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            LucideIcons.arrowLeft,
            color: theme.colorScheme.foreground,
          ),
          onPressed: () => context.go(AppRoutes.studentComplaints),
        ),
        title: Text(
          'Request Details',
          style: theme.textTheme.p.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.foreground,
          ),
        ),
      ),
      body: AsyncValueWidget(
        value: detailAsync,
        onRetry: () => ref.invalidate(complaintDetailProvider(complaintId)),
        data: (complaint) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StudentStatusStepper(status: complaint.status),
                  const SizedBox(height: 32),

                  Text(complaint.title, style: theme.textTheme.h3),
                  const SizedBox(height: 8),
                  Text(
                    '${complaint.category} • Submitted ${_formatDate(complaint.createdAt)}',
                    style: theme.textTheme.muted,
                  ),
                  const SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white, // Pop against off-white bg
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      complaint.description,
                      style: theme.textTheme.p.copyWith(height: 1.6),
                    ),
                  ),

                  // Student can delete own pending complaints
                  Consumer(
                    builder: (context, ref, _) {
                      final isOwner =
                          ref.watch(currentUserIdProvider) == complaint.userId;
                      if (!isOwner ||
                          complaint.status != ComplaintStatus.pending) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: ShadButton.outline(
                          onPressed: () => _delete(context, ref, complaint.id),
                          size: ShadButtonSize.sm,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.trash2,
                                size: 14,
                                color: Colors.red,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Withdraw Request',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 48),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          LucideIcons.messageSquare,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('Communication', style: theme.textTheme.h4),
                    ],
                  ),
                  const SizedBox(height: 16),

                  AsyncValueWidget(
                    value: commentsAsync,
                    data: (comments) => CommentList(comments: comments),
                  ),
                  const SizedBox(height: 16),
                  CommentInput(complaintId: complaintId),
                ],
              ),
            ),
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StudentStatusStepper extends StatelessWidget {
  const _StudentStatusStepper({required this.status});
  final ComplaintStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    // Determine step active state
    bool isPendingActive = true;
    bool isInProgressActive =
        status == ComplaintStatus.inProgress ||
        status == ComplaintStatus.resolved ||
        status == ComplaintStatus.rejected;
    bool isDoneActive =
        status == ComplaintStatus.resolved ||
        status == ComplaintStatus.rejected;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _StepIndicator(
            label: 'Submitted',
            isActive: isPendingActive,
            icon: LucideIcons.fileText,
          ),
          _StepConnector(isActive: isInProgressActive),
          _StepIndicator(
            label: 'Reviewed',
            isActive: isInProgressActive,
            icon: LucideIcons.search,
          ),
          _StepConnector(isActive: isDoneActive),
          _StepIndicator(
            label: status == ComplaintStatus.rejected ? 'Rejected' : 'Resolved',
            isActive: isDoneActive,
            icon: status == ComplaintStatus.rejected
                ? LucideIcons.circleX
                : LucideIcons.circleCheck,
            isError: status == ComplaintStatus.rejected,
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.label,
    required this.isActive,
    required this.icon,
    this.isError = false,
  });
  final String label;
  final bool isActive;
  final IconData icon;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final color = isError && isActive
        ? Colors.red
        : (isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.mutedForeground.withValues(alpha: 0.3));

    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive
                ? color.withValues(alpha: 0.15)
                : Colors.transparent,
            border: Border.all(color: color, width: isActive ? 2 : 1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.muted.copyWith(
            fontSize: 10,
            color: isActive ? theme.colorScheme.foreground : null,
          ),
        ),
      ],
    );
  }
}

class _StepConnector extends StatelessWidget {
  const _StepConnector({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        color: isActive ? theme.colorScheme.primary : theme.colorScheme.border,
      ),
    );
  }
}
