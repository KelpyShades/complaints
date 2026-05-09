import 'package:cross_file/cross_file.dart';

/// Local draft for an optional image on a new complaint (not persisted until submit).
class PendingComplaintImage {
  const PendingComplaintImage({
    required this.file,
    required this.mimeType,
    required this.fileExtension,
  });

  /// The selected file from image_picker
  final XFile file;
  final String mimeType;
  final String fileExtension;
}
