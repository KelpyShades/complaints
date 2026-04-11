import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';

Future<void> saveAndShareFile(List<int> bytes, String fileName) async {
  final nameOnly = fileName.contains('.')
      ? fileName.substring(0, fileName.lastIndexOf('.'))
      : fileName;
  final fileExtension = fileName.contains('.')
      ? fileName.substring(fileName.lastIndexOf('.') + 1)
      : 'xlsx';

  await FileSaver.instance.saveFile(
    name: nameOnly,
    bytes: Uint8List.fromList(bytes),
    fileExtension: fileExtension,
    mimeType: MimeType.microsoftExcel,
  );
}
