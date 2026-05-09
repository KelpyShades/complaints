import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:path/path.dart' as p;

import '../../data/complaint_media_constants.dart';
import '../../models/pending_complaint_image.dart';

class ComplaintImagePickerSection extends StatefulWidget {
  const ComplaintImagePickerSection({
    required this.onImagesChanged,
    super.key,
  });

  final ValueChanged<List<PendingComplaintImage>> onImagesChanged;

  @override
  State<ComplaintImagePickerSection> createState() => _ComplaintImagePickerSectionState();
}

class _ComplaintImagePickerSectionState extends State<ComplaintImagePickerSection> {
  final ImagePicker _picker = ImagePicker();
  final List<PendingComplaintImage> _images = [];

  Future<void> _pickImages() async {
    if (_images.length >= kComplaintMaxImages) {
      ShadToaster.of(context).show(
        const ShadToast.destructive(
          description: Text('You can only attach up to 5 images.'),
        ),
      );
      return;
    }

    try {
      final List<XFile> selectedImages = await _picker.pickMultiImage(
        imageQuality: 80,
      );

      if (!mounted) return;

      if (selectedImages.isNotEmpty) {
        int addedCount = 0;
        for (final xfile in selectedImages) {
          if (_images.length + addedCount >= kComplaintMaxImages) {
            ShadToaster.of(context).show(
              const ShadToast.destructive(
                description: Text('Maximum of 5 images allowed.'),
              ),
            );
            break;
          }

          final bytesLength = await xfile.length();
          if (!mounted) return;

          if (bytesLength > kComplaintImageMaxBytes) {
            ShadToaster.of(context).show(
              ShadToast.destructive(
                description: Text('${xfile.name} is larger than 10MB.'),
              ),
            );
            continue;
          }

          final ext = p.extension(xfile.name).toLowerCase();
          String mimeType = xfile.mimeType ?? 'image/jpeg';
          if (xfile.mimeType == null) {
            if (ext == '.png') {
              mimeType = 'image/png';
            } else if (ext == '.gif') {
              mimeType = 'image/gif';
            } else if (ext == '.webp') {
              mimeType = 'image/webp';
            }
          }

          _images.add(
            PendingComplaintImage(
              file: xfile,
              mimeType: mimeType,
              fileExtension: ext.isEmpty ? '.jpg' : ext,
            ),
          );
          addedCount++;
        }

        if (addedCount > 0) {
          setState(() {});
          widget.onImagesChanged(_images);
        }
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            description: Text('Error picking images: $e'),
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
    widget.onImagesChanged(_images);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Attach Images (${_images.length}/$kComplaintMaxImages)',
              style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w500),
            ),
            if (_images.length < kComplaintMaxImages)
              ShadButton.outline(
                size: ShadButtonSize.sm,
                onPressed: _pickImages,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.imagePlus, size: 16),
                    SizedBox(width: 8),
                    Text('Add Images'),
                  ],
                ),
              ),
          ],
        ),
        if (_images.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_images.length, (index) {
              final image = _images[index];
              return Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.colorScheme.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    // We can use Image.network for web, or file for mobile. 
                    // XFile handles this nicely if we just read it as bytes, but for thumbnails maybe cross_file provides a way.
                    // Actually XFile path works for web with Image.network, and mobile with Image.file. Let's just use FutureBuilder with readAsBytes.
                    child: FutureBuilder<Uint8List>(
                      future: image.file.readAsBytes(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Image.memory(
                            snapshot.data!,
                            fit: BoxFit.cover,
                          );
                        }
                        return const Center(child: ShadProgress());
                      },
                    ),
                  ),
                  Positioned(
                    top: -8,
                    right: -8,
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.x, size: 12, color: Colors.white),
                      ),
                      onPressed: () => _removeImage(index),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ],
    );
  }
}
