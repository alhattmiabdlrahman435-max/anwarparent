import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const int _cacheVersion = 1;

  static String _getChildrenKey(String parentId) =>
      'cache_v${_cacheVersion}_p${parentId}_children';

  static String _getGradesKey(String parentId, String studentId) =>
      'cache_v${_cacheVersion}_p${parentId}_s${studentId}_grades';

  /// Save children list to SharedPreferences for a specific parent
  static Future<void> saveChildren(String parentId, List<dynamic> jsonList) async {
    if (parentId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = jsonEncode({
        'version': _cacheVersion,
        'timestamp': DateTime.now().toIso8601String(),
        'data': jsonList,
      });
      await prefs.setString(_getChildrenKey(parentId), payload);
    } catch (e) {
      debugPrint('Error saving cached children: $e');
    }
  }

  /// Retrieve cached children list for a specific parent
  static Future<Map<String, dynamic>?> getCachedChildren(String parentId) async {
    if (parentId.isEmpty) return null;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_getChildrenKey(parentId));
      if (raw == null || raw.isEmpty) return null;

      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      if (decoded['version'] != _cacheVersion) return null;
      return decoded;
    } catch (e) {
      debugPrint('Error reading cached children: $e');
      return null;
    }
  }

  /// Save student grades list to SharedPreferences
  static Future<void> saveGrades(String parentId, String studentId, List<dynamic> jsonList) async {
    if (parentId.isEmpty || studentId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = jsonEncode({
        'version': _cacheVersion,
        'timestamp': DateTime.now().toIso8601String(),
        'data': jsonList,
      });
      await prefs.setString(_getGradesKey(parentId, studentId), payload);
    } catch (e) {
      debugPrint('Error saving cached grades: $e');
    }
  }

  /// Retrieve cached student grades list
  static Future<Map<String, dynamic>?> getCachedGrades(String parentId, String studentId) async {
    if (parentId.isEmpty || studentId.isEmpty) return null;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_getGradesKey(parentId, studentId));
      if (raw == null || raw.isEmpty) return null;

      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      if (decoded['version'] != _cacheVersion) return null;
      return decoded;
    } catch (e) {
      debugPrint('Error reading cached grades: $e');
      return null;
    }
  }

  /// Clear cache for a parent
  static Future<void> clearParentCache(String parentId) async {
    if (parentId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.contains('_p${parentId}_')).toList();
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      debugPrint('Error clearing parent cache: $e');
    }
  }
}
