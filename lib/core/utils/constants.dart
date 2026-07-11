import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConstants {
  static String get baseUrl {
    if (kDebugMode) {
      try {
        if (Platform.isAndroid) {
          return 'http://10.0.2.2:8000/api/';
        }
      } catch (_) {}
    }
    return 'http://127.0.0.1:8000/api/';
  }

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';

  static String? normalizeUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    
    // If it's an emoji/avatar character
    if (url.length <= 4) return url;
    
    final base = baseUrl;
    final apiIndex = base.indexOf('/api');
    final host = apiIndex != -1 ? base.substring(0, apiIndex) : base;
    
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      final cleanPath = url.startsWith('/') ? url : '/$url';
      return '$host$cleanPath';
    }
    
    try {
      final uri = Uri.parse(url);
      final baseUri = Uri.parse(host);
      return uri.replace(
        scheme: baseUri.scheme,
        host: baseUri.host,
        port: baseUri.port,
      ).toString();
    } catch (_) {
      return url;
    }
  }
}
