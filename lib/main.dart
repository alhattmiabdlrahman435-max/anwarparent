import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/settings_provider.dart';
import 'core/providers/notifications_provider.dart';
import 'core/providers/attendance_provider.dart';
import 'core/providers/assignments_provider.dart';
import 'core/providers/grades_provider.dart';
import 'core/providers/exams_provider.dart';
import 'core/providers/schedule_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'high_importance_channel',
  'إشعارات هامة',
  description: 'هذه القناة مخصصة لإشعارات الحضور والغياب الهامة.',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
);

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request permissions and print FCM Token asynchronously (non-blocking)
  _setupFirebaseMessaging();

  runApp(const ProviderScope(child: ParentApp()));
}

Future<void> _setupFirebaseMessaging() async {
  try {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Set foreground notification options to show banner/sound while app is open
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications to show heads-up banner on foreground
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(),
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload == 'exam_schedule' || payload == 'exams') {
          rootNavigatorKey.currentContext?.push('/exams');
        } else if (payload == 'weekly_schedule' || payload == 'schedule') {
          rootNavigatorKey.currentContext?.push('/schedule');
        } else if (payload == 'assignment' || payload == 'assignments') {
          rootNavigatorKey.currentContext?.push('/assignments');
        } else if (payload == 'grade' || payload == 'grades') {
          rootNavigatorKey.currentContext?.push('/grades');
        } else if (payload == 'absence_request') {
          rootNavigatorKey.currentContext?.push('/absence_history');
        } else if (payload == 'report' || payload == 'alert' || payload == 'notifications') {
          rootNavigatorKey.currentContext?.push('/alerts');
        } else {
          rootNavigatorKey.currentContext?.push('/attendance');
        }
      },
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('FCM Foreground Message: ${message.notification?.title} - ${message.notification?.body}');
      
      final notification = message.notification;
      final android = message.notification?.android;
      final type = message.data['type'] ?? 'attendance';

      if (notification != null && android != null && !kIsWeb) {
        _flutterLocalNotificationsPlugin.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              icon: '@mipmap/ic_launcher',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              enableVibration: true,
            ),
          ),
          payload: type,
        );
      }
    });

    // Handle background notification clicks
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final type = message.data['type'] ?? 'attendance';
      if (type == 'exam_schedule' || type == 'exams') {
        rootNavigatorKey.currentContext?.push('/exams');
      } else if (type == 'weekly_schedule' || type == 'schedule') {
        rootNavigatorKey.currentContext?.push('/schedule');
      } else if (type == 'assignment' || type == 'assignments') {
        rootNavigatorKey.currentContext?.push('/assignments');
      } else if (type == 'grade' || type == 'grades') {
        rootNavigatorKey.currentContext?.push('/grades');
      } else if (type == 'absence_request') {
        rootNavigatorKey.currentContext?.push('/absence_history');
      } else if (type == 'report' || type == 'alert' || type == 'notifications') {
        rootNavigatorKey.currentContext?.push('/alerts');
      } else {
        rootNavigatorKey.currentContext?.push('/attendance');
      }
    });

    // Handle terminated state notification clicks
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('FCM Notification clicked from terminated state.');
      Future.delayed(const Duration(milliseconds: 1500), () {
        final type = initialMessage.data['type'] ?? 'attendance';
        if (type == 'exam_schedule' || type == 'exams') {
          rootNavigatorKey.currentContext?.push('/exams');
        } else if (type == 'weekly_schedule' || type == 'schedule') {
          rootNavigatorKey.currentContext?.push('/schedule');
        } else if (type == 'assignment' || type == 'assignments') {
          rootNavigatorKey.currentContext?.push('/assignments');
        } else if (type == 'grade' || type == 'grades') {
          rootNavigatorKey.currentContext?.push('/grades');
        } else if (type == 'absence_request') {
          rootNavigatorKey.currentContext?.push('/absence_history');
        } else if (type == 'report' || type == 'alert' || type == 'notifications') {
          rootNavigatorKey.currentContext?.push('/alerts');
        } else {
          rootNavigatorKey.currentContext?.push('/attendance');
        }
      });
    }

    // On iOS, we must ensure APNS token is received before getting FCM token
    String? apnsToken;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      
      // On iOS simulators or debug configurations, the APNS token is always null.
      // We skip the 10-second retry loop in debug mode to make startup clean and fast.
      if (apnsToken == null && !kReleaseMode) {
        debugPrint('iOS Simulator/Debug detected: APNS token is null (Push Notifications are only supported on physical iOS devices).');
      } else {
        int retries = 0;
        while (apnsToken == null && retries < 5) {
          await Future.delayed(const Duration(seconds: 1));
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          retries++;
        }
      }
    }

    // Only attempt to get FCM token if we are not on iOS, or if we are on iOS and APNS token is available
    if (defaultTargetPlatform == TargetPlatform.iOS && apnsToken == null) {
      debugPrint('Skipped FCM token registration: APNS token is not available.');
    } else {
      String? token = await FirebaseMessaging.instance.getToken();
      debugPrint('================= FCM TOKEN =================');
      debugPrint(token);
      debugPrint('=============================================');
    }
  } catch (e) {
    debugPrint('Error getting FCM token: $e');
  }
}

class ParentApp extends ConsumerStatefulWidget {
  const ParentApp({super.key});

  @override
  ConsumerState<ParentApp> createState() => _ParentAppState();
}

class _ParentAppState extends ConsumerState<ParentApp> {
  @override
  void initState() {
    super.initState();
    _listenToFcmForDataRefresh();
  }

  void _listenToFcmForDataRefresh() {
    // When a foreground FCM message arrives, refresh the relevant data provider
    // immediately so the user sees up-to-date data without manual pull-to-refresh.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final type = message.data['type'] ?? '';
      debugPrint('[ParentApp] FCM data refresh triggered. type=$type');

      switch (type) {
        case 'attendance':
        case 'absence':
        case 'absence_request':
          ref.invalidate(attendanceDataProvider);
          break;
        case 'assignment':
        case 'assignments':
          ref.invalidate(assignmentsProvider);
          break;
        case 'grade':
        case 'grades':
          ref.invalidate(gradesProvider);
          break;
        case 'exam_schedule':
        case 'exams':
          ref.invalidate(examsProvider);
          break;
        case 'weekly_schedule':
        case 'schedule':
          ref.invalidate(classSchedulesProvider);
          break;
        case 'report':
        case 'alert':
        case 'notifications':
        default:
          ref.invalidate(notificationsProvider);
          break;
      }
    });

    // Also refresh on tap from background state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final type = message.data['type'] ?? '';
      // Trigger refresh for the relevant section
      switch (type) {
        case 'attendance':
        case 'absence':
        case 'absence_request':
          ref.invalidate(attendanceDataProvider);
          break;
        case 'assignment':
        case 'assignments':
          ref.invalidate(assignmentsProvider);
          break;
        case 'grade':
        case 'grades':
          ref.invalidate(gradesProvider);
          break;
        case 'exam_schedule':
        case 'exams':
          ref.invalidate(examsProvider);
          break;
        case 'weekly_schedule':
        case 'schedule':
          ref.invalidate(classSchedulesProvider);
          break;
        default:
          ref.invalidate(notificationsProvider);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      locale: settings.locale,
    );
  }
}
