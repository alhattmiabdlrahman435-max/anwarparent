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
import 'core/providers/children_provider.dart';
import 'core/providers/absence_requests_provider.dart';
import 'core/providers/finance_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'core/network/pusher_service.dart';

final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'high_importance_channel_v2',
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

/// Centralized notification routing - eliminates DRY violation.
/// Maps notification type to the correct app route.
void _navigateByNotificationType(String type) {
  const typeToRoute = {
    'exam_schedule': '/exams',
    'exams': '/exams',
    'weekly_schedule': '/schedule',
    'schedule': '/schedule',
    'assignment': '/assignments',
    'assignments': '/assignments',
    'grade': '/grades',
    'grades': '/grades',
    'absence_request': '/absence_history',
    'report': '/alerts',
    'alert': '/alerts',
    'notifications': '/alerts',
    'finance': '/fees',
  };
  final route = typeToRoute[type] ?? '/attendance';
  
  void tryNavigate(int retries) {
    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      GoRouter.of(context).go(route);
    } else if (retries < 10) {
      Future.delayed(const Duration(milliseconds: 300), () {
        tryNavigate(retries + 1);
      });
    } else {
      debugPrint("Failed to navigate to $route: context is null after retries.");
    }
  }

  tryNavigate(0);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission for push notifications immediately (blocking but very fast)
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Set foreground notification presentation options while app is open
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  } catch (e) {
    debugPrint('Firebase initialization/permission failed: $e');
  }

  // Request permissions and print FCM Token asynchronously (non-blocking)
  _setupFirebaseMessaging();

  // Initialize Pusher Client connection to Reverb
  PusherService().init();
  PusherService().connect();

  runApp(const ProviderScope(child: ParentApp()));
}

Future<void> _setupFirebaseMessaging() async {
  try {
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
        final payload = response.payload ?? 'attendance';
        _navigateByNotificationType(payload);
      },
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Request runtime notification permission on Android 13+
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // NOTE: FirebaseMessaging.onMessage is NOT listened here to avoid
    // duplicate listeners. It is handled exclusively in _ParentAppState
    // which has access to Riverpod ref for data refresh.

    // NOTE: onMessageOpenedApp is handled in _ParentAppState._listenToFcmForDataRefresh
    // to avoid duplicate listeners that cause double navigation.

    // Removed initialMessage handling here. Moved to _ParentAppState.initState() to ensure context is ready.

    // On iOS, we must ensure APNS token is received before getting FCM token
    String? apnsToken;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      
      if (apnsToken == null && !kReleaseMode) {
        debugPrint('iOS Simulator/Debug detected: APNS token is null (Push Notifications are only supported on physical iOS devices).');
      } else {
        int retries = 0;
        while (apnsToken == null && retries < 15) {
          await Future.delayed(const Duration(seconds: 1));
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          retries++;
        }
      }

      if (apnsToken == null && kReleaseMode) {
        debugPrint('APNS token is null. Note: Push Notifications are only supported on physical iOS devices.');
      }
    }

    // Only attempt to get FCM token if we are not on iOS, or if we are on iOS and APNS token is available
    if (defaultTargetPlatform == TargetPlatform.iOS && apnsToken == null && kReleaseMode) {
      debugPrint('Skipped FCM token registration: APNS token is not available.');
    } else {
      String? token = await FirebaseMessaging.instance.getToken();
      // Only print FCM token in debug mode to prevent token leakage
      if (kDebugMode) {
        debugPrint('================= FCM TOKEN =================');
        debugPrint(token);
        debugPrint('=============================================');
      }
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

class _ParentAppState extends ConsumerState<ParentApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _listenToFcmForDataRefresh();
    // Fetch initial data immediately on launch
    Future.microtask(() => _refreshAllData());

    // Check if app was launched from a terminated state via a notification click
    FirebaseMessaging.instance.getInitialMessage().then((initialMessage) {
      if (initialMessage != null) {
        debugPrint('FCM Notification clicked from terminated state.');
        // Wait a short moment for the router to be fully ready
        Future.delayed(const Duration(milliseconds: 500), () {
          final type = initialMessage.data['type'] ?? 'attendance';
          _navigateByNotificationType(type);
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshAllData();
    }
  }

  void _refreshAllData() {
    try {
      debugPrint('[ParentApp] Refreshing all data in background...');
      ref.read(childrenProvider.notifier).refresh();
      ref.read(notificationsProvider.notifier).refresh();
      ref.read(attendanceDataProvider.notifier).refresh();
      ref.read(assignmentsProvider.notifier).refresh();
      ref.read(gradesProvider.notifier).refresh();
      ref.read(examsProvider.notifier).refresh();
      ref.read(classSchedulesProvider.notifier).refresh();
      ref.read(absenceRequestsProvider.notifier).refresh();
      ref.read(financeProvider.notifier).refresh();
    } catch (e) {
      debugPrint('[ParentApp] Error during background refresh: $e');
    }
  }


  /// Centralized data refresh handler for notification types.
  void _refreshProviderByType(String type) {
    // Always invalidate the notifications list so the UI updates in real-time
    ref.invalidate(notificationsProvider);

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
      case 'finance':
        ref.invalidate(financeProvider);
        break;
      default:
        break;
    }
  }

  void _listenToFcmForDataRefresh() {
    // Single centralized FCM foreground listener.
    // Also shows local notification banner for heads-up display.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final type = message.data['type'] ?? '';
      debugPrint('[ParentApp] FCM data refresh triggered. type=$type');

      // Refresh the relevant data provider
      _refreshProviderByType(type);

      // Show local notification banner (foreground only on Android)
      final notification = message.notification;
      if (notification != null && !kIsWeb) {
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
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: type.isEmpty ? 'attendance' : type,
        );
      }
    });

    // Also refresh and navigate on tap from background state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final type = message.data['type'] ?? '';
      _refreshProviderByType(type);
      // Ensure we navigate to the correct screen
      Future.microtask(() {
        _navigateByNotificationType(type.isEmpty ? 'attendance' : type);
      });
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
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(settings.fontSizeFactor),
          ),
          child: child!,
        );
      },
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
