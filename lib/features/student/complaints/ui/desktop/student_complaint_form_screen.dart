import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:complaints/core/push_notifications/notification_service.dart';
import 'package:complaints/core/utils/user_facing_error_message.dart';
import 'package:complaints/core/router/app_router.dart';
import 'package:complaints/core/utils/validators.dart';
import 'package:complaints/features/shared/complaints/models/pending_complaint_audio.dart';
import 'package:complaints/features/shared/complaints/providers/complaint_form_provider.dart';
import 'package:complaints/features/shared/complaints/ui/voice_upload_recovery.dart';
import 'package:complaints/features/shared/complaints/ui/widgets/complaint_audio_recorder_section.dart';

class StudentComplaintFormScreen extends ConsumerStatefulWidget {
  const StudentComplaintFormScreen({this.existingComplaintId, super.key});
  final String? existingComplaintId;

  @override
  ConsumerState<StudentComplaintFormScreen> createState() =>
      _StudentComplaintFormScreenState();
}

class _StudentComplaintFormScreenState
    extends ConsumerState<StudentComplaintFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();

  PendingComplaintAudio? _audioDraft;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final outcome = await ref.read(complaintFormProvider.notifier).submit(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _categoryController.text.trim(),
          existingId: widget.existingComplaintId,
          audio: widget.existingComplaintId == null ? _audioDraft : null,
        );

    if (!mounted) return;

    switch (outcome) {
      case ComplaintFormSubmitSuccess():
        NotificationService.showSuccess(
          context,
          'Request submitted successfully!',
        );
        context.go(AppRoutes.studentComplaints);
      case ComplaintFormSubmitFailure():
        final error = ref.read(complaintFormProvider).error;
        NotificationService.showError(
          context,
          error != null
              ? userFacingErrorMessage(error)
              : 'Could not submit your request. Please try again.',
        );
      case ComplaintFormSubmitMissingAudio(:final complaintId, :final error):
        NotificationService.showWarning(
          context,
          'Your request was saved, but the voice note did not upload.',
        );
        await showVoiceUploadRecoverySheet(
          context: context,
          ref: ref,
          complaintId: complaintId,
          error: error,
          audio: _audioDraft!,
        );
        if (!mounted) return;
        context.go(AppRoutes.studentComplaints);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(complaintFormProvider);
    final isLoading = formState.isLoading;
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
          'New Request',
          style: theme.textTheme.small.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.foreground,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: theme.colorScheme.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.border.withValues(alpha: 0.5),
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'What do you need help with?',
                      style: theme.textTheme.h4,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please provide details so we can direct this to the right department.',
                      style: theme.textTheme.muted,
                    ),
                    const SizedBox(height: 32),

                    ShadInputFormField(
                      id: 'complaint-title',
                      controller: _titleController,
                      label: const Text('Title'),
                      placeholder: const Text(
                        'e.g. Broken projector in Room 101',
                      ),
                      validator: (v) => Validators.required(v, 'Title'),
                    ),
                    const SizedBox(height: 16),

                    ShadInputFormField(
                      id: 'complaint-category',
                      controller: _categoryController,
                      label: const Text('Category'),
                      placeholder: const Text('Facilities, IT, Billing, etc.'),
                      validator: (v) => Validators.required(v, 'Category'),
                    ),
                    const SizedBox(height: 16),

                    ShadInputFormField(
                      id: 'complaint-description',
                      controller: _descriptionController,
                      label: const Text('Description'),
                      placeholder: const Text(
                        'Describe the issue in detail...',
                      ),
                      maxLines: 5,
                      validator: (v) => Validators.required(v, 'Description'),
                    ),
                    if (widget.existingComplaintId == null) ...[
                      const SizedBox(height: 24),
                      ComplaintAudioRecorderSection(
                        onDraftChanged: (draft) {
                          setState(() => _audioDraft = draft);
                        },
                      ),
                    ],
                    const SizedBox(height: 32),

                    ShadButton(
                      onPressed: isLoading ? null : _submit,
                      size: ShadButtonSize.lg,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isLoading)
                            const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: SizedBox.square(
                                dimension: 16,
                                child: ShadProgress(),
                              ),
                            )
                          else
                            const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Icon(LucideIcons.send, size: 16),
                            ),
                          Text(isLoading ? 'Submitting...' : 'Submit Request'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
