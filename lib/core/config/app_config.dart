class AppConfig {
  // للتبديل مستقبلاً: false تعني أننا نتصل بالاستضافة الحية مباشرة
  static const bool isLocal = false; 

  // 1. الرابط الأساسي للـ API والاستضافة
  static const String baseUrl = 'https://msaratwasel.tech';
  
  // 2. إعدادات Reverb / Pusher المأخوذة من الاستضافة
  static const String reverbHost = 'msaratwasel.tech';
  static const int reverbPort = 8090;
  static const String reverbAppKey = 'bbwhoob4xfhkw0pihbff';
  static const bool isEncrypted = true; // wss:// للربط الآمن مع الاستضافة
  
  // مهلة الاتصال بالملي ثانية
  static const int activityTimeout = 30000; 
}
