import 'package:complaints/core/notifications/notification_service.dart';
import 'package:complaints/core/router/app_router.dart';
import 'package:complaints/core/widgets/async_value_widget.dart';
import 'package:complaints/features/complaints/models/complaint_model.dart';
import 'package:complaints/features/complaints/providers/complaint_detail_provider.dart';
import 'package:complaints/features/complaints/ui/widgets/comment_input.dart';
import 'package:complaints/features/complaints/ui/widgets/comment_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AdminComplaintDetailScreen extends ConsumerWidget {
  const AdminComplaintDetailScreen({required this.complaintId, super.key});
  final String complaintId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(complaintDetailProvider(complaintId));
    final commentsAsync = ref.watch(complaintCommentsProvider(complaintId));
    final theme = ShadTheme.of(context);

    // We can show a robust 2-column layout on desktop for admins
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        leading: ShadButton.ghost(
          onPressed: () => context.go(AppRoutes.adminComplaints),
          leading: const Icon(LucideIcons.arrowLeft),
        ),
        title: Text(
          'Complaint Details',
          style: theme.textTheme.small.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.foreground,
          ),
        ),
      ),
      body: AsyncValueWidget(
        value: detailAsync,
        onRetry: () => ref.invalidate(complaintDetailProvider(complaintId)),
        data: (complaint) {
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                // 2 Ccols for desktop
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ComplaintMainInfo(complaint: complaint),
                            const SizedBox(height: 32),
                            Text(
                              'Discussion Thread',
                              style: theme.textTheme.h4,
                            ),
                            const SizedBox(height: 16),
                            AsyncValueWidget(
                              value: commentsAsync,
                              data: (comments) =>
                                  CommentList(comments: comments),
                            ),
                            const SizedBox(height: 16),
                            CommentInput(complaintId: complaintId),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 300,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: theme.colorScheme.border),
                        ),
                        color: theme.colorScheme.card,
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: _AdminActionsSidebar(complaint: complaint),
                      ),
                    ),
                  ],
                );
              }

              // 1 col for mobile
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AdminActionsSidebar(
                      complaint: complaint,
                    ), // Action first on mobile
                    const SizedBox(height: 24),
                    _ComplaintMainInfo(complaint: complaint),
                    const SizedBox(height: 32),
                    Text('Discussion Thread', style: theme.textTheme.h4),
                    const SizedBox(height: 16),
                    AsyncValueWidget(
                      value: commentsAsync,
                      data: (comments) => CommentList(comments: comments),
                    ),
                    const SizedBox(height: 16),
                    CommentInput(complaintId: complaintId),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ComplaintMainInfo extends StatelessWidget {
  const _ComplaintMainInfo({required this.complaint});
  final ComplaintModel complaint;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(complaint.title, style: theme.textTheme.h2),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              LucideIcons.tag,
              size: 14,
              color: theme.colorScheme.mutedForeground,
            ),
            const SizedBox(width: 4),
            Text(complaint.category, style: theme.textTheme.small),
            const SizedBox(width: 16),
            Icon(
              LucideIcons.fingerprintPattern,
              size: 14,
              color: theme.colorScheme.mutedForeground,
            ),
            const SizedBox(width: 4),
            Text(
              complaint.id.split('-').first,
              style: theme.textTheme.small.copyWith(fontFamily: 'monospace'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.border),
          ),
          child: Text(
            complaint.description,
            style: theme.textTheme.p.copyWith(height: 1.6),
          ),
        ),
      ],
    );
  }
}

class _AdminActionsSidebar extends ConsumerWidget {
  const _AdminActionsSidebar({required this.complaint});
  final ComplaintModel complaint;

  Future<void> _updateStatus(
    BuildContext context,
    WidgetRef ref,
    ComplaintStatus status,
  ) async {
    final success = await ref
        .read(complaintDetailProvider(complaint.id).notifier)
        .updateStatus(status);

    if (!context.mounted) return;
    if (success) {
      NotificationService.showSuccess(
        context,
        'Status updated to ${status.label}',
      );
    } else {
      NotificationService.showError(context, 'Failed to update status.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manage Request',
          style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        // Status indicator
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CURRENT STATUS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    complaint.status.label,
                    style: theme.textTheme.p.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        Text(
          'UPDATE STATUS',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.mutedForeground,
          ),
        ),
        const SizedBox(height: 8),

        // Buttons
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: ComplaintStatus.values
              .where((s) => s != complaint.status)
              .map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ShadButton.outline(
                    size: ShadButtonSize.sm,
                    onPressed: () => _updateStatus(context, ref, s),
                    child: Text('Mark as ${s.label}'),
                  ),
                ),
              )
              .toList(),
        ),

        const SizedBox(height: 24),
        Divider(color: theme.colorScheme.border),
        const SizedBox(height: 16),

        Text(
          'STUDENT ID',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.mutedForeground,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          complaint.userId,
          style: theme.textTheme.small.copyWith(fontFamily: 'monospace'),
        ),

        if (complaint.createdAt != null) ...[
          const SizedBox(height: 16),
          Text(
            'SUBMITTED',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.mutedForeground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            complaint.createdAt!.toLocal().toString().split('.').first,
            style: theme.textTheme.small,
          ),
        ],
      ],
    );
  }
}
