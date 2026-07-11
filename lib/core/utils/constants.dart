class AppConstants {
  static const String baseUrl = 'http://192.168.1.2:8000/api/';

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
