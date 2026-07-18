class ApiRoutes {
  // Auth
  static const String login = 'login';
  static const String logout = 'logout';
  static const String updateFcmToken = 'user/fcm-token';
  
  // Profile
  static const String updatePhoto = 'user/update-photo';
  static const String updatePassword = 'user/update-password';
  static String updateParent(String id) => 'parents/$id';

  // Attendance
  static String studentAttendance(String id) => 'attendance/student/$id';
}
