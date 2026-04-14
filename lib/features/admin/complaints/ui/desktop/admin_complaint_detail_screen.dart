import 'package:complaints/core/push_notifications/notification_service.dart';
import 'package:complaints/core/router/app_router.dart';
import 'package:complaints/core/widgets/async_value_widget.dart';
import 'package:complaints/features/shared/complaints/models/comment_model.dart';
import 'package:complaints/features/shared/complaints/models/complaint_attachment_model.dart';
import 'package:complaints/features/shared/complaints/models/complaint_model.dart';
import 'package:complaints/features/shared/complaints/providers/complaint_detail_provider.dart';
import 'package:complaints/features/shared/complaints/ui/widgets/complaint_audio_attachment_card.dart';
import 'package:complaints/features/shared/complaints/ui/widgets/comment_input.dart';
import 'package:complaints/features/shared/complaints/ui/widgets/comment_list.dart';
import 'package:complaints/features/shared/complaints/ui/widgets/complaint_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AdminComplaintDetailScreen extends ConsumerWidget {
  const AdminComplaintDetailScreen({required this.complaintId, super.key});
  final String complaintId;

  static const double _wideBreakpoint = 880;

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
        leadingWidth: 48,
        leading: Center(
          child: ShadButton.ghost(
            size: ShadButtonSize.sm,
            onPressed: () => context.go(AppRoutes.adminComplaints),
            leading: Icon(
              LucideIcons.arrowLeft,
              size: 20,
              color: theme.colorScheme.foreground,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Case review',
              style: theme.textTheme.small.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
                color: theme.colorScheme.foreground,
              ),
            ),
            Text(
              'Complaint · ${complaintId.split('-').first}',
              style: theme.textTheme.muted.copyWith(fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: AsyncValueWidget(
        value: detailAsync,
        onRetry: () => ref.invalidate(complaintDetailProvider(complaintId)),
        data: (complaint) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > _wideBreakpoint;

              final mainColumn = SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  isWide ? 28 : 20,
                  8,
                  isWide ? 20 : 20,
                  32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _CaseHero(complaint: complaint),
                    const SizedBox(height: 28),
                    _DiscussionSection(
                      complaintId: complaintId,
                      commentsAsync: commentsAsync,
                    ),
                  ],
                ),
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: mainColumn),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 20, 24),
                      child: SizedBox(
                        width: 312,
                        child: _AdminSidePanel(complaint: complaint),
                      ),
                    ),
                  ],
                );
              }

              final keyboard = MediaQuery.viewInsetsOf(context).bottom;
              final fabBottom =
                  118 + keyboard + MediaQuery.viewPaddingOf(context).bottom;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: CustomScrollView(
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                              sliver: SliverList.list(
                                children: [
                                  _AdminMobileHeaderCard(complaint: complaint),
                                  const SizedBox(height: 16),
                                  _AdminMobileDescriptionCard(
                                    complaint: complaint,
                                  ),
                                  _ComplaintAudioAttachmentSection(
                                    complaintId: complaintId,
                                  ),
                                  const SizedBox(height: 28),
                                  _DiscussionSection(
                                    complaintId: complaintId,
                                    commentsAsync: commentsAsync,
                                    showCommentComposer: false,
                                    useCardChrome: false,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _StickyAdminCommentBar(complaintId: complaintId),
                    ],
                  ),
                  Positioned(
                    right: 14,
                    bottom: fabBottom,
                    child: _AdminNarrowStatusFabColumn(complaint: complaint),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _CaseHero extends StatelessWidget {
  const _CaseHero({required this.complaint});
  final ComplaintModel complaint;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final shortId = complaint.id.split('-').first;
    final submitted = complaint.createdAt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                complaint.title,
                style: theme.textTheme.h3.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                  height: 1.12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ComplaintStatusBadge(status: complaint.status),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MetaChip(
              theme: theme,
              icon: LucideIcons.folderTree,
              label: complaint.category,
            ),
            _MetaChip(
              theme: theme,
              icon: LucideIcons.idCard,
              label: shortId,
              mono: true,
            ),
            if (submitted != null)
              _MetaChip(
                theme: theme,
                icon: LucideIcons.calendarPlus,
                label: DateFormat.yMMMd().add_jm().format(submitted.toLocal()),
              ),
          ],
        ),
        const SizedBox(height: 22),
        _DescriptionCard(complaint: complaint),
        _ComplaintAudioAttachmentSection(complaintId: complaint.id),
      ],
    );
  }
}

class _ComplaintAudioAttachmentSection extends ConsumerWidget {
  const _ComplaintAudioAttachmentSection({required this.complaintId});

