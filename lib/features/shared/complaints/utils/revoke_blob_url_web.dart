import 'package:web/web.dart' as web;

void revokeBlobUrlIfNeeded(String url) {
  if (url.startsWith('blob:')) {
    web.URL.revokeObjectURL(url);
  }
}
