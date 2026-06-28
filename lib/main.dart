import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/settings_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('FCM Foreground Message: ${message.notification?.title} - ${message.notification?.body}');
    });

    // On iOS, we must ensure APNS token is received before getting FCM token
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      debugPrint('iOS detected: Waiting for APNS token...');
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      int retries = 0;
      while (apnsToken == null && retries < 10) {
        await Future.delayed(const Duration(seconds: 1));
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        retries++;
        debugPrint('Waiting for APNS token... (retry $retries/10)');
      }
      if (apnsToken == null) {
        debugPrint('WARNING: APNS token is null. Push Notifications capability might be missing in Xcode, or APNs credentials not configured in Firebase Console.');
      } else {
        debugPrint('APNS token received: $apnsToken');
      }
    }

    String? token = await FirebaseMessaging.instance.getToken();
    debugPrint('================= FCM TOKEN =================');
    debugPrint(token);
    debugPrint('=============================================');
  } catch (e) {
    debugPrint('Error getting FCM token: $e');
  }
}

class ParentApp extends ConsumerWidget {
  const ParentApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      builder: (context, child) {
        return Listener(
          onPointerDown: (_) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: child,
        );
      },
    );
  }
}
