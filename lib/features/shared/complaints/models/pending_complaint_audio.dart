/// Local draft for an optional voice note on a new complaint (not persisted until submit).
class PendingComplaintAudio {
  const PendingComplaintAudio({
    required this.pathOrBlobUrl,
    required this.isWebBlobUrl,
    required this.durationSeconds,
    required this.mimeType,
    required this.fileExtension,
    required this.fileSizeBytes,
  });

  /// Absolute file path (mobile/desktop) or `blob:` URL (web) from [AudioRecorder.stop].
  final String pathOrBlobUrl;
  final bool isWebBlobUrl;
  final int durationSeconds;
  final String mimeType;
  final String fileExtension;
  final int fileSizeBytes;
}
