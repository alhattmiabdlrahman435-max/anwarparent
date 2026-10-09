import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/student.dart';
import '../network/api_client.dart';
import '../services/cache_service.dart';
import '../utils/constants.dart';
import 'parent_provider.dart';

part 'children_provider.g.dart';

@Riverpod(keepAlive: true)
class ChildrenLoading extends _$ChildrenLoading {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

@Riverpod(keepAlive: true)
class Children extends _$Children {
  String? _loadedParentId;

  @override
  List<Student> build() {
    final parent = ref.watch(currentParentProvider);
    if (parent.id.isEmpty) {
      _loadedParentId = null;
      return [];
    }
    if (_loadedParentId == parent.id && state.isNotEmpty) {
      return state;
    }
    _loadedParentId = parent.id;
    Future.microtask(() => _loadFromBackend());
    return state;
  }

  Future<void> _loadFromBackend() async {
    final parent = ref.read(currentParentProvider);
    if (parent.id.isEmpty) {
      if (ref.mounted) {
        state = [];
      }
      return;
    }

    // 1. Read from local cache first if available
    try {
      final cached = await CacheService.getCachedChildren(parent.id);
      if (cached != null && cached['data'] != null && ref.mounted) {
        final List<dynamic> cachedList = cached['data'];
        final mapped = cachedList.map((item) {
          final schoolClass = item['school_class'] ?? item['schoolClass'];
          final gradeName = schoolClass != null ? (schoolClass['name_ar'] ?? '') : '';
          return Student(
            id: item['id'].toString(),
            name: item['name_ar'] ?? '',
            grade: gradeName,
            classId: item['class_id']?.toString() ?? '',
            photoUrl: AppConstants.normalizeUrl(item['photo_url']),
          );
        }).toList();

        if (ref.mounted && ref.read(currentParentProvider).id == parent.id && mapped.isNotEmpty) {
          state = mapped;
        }
      }
    } catch (e) {
      debugPrint('Error reading children cache: $e');
    }

    // Set loading state to true
    Future.microtask(() {
      if (ref.mounted) {
        ref.read(childrenLoadingProvider.notifier).set(true);
      }
    });

    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.get('parents/${parent.id}/students');

      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> list = response.data['students'] ?? [];

        // Save to cache
        await CacheService.saveChildren(parent.id, list);

        final mapped = list.map((item) {
          final schoolClass = item['school_class'] ?? item['schoolClass'];
          final gradeName = schoolClass != null ? (schoolClass['name_ar'] ?? '') : '';
          return Student(
            id: item['id'].toString(),
            name: item['name_ar'] ?? '',
            grade: gradeName,
            classId: item['class_id']?.toString() ?? '',
            photoUrl: AppConstants.normalizeUrl(item['photo_url']),
          );
        }).toList();

        if (ref.mounted && ref.read(currentParentProvider).id == parent.id) {
          state = mapped;
        }
      }
    } catch (e) {
      debugPrint('Error loading children: $e');
    } finally {
      if (ref.mounted) {
        ref.read(childrenLoadingProvider.notifier).set(false);
      }
    }
  }

  Future<void> refresh() async {
    await _loadFromBackend();
  }
}

@Riverpod(keepAlive: true)
class CurrentChild extends _$CurrentChild {
  String? _selectedChildId;

  @override
  Student? build() {
    final kids = ref.watch(childrenProvider);
    if (kids.isEmpty) return null;

    // If user previously selected a child, try to find it in the updated list
    if (_selectedChildId != null) {
      final found = kids.where((k) => k.id == _selectedChildId).firstOrNull;
      if (found != null) return found;
    }

    // Default to first child only if no prior selection
    return kids.first;
  }

  void setChild(Student child) {
    _selectedChildId = child.id;
    state = child;
  }
}
