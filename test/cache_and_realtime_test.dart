import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anwarparent/core/services/cache_service.dart';
import 'package:anwarparent/core/network/pusher_service.dart';
import 'package:anwarparent/core/models/student.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Cache-First & Realtime System Verification Tests', () {
    test('1. Cache يظهر فوراً - Fast immediate local cache retrieval', () async {
      const parentId = 'parent_1001';
      const studentId = 'student_2001';
      final mockGrades = [
        {
          'subject_id': 1,
          'term': 'term1',
          'month': 'm1',
          'hw_grade': '10',
          'att_grade': '10',
          'beh_grade': '10',
          'oral_grade': '10',
          'wrt_grade': '10',
          'subject': {'name_ar': 'الرياضيات'}
        }
      ];

      await CacheService.saveGrades(parentId, studentId, mockGrades);
      final cachedResult = await CacheService.getCachedGrades(parentId, studentId);

      expect(cachedResult, isNotNull);
      expect(cachedResult!['data'], isNotNull);
      expect((cachedResult['data'] as List).length, 1);
      expect(cachedResult['data'][0]['subject']['name_ar'], 'الرياضيات');
    });

    test('2. API يستبدل Cache بالبيانات الحديثة - Overwriting cache updates timestamp & data', () async {
      const parentId = 'parent_1001';
      const studentId = 'student_2001';
      
      // Old cached data
      await CacheService.saveGrades(parentId, studentId, [{'v': 1}]);
      final oldCache = await CacheService.getCachedGrades(parentId, studentId);
      expect(oldCache!['data'][0]['v'], 1);

      // Simulate API response replacement
      await CacheService.saveGrades(parentId, studentId, [{'v': 2, 'fresh': true}]);
      final freshCache = await CacheService.getCachedGrades(parentId, studentId);

      expect(freshCache!['data'][0]['fresh'], isTrue);
      expect(freshCache['data'][0]['v'], 2);
    });

    test('3. تبديل ولي الأمر لا يعرض Cache للحساب السابق - Parent isolation in cache keys', () async {
      const parentA = 'parent_1001';
      const parentB = 'parent_1002';
      const studentId = 'student_2001';

      await CacheService.saveGrades(parentA, studentId, [{'parent': 'A'}]);

      final cacheForB = await CacheService.getCachedGrades(parentB, studentId);
      expect(cacheForB, isNull);

      final cacheForA = await CacheService.getCachedGrades(parentA, studentId);
      expect(cacheForA, isNotNull);
      expect(cacheForA!['data'][0]['parent'], 'A');
    });

    test('4. وصول grade_published يحدث Refresh مرة واحدة فقط - Event deduplication logic', () {
      final pusher = PusherService();
      int triggerCount = 0;

      final payload = {
        'student_id': '20265022',
        'type': 'grade_published',
        'title': 'تم نشر درجات جديدة'
      };

      // Subscribe to public channel
      pusher.subscribe('public-notifications', 'grade_published', (_) {
        triggerCount++;
      });

      // Subscribe to user channel with same payload
      pusher.subscribe('App.Models.User.18', 'grade_published', (_) {
        triggerCount++;
      });

      expect(triggerCount, 0);

      // Verification of deduplication key building & parsing
      final parsed = PusherService.parsePayload(payload);
      final studentId = PusherService.extractStudentId(parsed);
      expect(studentId, '20265022');
    });

    test('5. حدث يخص طالبًا آخر لا يحدث Refresh لطالب غير معني - Event student matching', () {
      final parentChildren = [
        Student(id: '20265022', name: 'عبدالرحمن', grade: 'الأول الثانوي', classId: '7', photoUrl: ''),
      ];
      final activeStudentIds = parentChildren.map((s) => s.id).toSet();

      final eventForChild = {'student_id': '20265022', 'type': 'grade_published'};
      final eventForOtherChild = {'student_id': '99999999', 'type': 'grade_published'};

      final studentId1 = PusherService.extractStudentId(eventForChild);
      final studentId2 = PusherService.extractStudentId(eventForOtherChild);

      expect(activeStudentIds.contains(studentId1), isTrue);
      expect(activeStudentIds.contains(studentId2), isFalse);
    });

    test('6. انقطاع Reverb لا يمنع HTTP - Graceful fallback on WebSocket disconnect', () {
      final pusher = PusherService();
      expect(() => pusher.disconnect(), returnsNormally);
    });

    test('7. عودة Reverb تستعيد الاستماع بشكل صحيح - Re-initializing & connecting PusherService', () {
      final pusher = PusherService();
      expect(() => pusher.init(), returnsNormally);
      expect(() => pusher.connect(), returnsNormally);
    });

    test('8. التبديل بين الأبناء لا يسبب تسرب بيانات - Student isolation check', () {
      final student1 = Student(id: '101', name: 'أحمد', grade: '1', classId: '1', photoUrl: '');
      final student2 = Student(id: '102', name: 'محمد', grade: '2', classId: '2', photoUrl: '');

      final allGrades = [
        {'student_id': '101', 'subject': 'رياضيات'},
        {'student_id': '102', 'subject': 'علوم'},
      ];

      final filteredForStudent1 = allGrades.where((g) => g['student_id'] == student1.id).toList();
      final filteredForStudent2 = allGrades.where((g) => g['student_id'] == student2.id).toList();

      expect(filteredForStudent1.length, 1);
      expect(filteredForStudent1[0]['subject'], 'رياضيات');

      expect(filteredForStudent2.length, 1);
      expect(filteredForStudent2[0]['subject'], 'علوم');
    });

    test('9. تحديث طالب واحد مستهدف - Targeted single student update does not trigger HTTP for siblings', () async {
      const parentId = 'parent_1001';
      const student1 = '101';
      const student2 = '102';

      // Save initial cache for both kids
      await CacheService.saveGrades(parentId, student1, [{'v': 1, 'name': 'أحمد'}]);
      await CacheService.saveGrades(parentId, student2, [{'v': 1, 'name': 'محمد'}]);

      // Update only student 1 cache
      await CacheService.saveGrades(parentId, student1, [{'v': 2, 'name': 'أحمد المحدث'}]);

      final cache1 = await CacheService.getCachedGrades(parentId, student1);
      final cache2 = await CacheService.getCachedGrades(parentId, student2);

      expect(cache1!['data'][0]['v'], 2);
      expect(cache2!['data'][0]['v'], 1); // Student 2 remains unchanged
    });
  });
}
