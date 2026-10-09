import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/grade.dart';
import '../models/student.dart';
import '../network/api_client.dart';
import '../network/pusher_service.dart';
import '../services/cache_service.dart';
import 'children_provider.dart';
import 'parent_provider.dart';

part 'grades_provider.g.dart';

@Riverpod(keepAlive: true)
class GradesStatus extends _$GradesStatus {
  @override
  Map<String, dynamic> build() => {'isFromCache': false, 'lastUpdated': null};

  void update({required bool isFromCache, DateTime? lastUpdated}) {
    state = {'isFromCache': isFromCache, 'lastUpdated': lastUpdated};
  }
}

@Riverpod(keepAlive: true)
class Grades extends _$Grades {
  List<String> _loadedKidIds = [];
  String? _subscribedParentId;

  @override
  List<SubjectGrade> build() {
    final kids = ref.watch(childrenProvider);
    if (kids.isEmpty) {
      _loadedKidIds = [];
      return [];
    }

    final kidIds = kids.map((k) => k.id).toList();
    if (listEquals(_loadedKidIds, kidIds) && _loadedKidIds.isNotEmpty) {
      return state;
    }

    _loadedKidIds = kidIds;
    Future.microtask(() {
      _setupRealtimeListener(kids);
      _loadGradesForKids(kids);
    });

    return [];
  }

  void _setupRealtimeListener(List<Student> kids) {
    final parent = ref.read(currentParentProvider);
    if (parent.id.isEmpty) return;

    if (_subscribedParentId == parent.id) return;
    _subscribedParentId = parent.id;

    final parentIdStr = parent.id;

    void handleRealtimeEvent(Map<String, dynamic> payload) {
      final currentParent = ref.read(currentParentProvider);
      final currentKids = ref.read(childrenProvider);
      final currentKidIdsSet = currentKids.map((k) => k.id).toSet();
      final currentParentIdStr = currentParent.id;

      final eventStudentId = PusherService.extractStudentId(payload);
      final eventParentId = PusherService.extractParentId(payload);
      final type = payload['type']?.toString() ?? '';

      // Check if event targets current parent or any of parent's children
      final isTargetParent = eventParentId != null && eventParentId == currentParentIdStr;
      final isTargetStudent = eventStudentId != null && currentKidIdsSet.contains(eventStudentId);
      final isGradeEvent = type.contains('grade') || type.contains('Grade');

      if (isTargetParent || isTargetStudent || isGradeEvent) {
        debugPrint("⚡ [Realtime Grades] Matched event for student ($eventStudentId). Refreshing grades via HTTP API...");
        refresh(studentId: eventStudentId);
      } else {
        debugPrint("⏭️ [Realtime Grades] Event ignored - not targeted at current parent or children.");
      }
    }

    // Subscribe to public channel and user channel with deduplication
    PusherService().subscribe('public-notifications', 'Illuminate\\Notifications\\Events\\BroadcastNotificationCreated', handleRealtimeEvent);
    PusherService().subscribe('public-notifications', 'grade_published', handleRealtimeEvent);
    PusherService().subscribe('App.Models.User.$parentIdStr', 'Illuminate\\Notifications\\Events\\BroadcastNotificationCreated', handleRealtimeEvent);
  }

