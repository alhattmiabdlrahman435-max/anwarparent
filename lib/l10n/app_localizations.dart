import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'ولي الأمر'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @myChildren.
  ///
  /// In ar, this message translates to:
  /// **'أبنائي'**
  String get myChildren;

  /// No description provided for @notifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifications;

  /// No description provided for @assignments.
  ///
  /// In ar, this message translates to:
  /// **'الواجبات'**
  String get assignments;

  /// No description provided for @attendance.
  ///
  /// In ar, this message translates to:
  /// **'الحضور'**
  String get attendance;

  /// No description provided for @grades.
  ///
  /// In ar, this message translates to:
  /// **'الدرجات'**
  String get grades;

  /// No description provided for @fees.
  ///
  /// In ar, this message translates to:
  /// **'الرسوم الدراسية'**
  String get fees;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @selectChild.
  ///
  /// In ar, this message translates to:
  /// **'اختر الابن'**
  String get selectChild;

  /// No description provided for @goodMorning.
  ///
  /// In ar, this message translates to:
  /// **'صباح الخير'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In ar, this message translates to:
  /// **'طاب مساؤك'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير'**
  String get goodEvening;

  /// No description provided for @welcomeParent.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك، {name}'**
  String welcomeParent(String name);

  /// No description provided for @parentAccount.
  ///
  /// In ar, this message translates to:
  /// **'حساب ولي الأمر'**
  String get parentAccount;

  /// No description provided for @quickAccess.
  ///
  /// In ar, this message translates to:
  /// **'الوصول السريع'**
  String get quickAccess;

  /// No description provided for @absenceRequest.
  ///
  /// In ar, this message translates to:
  /// **'طلب غياب'**
  String get absenceRequest;

  /// No description provided for @absenceRequestsHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل طلبات الغياب'**
  String get absenceRequestsHistory;

  /// No description provided for @rejected.
  ///
  /// In ar, this message translates to:
  /// **'مرفوض'**
  String get rejected;

  /// No description provided for @approved.
  ///
  /// In ar, this message translates to:
  /// **'مقبول'**
  String get approved;

  /// No description provided for @pending.
  ///
  /// In ar, this message translates to:
  /// **'قيد الانتظار'**
  String get pending;

  /// No description provided for @rejectionReason.
  ///
  /// In ar, this message translates to:
  /// **'سبب الرفض:'**
  String get rejectionReason;

  /// No description provided for @gradesAndAnalytics.
  ///
  /// In ar, this message translates to:
  /// **'الدرجات والتحليلات'**
  String get gradesAndAnalytics;

  /// No description provided for @schoolAssignments.
  ///
  /// In ar, this message translates to:
  /// **'الواجبات المدرسية'**
  String get schoolAssignments;

  /// No description provided for @attendanceRecord.
  ///
  /// In ar, this message translates to:
  /// **'سجل الحضور'**
  String get attendanceRecord;

  /// No description provided for @exams.
  ///
  /// In ar, this message translates to:
  /// **'الاختبارات'**
  String get exams;

  /// No description provided for @account.
  ///
  /// In ar, this message translates to:
  /// **'الحساب'**
  String get account;

  /// No description provided for @profile.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In ar, this message translates to:
  /// **'تعديل بيانات الحساب'**
  String get editProfile;

  /// No description provided for @app.
  ///
  /// In ar, this message translates to:
  /// **'التطبيق'**
  String get app;

  /// No description provided for @appearance.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get appearance;

  /// No description provided for @light.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get dark;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @activitiesAndMessages.
  ///
  /// In ar, this message translates to:
  /// **'الأنشطة والرسائل'**
  String get activitiesAndMessages;

  /// No description provided for @support.
  ///
  /// In ar, this message translates to:
  /// **'الدعم'**
  String get support;

  /// No description provided for @helpCenter.
  ///
  /// In ar, this message translates to:
  /// **'مركز المساعدة'**
  String get helpCenter;

  /// No description provided for @contactUs.
  ///
  /// In ar, this message translates to:
  /// **'تواصل معنا'**
  String get contactUs;

  /// No description provided for @aboutApp.
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق'**
  String get aboutApp;

  /// No description provided for @privacyPolicy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get privacyPolicy;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @logoutConfirmation.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من تسجيل الخروج؟'**
  String get logoutConfirmation;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @generalNotification.
  ///
  /// In ar, this message translates to:
  /// **'إشعار عام'**
  String get generalNotification;

  /// No description provided for @publicHolidayTomorrow.
  ///
  /// In ar, this message translates to:
  /// **'غداً إجازة رسمية.'**
  String get publicHolidayTomorrow;

  /// No description provided for @oneHourAgo.
  ///
  /// In ar, this message translates to:
  /// **'منذ 1 ساعة'**
  String get oneHourAgo;

  /// No description provided for @privateMessageFromAdmin.
  ///
  /// In ar, this message translates to:
  /// **'رسالة خاصة من الإدارة'**
  String get privateMessageFromAdmin;

  /// No description provided for @reviewWithAdmin.
  ///
  /// In ar, this message translates to:
  /// **'نرجو مراجعة الإدارة بشأن مستوى الطالب.'**
  String get reviewWithAdmin;

  /// No description provided for @yesterday.
  ///
  /// In ar, this message translates to:
  /// **'أمس'**
  String get yesterday;

  /// No description provided for @login.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// No description provided for @welcomeBack.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك مجدداً ولي الأمر'**
  String get welcomeBack;

  /// No description provided for @phoneNumberOrUsername.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف / اسم المستخدم'**
  String get phoneNumberOrUsername;

  /// No description provided for @nationalId.
  ///
  /// In ar, this message translates to:
  /// **'الرقم الوطني'**
  String get nationalId;

  /// No description provided for @password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get forgotPassword;

  /// No description provided for @pleaseSelectStudent.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء اختيار الطالب'**
  String get pleaseSelectStudent;

  /// No description provided for @noAssignmentsForToday.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد واجبات لهذا اليوم'**
  String get noAssignmentsForToday;

  /// No description provided for @totalFees.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الرسوم'**
  String get totalFees;

  /// No description provided for @paid.
  ///
  /// In ar, this message translates to:
  /// **'تم الدفع'**
  String get paid;

  /// No description provided for @remaining.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي'**
  String get remaining;

  /// No description provided for @paymentHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل المدفوعات'**
  String get paymentHistory;

  /// No description provided for @financialPayment.
  ///
  /// In ar, this message translates to:
  /// **'دفعة مالية'**
  String get financialPayment;

  /// No description provided for @pleaseSelectChildToViewExams.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء اختيار ابن لعرض جداول الاختبارات الخاصة به'**
  String get pleaseSelectChildToViewExams;

  /// No description provided for @firstSemester.
  ///
  /// In ar, this message translates to:
  /// **'الفصل الدراسي الأول'**
  String get firstSemester;

  /// No description provided for @secondSemester.
  ///
  /// In ar, this message translates to:
  /// **'الفصل الدراسي الثاني'**
  String get secondSemester;

  /// No description provided for @noScheduleAddedFor.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد جدول مضاف لـ {period}'**
  String noScheduleAddedFor(String period);

  /// No description provided for @noGradesYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد درجات حتى الآن'**
  String get noGradesYet;

  /// No description provided for @finalResultNote.
  ///
  /// In ar, this message translates to:
  /// **'المحصلة النهائية (مجموع الأشهر ÷ 15)'**
  String get finalResultNote;

  /// No description provided for @children.
  ///
  /// In ar, this message translates to:
  /// **'الابناء'**
  String get children;

  /// No description provided for @attendanceBehavior.
  ///
  /// In ar, this message translates to:
  /// **'المواظبة'**
  String get attendanceBehavior;

  /// No description provided for @behavior.
  ///
  /// In ar, this message translates to:
  /// **'السلوك'**
  String get behavior;

  /// No description provided for @oral.
  ///
  /// In ar, this message translates to:
  /// **'الشفهي'**
  String get oral;

  /// No description provided for @homework.
  ///
  /// In ar, this message translates to:
  /// **'الواجب'**
  String get homework;

  /// No description provided for @written.
  ///
  /// In ar, this message translates to:
  /// **'التحريري'**
  String get written;

  /// No description provided for @midTermFinalExam.
  ///
  /// In ar, this message translates to:
  /// **'الاختبار النصفي / النهائي'**
  String get midTermFinalExam;

  /// No description provided for @totalTermGrades.
  ///
  /// In ar, this message translates to:
  /// **'مجموع درجات الترم'**
  String get totalTermGrades;

  /// No description provided for @totalYearlyGrades.
  ///
  /// In ar, this message translates to:
  /// **'المجموع الكلي للمادة (سنة)'**
  String get totalYearlyGrades;

  /// No description provided for @absenceRequestSentSuccessfully.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلب الغياب بنجاح'**
  String get absenceRequestSentSuccessfully;

  /// No description provided for @errorSendingAbsenceRequest.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء الإرسال'**
  String get errorSendingAbsenceRequest;

  /// No description provided for @selectDate.
  ///
  /// In ar, this message translates to:
  /// **'اختر التاريخ'**
  String get selectDate;

  /// No description provided for @reasonOptional.
  ///
  /// In ar, this message translates to:
  /// **'السبب (اختياري)'**
  String get reasonOptional;

  /// No description provided for @noRegisteredStudents.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد طلاب مسجلين'**
  String get noRegisteredStudents;

  /// No description provided for @exampleMedicalAppointment.
  ///
  /// In ar, this message translates to:
  /// **'مثال: موعد طبي...'**
  String get exampleMedicalAppointment;

  /// No description provided for @sendAbsenceRequest.
  ///
  /// In ar, this message translates to:
  /// **'إرسال طلب الغياب'**
  String get sendAbsenceRequest;

  /// No description provided for @attendanceDays.
  ///
  /// In ar, this message translates to:
  /// **'أيام الحضور'**
  String get attendanceDays;

  /// No description provided for @absenceDays.
  ///
  /// In ar, this message translates to:
  /// **'أيام الغياب'**
  String get absenceDays;

  /// No description provided for @pleaseSelectStudentToViewAttendance.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء اختيار الطالب لعرض سجل الحضور'**
  String get pleaseSelectStudentToViewAttendance;

  /// No description provided for @saturday.
  ///
  /// In ar, this message translates to:
  /// **'السبت'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In ar, this message translates to:
  /// **'الأحد'**
  String get sunday;

  /// No description provided for @monday.
  ///
  /// In ar, this message translates to:
  /// **'الاثنين'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In ar, this message translates to:
  /// **'الثلاثاء'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In ar, this message translates to:
  /// **'الأربعاء'**
  String get wednesday;

  /// No description provided for @currencySar.
  ///
  /// In ar, this message translates to:
  /// **'{amount} ر.ي'**
  String currencySar(String amount);

  /// No description provided for @math.
  ///
  /// In ar, this message translates to:
  /// **'الرياضيات'**
  String get math;

  /// No description provided for @science.
  ///
  /// In ar, this message translates to:
  /// **'العلوم'**
  String get science;

  /// No description provided for @arabicLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة العربية'**
  String get arabicLanguage;

  /// No description provided for @englishLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة الإنجليزية'**
  String get englishLanguage;

  /// No description provided for @quran.
  ///
  /// In ar, this message translates to:
  /// **'القرآن الكريم'**
  String get quran;

  /// No description provided for @socialStudies.
  ///
  /// In ar, this message translates to:
  /// **'الاجتماعيات'**
  String get socialStudies;

  /// No description provided for @history.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get history;

  /// No description provided for @physics.
  ///
  /// In ar, this message translates to:
  /// **'الفيزياء'**
  String get physics;

  /// No description provided for @month1.
  ///
  /// In ar, this message translates to:
  /// **'الشهر الأول'**
  String get month1;

  /// No description provided for @month2.
  ///
  /// In ar, this message translates to:
  /// **'الشهر الثاني'**
  String get month2;

  /// No description provided for @month3.
  ///
  /// In ar, this message translates to:
  /// **'الشهر الثالث'**
  String get month3;

  /// No description provided for @month4.
  ///
  /// In ar, this message translates to:
  /// **'الشهر الرابع'**
  String get month4;

  /// No description provided for @month5.
  ///
  /// In ar, this message translates to:
  /// **'الشهر الخامس'**
  String get month5;

  /// No description provided for @month6.
  ///
  /// In ar, this message translates to:
  /// **'الشهر السادس'**
  String get month6;

  /// No description provided for @finalExam.
  ///
  /// In ar, this message translates to:
  /// **'اختبار نهاية الترم'**
  String get finalExam;

  /// No description provided for @assignmentMath.
  ///
  /// In ar, this message translates to:
  /// **'حل التمارين صفحة 45 من كتاب الطالب.'**
  String get assignmentMath;

  /// No description provided for @assignmentScience.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة الفصل الثالث استعداداً للاختبار.'**
  String get assignmentScience;

  /// No description provided for @assignmentArabic.
  ///
  /// In ar, this message translates to:
  /// **'كتابة موضوع تعبير عن أهمية القراءة.'**
  String get assignmentArabic;

  /// No description provided for @assignmentHistory.
  ///
  /// In ar, this message translates to:
  /// **'تلخيص الدرس الثاني.'**
  String get assignmentHistory;

  /// No description provided for @assignmentPhysics.
  ///
  /// In ar, this message translates to:
  /// **'حل مسائل الحركة بتسارع ثابت.'**
  String get assignmentPhysics;

  /// No description provided for @assignmentQuran.
  ///
  /// In ar, this message translates to:
  /// **'حفظ سورة النبأ.'**
  String get assignmentQuran;

  /// No description provided for @assignmentMath2.
  ///
  /// In ar, this message translates to:
  /// **'جدول الضرب من 1 إلى 5.'**
  String get assignmentMath2;

  /// No description provided for @examQuran1.
  ///
  /// In ar, this message translates to:
  /// **'تسميع سورة البقرة من آية 1 إلى 50'**
  String get examQuran1;

  /// No description provided for @examQuran2.
  ///
  /// In ar, this message translates to:
  /// **'تسميع سورة البقرة من 50 إلى 100'**
  String get examQuran2;

  /// No description provided for @examMath1.
  ///
  /// In ar, this message translates to:
  /// **'الباب الأول فقط'**
  String get examMath1;

  /// No description provided for @examMath2.
  ///
  /// In ar, this message translates to:
  /// **'شامل'**
  String get examMath2;

  /// No description provided for @examArabic.
  ///
  /// In ar, this message translates to:
  /// **'النصوص والقواعد النحوية'**
  String get examArabic;

  /// No description provided for @examScience.
  ///
  /// In ar, this message translates to:
  /// **'الوحدة الثانية'**
  String get examScience;

  /// No description provided for @examSocial.
  ///
  /// In ar, this message translates to:
  /// **'الجغرافيا والتاريخ'**
  String get examSocial;

  /// No description provided for @examEnglish.
  ///
  /// In ar, this message translates to:
  /// **'شامل كامل الكتاب'**
  String get examEnglish;

  /// No description provided for @childName1.
  ///
  /// In ar, this message translates to:
  /// **'أحمد محمد عبدالله'**
  String get childName1;

  /// No description provided for @childGrade1.
  ///
  /// In ar, this message translates to:
  /// **'الصف الخامس - شعبة (أ)'**
  String get childGrade1;

  /// No description provided for @childName2.
  ///
  /// In ar, this message translates to:
  /// **'سارة محمد عبدالله'**
  String get childName2;

  /// No description provided for @childGrade2.
  ///
  /// In ar, this message translates to:
  /// **'الصف الثالث - شعبة (ب)'**
  String get childGrade2;

  /// No description provided for @childName3.
  ///
  /// In ar, this message translates to:
  /// **'عمر محمد عبدالله'**
  String get childName3;

  /// No description provided for @childGrade3.
  ///
  /// In ar, this message translates to:
  /// **'الصف الأول - شعبة (ج)'**
  String get childGrade3;

  /// No description provided for @classSchedule.
  ///
  /// In ar, this message translates to:
  /// **'جدول الحصص'**
  String get classSchedule;

  /// No description provided for @weeklyView.
  ///
  /// In ar, this message translates to:
  /// **'جدول الأسبوع'**
  String get weeklyView;

  /// No description provided for @dailyView.
  ///
  /// In ar, this message translates to:
  /// **'اليومي'**
  String get dailyView;

  /// No description provided for @weekendNote.
  ///
  /// In ar, this message translates to:
  /// **'اليوم إجازة نهاية الأسبوع'**
  String get weekendNote;

  /// No description provided for @pleaseSelectChildToViewSchedule.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء اختيار الابن لعرض جدول الحصص الخاص به'**
  String get pleaseSelectChildToViewSchedule;

  /// No description provided for @period.
  ///
  /// In ar, this message translates to:
  /// **'الحصة {number}'**
  String period(int number);

  /// No description provided for @teacher.
  ///
  /// In ar, this message translates to:
  /// **'المعلم'**
  String get teacher;

  /// No description provided for @islamicStudies.
  ///
  /// In ar, this message translates to:
  /// **'التربية الإسلامية'**
  String get islamicStudies;

  /// No description provided for @physicalEducation.
  ///
  /// In ar, this message translates to:
  /// **'التربية البدنية'**
  String get physicalEducation;

  /// No description provided for @art.
  ///
  /// In ar, this message translates to:
  /// **'الرسم الفني'**
  String get art;

  /// No description provided for @freeActivity.
  ///
  /// In ar, this message translates to:
  /// **'نشاط حر'**
  String get freeActivity;

  /// No description provided for @subject.
  ///
  /// In ar, this message translates to:
  /// **'المادة'**
  String get subject;

  /// No description provided for @date.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get date;

  /// No description provided for @time.
  ///
  /// In ar, this message translates to:
  /// **'الوقت'**
  String get time;

  /// No description provided for @syllabusNote.
  ///
  /// In ar, this message translates to:
  /// **'المقرر/الملاحظة'**
  String get syllabusNote;

  /// No description provided for @alerts.
  ///
  /// In ar, this message translates to:
  /// **'البلاغات'**
  String get alerts;

  /// No description provided for @highPriority.
  ///
  /// In ar, this message translates to:
  /// **'عالية الأهمية'**
  String get highPriority;

  /// No description provided for @noAlerts.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بلاغات حالياً'**
  String get noAlerts;

  /// No description provided for @alertsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر هنا بلاغات المعلمين المتعلقة بطفلك'**
  String get alertsSubtitle;

  /// No description provided for @errorLoadingAlerts.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء تحميل البلاغات: {error}'**
  String errorLoadingAlerts(String error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
