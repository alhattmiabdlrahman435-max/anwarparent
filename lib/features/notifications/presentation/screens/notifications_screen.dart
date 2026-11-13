import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_sliver_header.dart';
import '../../../../core/extensions/localization_extension.dart';
import '../../../../core/providers/notifications_provider.dart';
import '../../../../core/models/app_notification.dart';
import '../../../../core/providers/children_provider.dart';
import '../../../../core/models/student.dart';
import '../notification_presentation.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  final String? initialNotificationId;
  const NotificationsScreen({super.key, this.initialNotificationId});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _hasOpenedInitial = false;
  bool _loadingMore = false;

  /// الابن المختار في شريط الأبناء (null = كل الأبناء)
  String? _selectedChildId;

  /// تبويب مصدر الإشعارات: 'all' (الكل) | 'admin' (من الإدارة) | 'system' (تنبيهات النظام)
  String _sourceFilter = 'all';

  bool _matchesSource(AppNotification n) {
    if (_sourceFilter == 'admin') return n.source == 'admin';
    if (_sourceFilter == 'system') return n.source != 'admin';
    return true;
  }

  /// عدد الإشعارات المعروضة الذي نعتبره كافياً لملء الشاشة قبل انتظار التمرير
  static const int _minVisibleBeforeScroll = 10;

  Future<void> _loadMore() async {
    final notifier = ref.read(notificationsProvider.notifier);
    if (_loadingMore || !notifier.hasMore) return;
    setState(() => _loadingMore = true);
    await notifier.loadMore();
    if (mounted) setState(() => _loadingMore = false);
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.extentAfter < 400) {
      _loadMore();
    }
    return false;
  }

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

    final presentation =
        NotificationPresentation.of(context, notif, ref.read(childrenProvider));
    final IconData icon = presentation.icon;
    final Color iconColor = presentation.color;

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
                              notif.isEdited
                                  ? '$formattedDate | $formattedTime · ${Localizations.localeOf(ctx).languageCode == 'ar' ? 'معدَّل' : 'Edited'}'
                                  : '$formattedDate | $formattedTime',
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

              const SizedBox(height: 14),
              _buildSourceLine(presentation, subTextCol),
              if (presentation.relatedChildren.isNotEmpty) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: _buildChildrenTag(ctx, presentation.relatedChildren, isDark),
                ),
              ],
              const SizedBox(height: 14),
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
    final children = ref.watch(childrenProvider);
    // الابن المختار في شريط الأبناء (null = كل الأبناء)
    final selectedChild = children.where((c) => c.id == _selectedChildId).firstOrNull;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);

    // البلاغات لها صفحتها المستقلة
    final allVisible = (notificationsAsync.value ?? const <AppNotification>[])
        .where((n) => n.type != 'alert' && n.type != 'report')
        .toList();
    final hasUnread = allVisible
        .where((n) => NotificationPresentation.belongsTo(n, selectedChild))
        .any((n) => !n.isRead);

    return Scaffold(
      backgroundColor: bgColor,
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => ref.read(notificationsProvider.notifier).refresh(),
        child: NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            AppSliverHeader(
              title: context.loc.notifications,
              // الاختيار هنا عبر شريط الأبناء أدناه (مع خيار "كل الأبناء")
              showChildSwitcher: false,
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
            if (children.length > 1)
              SliverToBoxAdapter(
                child: _buildChildrenBar(
                  children: children,
                  notifications: allVisible,
                  isDark: isDark,
                ),
              ),
            SliverToBoxAdapter(
              child: _buildSourceTabsBar(
                notifications: allVisible
                    .where((n) => NotificationPresentation.belongsTo(n, selectedChild))
                    .toList(),
                isDark: isDark,
              ),
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
                // إشعارات الإدارة العامة تظهر دائماً، والخاصة بابن/صف تظهر حسب الابن المختار والتبويب المختار
                final notifications = allVisible
                    .where((n) => NotificationPresentation.belongsTo(n, selectedChild) && _matchesSource(n))
                    .toList();

                _checkAndOpenInitial(notifications, isDark);

                // إذا كانت الإشعارات المعروضة لهذا الابن قليلة وتوجد صفحات أقدم،
                // نحمّلها تلقائياً بدون انتظار التمرير
                final hasMore = ref.read(notificationsProvider.notifier).hasMore;
                if (hasMore && notifications.length < _minVisibleBeforeScroll) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _loadMore();
                  });
                }

                if (notifications.isEmpty && hasMore) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

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
                        // العنصر الأخير: مؤشر تحميل الإشعارات الأقدم
                        if (index == notifications.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2.5),
                              ),
                            ),
                          );
                        }
                        final notif = notifications[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: GestureDetector(
                            onTap: () {
                              // إشعار واجب: يفتح صفحة الواجبات على يوم الواجب ويعرضه مباشرة
                              final aid = notif.assignmentId;
                              if (aid != null && aid.isNotEmpty) {
                                if (!notif.isRead) {
                                  ref.read(notificationsProvider.notifier).markAsRead(notif.id);
                                }
                                final day = DateFormat('yyyy-MM-dd').format(notif.createdAt.toLocal());
                                context.push('/assignments?aid=$aid&date=$day');
                                return;
                              }
                              _showNotificationDetails(context, notif, isDark);
                            },
                            child: _buildNotificationCard(
                              context: context,
                              notification: notif,
                              children: children,
                              cardColor: cardColor,
                              textColor: textColor,
                              subTextColor: subTextColor,
                              isDark: isDark,
                            ),
                          ),
                        );
                      },
                      childCount: notifications.length + (hasMore ? 1 : 0),
                    ),
                  ),
                );
              },
            ),
          ],
          ),
        ),
      ),
    );
  }

  /// شريط الأبناء: "كل الأبناء" ثم اسم كل ابن، مع نقطة إذا كان له جديد
  Widget _buildChildrenBar({
    required List<Student> children,
    required List<AppNotification> notifications,
    required bool isDark,
  }) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    const brand = Color(0xFF062A5A);

    // عدد الإشعارات غير المقروءة الخاصة بهذا الابن (بدون الإشعارات العامة)
    int childUnreadCount(Student c) => notifications
        .where((n) =>
            !n.isRead &&
            n.targetType != 'all_parents' &&
            NotificationPresentation.belongsTo(n, c))
        .length;

    Widget chip({
      required String label,
      required bool selected,
      required int count,
      required VoidCallback onTap,
    }) {
      return Padding(
        padding: const EdgeInsetsDirectional.only(end: 8),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? brand : (isDark ? const Color(0xFF1E293B) : Colors.white),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? brand : (isDark ? Colors.white12 : Colors.grey.shade300),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? Colors.white
                        : (isDark ? Colors.white70 : const Color(0xFF334155)),
                  ),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    constraints: const BoxConstraints(minWidth: 18),
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
        children: [
          chip(
            label: isAr ? 'كل الأبناء' : 'All children',
            selected: _selectedChildId == null,
            count: 0,
            onTap: () => setState(() => _selectedChildId = null),
          ),
          for (final c in children)
            chip(
              label: NotificationPresentation.firstName(c),
              selected: _selectedChildId == c.id,
              count: childUnreadCount(c),
              onTap: () => setState(() => _selectedChildId = c.id),
            ),
        ],
      ),
    );
  }

  /// شريط تبويبات المصدر: "الكل" | "من الإدارة" | "تنبيهات النظام"
  Widget _buildSourceTabsBar({
    required List<AppNotification> notifications,
    required bool isDark,
  }) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    const brand = Color(0xFF062A5A);

    final adminUnread = notifications.where((n) => !n.isRead && n.source == 'admin').length;
    final systemUnread = notifications.where((n) => !n.isRead && n.source != 'admin').length;

    Widget tabItem({
      required String keyId,
      required String label,
      required IconData icon,
      required int unread,
    }) {
      final selected = _sourceFilter == keyId;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _sourceFilter = keyId),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
            decoration: BoxDecoration(
              color: selected ? brand : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: selected
                      ? Colors.white
                      : (isDark ? Colors.white70 : const Color(0xFF475569)),
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      color: selected
                          ? Colors.white
                          : (isDark ? Colors.white70 : const Color(0xFF334155)),
                      fontFamily: 'GoogleSans',
                    ),
                  ),
                ),
                if (unread > 0) ...[
                  const SizedBox(width: 5),
                  Container(
                    constraints: const BoxConstraints(minWidth: 17),
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      unread > 99 ? '99+' : '$unread',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            tabItem(
              keyId: 'all',
              label: isAr ? 'الكل' : 'All',
              icon: CupertinoIcons.bell_fill,
              unread: 0,
            ),
            tabItem(
              keyId: 'admin',
              label: isAr ? 'من الإدارة' : 'From Admin',
              icon: CupertinoIcons.speaker_2_fill,
              unread: adminUnread,
            ),
            tabItem(
              keyId: 'system',
              label: isAr ? 'تنبيهات النظام' : 'System Alerts',
              icon: CupertinoIcons.sparkles,
              unread: systemUnread,
            ),
          ],
        ),
      ),
    );
  }

  /// سطر "المصدر · لمن أُرسل" أعلى الإشعار
  Widget _buildSourceLine(NotificationPresentation p, Color subTextColor) {
    final text = p.audienceLabel.isEmpty
        ? p.sourceLabel
        : '${p.sourceLabel} · ${p.audienceLabel}';
    return Row(
      children: [
        Icon(p.icon, size: 13, color: p.color),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: subTextColor,
            ),
          ),
        ),
      ],
    );
  }

  /// اسم الابن/الأبناء الذين يخصهم الإشعار
  Widget _buildChildrenTag(BuildContext context, List<Student> kids, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.person_fill,
            size: 11,
            color: isDark ? Colors.white60 : const Color(0xFF475569),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              NotificationPresentation.childrenNames(context, kids),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : const Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required BuildContext context,
    required AppNotification notification,
    required List<Student> children,
    required Color cardColor,
    required Color textColor,
    required Color subTextColor,
    required bool isDark,
  }) {
    final p = NotificationPresentation.of(context, notification, children);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final formattedTime = DateFormat('yyyy-MM-dd hh:mm a', isAr ? 'ar' : 'en')
        .format(notification.createdAt.toLocal());
    final editedLabel = isAr ? 'معدَّل' : 'Edited';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: !notification.isRead
            ? Border.all(color: p.color.withValues(alpha: 0.5), width: 1.5)
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildSourceLine(p, subTextColor)),
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: p.color, shape: BoxShape.circle),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            notification.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
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
          const SizedBox(height: 10),
          Row(
            children: [
              if (p.relatedChildren.isNotEmpty)
                Flexible(child: _buildChildrenTag(context, p.relatedChildren, isDark)),
              const Spacer(),
              Text(
                notification.isEdited ? '$formattedTime · $editedLabel' : formattedTime,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
