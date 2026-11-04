import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_sliver_header.dart';
import '../../../../core/extensions/localization_extension.dart';
import '../../../../core/providers/notifications_provider.dart';
import '../../../../core/models/app_notification.dart';
import '../../../../core/providers/children_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  final String? initialNotificationId;
  const NotificationsScreen({super.key, this.initialNotificationId});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _hasOpenedInitial = false;

  void _checkAndOpenInitial(List<AppNotification> list, bool isDark) {
    if (_hasOpenedInitial || widget.initialNotificationId == null) return;
    final match = list.where((n) => n.id == widget.initialNotificationId).firstOrNull;
    if (match != null) {
      _hasOpenedInitial = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showNotificationDetails(context, match, isDark);
        }
      });
    }
  }

  void _showNotificationDetails(BuildContext context, AppNotification notif, bool isDark) {
    if (!notif.isRead) {
      ref.read(notificationsProvider.notifier).markAsRead(notif.id);
    }

    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textCol = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextCol = isDark ? Colors.white70 : const Color(0xFF64748B);

    final String formattedDate = DateFormat('yyyy-MM-dd', 'ar').format(notif.createdAt.toLocal());
    final String formattedTime = DateFormat('hh:mm a', 'ar').format(notif.createdAt.toLocal());

    IconData icon;
    Color iconColor;
    switch (notif.type) {
      case 'attendance':
        icon = CupertinoIcons.checkmark_circle_fill;
        iconColor = Colors.green;
        break;
      case 'grade':
        icon = CupertinoIcons.doc_text_fill;
        iconColor = Colors.blueAccent;
        break;
      case 'general':
      default:
        icon = CupertinoIcons.bell_fill;
        iconColor = Colors.orangeAccent;
        break;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            top: 14,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).padding.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Header: Icon + Title + Date
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: iconColor, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textCol,
                            fontFamily: 'GoogleSans',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(CupertinoIcons.clock, size: 14, color: subTextCol),
                            const SizedBox(width: 4),
                            Text(
                              '$formattedDate | $formattedTime',
                              style: TextStyle(
                                fontSize: 12,
                                color: subTextCol,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              Divider(height: 1, color: isDark ? Colors.white12 : Colors.grey.shade200),
              const SizedBox(height: 16),

              // Content Box
              Container(
                constraints: const BoxConstraints(maxHeight: 340),
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.grey.shade200,
                      ),
                    ),
                    child: SelectableText(
                      notif.content,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: textCol,
                        fontFamily: 'GoogleSans',
                      ),
                    ),
                  ),
                ),
              ),

              // Attachment Button (if available)
              if (notif.attachmentUrl != null && notif.attachmentUrl!.isNotEmpty) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    final uri = Uri.tryParse(notif.attachmentUrl!);
                    if (uri != null) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(CupertinoIcons.paperclip, size: 18),
                  label: const Text('عرض المرفق'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Close Button
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF062A5A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text(
                  'إغلاق',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GoogleSans',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final currentChild = ref.watch(currentChildProvider);
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);

    final hasUnread = notificationsAsync.maybeWhen(
      data: (allNotifications) {
        var notifications = allNotifications
            .where((n) => n.type != 'alert' && n.type != 'report')
            .toList();

        if (currentChild != null) {
          notifications = notifications.where((n) {
            if (n.targetType == 'all_parents') return true;
            if (n.targetType == 'by_student' && n.targetId == currentChild.id) return true;
            if (n.targetType == 'by_class' && n.targetId == currentChild.classId) return true;
            return false;
          }).toList();
        }
        return notifications.any((n) => !n.isRead);
      },
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: bgColor,
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => ref.read(notificationsProvider.notifier).refresh(),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            AppSliverHeader(
              title: context.loc.notifications,
              trailing: hasUnread
                  ? CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        ref.read(notificationsProvider.notifier).markAllAsRead();
                      },
                      child: Icon(
                        Icons.done_all_rounded,
                        color: isDark ? Colors.white : const Color(0xFF062A5A),
                        size: 28,
                      ),
                    )
                  : null,
            ),
            notificationsAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => SliverFillRemaining(
                child: Center(
                  child: Text(
                    context.loc.errorLoadingNotifications(err.toString()),
                    style: TextStyle(color: textColor, fontFamily: 'GoogleSans'),
                  ),
                ),
              ),
              data: (allNotifications) {
                // Filter out alerts and reports so they only show in Alerts tab/screen
                var notifications = allNotifications
                    .where((n) => n.type != 'alert' && n.type != 'report')
                    .toList();

                if (currentChild != null) {
                  notifications = notifications.where((n) {
                    if (n.targetType == 'all_parents') return true;
                    if (n.targetType == 'by_student' && n.targetId == currentChild.id) return true;
                    if (n.targetType == 'by_class' && n.targetId == currentChild.classId) return true;
                    return false;
                  }).toList();
                }

                _checkAndOpenInitial(notifications, isDark);

                if (notifications.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.bell_slash,
                            size: 64,
                            color: isDark ? Colors.white24 : Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            context.loc.noPublicNotifications,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: subTextColor,
                              fontFamily: 'GoogleSans',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final notif = notifications[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: GestureDetector(
                            onTap: () {
                              _showNotificationDetails(context, notif, isDark);
                            },
                            child: _buildNotificationCard(
                              context: context,
                              notification: notif,
                              cardColor: cardColor,
                              textColor: textColor,
                              subTextColor: subTextColor,
                              isDark: isDark,
                            ),
                          ),
                        );
                      },
                      childCount: notifications.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required BuildContext context,
    required AppNotification notification,
    required Color cardColor,
    required Color textColor,
    required Color subTextColor,
    required bool isDark,
  }) {
    IconData icon;
    Color iconColor;

    switch (notification.type) {
      case 'attendance':
        icon = CupertinoIcons.checkmark_circle_fill;
        iconColor = Colors.green;
        break;
      case 'grade':
        icon = CupertinoIcons.doc_text_fill;
        iconColor = Colors.blueAccent;
        break;
      case 'general':
      default:
        icon = CupertinoIcons.bell_fill;
        iconColor = Colors.orangeAccent;
        break;
    }

    final String formattedTime = DateFormat('yyyy-MM-dd HH:mm', Localizations.localeOf(context).languageCode).format(notification.createdAt.toLocal());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: !notification.isRead
            ? Border.all(color: iconColor.withValues(alpha: 0.5), width: 1.5)
            : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: iconColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  notification.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w600,
                    color: subTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedTime,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'عرض التفاصيل',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: iconColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          CupertinoIcons.chevron_left,
                          size: 12,
                          color: iconColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