  Future<void> _loadGradesForKids(List<Student> kids, {String? targetStudentId}) async {
    final parentId = ref.read(currentParentProvider).id;
    if (parentId.isEmpty) return;

    final kidsToFetch = (targetStudentId != null && targetStudentId.isNotEmpty)
        ? kids.where((k) => k.id == targetStudentId).toList()
        : kids;

    if (kidsToFetch.isEmpty) return;

    // Step 1: Read from local Cache first (Cache-First)
    try {
      final List<SubjectGrade> cachedGrades = [];
      DateTime? latestCacheTime;

      for (final kid in kidsToFetch) {
        final cached = await CacheService.getCachedGrades(parentId, kid.id);
        if (cached != null && cached['data'] != null) {
          final List<dynamic> list = cached['data'];
          final parsedTime = cached['timestamp'] != null ? DateTime.tryParse(cached['timestamp']) : null;
          if (parsedTime != null && (latestCacheTime == null || parsedTime.isAfter(latestCacheTime))) {
            latestCacheTime = parsedTime;
          }

          final Map<int, List<dynamic>> grouped = {};
          for (final record in list) {
            final subjectId = int.tryParse(record['subject_id']?.toString() ?? '') ?? 0;
            if (subjectId == 0) continue;
            grouped.putIfAbsent(subjectId, () => []).add(record);
          }

          grouped.forEach((subjectId, records) {
            final firstRecord = records.first;
            final subjectName = firstRecord['subject']?['name_ar'] ?? '';
            final iconName = _getIconForSubject(subjectName);
            final term1Grade = _buildTermGrade(records, 'term1');
            final term2Grade = _buildTermGrade(records, 'term2');

            cachedGrades.add(
              SubjectGrade(
                id: '${kid.id}_$subjectId',
                studentId: kid.id,
                subjectName: subjectName,
                iconName: iconName,
                term1: term1Grade,
                term2: term2Grade,
              ),
            );
          });
        }
      }

      if (cachedGrades.isNotEmpty && ref.mounted && ref.read(currentParentProvider).id == parentId) {
        if (targetStudentId != null && targetStudentId.isNotEmpty) {
          // Merge targeted student cache with existing state for other kids
          final remaining = state.where((g) => g.studentId != targetStudentId).toList();
          state = [...remaining, ...cachedGrades];
        } else {
          state = cachedGrades;
        }
        ref.read(gradesStatusProvider.notifier).update(
          isFromCache: true,
          lastUpdated: latestCacheTime,
        );
      }
    } catch (e) {
      debugPrint('Error reading grades cache: $e');
    }

    // Step 2: Fetch fresh data from HTTP API in background
    try {
      final dio = ref.read(apiClientProvider);

      final results = await Future.wait(
        kidsToFetch.map((kid) async {
          try {
            final response = await dio.get('grades/detailed/${kid.id}');
            if (response.data != null && response.data['success'] == true) {
              final List<dynamic> list = response.data['grades'] ?? [];

              // Save fresh response to local cache
              await CacheService.saveGrades(parentId, kid.id, list);

              final Map<int, List<dynamic>> grouped = {};
              for (final record in list) {
                final subjectId = int.tryParse(record['subject_id']?.toString() ?? '') ?? 0;
                if (subjectId == 0) continue;
                grouped.putIfAbsent(subjectId, () => []).add(record);
              }

              final List<SubjectGrade> kidGrades = [];
              grouped.forEach((subjectId, records) {
                final firstRecord = records.first;
                final subjectName = firstRecord['subject']?['name_ar'] ?? '';
                final iconName = _getIconForSubject(subjectName);
                final term1Grade = _buildTermGrade(records, 'term1');
                final term2Grade = _buildTermGrade(records, 'term2');

                kidGrades.add(
                  SubjectGrade(
                    id: '${kid.id}_$subjectId',
                    studentId: kid.id,
                    subjectName: subjectName,
                    iconName: iconName,
                    term1: term1Grade,
                    term2: term2Grade,
                  ),
                );
              });
              return kidGrades;
            }
          } catch (e) {
            debugPrint('Error loading HTTP grades for student ${kid.id}: $e');
          }
          return <SubjectGrade>[];
        }),
      );

      if (!ref.mounted) return;
      if (ref.read(currentParentProvider).id != parentId) return;

      final freshFetchedGrades = results.expand((grades) => grades).toList();
      if (freshFetchedGrades.isNotEmpty) {
        if (targetStudentId != null && targetStudentId.isNotEmpty) {
          // Merge targeted fresh grades with existing state for other kids
          final remaining = state.where((g) => g.studentId != targetStudentId).toList();
          state = [...remaining, ...freshFetchedGrades];
        } else {
          state = freshFetchedGrades;
        }
        ref.read(gradesStatusProvider.notifier).update(
          isFromCache: false,
          lastUpdated: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('Error loading detailed grades: $e');
    }
  }

  Future<void> refresh({String? studentId}) async {
    final kids = ref.read(childrenProvider);
    if (kids.isNotEmpty) {
      await _loadGradesForKids(kids, targetStudentId: studentId);
    }
  }

  String _getIconForSubject(String name) {
    if (name.contains('رياضيات')) return 'function';
    if (name.contains('علوم')) return 'lab_flask';
    if (name.contains('لغتي') || name.contains('عربي') || name.contains('اللغة العربية')) return 'book';
    return 'book';
  }

  TermGrade _buildTermGrade(List<dynamic> records, String termKey) {
    final termRecords = records.where((r) => r['term'] == termKey).toList();

    final m1 = termRecords.firstWhere((r) => r['month'] == 'm1', orElse: () => null);
    final m2 = termRecords.firstWhere((r) => r['month'] == 'm2', orElse: () => null);
    final m3 = termRecords.firstWhere((r) => r['month'] == 'm3', orElse: () => null);
    final finalExamRecord = termRecords.firstWhere((r) => r['month'] == 'final', orElse: () => null);

    return TermGrade(
      month1: _buildMonthlyGrade('المحصلة الأولى', m1),
      month2: _buildMonthlyGrade('المحصلة الثانية', m2),
      month3: _buildMonthlyGrade('المحصلة الثالثة', m3),
      termExam: finalExamRecord != null ? (double.tryParse(finalExamRecord['final_exam']?.toString() ?? '0') ?? 0.0) : 0.0,
    );
  }

  MonthlyGrade _buildMonthlyGrade(String name, dynamic record) {
    if (record == null) {
      return MonthlyGrade(
        monthName: name,
        homework: 0.0,
        attendance: 0.0,
        behavior: 0.0,
        oral: 0.0,
        written: 0.0,
      );
    }

    return MonthlyGrade(
      monthName: name,
      homework: double.tryParse(record['hw_grade']?.toString() ?? '0') ?? 0.0,
      attendance: double.tryParse(record['att_grade']?.toString() ?? '0') ?? 0.0,
      behavior: double.tryParse(record['beh_grade']?.toString() ?? '0') ?? 0.0,
      oral: double.tryParse(record['oral_grade']?.toString() ?? '0') ?? 0.0,
      written: double.tryParse(record['wrt_grade']?.toString() ?? '0') ?? 0.0,
    );
  }
}
