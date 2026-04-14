import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:complaints/core/push_notifications/notification_service.dart';
import 'package:complaints/core/utils/user_facing_error_message.dart';

import '../providers/complaint_detail_provider.dart';
import '../providers/complaint_form_provider.dart';
import '../models/pending_complaint_audio.dart';

/// Shown when the complaint is saved but the voice note failed to upload.
Future<void> showVoiceUploadRecoverySheet({
  required BuildContext context,
  required WidgetRef ref,
  required String complaintId,
  required Object error,
  required PendingComplaintAudio audio,
}) async {
  await showShadDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return ShadDialog.alert(
        title: const Text('Voice note not uploaded'),
        description: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Your request was saved, but the voice note did not upload. '
            'You can retry now, or continue without the voice note.',
          ),
        ),
        actions: [
          ShadButton.outline(
            child: const Text('Continue without voice note'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          ShadButton(
            child: const Text('Retry upload'),
            onPressed: () async {
              final nav = Navigator.of(dialogContext);
              final outcome = await ref
                  .read(complaintFormProvider.notifier)
                  .retryAudioUpload(
                    complaintId: complaintId,
                    audio: audio,
                  );
              if (!context.mounted) return;
              if (outcome is ComplaintFormSubmitSuccess) {
                ref.invalidate(complaintAttachmentsProvider(complaintId));
                nav.pop();
                NotificationService.showSuccess(
                  context,
                  'Voice note uploaded successfully.',
                );
              } else if (outcome is ComplaintFormSubmitFailure) {
                NotificationService.showError(
                  context,
                  userFacingErrorMessage(outcome.error),
                );
              }
            },
          ),
        ],
      );
    },
  );
}
