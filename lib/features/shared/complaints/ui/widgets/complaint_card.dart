import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../models/complaint_model.dart';
import 'complaint_status_badge.dart';

/// List row for a complaint — compact, tappable, status-tinted accent.
class ComplaintCard extends StatelessWidget {
  const ComplaintCard({
    required this.complaint,
    required this.onTap,
    super.key,
  });

  final ComplaintModel complaint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final created = complaint.createdAt;
    final strip = _statusStripColor(theme, complaint.status);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.foreground.withValues(alpha: 0.045),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Material(
          color: theme.colorScheme.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: theme.colorScheme.border.withValues(alpha: 0.88),
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: strip,
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(13),
                      ),
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 13, 10, 13),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.muted,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(9),
                            child: Icon(
                              LucideIcons.fileText,
                              size: 18,
                              color: theme.colorScheme.foreground.withValues(
                                alpha: 0.72,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                complaint.title,
                                style: theme.textTheme.p.copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.28,
                                  height: 1.28,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 7),
                              Row(
                                children: [
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.06),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        complaint.category,
                                        style: theme.textTheme.muted.copyWith(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.15,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  if (created != null) ...[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      child: Text(
                                        '·',
                                        style: theme.textTheme.muted.copyWith(
                                          fontSize: 12,
                                          height: 1,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      timeago.format(created),
                                      style: theme.textTheme.muted.copyWith(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ComplaintStatusBadge(status: complaint.status),
                              const SizedBox(width: 2),
                              Icon(
                                LucideIcons.chevronRight,
                                size: 17,
                                color: theme.colorScheme.mutedForeground
                                    .withValues(alpha: 0.42),
                              ),
                            ],
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
    ),
    );
  }
}

Color _statusStripColor(ShadThemeData theme, ComplaintStatus status) {
  return switch (status) {
    ComplaintStatus.pending => theme.colorScheme.primary.withValues(
      alpha: 0.55,
    ),
    ComplaintStatus.inProgress => theme.colorScheme.accent.withValues(
      alpha: 0.85,
    ),
    ComplaintStatus.resolved => theme.colorScheme.primary.withValues(
      alpha: 0.28,
    ),
    ComplaintStatus.rejected => theme.colorScheme.destructive.withValues(
      alpha: 0.75,
    ),
  };
}
