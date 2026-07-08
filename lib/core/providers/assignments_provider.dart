import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/assignment.dart';
import '../network/api_client.dart';
import 'parent_provider.dart';

part 'assignments_provider.g.dart';

@Riverpod(keepAlive: true)
class Assignments extends _$Assignments {
  @override
  List<Assignment> build() {
    _loadFromBackend();
    return [];
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
      final response = await dio.get('assignments');

      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> list = response.data['assignments'] ?? [];
        final List<Assignment> parsed = [];

        for (final item in list) {
          final subject = item['subject'];
          final subjectName = subject != null ? (subject['name_ar'] ?? '') : '';
          
          final List<dynamic> submissions = item['submissions'] ?? [];
          for (final sub in submissions) {
            final studentId = sub['student_id']?.toString() ?? '';
            final subId = sub['id']?.toString() ?? '';
            final status = sub['status'] ?? 'pending';
            final teacherNote = sub['teacher_note'];
            
            DateTime publishDate;
            try {
              publishDate = DateTime.parse(item['created_at'] ?? item['date_created'] ?? DateTime.now().toString());
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
                studentId: studentId,
                subjectName: subjectName,
                title: item['title'] ?? '',
                content: item['content'] ?? '',
                date: publishDate,
                dueDate: dueDate,
                attachmentUrl: item['attachment_url'],
                status: status,
                teacherNote: teacherNote,
              ),
            );
          }
        }

        if (ref.mounted) {
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
