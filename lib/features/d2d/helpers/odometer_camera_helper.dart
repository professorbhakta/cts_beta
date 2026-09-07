import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Outcome of a camera-only capture + compress for odometer multipart upload.
enum OdometerCameraFailure {
  permissionDenied,
  cancelled,
  compressFailed,
}

class OdometerCameraResult {
  const OdometerCameraResult._({this.path, this.failure});

  final String? path;
  final OdometerCameraFailure? failure;

  bool get isSuccess => path != null && failure == null;

  factory OdometerCameraResult.ok(String path) =>
      OdometerCameraResult._(path: path);

  factory OdometerCameraResult.fail(OdometerCameraFailure failure) =>
      OdometerCameraResult._(failure: failure);
}

/// Captures an odometer photo from the **camera only** (no gallery) and
/// compresses to roughly 200–500 KB for multipart upload.
class OdometerCameraHelper {
  OdometerCameraHelper({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  static const int _minBytes = 200 * 1024;
  static const int _maxBytes = 500 * 1024;

  /// Request camera permission, open camera, compress, return file path.
  Future<OdometerCameraResult> captureCompressedPhoto() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    if (status.isPermanentlyDenied) {
      return OdometerCameraResult.fail(OdometerCameraFailure.permissionDenied);
    }
    if (!status.isGranted) {
      return OdometerCameraResult.fail(OdometerCameraFailure.permissionDenied);
    }

    final XFile? shot = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 90,
    );
    if (shot == null) {
      return OdometerCameraResult.fail(OdometerCameraFailure.cancelled);
    }

    final compressed = await _compressToTarget(shot.path);
    if (compressed == null) {
      return OdometerCameraResult.fail(OdometerCameraFailure.compressFailed);
    }
    return OdometerCameraResult.ok(compressed);
  }

  Future<String?> _compressToTarget(String sourcePath) async {
    final tmp = await getTemporaryDirectory();
    final outPath = p.join(
      tmp.path,
      'odo_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    // Prefer landing under max; allow under min if the shot is already small.
    var quality = 75;
    Uint8List? best;
    for (var i = 0; i < 5; i++) {
      final bytes = await FlutterImageCompress.compressWithFile(
        sourcePath,
        quality: quality,
        minWidth: 1280,
        minHeight: 1280,
        format: CompressFormat.jpeg,
      );
      if (bytes == null || bytes.isEmpty) break;
      best = bytes;
      if (bytes.lengthInBytes <= _maxBytes) {
        if (bytes.lengthInBytes >= _minBytes || quality >= 85) {
          break;
        }
        // Too small — bump quality once if room.
        quality = (quality + 10).clamp(10, 95);
        continue;
      }
      quality = (quality - 15).clamp(10, 95);
    }

    if (best == null || best.isEmpty) return null;

    final file = File(outPath);
    await file.writeAsBytes(best, flush: true);
    return file.path;
  }
}