  final String complaintId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(complaintAttachmentsProvider(complaintId));
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
        if (audio == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: ComplaintAudioAttachmentCard(attachment: audio),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.theme,
    required this.icon,
    required this.label,
    this.mono = false,
  });

  final ShadThemeData theme;
  final IconData icon;
  final String label;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.border.withValues(alpha: 0.9),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: theme.colorScheme.mutedForeground),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.small.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: mono ? 0 : -0.1,
                  fontFamily: mono ? 'monospace' : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.complaint});
  final ComplaintModel complaint;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final accent = _statusStripColor(theme, complaint.status);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.foreground.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: theme.colorScheme.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: theme.colorScheme.border),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: accent),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DESCRIPTION',
                          style: theme.textTheme.small.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                            letterSpacing: 1.1,
                            color: theme.colorScheme.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SelectableText(
                          complaint.description,
                          style: theme.textTheme.p.copyWith(
                            height: 1.55,
                            letterSpacing: -0.05,
                          ),
                        ),
                      ],
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

class _DiscussionSection extends ConsumerWidget {
  const _DiscussionSection({
    required this.complaintId,
    required this.commentsAsync,
    this.showCommentComposer = true,
    this.useCardChrome = true,
  });

  final String complaintId;
  final AsyncValue<List<CommentModel>> commentsAsync;
  final bool showCommentComposer;
  final bool useCardChrome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);

    final thread = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (useCardChrome) ...[
          Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    LucideIcons.messagesSquare,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discussion',
                      style: theme.textTheme.h4.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Text(
                      'Thread with the student',
                      style: theme.textTheme.muted.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: theme.colorScheme.border.withValues(alpha: 0.85),
          ),
          const SizedBox(height: 12),
        ] else ...[
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
                  '${commentsAsync.valueOrNull?.length ?? 0}',
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
            'Notes and replies appear below.',
            style: theme.textTheme.muted.copyWith(height: 1.35),
          ),
          const SizedBox(height: 14),
        ],
        AsyncValueWidget<List<CommentModel>>(
          value: commentsAsync,
          onRetry: () => ref.invalidate(complaintCommentsProvider(complaintId)),
          data: (comments) => CommentList(comments: comments),
        ),
        if (showCommentComposer) ...[
          const SizedBox(height: 8),
          CommentInput(complaintId: complaintId),
        ],
      ],
    );

    if (!useCardChrome) return thread;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.border),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.foreground.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: thread,
      ),
    );
  }
}

class _AdminSidePanel extends ConsumerWidget {
  const _AdminSidePanel({required this.complaint});
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
    final targets = ComplaintStatus.values
        .where((s) => s != complaint.status)
        .toList();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.border),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.foreground.withValues(alpha: 0.05),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'WORKFLOW',
              style: theme.textTheme.small.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 10,
                letterSpacing: 1.05,
                color: theme.colorScheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _statusPanelBackground(theme, complaint.status),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _statusPanelBorder(theme, complaint.status),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current status',
                    style: theme.textTheme.muted.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _statusStripColor(theme, complaint.status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          complaint.status.label,
                          style: theme.textTheme.p.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      ComplaintStatusBadge(status: complaint.status),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'SET STATUS',
              style: theme.textTheme.small.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 10,
                letterSpacing: 1.05,
                color: theme.colorScheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 10),
            for (final s in targets) ...[
              _StatusActionTile(
                theme: theme,
                status: s,
                onPressed: () => _updateStatus(context, ref, s),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 8),
            Divider(
              height: 1,
              color: theme.colorScheme.border.withValues(alpha: 0.85),
            ),
            const SizedBox(height: 16),
            Text(
              'RECORD',
              style: theme.textTheme.small.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 10,
                letterSpacing: 1.05,
                color: theme.colorScheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 10),
            _RecordTile(
              theme: theme,
              icon: LucideIcons.userRound,
              label: 'Reporter user ID',
              value: complaint.userId,
            ),
            if (complaint.createdAt != null) ...[
              const SizedBox(height: 10),
              _RecordTile(
                theme: theme,
                icon: LucideIcons.calendarClock,
                label: 'Submitted',
                value: DateFormat.yMMMd().add_jm().format(
                  complaint.createdAt!.toLocal(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusActionTile extends StatelessWidget {
  const _StatusActionTile({
    required this.theme,
    required this.status,
    required this.onPressed,
  });

  final ShadThemeData theme;
  final ComplaintStatus status;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final icon = _statusActionIcon(status);
    final subtle = _statusStripColor(theme, status).withValues(alpha: 0.12);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: theme.colorScheme.background,
            border: Border.all(color: theme.colorScheme.border),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: subtle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      icon,
                      size: 18,
                      color: _statusStripColor(theme, status),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mark as ${status.label}',
                        style: theme.textTheme.small.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.15,
                        ),
                      ),
                      Text(
                        _statusActionHint(status),
                        style: theme.textTheme.muted.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: theme.colorScheme.mutedForeground.withValues(
                    alpha: 0.45,
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

class _RecordTile extends StatelessWidget {
  const _RecordTile({
    required this.theme,
    required this.icon,
    required this.label,
    required this.value,
  });

  final ShadThemeData theme;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.muted.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.border.withValues(alpha: 0.7),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.mutedForeground),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.muted.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    value,
                    style: theme.textTheme.small.copyWith(
                      fontFamily: 'monospace',
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Narrow (mobile) layout — student-style cards + workflow FABs ─────────

class _AdminMobileHeaderCard extends StatelessWidget {
  const _AdminMobileHeaderCard({required this.complaint});

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
              _adminMobileHeroMetaLine(complaint),
              style: theme.textTheme.muted.copyWith(fontSize: 13, height: 1.35),
            ),
            const SizedBox(height: 18),
            _AdminMobileStageBar(status: complaint.status),
          ],
        ),
      ),
    );
  }
}

class _AdminMobileDescriptionCard extends StatelessWidget {
  const _AdminMobileDescriptionCard({required this.complaint});

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
              'Details',
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

class _StickyAdminCommentBar extends StatelessWidget {
  const _StickyAdminCommentBar({required this.complaintId});

  final String complaintId;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.border.withValues(alpha: 0.9),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.foreground.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: CommentInput(complaintId: complaintId),
        ),
      ),
    );
  }
}

