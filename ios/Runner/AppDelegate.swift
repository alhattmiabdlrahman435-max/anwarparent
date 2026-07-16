import Flutter
import UIKit
import UserNotifications
import FirebaseMessaging
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, MessagingDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Firebase is already initialized by Flutter, but ensure it's ready if needed
    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
    }

    // Set UNUserNotificationCenter delegate BEFORE calling super
    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    Messaging.messaging().delegate = self

    // Register for remote notifications
    application.registerForRemoteNotifications()

    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    
    if let controller = window?.rootViewController as? FlutterViewController {
      setupBadgeChannel(messenger: controller.binaryMessenger)
    }
    
    return result
  }

  // MARK: - UNUserNotificationCenterDelegate
  // This ensures notifications are displayed even when the app is in foreground
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .badge, .sound])
    } else {
      completionHandler([.alert, .badge, .sound])
    }
  }

  // Handle notification tap
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
  }

  // MARK: - APNS Token forwarding
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    // Forward APNS token to Firebase
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    setupBadgeChannel(messenger: engineBridge.applicationRegistrar.messenger())
  }

  private func setupBadgeChannel(messenger: FlutterBinaryMessenger) {
    let badgeChannel = FlutterMethodChannel(name: "com.anwaralola.app/badge",
                                              binaryMessenger: messenger)
    badgeChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "setBadge" {
        if let args = call.arguments as? [String: Any],
           let count = args["count"] as? Int {
          if #available(iOS 16.0, *) {
            UNUserNotificationCenter.current().setBadgeCount(count) { error in
              if let error = error {
                print("Error setting badge: \(error.localizedDescription)")
              }
            }
          } else {
            UIApplication.shared.applicationIconBadgeNumber = count
          }
          result(true)
        } else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Count is required", details: nil))
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    })
  }
}
