import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/class_schedule.dart';

part 'schedule_provider.g.dart';

@riverpod
class ClassSchedules extends _$ClassSchedules {
  @override
  List<ClassSchedule> build() {
    return _mockSchedules;
  }

  ClassSchedule? getScheduleForStudent(String studentId) {
    try {
      return state.firstWhere((s) => s.studentId == studentId);
    } catch (_) {
      return null;
    }
  }
}

const _mockSchedules = [
  // Student 1 - Ahmed (Grade 5)
  ClassSchedule(
    studentId: '1',
    days: [
      ClassScheduleDay(
        dayKey: 'saturday',
        periods: [
          ClassPeriod(periodNumber: 1, subjectName: 'القرآن الكريم', startTime: '08:00', endTime: '08:45', teacherName: 'أ/ خالد منصور'),
          ClassPeriod(periodNumber: 2, subjectName: 'الرياضيات', startTime: '08:45', endTime: '09:30', teacherName: 'أ/ علي الكحلاني'),
          ClassPeriod(periodNumber: 3, subjectName: 'اللغة العربية', startTime: '09:45', endTime: '10:30', teacherName: 'أ/ عبدالله الصنعاني'),
          ClassPeriod(periodNumber: 4, subjectName: 'العلوم', startTime: '10:30', endTime: '11:15', teacherName: 'أ/ محمد الحيمي'),
          ClassPeriod(periodNumber: 5, subjectName: 'اللغة الإنجليزية', startTime: '11:30', endTime: '12:15', teacherName: 'Mr. James'),
          ClassPeriod(periodNumber: 6, subjectName: 'الاجتماعيات', startTime: '12:15', endTime: '01:00', teacherName: 'أ/ يحيى عياش'),
          ClassPeriod(periodNumber: 7, subjectName: 'التربية البدنية', startTime: '01:00', endTime: '01:45', teacherName: 'أ/ طارق صالح'),
        ],
      ),
      ClassScheduleDay(
        dayKey: 'sunday',
        periods: [
          ClassPeriod(periodNumber: 1, subjectName: 'القرآن الكريم', startTime: '08:00', endTime: '08:45', teacherName: 'أ/ خالد منصور'),
          ClassPeriod(periodNumber: 2, subjectName: 'اللغة العربية', startTime: '08:45', endTime: '09:30', teacherName: 'أ/ عبدالله الصنعاني'),
          ClassPeriod(periodNumber: 3, subjectName: 'الرياضيات', startTime: '09:45', endTime: '10:30', teacherName: 'أ/ علي الكحلاني'),
          ClassPeriod(periodNumber: 4, subjectName: 'التربية الإسلامية', startTime: '10:30', endTime: '11:15', teacherName: 'أ/ أحمد الجبلي'),
          ClassPeriod(periodNumber: 5, subjectName: 'العلوم', startTime: '11:30', endTime: '12:15', teacherName: 'أ/ محمد الحيمي'),
          ClassPeriod(periodNumber: 6, subjectName: 'اللغة الإنجليزية', startTime: '12:15', endTime: '01:00', teacherName: 'Mr. James'),
          ClassPeriod(periodNumber: 7, subjectName: 'الرسم الفني', startTime: '01:00', endTime: '01:45', teacherName: 'أ/ عادل فارع'),
        ],
      ),
      ClassScheduleDay(
        dayKey: 'monday',
        periods: [
          ClassPeriod(periodNumber: 1, subjectName: 'الرياضيات', startTime: '08:00', endTime: '08:45', teacherName: 'أ/ علي الكحلاني'),
          ClassPeriod(periodNumber: 2, subjectName: 'العلوم', startTime: '08:45', endTime: '09:30', teacherName: 'أ/ محمد الحيمي'),
          ClassPeriod(periodNumber: 3, subjectName: 'القرآن الكريم', startTime: '09:45', endTime: '10:30', teacherName: 'أ/ خالد منصور'),
          ClassPeriod(periodNumber: 4, subjectName: 'اللغة العربية', startTime: '10:30', endTime: '11:15', teacherName: 'أ/ عبدالله الصنعاني'),
          ClassPeriod(periodNumber: 5, subjectName: 'التربية الإسلامية', startTime: '11:30', endTime: '12:15', teacherName: 'أ/ أحمد الجبلي'),
          ClassPeriod(periodNumber: 6, subjectName: 'الاجتماعيات', startTime: '12:15', endTime: '01:00', teacherName: 'أ/ يحيى عياش'),
          ClassPeriod(periodNumber: 7, subjectName: 'نشاط حر', startTime: '01:00', endTime: '01:45', teacherName: 'أ/ طارق صالح'),
        ],
      ),
      ClassScheduleDay(
        dayKey: 'tuesday',
        periods: [
          ClassPeriod(periodNumber: 1, subjectName: 'اللغة العربية', startTime: '08:00', endTime: '08:45', teacherName: 'أ/ عبدالله الصنعاني'),
          ClassPeriod(periodNumber: 2, subjectName: 'اللغة الإنجليزية', startTime: '08:45', endTime: '09:30', teacherName: 'Mr. James'),
          ClassPeriod(periodNumber: 3, subjectName: 'الرياضيات', startTime: '09:45', endTime: '10:30', teacherName: 'أ/ علي الكحلاني'),
          ClassPeriod(periodNumber: 4, subjectName: 'القرآن الكريم', startTime: '10:30', endTime: '11:15', teacherName: 'أ/ خالد منصور'),
          ClassPeriod(periodNumber: 5, subjectName: 'العلوم', startTime: '11:30', endTime: '12:15', teacherName: 'أ/ محمد الحيمي'),
          ClassPeriod(periodNumber: 6, subjectName: 'التربية الإسلامية', startTime: '12:15', endTime: '01:00', teacherName: 'أ/ أحمد الجبلي'),
          ClassPeriod(periodNumber: 7, subjectName: 'التربية البدنية', startTime: '01:00', endTime: '01:45', teacherName: 'أ/ طارق صالح'),
        ],
      ),
      ClassScheduleDay(
        dayKey: 'wednesday',
        periods: [
          ClassPeriod(periodNumber: 1, subjectName: 'العلوم', startTime: '08:00', endTime: '08:45', teacherName: 'أ/ محمد الحيمي'),
          ClassPeriod(periodNumber: 2, subjectName: 'الرياضيات', startTime: '08:45', endTime: '09:30', teacherName: 'أ/ علي الكحلاني'),
          ClassPeriod(periodNumber: 3, subjectName: 'اللغة الإنجليزية', startTime: '09:45', endTime: '10:30', teacherName: 'Mr. James'),
          ClassPeriod(periodNumber: 4, subjectName: 'اللغة العربية', startTime: '10:30', endTime: '11:15', teacherName: 'أ/ عبدالله الصنعاني'),
          ClassPeriod(periodNumber: 5, subjectName: 'القرآن الكريم', startTime: '11:30', endTime: '12:15', teacherName: 'أ/ خالد منصور'),
          ClassPeriod(periodNumber: 6, subjectName: 'الاجتماعيات', startTime: '12:15', endTime: '01:00', teacherName: 'أ/ يحيى عياش'),
          ClassPeriod(periodNumber: 7, subjectName: 'نشاط حر', startTime: '01:00', endTime: '01:45', teacherName: 'أ/ طارق صالح'),
        ],
      ),
    ],
  ),

  // Student 2 - Sarah (Grade 3)
  ClassSchedule(
    studentId: '2',
    days: [
      ClassScheduleDay(
        dayKey: 'saturday',
        periods: [
          ClassPeriod(periodNumber: 1, subjectName: 'القرآن الكريم', startTime: '08:00', endTime: '08:45', teacherName: 'أ/ خالد منصور'),
          ClassPeriod(periodNumber: 2, subjectName: 'اللغة العربية', startTime: '08:45', endTime: '09:30', teacherName: 'أ/ عبدالله الصنعاني'),
          ClassPeriod(periodNumber: 3, subjectName: 'الرياضيات', startTime: '09:45', endTime: '10:30', teacherName: 'أ/ علي الكحلاني'),
          ClassPeriod(periodNumber: 4, subjectName: 'الرسم الفني', startTime: '10:30', endTime: '11:15', teacherName: 'أ/ عادل فارع'),
          ClassPeriod(periodNumber: 5, subjectName: 'التربية الإسلامية', startTime: '11:30', endTime: '12:15', teacherName: 'أ/ أحمد الجبلي'),
          ClassPeriod(periodNumber: 6, subjectName: 'العلوم', startTime: '12:15', endTime: '01:00', teacherName: 'أ/ محمد الحيمي'),
          ClassPeriod(periodNumber: 7, subjectName: 'نشاط حر', startTime: '01:00', endTime: '01:45', teacherName: 'أ/ طارق صالح'),
        ],
      ),
      ClassScheduleDay(
        dayKey: 'sunday',
        periods: [
          ClassPeriod(periodNumber: 1, subjectName: 'الرياضيات', startTime: '08:00', endTime: '08:45', teacherName: 'أ/ علي الكحلاني'),
          ClassPeriod(periodNumber: 2, subjectName: 'العلوم', startTime: '08:45', endTime: '09:30', teacherName: 'أ/ محمد الحيمي'),
          ClassPeriod(periodNumber: 3, subjectName: 'اللغة العربية', startTime: '09:45', endTime: '10:30', teacherName: 'أ/ عبدالله الصنعاني'),
          ClassPeriod(periodNumber: 4, subjectName: 'القرآن الكريم', startTime: '10:30', endTime: '11:15', teacherName: 'أ/ خالد منصور'),
          ClassPeriod(periodNumber: 5, subjectName: 'اللغة الإنجليزية', startTime: '11:30', endTime: '12:15', teacherName: 'Mr. James'),
          ClassPeriod(periodNumber: 6, subjectName: 'التربية الإسلامية', startTime: '12:15', endTime: '01:00', teacherName: 'أ/ أحمد الجبلي'),
          ClassPeriod(periodNumber: 7, subjectName: 'التربية البدنية', startTime: '01:00', endTime: '01:45', teacherName: 'أ/ طارق صالح'),
        ],
      ),
      ClassScheduleDay(
        dayKey: 'monday',
        periods: [
          ClassPeriod(periodNumber: 1, subjectName: 'اللغة العربية', startTime: '08:00', endTime: '08:45', teacherName: 'أ/ عبدالله الصنعاني'),
          ClassPeriod(periodNumber: 2, subjectName: 'القرآن الكريم', startTime: '08:45', endTime: '09:30', teacherName: 'أ/ خالد منصور'),
          ClassPeriod(periodNumber: 3, subjectName: 'الرياضيات', startTime: '09:45', endTime: '10:30', teacherName: 'أ/ علي الكحلاني'),
          ClassPeriod(periodNumber: 4, subjectName: 'اللغة الإنجليزية', startTime: '10:30', endTime: '11:15', teacherName: 'Mr. James'),
          ClassPeriod(periodNumber: 5, subjectName: 'العلوم', startTime: '11:30', endTime: '12:15', teacherName: 'أ/ محمد الحيمي'),
          ClassPeriod(periodNumber: 6, subjectName: 'الرسم الفني', startTime: '12:15', endTime: '01:00', teacherName: 'أ/ عادل فارع'),
          ClassPeriod(periodNumber: 7, subjectName: 'نشاط حر', startTime: '01:00', endTime: '01:45', teacherName: 'أ/ طارق صالح'),
        ],
      ),
      ClassScheduleDay(
        dayKey: 'tuesday',
        periods: [
          ClassPeriod(periodNumber: 1, subjectName: 'التربية الإسلامية', startTime: '08:00', endTime: '08:45', teacherName: 'أ/ أحمد الجبلي'),
          ClassPeriod(periodNumber: 2, subjectName: 'الرياضيات', startTime: '08:45', endTime: '09:30', teacherName: 'أ/ علي الكحلاني'),
          ClassPeriod(periodNumber: 3, subjectName: 'اللغة العربية', startTime: '09:45', endTime: '10:30', teacherName: 'أ/ عبدالله الصنعاني'),
          ClassPeriod(periodNumber: 4, subjectName: 'العلوم', startTime: '10:30', endTime: '11:15', teacherName: 'أ/ محمد الحيمي'),
          ClassPeriod(periodNumber: 5, subjectName: 'القرآن الكريم', startTime: '11:30', endTime: '12:15', teacherName: 'أ/ خالد منصور'),
          ClassPeriod(periodNumber: 6, subjectName: 'اللغة الإنجليزية', startTime: '12:15', endTime: '01:00', teacherName: 'Mr. James'),
          ClassPeriod(periodNumber: 7, subjectName: 'التربية البدنية', startTime: '01:00', endTime: '01:45', teacherName: 'أ/ طارق صالح'),
        ],
      ),
      ClassScheduleDay(
        dayKey: 'wednesday',
        periods: [
          ClassPeriod(periodNumber: 1, subjectName: 'اللغة الإنجليزية', startTime: '08:00', endTime: '08:45', teacherName: 'Mr. James'),
          ClassPeriod(periodNumber: 2, subjectName: 'اللغة العربية', startTime: '08:45', endTime: '09:30', teacherName: 'أ/ عبدالله الصنعاني'),
          ClassPeriod(periodNumber: 3, subjectName: 'القرآن الكريم', startTime: '09:45', endTime: '10:30', teacherName: 'أ/ خالد منصور'),
          ClassPeriod(periodNumber: 4, subjectName: 'الرياضيات', startTime: '10:30', endTime: '11:15', teacherName: 'أ/ علي الكحلاني'),
          ClassPeriod(periodNumber: 5, subjectName: 'العلوم', startTime: '11:30', endTime: '12:15', teacherName: 'أ/ محمد الحيمي'),
          ClassPeriod(periodNumber: 6, subjectName: 'التربية الإسلامية', startTime: '12:15', endTime: '01:00', teacherName: 'أ/ أحمد الجبلي'),
          ClassPeriod(periodNumber: 7, subjectName: 'نشاط حر', startTime: '01:00', endTime: '01:45', teacherName: 'أ/ طارق صالح'),
        ],
      ),
    ],
  ),

  // Student 3 - Omar (Grade 1)
  ClassSchedule(
    studentId: '3',
    days: [
      ClassScheduleDay(
        dayKey: 'saturday',
        periods: [
          ClassPeriod(periodNumber: 1, subjectName: 'القرآن الكريم', startTime: '08:00', endTime: '08:45', teacherName: 'أ/ خالد منصور'),
          ClassPeriod(periodNumber: 2, subjectName: 'القرآن الكريم', startTime: '08:45', endTime: '09:30', teacherName: 'أ/ خالد منصور'),
          ClassPeriod(periodNumber: 3, subjectName: 'اللغة العربية', startTime: '09:45', endTime: '10:30', teacherName: 'أ/ عبدالله الصنعاني'),
          ClassPeriod(periodNumber: 4, subjectName: 'الرياضيات', startTime: '10:30', endTime: '11:15', teacherName: 'أ/ علي الكحلاني'),
          ClassPeriod(periodNumber: 5, subjectName: 'الرسم الفني', startTime: '11:30', endTime: '12:15', teacherName: 'أ/ عادل فارع'),
          ClassPeriod(periodNumber: 6, subjectName: 'التربية البدنية', startTime: '12:15', endTime: '01:00', teacherName: 'أ/ طارق صالح'),
          ClassPeriod(periodNumber: 7, subjectName: 'نشاط حر', startTime: '01:00', endTime: '01:45', teacherName: 'أ/ طارق صالح'),
        ],
      ),
      ClassScheduleDay(
        dayKey: 'sunday',
        periods: [
          ClassPeriod(periodNumber: 1, subjectName: 'اللغة العربية', startTime: '08:00', endTime: '08:45', teacherName: 'أ/ عبدالله الصنعاني'),
          ClassPeriod(periodNumber: 2, subjectName: 'اللغة العربية', startTime: '08:45', endTime: '09:30', teacherName: 'أ/ عبدالله الصنعاني'),
          ClassPeriod(periodNumber: 3, subjectName: 'الرياضيات', startTime: '09:45', endTime: '10:30', teacherName: 'أ/ علي الكحلاني'),
          ClassPeriod(periodNumber: 4, subjectName: 'القرآن الكريم', startTime: '10:30', endTime: '11:15', teacherName: 'أ/ خالد منصور'),
          ClassPeriod(periodNumber: 5, subjectName: 'التربية الإسلامية', startTime: '11:30', endTime: '12:15', teacherName: 'أ/ أحمد الجبلي'),
          ClassPeriod(periodNumber: 6, subjectName: 'العلوم', startTime: '12:15', endTime: '01:00', teacherName: 'أ/ محمد الحيمي'),
          ClassPeriod(periodNumber: 7, subjectName: 'نشاط حر', startTime: '01:00', endTime: '01:45', teacherName: 'أ/ طارق صالح'),
        ],
      ),
      ClassScheduleDay(
        dayKey: 'monday',
        periods: [
          ClassPeriod(periodNumber: 1, subjectName: 'الرياضيات', startTime: '08:00', endTime: '08:45', teacherName: 'أ/ علي الكحلاني'),
          ClassPeriod(periodNumber: 2, subjectName: 'الرياضيات', startTime: '08:45', endTime: '09:30', teacherName: 'أ/ علي الكحلاني'),
          ClassPeriod(periodNumber: 3, subjectName: 'القرآن الكريم', startTime: '09:45', endTime: '10:30', teacherName: 'أ/ خالد منصور'),
          ClassPeriod(periodNumber: 4, subjectName: 'اللغة العربية', startTime: '10:30', endTime: '11:15', teacherName: 'أ/ عبدالله الصنعاني'),
          ClassPeriod(periodNumber: 5, subjectName: 'اللغة الإنجليزية', startTime: '11:30', endTime: '12:15', teacherName: 'Mr. James'),
          ClassPeriod(periodNumber: 6, subjectName: 'الرسم الفني', startTime: '12:15', endTime: '01:00', teacherName: 'أ/ عادل فارع'),
          ClassPeriod(periodNumber: 7, subjectName: 'نشاط حر', startTime: '01:00', endTime: '01:45', teacherName: 'أ/ طارق صالح'),
        ],
      ),
      ClassScheduleDay(
        dayKey: 'tuesday',
        periods: [
          ClassPeriod(periodNumber: 1, subjectName: 'القرآن الكريم', startTime: '08:00', endTime: '08:45', teacherName: 'أ/ خالد منصور'),
          ClassPeriod(periodNumber: 2, subjectName: 'اللغة العربية', startTime: '08:45', endTime: '09:30', teacherName: 'أ/ عبدالله الصنعاني'),
          ClassPeriod(periodNumber: 3, subjectName: 'التربية الإسلامية', startTime: '09:45', endTime: '10:30', teacherName: 'أ/ أحمد الجبلي'),
          ClassPeriod(periodNumber: 4, subjectName: 'الرياضيات', startTime: '10:30', endTime: '11:15', teacherName: 'أ/ علي الكحلاني'),
          ClassPeriod(periodNumber: 5, subjectName: 'العلوم', startTime: '11:30', endTime: '12:15', teacherName: 'أ/ محمد الحيمي'),
          ClassPeriod(periodNumber: 6, subjectName: 'التربية البدنية', startTime: '12:15', endTime: '01:00', teacherName: 'أ/ طارق صالح'),
          ClassPeriod(periodNumber: 7, subjectName: 'نشاط حر', startTime: '01:00', endTime: '01:45', teacherName: 'أ/ طارق صالح'),
        ],
      ),
      ClassScheduleDay(
        dayKey: 'wednesday',
        periods: [
          ClassPeriod(periodNumber: 1, subjectName: 'اللغة العربية', startTime: '08:00', endTime: '08:45', teacherName: 'أ/ عبدالله الصنعاني'),
          ClassPeriod(periodNumber: 2, subjectName: 'القرآن الكريم', startTime: '08:45', endTime: '09:30', teacherName: 'أ/ خالد منصور'),
          ClassPeriod(periodNumber: 3, subjectName: 'الرياضيات', startTime: '09:45', endTime: '10:30', teacherName: 'أ/ علي الكحلاني'),
          ClassPeriod(periodNumber: 4, subjectName: 'اللغة الإنجليزية', startTime: '10:30', endTime: '11:15', teacherName: 'Mr. James'),
          ClassPeriod(periodNumber: 5, subjectName: 'التربية الإسلامية', startTime: '11:30', endTime: '12:15', teacherName: 'أ/ أحمد الجبلي'),
          ClassPeriod(periodNumber: 6, subjectName: 'نشاط حر', startTime: '12:15', endTime: '01:00', teacherName: 'أ/ طارق صالح'),
          ClassPeriod(periodNumber: 7, subjectName: 'نشاط حر', startTime: '01:00', endTime: '01:45', teacherName: 'أ/ طارق صالح'),
        ],
      ),
    ],
  ),
];
