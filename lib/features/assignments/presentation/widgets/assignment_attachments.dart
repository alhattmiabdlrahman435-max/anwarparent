import 'package:flutter/material.dart';

/// هل الرابط لصورة؟ (حسب الامتداد، مع تجاهل query string)
bool isImageAttachmentUrl(String url) {
  final path = (Uri.tryParse(url)?.path ?? url).toLowerCase();
  const exts = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp', '.heic', '.heif'];
  return exts.any(path.endsWith);
}

String _fileNameFromUrl(String url) {
  final uri = Uri.tryParse(url);
  final segments = uri?.pathSegments.where((s) => s.isNotEmpty).toList() ?? const [];
  if (segments.isEmpty) return url;
  try {
    return Uri.decodeComponent(segments.last);
  } catch (_) {
    return segments.last;
  }
}

/// يعرض كل مرفقات الواجب: الصور كصف مصغّرات (تفتح عارضاً بملء الشاشة)،
/// والملفات الأخرى كصفوف تُفتح خارجياً عبر [onOpenFile].
class AssignmentAttachments extends StatelessWidget {
  final List<String> urls;
  final bool isDark;
  final bool isArabic;
  final void Function(String url) onOpenFile;

  const AssignmentAttachments({
    super.key,
    required this.urls,
    required this.isDark,
    required this.isArabic,
    required this.onOpenFile,
  });

  @override
  Widget build(BuildContext context) {
    final images = urls.where(isImageAttachmentUrl).toList();
    final files = urls.where((u) => !isImageAttachmentUrl(u)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (images.isNotEmpty) ...[
          Row(
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 18,
                color: isDark ? Colors.white70 : const Color(0xFF062A5A),
              ),
              const SizedBox(width: 6),
              Text(
                isArabic
                    ? (images.length == 1
                        ? 'صورة واحدة'
                        : images.length == 2
                            ? 'صورتان'
                            : images.length <= 10
                                ? '${images.length} صور'
                                : '${images.length} صورة')
                    : '${images.length} ${images.length == 1 ? 'image' : 'images'}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : const Color(0xFF062A5A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => AttachmentImageViewer.open(context, images, index),
                  child: Hero(
                    tag: 'assignment_img_${images[index]}_$index',
                    child: Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.2),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF062A5A),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stack) => Icon(
                          Icons.broken_image_outlined,
                          color: isDark ? Colors.white38 : Colors.grey[400],
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (files.isNotEmpty) const SizedBox(height: 12),
        ],
        for (final url in files) ...[
          _buildFileRow(url),
          if (url != files.last) const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildFileRow(String url) {
    final name = _fileNameFromUrl(url);
    final isPdf = name.toLowerCase().endsWith('.pdf');
    return InkWell(
      onTap: () => onOpenFile(url),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE0F2FE),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white10 : const Color(0xFFBAE6FD),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isPdf ? Icons.picture_as_pdf : Icons.insert_drive_file_outlined,
              color: isPdf
                  ? (isDark ? Colors.red[300] : Colors.red[700])
                  : (isDark ? Colors.white70 : const Color(0xFF0369A1)),
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0369A1),
                    ),
                  ),
                  Text(
                    isArabic ? 'انقر للتحميل والعرض' : 'Tap to download and view',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : const Color(0xFF0284C7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new,
              color: isDark ? Colors.white70 : const Color(0xFF0284C7),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// عارض صور بملء الشاشة: تمرير بين الصور + تكبير/تصغير + زر إغلاق
class AttachmentImageViewer extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;

  const AttachmentImageViewer({
    super.key,
    required this.urls,
    this.initialIndex = 0,
  });

  static Future<void> open(BuildContext context, List<String> urls, int index) {
    return Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AttachmentImageViewer(urls: urls, initialIndex: index),
      ),
    );
  }

  @override
  State<AttachmentImageViewer> createState() => _AttachmentImageViewerState();
}

class _AttachmentImageViewerState extends State<AttachmentImageViewer> {
  late final PageController _controller;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.urls.length;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: total,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: (context, index) {
                final url = widget.urls[index];
                return Hero(
                  tag: 'assignment_img_${url}_$index',
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 5,
                    child: Center(
                      child: Image.network(
                        url,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          );
                        },
                        errorBuilder: (context, error, stack) => const Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white54,
                          size: 64,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            PositionedDirectional(
              top: 8,
              start: 8,
              child: Material(
                color: Colors.black.withValues(alpha: 0.45),
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            if (total > 1)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_current + 1} / $total',
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
