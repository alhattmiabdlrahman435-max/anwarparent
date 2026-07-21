import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Result of a pick-and-compress operation.
class ImagePickResult {
  final File file;
  final int originalSizeBytes;
  final int compressedSizeBytes;

  const ImagePickResult({
    required this.file,
    required this.originalSizeBytes,
    required this.compressedSizeBytes,
  });

  double get compressionRatio =>
      originalSizeBytes > 0 ? compressedSizeBytes / originalSizeBytes : 1.0;
}

/// Errors thrown by ImageCompressService.
class ImageValidationException implements Exception {
  final String message;
  const ImageValidationException(this.message);
  @override
  String toString() => message;
}

/// Central service for image validation, compression, and picking.
///
/// Policy enforced here:
/// - Allowed types: jpg, jpeg, png, webp
/// - Max size BEFORE compress: 10 MB  (blocks huge files immediately)
/// - Target quality: 75%, max 1200×1200 px (profile) / 1920×1920 (attachments)
/// - Max size AFTER compress: 5 MB   (if still too large → throws)
class ImageCompressService {
  static const int _maxBeforeBytes = 10 * 1024 * 1024;  // 10 MB
  static const int _maxAfterBytes  =  5 * 1024 * 1024;  //  5 MB
  static const Set<String> _allowedExtensions = {'jpg', 'jpeg', 'png', 'webp'};

  static const _uuid = Uuid();

  // ─── Public API ───────────────────────────────────────────────────────────

  /// Pick an image from [source], validate it, compress it, and return the
  /// result. Returns `null` if the user cancelled the picker.
  ///
  /// [maxWidth] / [maxHeight] control the pixel cap (default: 1200).
  /// Use 1920 for report/assignment attachments.
  static Future<ImagePickResult?> pickAndCompress({
    required ImageSource source,
    int maxWidth  = 1200,
    int maxHeight = 1200,
    int quality   = 75,
  }) async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: source);
    if (picked == null) return null;

    return compress(
      File(picked.path),
      maxWidth:  maxWidth,
      maxHeight: maxHeight,
      quality:   quality,
    );
  }

  /// Compress an already-picked [file].
  /// Throws [ImageValidationException] on type/size violations.
  static Future<ImagePickResult> compress(
    File file, {
    int maxWidth  = 1200,
    int maxHeight = 1200,
    int quality   = 75,
  }) async {
    // ── 1. Type validation (extension) ──────────────────────────────────────
    final ext = file.path.split('.').last.toLowerCase();
    if (!_allowedExtensions.contains(ext)) {
      throw ImageValidationException(
        'نوع الملف غير مدعوم. الأنواع المسموح بها: JPG، PNG، WEBP.',
      );
    }

    // ── 2. Size validation BEFORE compression ────────────────────────────────
    final originalSize = await file.length();
    if (originalSize > _maxBeforeBytes) {
      final mb = (originalSize / 1_048_576).toStringAsFixed(1);
      throw ImageValidationException(
        'حجم الصورة ($mb MB) يتجاوز الحد المسموح (10 MB). '
        'اختر صورة أصغر حجماً.',
      );
    }

    // ── 3. Compress ──────────────────────────────────────────────────────────
    final compressed = await _doCompress(
      file,
      maxWidth:  maxWidth,
      maxHeight: maxHeight,
      quality:   quality,
    );

    // ── 4. Size validation AFTER compression ─────────────────────────────────
    final compressedSize = await compressed.length();
    if (compressedSize > _maxAfterBytes) {
      // Clean up the temp file before throwing
      try { await compressed.delete(); } catch (_) {}

      final mb = (compressedSize / 1_048_576).toStringAsFixed(1);
      throw ImageValidationException(
        'الصورة كبيرة جداً حتى بعد الضغط ($mb MB). '
        'الحد الأقصى المسموح للرفع هو 5 MB.',
      );
    }

    return ImagePickResult(
      file:                 compressed,
      originalSizeBytes:    originalSize,
      compressedSizeBytes:  compressedSize,
    );
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  static Future<File> _doCompress(
    File source, {
    required int maxWidth,
    required int maxHeight,
    required int quality,
  }) async {
    final tmpDir  = await getTemporaryDirectory();
    final outPath = '${tmpDir.path}/${_uuid.v4()}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      source.absolute.path,
      outPath,
      minWidth:  maxWidth,
      minHeight: maxHeight,
      quality:   quality,
      format:    CompressFormat.jpeg,
    );

    if (result == null) {
      debugPrint('[ImageCompressService] Compression returned null; using original.');
      return source;
    }

    return File(result.path);
  }
}
