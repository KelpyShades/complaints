import 'dart:io';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';

import '../models/pending_complaint_audio.dart';

Future<Uint8List> readPendingComplaintAudioBytes(PendingComplaintAudio audio) async {
  if (audio.isWebBlobUrl) {
    return XFile(audio.pathOrBlobUrl, mimeType: audio.mimeType).readAsBytes();
  }
  return File(audio.pathOrBlobUrl).readAsBytes();
}
