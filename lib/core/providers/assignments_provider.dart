import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/assignment.dart';
import '../network/api_client.dart';
import '../network/pusher_service.dart';
import 'parent_provider.dart';

part 'assignments_provider.g.dart';

@Riverpod(keepAlive: true)
class Assignments extends _$Assignments {
  String? _loadedParentId;

  @override
  List<Assignment> build() {
    final parent = ref.watch(currentParentProvider);
    if (parent.id.isEmpty) {
      _loadedParentId = null;
      return [];
    }
    if (_loadedParentId == parent.id) {
      return _currentOrEmpty();
    }
    _loadedParentId = parent.id;
    _listenToRealtimeChanges();
    Future.microtask(() => _loadFromBackend());
    return _currentOrEmpty();
  }

  bool _realtimeSubscribed = false;

  /// WebSocket (Reverb): عند إضافة المعلم واجباً أو تعديله أو حذفه تتحدث القائمة في نفس اللحظة
  void _listenToRealtimeChanges() {
    if (_realtimeSubscribed) return;
    _realtimeSubscribed = true;
    PusherService().subscribe('public-assignments', 'assignments_changed', (_) {
      if (ref.mounted && _loadedParentId != null) _loadFromBackend();
    });
  }

  /// قراءة الحالة الحالية بأمان: في أول بناء لا توجد حالة بعد، وقراءتها كانت تُسقط شاشة الواجبات
  List<Assignment> _currentOrEmpty() {
    try {
      return state;
    } catch (_) {
      return const [];
    }
  }

  Future<void> _loadFromBackend() async {
    final parent = ref.read(currentParentProvider);
    if (parent.id.isEmpty) {
      if (ref.mounted) {
        state = [];
      }
      return;
    }

    try {
      final dio = ref.read(apiClientProvider);
      // الخادم يُرجع 20 فقط افتراضياً؛ نطلب عدداً كافياً لكل الأبناء
      final response = await dio.get('assignments', queryParameters: {'per_page': 500});

      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> list = response.data['assignments'] ?? [];
        final List<Assignment> parsed = [];

        for (final item in list) {
          final subject = item['subject'];
          final subjectName = subject != null ? (subject['name_ar'] ?? '') : '';

          // مرفقات متعددة (attachment_urls) مع الرجوع للحقل القديم attachment_url
          final List<String> attachmentUrls = [];
          final rawUrls = item['attachment_urls'];
          if (rawUrls is List) {
            for (final u in rawUrls) {
              final s = u?.toString().trim() ?? '';
              if (s.isNotEmpty) attachmentUrls.add(s);
            }
          }
          if (attachmentUrls.isEmpty) {
            final legacy = item['attachment_url']?.toString().trim() ?? '';
            if (legacy.isNotEmpty) attachmentUrls.add(legacy);
          }
          
          final List<dynamic> submissions = item['submissions'] ?? [];
          for (final sub in submissions) {
            final studentId = sub['student_id']?.toString() ?? '';
            final subId = sub['id']?.toString() ?? '';
            final status = sub['status'] ?? 'pending';
            final teacherNote = sub['teacher_note'];
            
            DateTime publishDate;
            try {
              // created_at يصل بتوقيت UTC؛ نحوّله للتوقيت المحلي حتى يظهر الواجب في يومه الصحيح
              publishDate = DateTime.parse(item['created_at'] ?? item['date_created'] ?? DateTime.now().toString()).toLocal();
            } catch (_) {
              publishDate = DateTime.now();
            }

            DateTime dueDate;
            try {
              dueDate = DateTime.parse(item['due_date']);
            } catch (_) {
              dueDate = DateTime.now().add(const Duration(days: 1));
            }

            parsed.add(
              Assignment(
                id: subId, // Use submission ID as unique identifier for this student's assignment copy
                assignmentId: item['id']?.toString() ?? '',
                studentId: studentId,
                subjectName: subjectName,
                title: item['title'] ?? '',
                content: item['content'] ?? '',
                date: publishDate,
                dueDate: dueDate,
                attachmentUrls: attachmentUrls,
                status: status,
                teacherNote: teacherNote,
                editedAt: DateTime.tryParse(item['edited_at']?.toString() ?? '')?.toLocal(),
              ),
            );
          }
        }

        if (ref.mounted && ref.read(currentParentProvider).id == parent.id) {
          state = parsed;
        }
      }
    } catch (e) {
      debugPrint('Error loading assignments: $e');
    }
  }

  Future<void> refresh() async {
    await _loadFromBackend();
  }

  Future<void> toggleAssignmentStatus(String submissionId, String assignmentId, String studentId) async {
    final assignmentIndex = state.indexWhere((a) => a.id == submissionId);
    if (assignmentIndex == -1) return;

    final currentAssignment = state[assignmentIndex];
    final newStatus = currentAssignment.status == 'pending' ? 'submitted' : 'pending';
    final newNote = newStatus == 'pending' ? null : currentAssignment.teacherNote;

    // Optimistically update the UI state
    final updated = currentAssignment.copyWith(status: newStatus);
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == assignmentIndex) updated else state[i]
    ];

    try {
      final dio = ref.read(apiClientProvider);
      await dio.put('assignments/$assignmentId/submissions', data: {
        'submissions': [
          {
            'student_id': int.parse(studentId),
            'status': newStatus,
            'teacher_note': newNote,
          }
        ]
      });
    } catch (e) {
      // Revert state on error
      debugPrint('Error toggling assignment status: $e');
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == assignmentIndex) currentAssignment else state[i]
      ];
      rethrow;
    }
  }
}
