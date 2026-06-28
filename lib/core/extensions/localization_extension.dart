import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

extension LocalizationExtension on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this)!;

  String translateMock(String mock) {
    switch (mock) {
      case 'الرياضيات':
        return loc.math;
      case 'العلوم':
        return loc.science;
      case 'اللغة العربية':
        return loc.arabicLanguage;
      case 'اللغة الإنجليزية':
        return loc.englishLanguage;
      case 'القرآن الكريم':
        return loc.quran;
      case 'الاجتماعيات':
        return loc.socialStudies;
      case 'التاريخ':
        return loc.history;
      case 'الفيزياء':
        return loc.physics;
      case 'الشهر الأول':
        return loc.month1;
      case 'الشهر الثاني':
        return loc.month2;
      case 'الشهر الثالث':
        return loc.month3;
      case 'الشهر الرابع':
        return loc.month4;
      case 'الشهر الخامس':
        return loc.month5;
      case 'الشهر السادس':
        return loc.month6;
      case 'اختبار نهاية الترم':
        return loc.finalExam;
      case 'حل التمارين صفحة 45 من كتاب الطالب.':
        return loc.assignmentMath;
      case 'مراجعة الفصل الثالث استعداداً للاختبار.':
        return loc.assignmentScience;
      case 'كتابة موضوع تعبير عن أهمية القراءة.':
        return loc.assignmentArabic;
      case 'تلخيص الدرس الثاني.':
        return loc.assignmentHistory;
      case 'حل مسائل الحركة بتسارع ثابت.':
        return loc.assignmentPhysics;
      case 'حفظ سورة النبأ.':
        return loc.assignmentQuran;
      case 'جدول الضرب من 1 إلى 5.':
        return loc.assignmentMath2;
      case 'تسميع سورة البقرة من آية 1 إلى 50':
        return loc.examQuran1;
      case 'تسميع سورة البقرة من 50 إلى 100':
        return loc.examQuran2;
      case 'الباب الأول فقط':
        return loc.examMath1;
      case 'شامل':
        return loc.examMath2;
      case 'النصوص والقواعد النحوية':
        return loc.examArabic;
      case 'الوحدة الثانية':
        return loc.examScience;
      case 'الجغرافيا والتاريخ':
        return loc.examSocial;
      case 'شامل كامل الكتاب':
        return loc.examEnglish;
      case 'أحمد محمد عبدالله':
        return loc.childName1;
      case 'سارة محمد عبدالله':
        return loc.childName2;
      case 'عمر محمد عبدالله':
        return loc.childName3;
      case 'الصف الخامس - شعبة (أ)':
        return loc.childGrade1;
      case 'الصف الثالث - شعبة (ب)':
        return loc.childGrade2;
      case 'الصف الأول - شعبة (ج)':
        return loc.childGrade3;
      case 'محمد عبدالله':
        return loc.localeName == 'en' ? 'Mohammed Abdullah' : 'محمد عبدالله';
      case 'التربية الإسلامية':
        return loc.islamicStudies;
      case 'التربية البدنية':
        return loc.physicalEducation;
      case 'الرسم الفني':
        return loc.art;
      case 'نشاط حر':
        return loc.freeActivity;
      case '08:00 ص - 09:30 ص':
        return loc.localeName == 'en' ? '08:00 AM - 09:30 AM' : '08:00 ص - 09:30 ص';
      case '08:00 ص - 10:00 ص':
        return loc.localeName == 'en' ? '08:00 AM - 10:00 AM' : '08:00 ص - 10:00 ص';
      default:
        return mock;
    }
  }
}
