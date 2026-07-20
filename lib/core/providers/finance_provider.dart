import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/student_finance.dart';
import '../models/student.dart';
import '../network/api_client.dart';
import 'children_provider.dart';

part 'finance_provider.g.dart';

@Riverpod(keepAlive: true)
class Finance extends _$Finance {
  List<String> _loadedKidIds = [];

  @override
  FutureOr<List<StudentFinanceSummary>> build() async {
    final kids = ref.watch(childrenProvider);
    if (kids.isEmpty) {
      _loadedKidIds = [];
      return [];
    }

    final kidIds = kids.map((k) => k.id).toList();
    if (listEquals(_loadedKidIds, kidIds) && state.hasValue) {
      return state.requireValue;
    }

    _loadedKidIds = kidIds;
    return _loadFinanceForKids(kids);
  }

  Future<List<StudentFinanceSummary>> _loadFinanceForKids(List<Student> kids) async {
    final dio = ref.read(apiClientProvider);

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

    return results.whereType<StudentFinanceSummary>().toList();
  }

  Future<void> refresh() async {
    final kids = ref.read(childrenProvider);
    if (kids.isNotEmpty) {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() => _loadFinanceForKids(kids));
    }
  }

  StudentFinanceSummary? getFinanceForStudent(String studentId) {
    if (!state.hasValue) return null;
    try {
      return state.requireValue.firstWhere((f) => f.studentId == studentId);
    } catch (_) {
      return null;
    }
  }
}
