import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:complaints/core/push_notifications/notification_service.dart';
import '../../models/complaint_attachment_model.dart';
import '../../providers/complaint_repository_provider.dart';

/// Plays a stored complaint audio attachment via a short-lived signed URL (streams; no full download required).
class ComplaintAudioAttachmentCard extends ConsumerStatefulWidget {
  const ComplaintAudioAttachmentCard({super.key, required this.attachment});

  final ComplaintAttachmentModel attachment;

  @override
  ConsumerState<ComplaintAudioAttachmentCard> createState() =>
      _ComplaintAudioAttachmentCardState();
}

class _ComplaintAudioAttachmentCardState
    extends ConsumerState<ComplaintAudioAttachmentCard> {
  AudioPlayer? _player;

  @override
  void dispose() {
    unawaited(_player?.dispose());
    super.dispose();
  }

  String _fmt(int? seconds) {
    final s = (seconds ?? 0).clamp(0, 24 * 3600);
    final m = s ~/ 60;
    final r = s % 60;
    return '${m.toString().padLeft(2, '0')}:${r.toString().padLeft(2, '0')}';
  }

  Future<void> _togglePlay() async {
    final created = _player == null;
    _player ??= AudioPlayer();
    if (created && mounted) setState(() {});

    final player = _player!;

    if (player.playing) {
      await player.pause();
      setState(() {});
      return;
    }

    try {
      final url = await ref
          .read(complaintRepositoryProvider)
          .signedUrlForComplaintMedia(widget.attachment.storagePath);
      await player.setUrl(url);
      await player.seek(Duration.zero);
      await player.play();
    } catch (e) {
      if (mounted) {
        NotificationService.showError(
          context,
          'Could not start playback. Check your connection and try again.',
        );
      }
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final a = widget.attachment;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.border.withValues(alpha: 0.85),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(LucideIcons.mic, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Audio attachment',
                        style: theme.textTheme.small.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.35,
                        ),
                      ),
                      Text(
                        '${_fmt(a.durationSeconds)} · '
                        '${(a.fileSize / 1024).toStringAsFixed(0)} KB',
                        style: theme.textTheme.muted.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (_player != null)
                  StreamBuilder<PlayerState>(
                    stream: _player!.playerStateStream,
                    builder: (context, snap) {
                      final playing = snap.data?.playing ?? false;
                      return ShadButton.outline(
                        size: ShadButtonSize.sm,
                        onPressed: _togglePlay,
                        child: Icon(
                          playing ? LucideIcons.pause : LucideIcons.play,
                          size: 16,
                        ),
                      );
                    },
                  )
                else
                  ShadButton.outline(
                    size: ShadButtonSize.sm,
                    onPressed: _togglePlay,
                    child: const Icon(LucideIcons.play, size: 16),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
