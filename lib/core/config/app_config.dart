class AppConfig {
  // false تعني التوصيل بسيرفر الاستضافة السحابي الفعلي
  static const bool isLocal = false; 

  // 1. الرابط الأساسي للـ API والاستضافة
  static const String baseUrl = 'https://msaratwasel.tech';
  
  // 2. إعدادات Reverb / Pusher المأخوذة من الاستضافة
  static String get reverbHost => isLocal ? '192.168.8.188' : 'msaratwasel.tech';
  static int get reverbPort => isLocal ? 8080 : 8090;
  static String get reverbAppKey => isLocal ? 'anwar-alola-key-2024' : 'bbwhoob4xfhkw0pihbff';
  static bool get isEncrypted => !isLocal; // ws:// للمحلي و wss:// للاستضافة
  
  // مهلة الاتصال بالملي ثانية
  static const int activityTimeout = 30000; 
}
