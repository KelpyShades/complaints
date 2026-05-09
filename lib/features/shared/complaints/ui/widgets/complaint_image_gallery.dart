import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/complaint_attachment_model.dart';
import '../../providers/complaint_repository_provider.dart';

class ComplaintImageGallery extends ConsumerWidget {
  const ComplaintImageGallery({
    required this.attachments,
    super.key,
  });

  final List<ComplaintAttachmentModel> attachments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    final theme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Attached Images',
          style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: attachments.map((attachment) {
            return _ImageThumbnail(attachment: attachment);
          }).toList(),
        ),
      ],
    );
  }
}

class _ImageThumbnail extends ConsumerWidget {
  const _ImageThumbnail({required this.attachment});

  final ComplaintAttachmentModel attachment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final repo = ref.watch(complaintRepositoryProvider);

    return FutureBuilder<String>(
      future: repo.signedUrlForComplaintMedia(attachment.storagePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: theme.colorScheme.muted,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(child: ShadProgress()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: theme.colorScheme.muted,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.border),
            ),
            child: const Center(
              child: Icon(LucideIcons.imageOff, size: 24),
            ),
          );
        }

        return GestureDetector(
          onTap: () {
            _showFullScreenImage(context, snapshot.data!);
          },
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.border),
              image: DecorationImage(
                image: NetworkImage(snapshot.data!),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFullScreenImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: const Icon(LucideIcons.x, color: Colors.white, size: 32),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
