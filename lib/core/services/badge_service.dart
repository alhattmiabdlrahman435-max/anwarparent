import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class BadgeService {
  static const _channel = MethodChannel('com.anwaralola.app/badge');

  static Future<void> setBadge(int count) async {
    // Only call badge update on iOS. Android badge is handled by status bar notifications automatically.
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        await _channel.invokeMethod('setBadge', {'count': count});
        debugPrint('[BadgeService] Set badge to: $count');
      } on PlatformException catch (e) {
        debugPrint("[BadgeService] Failed to set badge: '${e.message}'.");
      }
    }
  }

  static Future<void> clearBadge() async {
    await setBadge(0);
  }
}