class _AdminNarrowStatusFabColumn extends ConsumerWidget {
  const _AdminNarrowStatusFabColumn({required this.complaint});

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
    final targets = ComplaintStatus.values
        .where((s) => s != complaint.status)
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < targets.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'admin_status_${complaint.id}_${targets[i].name}',
            tooltip: 'Mark as ${targets[i].label}',
            backgroundColor: theme.colorScheme.card,
            foregroundColor: theme.colorScheme.foreground,
            onPressed: () => _updateStatus(context, ref, targets[i]),
            child: Icon(_statusActionIcon(targets[i]), size: 22),
          ),
        ],
      ],
    );
  }
}

String _adminMobileHeroMetaLine(ComplaintModel complaint) {
  final date = complaint.createdAt;
  final dateStr = date == null
      ? ''
      : DateFormat.yMMMd().add_jm().format(date.toLocal());
  final parts = <String>[complaint.category];
  if (dateStr.isNotEmpty) parts.add(dateStr);
  return parts.join(' · ');
}

class _AdminMobileStageBar extends StatelessWidget {
  const _AdminMobileStageBar({required this.status});

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
          _adminStageCaption(status),
          style: theme.textTheme.muted.copyWith(fontSize: 12, height: 1.3),
        ),
      ],
    );
  }
}

String _adminStageCaption(ComplaintStatus status) {
  return switch (status) {
    ComplaintStatus.pending => 'Received — awaiting triage.',
    ComplaintStatus.inProgress => 'In progress — team is handling it.',
    ComplaintStatus.resolved => 'Resolved — no further action needed.',
    ComplaintStatus.rejected => 'This request was not accepted.',
  };
}

Color _statusStripColor(ShadThemeData theme, ComplaintStatus status) {
  return switch (status) {
    ComplaintStatus.pending => theme.colorScheme.primary.withValues(alpha: 0.7),
    ComplaintStatus.inProgress => theme.colorScheme.accent,
    ComplaintStatus.resolved => theme.colorScheme.primary.withValues(
      alpha: 0.35,
    ),
    ComplaintStatus.rejected => theme.colorScheme.destructive,
  };
}

Color _statusPanelBackground(ShadThemeData theme, ComplaintStatus status) {
  final c = _statusStripColor(theme, status);
  return Color.alphaBlend(c.withValues(alpha: 0.08), theme.colorScheme.card);
}

Color _statusPanelBorder(ShadThemeData theme, ComplaintStatus status) {
  return _statusStripColor(theme, status).withValues(alpha: 0.22);
}

IconData _statusActionIcon(ComplaintStatus status) {
  return switch (status) {
    ComplaintStatus.pending => LucideIcons.list,
    ComplaintStatus.inProgress => LucideIcons.play,
    ComplaintStatus.resolved => LucideIcons.check,
    ComplaintStatus.rejected => LucideIcons.x,
  };
}

String _statusActionHint(ComplaintStatus status) {
  return switch (status) {
    ComplaintStatus.pending => 'Return to queue',
    ComplaintStatus.inProgress => 'Actively being handled',
    ComplaintStatus.resolved => 'Close as completed',
    ComplaintStatus.rejected => 'Decline this request',
  };
}
