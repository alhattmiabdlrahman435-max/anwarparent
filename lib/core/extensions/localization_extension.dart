import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

extension LocalizationExtension on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this)!;

  String translateMock(String mock) {
    switch (mock) {
      case 'الصف الخامس - أ':
        return loc.localeName == 'en' ? 'Grade 5 - A' : 'الصف الخامس - أ';
      case 'الصف السادس - b':
      case 'الصف السادس - ب':
        return loc.localeName == 'en' ? 'Grade 6 - B' : 'الصف السادس - ب';
      case 'لغتي':
        return loc.localeName == 'en' ? 'Arabic (Lughati)' : 'لغتي';
      case 'الرياضيات والعلوم':
        return loc.localeName == 'en' ? '${loc.math} & ${loc.science}' : 'الرياضيات والعلوم';
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
      case 'معلم المادة':
        return loc.localeName == 'en' ? 'Subject Teacher' : 'معلم المادة';
      default:
        return mock;
    }
  }

  String toArabicNumbers(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], arabic[i]);
    }
    return input;
  }
}
