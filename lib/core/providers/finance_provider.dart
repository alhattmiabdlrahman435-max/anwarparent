import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/student_finance.dart';
import '../models/student.dart';
import '../network/api_client.dart';
import 'children_provider.dart';

part 'finance_provider.g.dart';

@Riverpod(keepAlive: true)
class Finance extends _$Finance {

  @override
  List<StudentFinanceSummary> build() {
    final kids = ref.watch(childrenProvider);
    if (kids.isEmpty) {
      return [];
    }

    Future.microtask(() => _loadFinanceForKids(kids));

    return state;
  }

  Future<void> _loadFinanceForKids(List<Student> kids) async {
    try {
      final dio = ref.read(apiClientProvider);

      // Load finance for all children in parallel for faster loading
      final results = await Future.wait(
        kids.map((kid) async {
          final response = await dio.get('finance/student/${kid.id}');
          if (response.data != null && response.data['success'] == true) {
            return StudentFinanceSummary.fromJson(
              response.data['tuition'] ?? {},
              response.data['payments'] ?? [],
            );
          }
          return null;
        }),
      );

      final allSummaries = results.whereType<StudentFinanceSummary>().toList();

      if (ref.mounted) {
        state = allSummaries;
      }
    } catch (e) {
      debugPrint('Error loading student finance data: $e');
    }
  }

  Future<void> refresh() async {
    final kids = ref.read(childrenProvider);
    if (kids.isNotEmpty) {
      await _loadFinanceForKids(kids);
    }
  }

  StudentFinanceSummary? getFinanceForStudent(String studentId) {
    try {
      return state.firstWhere((f) => f.studentId == studentId);
    } catch (_) {
      return null;
    }
  }
}
