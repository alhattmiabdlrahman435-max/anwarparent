// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'ولي الأمر';

  @override
  String get home => 'الرئيسية';

  @override
  String get myChildren => 'أبنائي';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get assignments => 'الواجبات';

  @override
  String get attendance => 'الحضور';

  @override
  String get grades => 'الدرجات';

  @override
  String get fees => 'الرسوم الدراسية';

  @override
  String get settings => 'الإعدادات';

  @override
  String get selectChild => 'اختر الابن';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodAfternoon => 'طاب مساؤك';

  @override
  String get goodEvening => 'مساء الخير';

  @override
  String welcomeParent(String name) {
    return 'مرحباً بك، $name';
  }

  @override
  String get parentAccount => 'حساب ولي الأمر';

  @override
  String get quickAccess => 'الوصول السريع';

  @override
  String get absenceRequest => 'طلب غياب';

  @override
  String get absenceRequestsHistory => 'سجل طلبات الغياب';

  @override
  String get rejected => 'مرفوض';

  @override
  String get approved => 'مقبول';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get rejectionReason => 'سبب الرفض:';

  @override
  String get gradesAndAnalytics => 'الدرجات والتحليلات';

  @override
  String get schoolAssignments => 'الواجبات المدرسية';

  @override
  String get attendanceRecord => 'سجل الحضور';

  @override
  String get exams => 'الاختبارات';

  @override
  String get account => 'الحساب';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get editProfile => 'تعديل بيانات الحساب';

  @override
  String get app => 'التطبيق';

  @override
  String get appearance => 'المظهر';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get language => 'اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get activitiesAndMessages => 'الأنشطة والرسائل';

  @override
  String get support => 'الدعم';

  @override
  String get helpCenter => 'مركز المساعدة';

  @override
  String get contactUs => 'تواصل معنا';

  @override
  String get aboutApp => 'عن التطبيق';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirmation => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get generalNotification => 'إشعار عام';

  @override
  String get publicHolidayTomorrow => 'غداً إجازة رسمية.';

  @override
  String get oneHourAgo => 'منذ 1 ساعة';

  @override
  String get privateMessageFromAdmin => 'رسالة خاصة من الإدارة';

  @override
  String get reviewWithAdmin => 'نرجو مراجعة الإدارة بشأن مستوى الطالب.';

  @override
  String get yesterday => 'أمس';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get welcomeBack => 'مرحباً بك مجدداً ولي الأمر';

  @override
  String get phoneNumberOrUsername => 'رقم الهاتف / اسم المستخدم';

  @override
  String get nationalId => 'الرقم الوطني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get pleaseSelectStudent => 'الرجاء اختيار الطالب';

  @override
  String get noAssignmentsForToday => 'لا توجد واجبات لهذا اليوم';

  @override
  String get totalFees => 'إجمالي الرسوم';

  @override
  String get paid => 'تم الدفع';

  @override
  String get remaining => 'المتبقي';

  @override
  String get paymentHistory => 'سجل المدفوعات';

  @override
  String get financialPayment => 'دفعة مالية';

  @override
  String get pleaseSelectChildToViewExams =>
      'الرجاء اختيار ابن لعرض جداول الاختبارات الخاصة به';

  @override
  String get firstSemester => 'الفصل الدراسي الأول';

  @override
  String get secondSemester => 'الفصل الدراسي الثاني';

  @override
  String noScheduleAddedFor(String period) {
    return 'لا يوجد جدول مضاف لـ $period';
  }

  @override
  String get noGradesYet => 'لا توجد درجات حتى الآن';

  @override
  String get finalResultNote => 'المحصلة النهائية (مجموع الأشهر ÷ 15)';

  @override
  String get children => 'الابناء';

  @override
  String get attendanceBehavior => 'المواظبة';

  @override
  String get behavior => 'السلوك';

  @override
  String get oral => 'الشفهي';

  @override
  String get homework => 'الواجب';

  @override
  String get written => 'التحريري';

  @override
  String get midTermFinalExam => 'الاختبار النصفي / النهائي';

  @override
  String get totalTermGrades => 'مجموع درجات الترم';

  @override
  String get totalYearlyGrades => 'المجموع الكلي للمادة (سنة)';

  @override
  String get absenceRequestSentSuccessfully => 'تم إرسال طلب الغياب بنجاح';

  @override
  String get errorSendingAbsenceRequest => 'حدث خطأ أثناء الإرسال';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get reasonOptional => 'السبب (اختياري)';

  @override
  String get noRegisteredStudents => 'لا يوجد طلاب مسجلين';

  @override
  String get exampleMedicalAppointment => 'مثال: موعد طبي...';

  @override
  String get sendAbsenceRequest => 'إرسال طلب الغياب';

  @override
  String get attendanceDays => 'أيام الحضور';

  @override
  String get absenceDays => 'أيام الغياب';

  @override
  String get pleaseSelectStudentToViewAttendance =>
      'الرجاء اختيار الطالب لعرض سجل الحضور';

  @override
  String get saturday => 'السبت';

  @override
  String get sunday => 'الأحد';

  @override
  String get monday => 'الاثنين';

  @override
  String get tuesday => 'الثلاثاء';

  @override
  String get wednesday => 'الأربعاء';

  @override
  String currencySar(String amount) {
    return '$amount ر.ي';
  }

  @override
  String get math => 'الرياضيات';

  @override
  String get science => 'العلوم';

  @override
  String get arabicLanguage => 'اللغة العربية';

  @override
  String get englishLanguage => 'اللغة الإنجليزية';

  @override
  String get quran => 'القرآن الكريم';

  @override
  String get socialStudies => 'الاجتماعيات';

  @override
  String get history => 'التاريخ';

  @override
  String get physics => 'الفيزياء';

  @override
  String get month1 => 'الشهر الأول';

  @override
  String get month2 => 'الشهر الثاني';

  @override
  String get month3 => 'الشهر الثالث';

  @override
  String get month4 => 'الشهر الرابع';

  @override
  String get month5 => 'الشهر الخامس';

  @override
  String get month6 => 'الشهر السادس';

  @override
  String get finalExam => 'اختبار نهاية الترم';

  @override
  String get assignmentMath => 'حل التمارين صفحة 45 من كتاب الطالب.';

  @override
  String get assignmentScience => 'مراجعة الفصل الثالث استعداداً للاختبار.';

  @override
  String get assignmentArabic => 'كتابة موضوع تعبير عن أهمية القراءة.';

  @override
  String get assignmentHistory => 'تلخيص الدرس الثاني.';

  @override
  String get assignmentPhysics => 'حل مسائل الحركة بتسارع ثابت.';

  @override
  String get assignmentQuran => 'حفظ سورة النبأ.';

  @override
  String get assignmentMath2 => 'جدول الضرب من 1 إلى 5.';

  @override
  String get examQuran1 => 'تسميع سورة البقرة من آية 1 إلى 50';

  @override
  String get examQuran2 => 'تسميع سورة البقرة من 50 إلى 100';

  @override
  String get examMath1 => 'الباب الأول فقط';

  @override
  String get examMath2 => 'شامل';

  @override
  String get examArabic => 'النصوص والقواعد النحوية';

  @override
  String get examScience => 'الوحدة الثانية';

  @override
  String get examSocial => 'الجغرافيا والتاريخ';

  @override
  String get examEnglish => 'شامل كامل الكتاب';

  @override
  String get childName1 => 'أحمد محمد عبدالله';

  @override
  String get childGrade1 => 'الصف الخامس - شعبة (أ)';

  @override
  String get childName2 => 'سارة محمد عبدالله';

  @override
  String get childGrade2 => 'الصف الثالث - شعبة (ب)';

  @override
  String get childName3 => 'عمر محمد عبدالله';

  @override
  String get childGrade3 => 'الصف الأول - شعبة (ج)';

  @override
  String get classSchedule => 'جدول الحصص';

  @override
  String get weeklyView => 'جدول الأسبوع';

  @override
  String get dailyView => 'اليومي';

  @override
  String get weekendNote => 'اليوم إجازة نهاية الأسبوع';

  @override
  String get pleaseSelectChildToViewSchedule =>
      'الرجاء اختيار الابن لعرض جدول الحصص الخاص به';

  @override
  String period(int number) {
    return 'الحصة $number';
  }

  @override
  String get teacher => 'المعلم';

  @override
  String get islamicStudies => 'التربية الإسلامية';

  @override
  String get physicalEducation => 'التربية البدنية';

  @override
  String get art => 'الرسم الفني';

  @override
  String get freeActivity => 'نشاط حر';

  @override
  String get subject => 'المادة';

  @override
  String get date => 'التاريخ';

  @override
  String get time => 'الوقت';

  @override
  String get syllabusNote => 'المقرر/الملاحظة';

  @override
  String get alerts => 'البلاغات';

  @override
  String get highPriority => 'عالية الأهمية';

  @override
  String get noAlerts => 'لا توجد بلاغات حالياً';

  @override
  String get alertsSubtitle => 'ستظهر هنا بلاغات المعلمين المتعلقة بطفلك';

  @override
  String errorLoadingAlerts(String error) {
    return 'حدث خطأ أثناء تحميل البلاغات: $error';
  }

  @override
  String get duplicateAbsenceRequest =>
      'لقد قمت بتقديم طلب غياب لهذا الطالب في هذا التاريخ مسبقاً';

  @override
  String errorLoadingNotifications(String error) {
    return 'حدث خطأ أثناء تحميل الإشعارات: $error';
  }

  @override
  String get noPublicNotifications => 'لا توجد إشعارات عامة حالياً';

  @override
  String get noFeesRegistered => 'لا توجد رسوم مالية مسجلة لهذا الطالب';

  @override
  String get noPaymentsRegistered => 'لم يتم تسجيل أي عمليات دفع بعد';

  @override
  String get pleaseEnterAbsenceReason => 'يرجى كتابة سبب الغياب';

  @override
  String get markAllAsRead => 'تحديد الكل كمقروء';
}
