import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/complaint_model.dart';
import 'complaint_status_badge.dart';

/// Card widget for displaying a complaint in a list.
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

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ShadCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + status
            Row(
              children: [
                Expanded(
                  child: Text(
                    complaint.title,
                    style: theme.textTheme.p.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                ComplaintStatusBadge(status: complaint.status),
              ],
            ),
            const SizedBox(height: 8),

            // Description preview
            Text(
              complaint.description,
              style: theme.textTheme.muted,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Category
            Row(
              children: [
                Icon(
                  LucideIcons.tag,
                  size: 14,
                  color: theme.colorScheme.mutedForeground,
                ),
                const SizedBox(width: 4),
                Text(complaint.category, style: theme.textTheme.small),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
