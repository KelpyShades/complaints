import 'package:complaints/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
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
    final user = ref.watch(currentUserProvider).valueOrNull;

    if (comments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.border),
        ),
        child: Text(
          'No review notes yet.',
          style: theme.textTheme.muted.copyWith(height: 1.4),
        ),
      );
    }

    return Column(
      children: comments.map((comment) {
        // final isCurrentUser = comment.userId == user?.id;
        // final authorLabel = isCurrentUser
        //     ? 'You'
        //     : user?.role == 'admin'
        //     ? 'Student'
        //     : 'Support team';

        final isMe = comment.userId == user?.id;
        final isAdmin = user?.role == 'admin';

        // Determine label (In a real app, you'd fetch the user's name/role)
        final label = isMe ? 'You' : (isAdmin ? 'Student' : 'Admin');
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isMe
                ? theme.colorScheme.primary.withValues(alpha: 0.06)
                : theme.colorScheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isMe
                  ? theme.colorScheme.primary.withValues(alpha: 0.18)
                  : theme.colorScheme.border.withValues(alpha: 0.95),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      style: theme.textTheme.small.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                  if (comment.createdAt != null)
                    Text(
                      _formatTime(comment.createdAt!),
                      style: theme.textTheme.muted.copyWith(
                        fontSize: 11,
                        height: 1.2,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                comment.content,
                style: theme.textTheme.p.copyWith(
                  height: 1.45,
                  letterSpacing: -0.05,
                ),
              ),
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
