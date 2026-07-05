import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_sliver_header.dart';
import '../../../../core/providers/notifications_provider.dart';
import '../../../../core/models/app_notification.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);
    const alertColor = Color(0xFFDC2626); // Red for alerts

    return Scaffold(
      backgroundColor: bgColor,
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        color: alertColor,
        onRefresh: () => ref.read(notificationsProvider.notifier).refresh(),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            AppSliverHeader(
              title: 'البلاغات',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: alertColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: alertColor.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.exclamationmark_shield_fill,
                      size: 14,
                      color: alertColor,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'عالية الأهمية',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: alertColor,
                        fontFamily: 'GoogleSans',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            notificationsAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: alertColor)),
              ),
              error: (err, stack) => SliverFillRemaining(
                child: Center(
                  child: Text(
                    'حدث خطأ أثناء تحميل البلاغات: $err',
                    style: TextStyle(color: textColor, fontFamily: 'GoogleSans'),
                  ),
                ),
              ),
              data: (allNotifications) {
                // Filter only alert/report type notifications
                final alerts = allNotifications
                    .where((n) => n.type == 'alert' || n.type == 'report')
                    .toList();

                if (alerts.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: alertColor.withValues(alpha: 0.07),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              CupertinoIcons.shield_lefthalf_fill,
                              size: 56,
                              color: alertColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'لا توجد بلاغات حالياً',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                              fontFamily: 'GoogleSans',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ستظهر هنا بلاغات المعلمين المتعلقة بطفلك',
                            style: TextStyle(
                              fontSize: 13,
                              color: subTextColor,
                              fontFamily: 'GoogleSans',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final unreadCount = alerts.where((n) => !n.isRead).length;

                return SliverMainAxisGroup(
                  slivers: [
                    // Unread count banner
                    if (unreadCount > 0)
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                alertColor.withValues(alpha: 0.12),
                                alertColor.withValues(alpha: 0.06),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: alertColor.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                CupertinoIcons.exclamationmark_circle_fill,
                                color: alertColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'لديك $unreadCount بلاغ غير مقروء',
                                style: const TextStyle(
                                  fontFamily: 'GoogleSans',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: alertColor,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  for (final a in alerts.where((n) => !n.isRead)) {
                                    ref
                                        .read(notificationsProvider.notifier)
                                        .markAsRead(a.id);
                                  }
                                },
                                child: Text(
                                  'تعيين الكل كمقروء',
                                  style: TextStyle(
                                    fontFamily: 'GoogleSans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: alertColor.withValues(alpha: 0.8),
                                    decoration: TextDecoration.underline,
                                    decorationColor:
                                        alertColor.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Alert cards list
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final alert = alerts[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14.0),
                              child: GestureDetector(
                                onTap: () {
                                  if (!alert.isRead) {
                                    ref
                                        .read(notificationsProvider.notifier)
                                        .markAsRead(alert.id);
                                  }
                                },
                                child: _buildAlertCard(
                                  context: context,
                                  alert: alert,
                                  cardColor: cardColor,
                                  textColor: textColor,
                                  subTextColor: subTextColor,
                                  isDark: isDark,
                                ),
                              ),
                            );
                          },
                          childCount: alerts.length,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard({
    required BuildContext context,
    required AppNotification alert,
    required Color cardColor,
    required Color textColor,
    required Color subTextColor,
    required bool isDark,
  }) {
    const alertColor = Color(0xFFDC2626);

    // Format time in a readable format
    final dt = alert.createdAt.toLocal();
    final formattedTime =
        '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} – ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: alert.isRead
              ? (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200)
              : alertColor.withValues(alpha: 0.4),
          width: alert.isRead ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: alert.isRead
                ? Colors.black.withValues(alpha: 0.02)
                : alertColor.withValues(alpha: isDark ? 0.12 : 0.05),
            blurRadius: alert.isRead ? 8 : 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Indicator bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: alert.isRead
                      ? [
                          isDark ? Colors.white.withValues(alpha: 0.02) : Colors.grey.shade100,
                          isDark ? Colors.white.withValues(alpha: 0.01) : Colors.white,
                        ]
                      : [
                          alertColor.withValues(alpha: 0.12),
                          alertColor.withValues(alpha: 0.04),
                        ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: alert.isRead
                          ? Colors.grey.withValues(alpha: 0.2)
                          : alertColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.exclamationmark_shield_fill,
                      color: alert.isRead ? Colors.grey : alertColor,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'بلاغ رسمي من الإدارة',
                    style: TextStyle(
                      fontFamily: 'GoogleSans',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: alert.isRead ? subTextColor : alertColor,
                    ),
                  ),
                  const Spacer(),
                  if (!alert.isRead)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: alertColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'جديد',
                        style: TextStyle(
                          fontFamily: 'GoogleSans',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    style: TextStyle(
                      fontFamily: 'GoogleSans',
                      fontSize: 16,
                      fontWeight: alert.isRead ? FontWeight.w600 : FontWeight.bold,
                      color: textColor,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    alert.content,
                    style: TextStyle(
                      fontFamily: 'GoogleSans',
                      fontSize: 14,
                      fontWeight: alert.isRead ? FontWeight.w400 : FontWeight.w500,
                      color: subTextColor,
                      height: 1.6,
                    ),
                  ),

                  // Display Attachment if available
                  if (alert.attachmentUrl != null && alert.attachmentUrl!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Image.network(
                              alert.attachmentUrl!,
                              height: 160,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 80,
                                  color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade100,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        CupertinoIcons.doc_text_fill,
                                        color: subTextColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'الملف المرفق',
                                        style: TextStyle(
                                          fontFamily: 'GoogleSans',
                                          color: textColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 160,
                                  color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.grey.shade50,
                                  child: const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2, color: alertColor),
                                  ),
                                );
                              },
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'مرفق إثبات مع البلاغ',
                                      style: TextStyle(
                                        fontFamily: 'GoogleSans',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: subTextColor,
                                      ),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _downloadAttachment(context, alert.attachmentUrl!),
                                    icon: const Icon(CupertinoIcons.cloud_download, size: 14, color: Colors.blueAccent),
                                    label: const Text(
                                      'تحميل المرفق',
                                      style: TextStyle(
                                        fontFamily: 'GoogleSans',
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: () => _showFullScreenImage(context, alert.attachmentUrl!),
                                    icon: const Icon(CupertinoIcons.fullscreen, size: 14, color: Colors.green),
                                    label: const Text(
                                      'عرض المرفق',
                                      style: TextStyle(
                                        fontFamily: 'GoogleSans',
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.clock,
                        size: 12,
                        color: subTextColor.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formattedTime,
                        style: TextStyle(
                          fontFamily: 'GoogleSans',
                          fontSize: 11,
                          color: subTextColor.withValues(alpha: 0.7),
                        ),
                      ),
                      if (!alert.isRead) ...[
                        const Spacer(),
                        Text(
                          'اضغط لتعيينه كمقروء',
                          style: TextStyle(
                            fontFamily: 'GoogleSans',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: alertColor.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'عرض المرفق',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'GoogleSans',
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(CupertinoIcons.cloud_download, color: Colors.white),
                onPressed: () async {
                  try {
                    final uri = Uri.parse(imageUrl);
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } catch (e) {
                    debugPrint('Error launching url: $e');
                  }
                },
              ),
            ],
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(CupertinoIcons.doc_text, size: 80, color: Colors.white54),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _downloadAttachment(BuildContext context, String url) async {
    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFFDC2626)),
                SizedBox(width: 16),
                Text(
                  'جاري تحميل الملف...',
                  style: TextStyle(fontFamily: 'GoogleSans', fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final dio = Dio();
      final uri = Uri.parse(url);
      final fileName = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'attachment_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      Directory? dir;
      if (Platform.isAndroid) {
        dir = Directory('/storage/emulated/0/Download');
        if (!await dir.exists()) {
          dir = await getExternalStorageDirectory();
        }
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      final savePath = '${dir!.path}/$fileName';
      
      await dio.download(url, savePath);
      
      // Close the loading dialog
      if (!context.mounted) return;
      Navigator.pop(context);
      
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'تم التحميل بنجاح',
            style: TextStyle(fontFamily: 'GoogleSans', fontWeight: FontWeight.bold),
          ),
          content: Text(
            'تم حفظ الملف بنجاح في مجلد التنزيلات:\n$savePath',
            style: const TextStyle(fontFamily: 'GoogleSans'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('حسنًا'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }
      
      // Fallback: Save to app documents directory
      try {
        final dio = Dio();
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'attachment_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savePath = '${appDir.path}/$fileName';
        await dio.download(url, savePath);
        
        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
              'تم حفظ الملف في مستندات التطبيق',
              style: TextStyle(fontFamily: 'GoogleSans', fontWeight: FontWeight.bold),
            ),
            content: Text(
              'تم حفظ الملف بنجاح في:\n$savePath',
              style: const TextStyle(fontFamily: 'GoogleSans'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('حسنًا'),
              ),
            ],
          ),
        );
      } catch (innerError) {
        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('خطأ في التحميل'),
            content: Text('فشل تحميل وحفظ الملف: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('حسنًا'),
              ),
            ],
          ),
        );
      }
    }
  }
}
