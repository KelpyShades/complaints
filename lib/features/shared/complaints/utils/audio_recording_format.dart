import 'package:record/record.dart';

/// Primary MIME (no codec parameters) for Supabase `Content-Type`.
String mimeTypeForEncoder(AudioEncoder encoder) {
  return switch (encoder) {
    AudioEncoder.aacLc ||
    AudioEncoder.aacEld ||
    AudioEncoder.aacHe => 'audio/mp4',
    AudioEncoder.opus => 'audio/webm',
    AudioEncoder.wav => 'audio/wav',
    AudioEncoder.pcm16bits => 'audio/pcm',
    AudioEncoder.flac => 'audio/flac',
    AudioEncoder.amrNb || AudioEncoder.amrWb => 'audio/3gpp',
  };
}

String fileExtensionForEncoder(AudioEncoder encoder) {
  return switch (encoder) {
    AudioEncoder.aacLc || AudioEncoder.aacEld || AudioEncoder.aacHe => 'm4a',
    AudioEncoder.opus => 'webm',
    AudioEncoder.wav => 'wav',
    AudioEncoder.pcm16bits => 'pcm',
    AudioEncoder.flac => 'flac',
    AudioEncoder.amrNb || AudioEncoder.amrWb => '3gp',
  };
}
