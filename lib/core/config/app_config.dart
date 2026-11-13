class AppConfig {
  // false تعني التوصيل بسيرفر الاستضافة السحابي الفعلي
  // للتشغيل المحلي: flutter run --dart-define=LOCAL=true
  static const bool isLocal = bool.fromEnvironment('LOCAL', defaultValue: false);

  // عنوان جهاز السيرفر المحلي. عبر كابل USB: --dart-define=LOCAL_HOST=127.0.0.1 مع adb reverse
  static const String localHost = String.fromEnvironment('LOCAL_HOST', defaultValue: '192.168.8.188');

  // 1. الرابط الأساسي للـ API والاستضافة
  static const String baseUrl = 'https://msaratwasel.tech';
  
  // 2. إعدادات Reverb / Pusher المأخوذة من الاستضافة
  static String get reverbHost => isLocal ? localHost : 'msaratwasel.tech';
  static int get reverbPort => isLocal ? 8080 : 8090;
  static String get reverbAppKey => isLocal ? 'anwar-alola-key-2024' : 'bbwhoob4xfhkw0pihbff';
  static bool get isEncrypted => !isLocal; // ws:// للمحلي و wss:// للاستضافة
  
  // مهلة الاتصال بالملي ثانية
  static const int activityTimeout = 30000; 
}
