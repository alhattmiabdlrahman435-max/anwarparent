import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/student_finance.dart';
import '../network/api_client.dart';
import 'children_provider.dart';

part 'finance_provider.g.dart';

@Riverpod(keepAlive: true)
class Finance extends _$Finance {
  List<StudentFinanceSummary> _cachedFinance = [];

  @override
  List<StudentFinanceSummary> build() {
    final kids = ref.watch(childrenProvider);
    if (kids.isEmpty) {
      _cachedFinance = [];
      return [];
    }

    Future.microtask(() => _loadFinanceForKids(kids));

    return _cachedFinance;
  }

  Future<void> _loadFinanceForKids(List<dynamic> kids) async {
    try {
      final dio = ref.read(apiClientProvider);
      final List<StudentFinanceSummary> allSummaries = [];

      for (final kid in kids) {
        final response = await dio.get('finance/student/${kid.id}');
        if (response.data != null && response.data['success'] == true) {
          final summary = StudentFinanceSummary.fromJson(
            response.data['tuition'] ?? {},
            response.data['payments'] ?? [],
          );
          allSummaries.add(summary);
        }
      }

      if (ref.mounted) {
        _cachedFinance = allSummaries;
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
