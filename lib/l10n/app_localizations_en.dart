// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Parent App';

  @override
  String get home => 'Home';

  @override
  String get myChildren => 'My Children';

  @override
  String get notifications => 'Notifications';

  @override
  String get assignments => 'Assignments';

  @override
  String get attendance => 'Attendance';

  @override
  String get grades => 'Grades';

  @override
  String get fees => 'Tuition Fees';

  @override
  String get settings => 'Settings';

  @override
  String get selectChild => 'Select Child';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String welcomeParent(String name) {
    return 'Welcome, $name';
  }

  @override
  String get parentAccount => 'Parent Account';

  @override
  String get quickAccess => 'Quick Access';

  @override
  String get absenceRequest => 'Absence Request';

  @override
  String get absenceRequestsHistory => 'Absence History';

  @override
  String get rejected => 'Rejected';

  @override
  String get approved => 'Approved';

  @override
  String get pending => 'Pending';

  @override
  String get rejectionReason => 'Rejection Reason:';

  @override
  String get gradesAndAnalytics => 'Grades & Analytics';

  @override
  String get schoolAssignments => 'School Assignments';

  @override
  String get attendanceRecord => 'Attendance Record';

  @override
  String get exams => 'Exams';

  @override
  String get account => 'Account';

  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit account details';

  @override
  String get app => 'App';

  @override
  String get appearance => 'Appearance';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get activitiesAndMessages => 'Activities and messages';

  @override
  String get support => 'Support';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get aboutApp => 'About App';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get generalNotification => 'General Notification';

  @override
  String get publicHolidayTomorrow => 'Tomorrow is a public holiday.';

  @override
  String get oneHourAgo => '1 hour ago';

  @override
  String get privateMessageFromAdmin => 'Private message from administration';

  @override
  String get reviewWithAdmin =>
      'Please review with administration regarding the student\'s level.';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get login => 'Login';

  @override
  String get welcomeBack => 'Welcome back Parent';

  @override
  String get phoneNumberOrUsername => 'Phone Number / Username';

  @override
  String get nationalId => 'National ID';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get pleaseSelectStudent => 'Please select a student';

  @override
  String get noAssignmentsForToday => 'No assignments for today';

  @override
  String get totalFees => 'Total Fees';

  @override
  String get paid => 'Paid';

  @override
  String get remaining => 'Remaining';

  @override
  String get paymentHistory => 'Payment History';

  @override
  String get financialPayment => 'Financial Payment';

  @override
  String get pleaseSelectChildToViewExams =>
      'Please select a child to view their exam schedules';

  @override
  String get firstSemester => 'First Semester';

  @override
  String get secondSemester => 'Second Semester';

  @override
  String noScheduleAddedFor(String period) {
    return 'No schedule added for $period';
  }

  @override
  String get noGradesYet => 'No grades yet';

  @override
  String get finalResultNote => 'Final result (total months ÷ 15)';

  @override
  String get children => 'Children';

  @override
  String get attendanceBehavior => 'Attendance';

  @override
  String get behavior => 'Behavior';

  @override
  String get oral => 'Oral';

  @override
  String get homework => 'Homework';

  @override
  String get written => 'Written';

  @override
  String get midTermFinalExam => 'Mid-term / Final Exam';

  @override
  String get totalTermGrades => 'Total Term Grades';

  @override
  String get totalYearlyGrades => 'Total Yearly Grades (Subject)';

  @override
  String get absenceRequestSentSuccessfully =>
      'Absence request sent successfully';

  @override
  String get errorSendingAbsenceRequest => 'Error sending absence request';

  @override
  String get selectDate => 'Select Date';

  @override
  String get reasonOptional => 'Reason (Optional)';

  @override
  String get noRegisteredStudents => 'No registered students';

  @override
  String get exampleMedicalAppointment => 'Example: Medical appointment...';

  @override
  String get sendAbsenceRequest => 'Send Absence Request';

  @override
  String get attendanceDays => 'Attendance Days';

  @override
  String get absenceDays => 'Absence Days';

  @override
  String get pleaseSelectStudentToViewAttendance =>
      'Please select student to view attendance';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String currencySar(String amount) {
    return '$amount R.Y';
  }

  @override
  String get math => 'Math';

  @override
  String get science => 'Science';

  @override
  String get arabicLanguage => 'Arabic Language';

  @override
  String get englishLanguage => 'English Language';

  @override
  String get quran => 'Holy Quran';

  @override
  String get socialStudies => 'Social Studies';

  @override
  String get history => 'History';

  @override
  String get physics => 'Physics';

  @override
  String get month1 => 'First Month';

  @override
  String get month2 => 'Second Month';

  @override
  String get month3 => 'Third Month';

  @override
  String get month4 => 'Fourth Month';

  @override
  String get month5 => 'Fifth Month';

  @override
  String get month6 => 'Sixth Month';

  @override
  String get finalExam => 'End of Term Exam';

  @override
  String get assignmentMath => 'Solve exercises page 45 from student book.';

  @override
  String get assignmentScience => 'Review chapter three for the exam.';

  @override
  String get assignmentArabic =>
      'Write an essay about the importance of reading.';

  @override
  String get assignmentHistory => 'Summarize the second lesson.';

  @override
  String get assignmentPhysics =>
      'Solve constant acceleration motion problems.';

  @override
  String get assignmentQuran => 'Memorize Surah An-Naba.';

  @override
  String get assignmentMath2 => 'Multiplication table from 1 to 5.';

  @override
  String get examQuran1 => 'Recite Surah Al-Baqarah from verse 1 to 50';

  @override
  String get examQuran2 => 'Recite Surah Al-Baqarah from 50 to 100';

  @override
  String get examMath1 => 'Chapter one only';

  @override
  String get examMath2 => 'Comprehensive';

  @override
  String get examArabic => 'Texts and grammar';

  @override
  String get examScience => 'Second unit';

  @override
  String get examSocial => 'Geography and history';

  @override
  String get examEnglish => 'Comprehensive whole book';

  @override
  String get childName1 => 'Ahmed Mohammed Abdullah';

  @override
  String get childGrade1 => 'Grade 5 - Section (A)';

  @override
  String get childName2 => 'Sarah Mohammed Abdullah';

  @override
  String get childGrade2 => 'Grade 3 - Section (B)';

  @override
  String get childName3 => 'Omar Mohammed Abdullah';

  @override
  String get childGrade3 => 'Grade 1 - Section (C)';

  @override
  String get classSchedule => 'Class Schedule';

  @override
  String get weeklyView => 'Weekly View';

  @override
  String get dailyView => 'Daily View';

  @override
  String get weekendNote => 'Today is a weekend holiday';

  @override
  String get pleaseSelectChildToViewSchedule =>
      'Please select a child to view their class schedule';

  @override
  String period(int number) {
    return 'Period $number';
  }

  @override
  String get teacher => 'Teacher';

  @override
  String get islamicStudies => 'Islamic Studies';

  @override
  String get physicalEducation => 'Physical Education';

  @override
  String get art => 'Art';

  @override
  String get freeActivity => 'Free Activity';

  @override
  String get subject => 'Subject';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get syllabusNote => 'Syllabus / Note';

  @override
  String get alerts => 'Alerts';

  @override
  String get highPriority => 'High Priority';

  @override
  String get noAlerts => 'No alerts currently';

  @override
  String get alertsSubtitle =>
      'Teacher alerts regarding your child will appear here';

  @override
  String errorLoadingAlerts(String error) {
    return 'An error occurred while loading alerts: $error';
  }

  @override
  String get duplicateAbsenceRequest =>
      'An absence request for this student on this date already exists';

  @override
  String errorLoadingNotifications(String error) {
    return 'An error occurred while loading notifications: $error';
  }

  @override
  String get noPublicNotifications => 'No public notifications currently';

  @override
  String get noFeesRegistered => 'No tuition fees registered for this student';

  @override
  String get noPaymentsRegistered => 'No payments have been registered yet';

  @override
  String get pleaseEnterAbsenceReason => 'Please enter a reason for absence';

  @override
  String get markAllAsRead => 'Mark all as read';
}
