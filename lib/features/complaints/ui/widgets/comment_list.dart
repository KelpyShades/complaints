import 'package:complaints/features/auth/providers/auth_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/comment_model.dart';

/// Displays a list of comments.
class CommentList extends ConsumerWidget {
  const CommentList({required this.comments, super.key});

  final List<CommentModel> comments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final user = ref.read(currentUserProvider);

    if (comments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text('No comments yet.', style: theme.textTheme.muted),
      );
    }

    return Column(
      children: comments.map((comment) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.accent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    comment.userId == user.valueOrNull?.id
                        ? 'You'
                        : user.valueOrNull?.role == 'admin'
                        ? 'Student'
                        : 'Admin',
                    style: theme.textTheme.small.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (comment.createdAt != null)
                    Text(
                      _formatTime(comment.createdAt!),
                      style: theme.textTheme.muted,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(comment.content, style: theme.textTheme.p),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month} $hour:$minute';
  }
}
