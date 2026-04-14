import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../../core/push_notifications/notification_service.dart';
import '../../../../auth/providers/auth_provider.dart';
import '../../providers/complaint_detail_provider.dart';

/// Text input for adding a comment to a complaint.
class CommentInput extends ConsumerStatefulWidget {
  const CommentInput({required this.complaintId, super.key});

  final String complaintId;

  @override
  ConsumerState<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends ConsumerState<CommentInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    final success = await ref
        .read(addCommentProvider.notifier)
        .execute(
          complaintId: widget.complaintId,
          userId: user.id,
          content: content,
        );

    if (!mounted) return;

    if (success) {
      _controller.clear();
    } else {
      NotificationService.showError(context, 'Failed to add comment.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final addState = ref.watch(addCommentProvider);
    final isLoading = addState.isLoading;
    final theme = ShadTheme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: ShadInput(
                controller: _controller,
                placeholder: const Text('Write an update or reply...'),
                enabled: !isLoading,
              ),
            ),
            const SizedBox(width: 10),
            ShadIconButton(
              onPressed: isLoading ? null : _submit,
              icon: isLoading
                  ? const SizedBox.square(dimension: 16, child: ShadProgress())
                  : const Icon(LucideIcons.send, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}
