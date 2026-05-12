import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:complaints/core/push_notifications/notification_service.dart';
import 'package:complaints/core/utils/user_facing_error_message.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/pending_complaint_audio.dart';
import '../../utils/audio_recording_format.dart';
import '../../utils/revoke_blob_url.dart';

/// Optional voice note for a new complaint (text fields stay required).
class ComplaintAudioRecorderSection extends StatefulWidget {
  const ComplaintAudioRecorderSection({
    super.key,
    required this.onDraftChanged,
  });

  final ValueChanged<PendingComplaintAudio?> onDraftChanged;

  @override
  State<ComplaintAudioRecorderSection> createState() =>
      _ComplaintAudioRecorderSectionState();
}

class _ComplaintAudioRecorderSectionState
    extends State<ComplaintAudioRecorderSection> {
  static const int _maxDurationSeconds = 600;

  final AudioRecorder _recorder = AudioRecorder();
  AudioPlayer? _previewPlayer;
  Timer? _tick;

  RecordConfig? _config;
  bool _busy = false;
  bool _recording = false;
  int _elapsedSeconds = 0;
  Stopwatch? _stopwatch;
  PendingComplaintAudio? _draft;

  @override
  void dispose() {
    _tick?.cancel();
    unawaited(_previewPlayer?.dispose());
    if (_draft != null) {
      _cleanupDraftFile(_draft!);
    }
    unawaited(_recorder.dispose());
    super.dispose();
  }

  Future<void> _ensureMicAccess() async {
    if (kIsWeb) {
      final ok = await _recorder.hasPermission(request: true);
      if (!ok) {
        throw Exception(
          'Microphone access was denied. Allow the microphone for this site '
          '(often via the lock or tune icon in the address bar) and try again.',
        );
      }
      return;
    }

    final status = await Permission.microphone.request();
    if (status.isGranted) return;

    if (status.isPermanentlyDenied) {
      throw Exception(
        'Microphone access is turned off in system settings. Enable it for this '
        'app to attach a voice note.',
      );
    }

    throw Exception('Microphone access is required to record a voice note.');
  }

  Future<RecordConfig?> _pickEncoderConfig() async {
    // Prefer WAV for reliable in-app playback (preview + attachment player).
    // Keep PCM as fallback, and use mono + 16kHz to stay within upload limits.
    final order = <AudioEncoder>[
      AudioEncoder.wav,
      AudioEncoder.pcm16bits,
      AudioEncoder.aacLc,
      AudioEncoder.opus,
      AudioEncoder.aacEld,
      AudioEncoder.aacHe,
      AudioEncoder.flac,
    ];

    for (final enc in order) {
      if (await _recorder.isEncoderSupported(enc)) {
        if (enc == AudioEncoder.pcm16bits || enc == AudioEncoder.wav) {
          return RecordConfig(encoder: enc, sampleRate: 16000, numChannels: 1);
        }
        return RecordConfig(encoder: enc, bitRate: 128000);
      }
    }

    // Safari iOS / WebKit: isEncoderSupported may return false for every
    // AudioEncoder value even though the browser *can* record audio/mp4 (AAC).
    // Fall back to aacLc which maps to the format Safari actually produces.
    if (kIsWeb) {
      return RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000);
    }

    return null;
  }

  Future<String> _outputPathForEncoder(AudioEncoder encoder) async {
    final ext = fileExtensionForEncoder(encoder);
    if (kIsWeb) {
      return 'ignored.web.$ext';
    }
    final dir = await getTemporaryDirectory();
    return p.join(
      dir.path,
      'complaint_audio_${DateTime.now().millisecondsSinceEpoch}.$ext',
    );
  }

  /// Returns a user-friendly message for recording-specific errors.
  String _audioErrorMessage(Object error) {
    final msg = error.toString();
    // If it's one of our own descriptive exceptions, show it directly.
    if (msg.contains('Microphone') ||
        msg.contains('microphone') ||
        msg.contains('audio format') ||
        msg.contains('voice note')) {
      // Strip the "Exception: " prefix if present.
      return msg.replaceFirst(RegExp(r'^Exception:\s*'), '');
    }
    return userFacingErrorMessage(error);
  }

  Future<void> _start() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await _ensureMicAccess();
      final cfg = await _pickEncoderConfig();
      if (cfg == null) {
        throw Exception(
          'This device or browser does not support a compatible audio format.',
        );
      }
      final path = await _outputPathForEncoder(cfg.encoder);
      await _recorder.start(cfg, path: path);
      _config = cfg;
      _stopwatch = Stopwatch()..start();
      _elapsedSeconds = 0;
      _tick = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted || _stopwatch == null) return;
        final sec = _stopwatch!.elapsed.inSeconds;
        if (sec >= _maxDurationSeconds) {
          unawaited(_stop());
          return;
        }
        setState(() => _elapsedSeconds = sec);
      });
      setState(() => _recording = true);
    } catch (e) {
      if (mounted) {
        NotificationService.showError(context, _audioErrorMessage(e));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _stop() async {
    if (!_recording) return;
    setState(() {
      _busy = true;
      _recording = false;
    });
    _tick?.cancel();
    _tick = null;
    _stopwatch?.stop();
    final elapsed = (_stopwatch?.elapsed ?? Duration.zero).inSeconds;
    _stopwatch = null;

    try {
      final path = await _recorder.stop();
      final cfg = _config;
      if (path == null || cfg == null) {
        widget.onDraftChanged(null);
        setState(() => _draft = null);
        _config = null;
        return;
      }

      final isBlob = kIsWeb || path.startsWith('blob:');
      final mime = mimeTypeForEncoder(cfg.encoder);
      final ext = fileExtensionForEncoder(cfg.encoder);

      late final int size;
      if (isBlob) {
        final bytes = await XFile(path, mimeType: mime).readAsBytes();
        size = bytes.length;
      } else {
        final file = XFile(path, mimeType: mime);
        final bytes = await file.readAsBytes();
        size = bytes.length;
      }

      final draft = PendingComplaintAudio(
        pathOrBlobUrl: path,
        isWebBlobUrl: isBlob,
        durationSeconds: elapsed.clamp(1, _maxDurationSeconds),
        mimeType: mime,
        fileExtension: ext,
        fileSizeBytes: size,
      );

      if (!mounted) return;
      setState(() => _draft = draft);
      widget.onDraftChanged(draft);
    } catch (e) {
      if (mounted) {
        NotificationService.showError(context, _audioErrorMessage(e));
      }
      widget.onDraftChanged(null);
      setState(() => _draft = null);
    } finally {
      _config = null;
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancelWhileRecording() async {
    if (_busy) return;
    setState(() => _busy = true);
    _tick?.cancel();
    _tick = null;
    _stopwatch?.stop();
    _stopwatch = null;
    setState(() {
      _recording = false;
      _elapsedSeconds = 0;
    });
    try {
      await _recorder.cancel();
    } catch (e) {
      if (mounted) {
        NotificationService.showError(
          context,
          'Could not cancel recording cleanly. Please try again.',
        );
      }
    } finally {
      _config = null;
      if (mounted) setState(() => _busy = false);
    }
  }

  void _deleteDraft() {
    final d = _draft;
    if (d == null) return;
    unawaited(_previewPlayer?.stop());
    _cleanupDraftFile(d);
    setState(() => _draft = null);
    widget.onDraftChanged(null);
  }

  void _cleanupDraftFile(PendingComplaintAudio draft) {
    if (draft.isWebBlobUrl) {
      revokeBlobUrlIfNeeded(draft.pathOrBlobUrl);
    }
    // On native platforms, temp files are cleaned up by the OS.
    // Explicit deletion removed to avoid dart:io dependency on web.
  }

  Future<void> _togglePreview() async {
    final draft = _draft;
    if (draft == null) return;

    final created = _previewPlayer == null;
    _previewPlayer ??= AudioPlayer();
    if (created && mounted) setState(() {});

    final player = _previewPlayer!;

    if (player.playing) {
      await player.pause();
      setState(() {});
      return;
    }

    try {
      if (kIsWeb && draft.mimeType == 'audio/pcm') {
        NotificationService.showError(
          context,
          'This recording format cannot be previewed in-browser. '
          'Please re-record and try again.',
        );
        return;
      }

      // On web (including Safari iOS), always use setUrl — AudioSource.file
      // is not supported by just_audio_web. For native platforms, use the
      // file-based source for better seeking and offline support.
      if (kIsWeb) {
        await player.setUrl(draft.pathOrBlobUrl);
      } else {
        await player.setAudioSource(AudioSource.file(draft.pathOrBlobUrl));
      }
      await player.seek(Duration.zero);
      await player.play();
    } catch (e) {
      if (mounted) {
        NotificationService.showError(
          context,
          'Could not play the recording. Try stopping and re-recording.',
        );
      }
    }
    if (mounted) setState(() {});
  }

  String _fmt(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Voice note (optional)',
          style: theme.textTheme.small.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.35,
            color: theme.colorScheme.mutedForeground,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Adds a short recording with your request. You can preview or delete '
          'before submitting.',
          style: theme.textTheme.muted.copyWith(height: 1.35),
        ),
        const SizedBox(height: 16),
        if (_draft == null) ...[
          Row(
            children: [
              if (!_recording)
                ShadButton(
                  onPressed: _busy ? null : _start,
                  size: ShadButtonSize.sm,
                  leading: const Icon(LucideIcons.mic, size: 16),
                  child: const Text('Record'),
                )
              else ...[
                ShadButton.destructive(
                  onPressed: _busy ? null : _cancelWhileRecording,
                  size: ShadButtonSize.sm,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ShadButton(
                  onPressed: _busy ? null : _stop,
                  size: ShadButtonSize.sm,
                  leading: const Icon(LucideIcons.square, size: 14),
                  child: const Text('Stop'),
                ),
                const SizedBox(width: 12),
                Text(
                  _fmt(_elapsedSeconds),
                  style: theme.textTheme.p.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ],
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.muted.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.border.withValues(alpha: 0.65),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.volume2,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recording ready',
                        style: theme.textTheme.small.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${_fmt(_draft!.durationSeconds)} · '
                        '${(_draft!.fileSizeBytes / 1024).toStringAsFixed(0)} KB',
                        style: theme.textTheme.muted.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (_previewPlayer != null)
                  StreamBuilder<PlayerState>(
                    stream: _previewPlayer!.playerStateStream,
                    builder: (context, snap) {
                      final playing = snap.data?.playing ?? false;
                      return ShadButton.outline(
                        size: ShadButtonSize.sm,
                        onPressed: _togglePreview,
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
                    onPressed: _togglePreview,
                    child: const Icon(LucideIcons.play, size: 16),
                  ),
                const SizedBox(width: 8),
                ShadButton.ghost(
                  size: ShadButtonSize.sm,
                  onPressed: _deleteDraft,
                  child: Icon(
                    LucideIcons.trash2,
                    size: 16,
                    color: theme.colorScheme.destructive,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
