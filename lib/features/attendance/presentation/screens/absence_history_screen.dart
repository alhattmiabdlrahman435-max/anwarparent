import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_sliver_header.dart';
import '../../../../core/providers/absence_requests_provider.dart';
import '../../../../core/models/absence_request.dart';
import '../../../../core/extensions/localization_extension.dart';

class AbsenceHistoryScreen extends ConsumerStatefulWidget {
  const AbsenceHistoryScreen({super.key});

  @override
  ConsumerState<AbsenceHistoryScreen> createState() => _AbsenceHistoryScreenState();
}

class _AbsenceHistoryScreenState extends ConsumerState<AbsenceHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref.read(absenceRequestsProvider.notifier).refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final requestsAsync = ref.watch(absenceRequestsProvider);

    return Scaffold(
      backgroundColor: bgColor,
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => ref.read(absenceRequestsProvider.notifier).refresh(),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            AppSliverHeader(
              title: context.loc.absenceRequestsHistory,
              showChildSwitcher: false,
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              sliver: requestsAsync.when(
                loading: () => const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, stack) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'خطأ أثناء تحميل السجل',
                      style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF64748B)),
                    ),
                  ),
                ),
                data: (requests) {
                  if (requests.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          context.loc.language == 'ar'
                              ? 'لا توجد طلبات غياب سابقة'
                              : 'No previous absence requests',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : const Color(0xFF64748B),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final request = requests[index];
                        return _AbsenceRequestCard(
                          request: request,
                          isDark: isDark,
                        );
                      },
                      childCount: requests.length,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AbsenceRequestCard extends StatelessWidget {
  final AbsenceRequest request;
  final bool isDark;

  const _AbsenceRequestCard({
    required this.request,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final isRejected = request.status == AbsenceRequestStatus.rejected;
    final isApproved = request.status == AbsenceRequestStatus.approved;

    // Badges style
    final badgeBgColor = isRejected
        ? (isDark ? const Color(0xFF3B1E1E) : const Color(0xFFFFEBEB))
        : isApproved
            ? (isDark ? const Color(0xFF1E3B24) : const Color(0xFFE8F5E9))
            : (isDark ? const Color(0xFF2D3748) : const Color(0xFFEDF2F7));

    final badgeBorderColor = isRejected
        ? (isDark ? const Color(0xFF5A2A2A) : const Color(0xFFFFC1C1))
        : isApproved
            ? (isDark ? const Color(0xFF2A5A30) : const Color(0xFFC8E6C9))
            : (isDark ? const Color(0xFF4A5568) : const Color(0xFFCBD5E0));

    final badgeTextColor = isRejected
        ? const Color(0xFFE53935)
        : isApproved
            ? const Color(0xFF2E7D32)
            : (isDark ? Colors.white70 : const Color(0xFF4A5568));

    final statusText = isRejected
        ? context.loc.rejected
        : isApproved
            ? context.loc.approved
            : context.loc.pending;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.15),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Student Name (start) & Status Badge (end)
          // Row automatically handles RTL mirroring
          Row(
            children: [
              Expanded(
                child: Text(
                  request.studentName,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: badgeBorderColor, width: 1),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: badgeTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Date Row (Icon first, then Text)
          // In RTL, Row places Icon on the right and Text on the left.
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Text(
                "${request.date.year}-${request.date.month}-${request.date.day}",
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          if (request.reason.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              request.reason,
              style: TextStyle(
                color: isDark ? Colors.white70 : const Color(0xFF1E293B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          // Rejection section
          if (isRejected && request.rejectionReason != null) ...[
            const SizedBox(height: 8),
            Divider(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.15),
              thickness: 1,
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.loc.rejectionReason,
                  style: const TextStyle(
                    color: Color(0xFFE53935),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  request.rejectionReason!,
                  style: const TextStyle(
                    color: Color(0xFFE53935),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
