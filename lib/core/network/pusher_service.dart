import 'dart:convert';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class PusherService {
  static final PusherService _instance = PusherService._internal();
  factory PusherService() => _instance;
  PusherService._internal();

  PusherChannelsClient? _client;
  bool _initialized = false;

  final Map<String, int> _recentEventTimestamps = {};
  final Map<String, Channel> _activeChannels = {};

  void init() {
    if (_initialized) return;

    final options = PusherChannelsOptions.fromHost(
      scheme: AppConfig.isEncrypted ? 'wss' : 'ws',
      host: AppConfig.reverbHost,
      port: AppConfig.reverbPort,
      key: AppConfig.reverbAppKey,
    );

    _client = PusherChannelsClient.websocket(
      options: options,
      connectionErrorHandler: (exception, trace, refresh) {
        debugPrint("❌ [PusherService] Connection error: $exception");
        Future.delayed(const Duration(seconds: 5), () {
          try {
            refresh();
          } catch (e) {
            debugPrint("❌ [PusherService] Reconnect failed: $e");
          }
        });
      },
    );

    _client?.onConnectionEstablished.listen((_) {
      debugPrint("⚡ [PusherService] Connection established successfully!");
    });

    _initialized = true;
    debugPrint("⚡ [PusherService] Initialized Reverb configuration (dart_pusher_channels).");
  }

  void connect() {
    if (!_initialized) init();
    try {
      _client?.connect();
      debugPrint("⚡ [PusherService] Connecting to Reverb...");
    } catch (e) {
      debugPrint("❌ [PusherService] Reverb connect exception (handled gracefully): $e");
    }
  }

  void disconnect() {
    try {
      _client?.disconnect();
      _activeChannels.clear();
      debugPrint("🔌 [PusherService] Disconnected.");
    } catch (e) {
      debugPrint("❌ [PusherService] Reverb disconnect exception: $e");
    }
  }

  /// Subscribe helper with deduplication across channels (2-second window)
  void subscribe(String channelName, String eventName, void Function(Map<String, dynamic> payload) onEvent) {
    if (!_initialized) init();

    try {
      final channel = _client?.publicChannel(channelName);
      if (channel != null) {
        _activeChannels[channelName] = channel;

        channel.bind(eventName).listen((event) {
          debugPrint("⚡ [PusherService] Received event '$eventName' on '$channelName': ${event.data}");
          
          final payload = parsePayload(event.data);
          final eventKey = _buildEventDeduplicationKey(eventName, payload);
          final now = DateTime.now().millisecondsSinceEpoch;

          // Deduplication: check if same event key was processed in the last 2000 ms
          if (_recentEventTimestamps.containsKey(eventKey)) {
            final lastTime = _recentEventTimestamps[eventKey]!;
            if (now - lastTime < 2000) {
              debugPrint("⏭️ [PusherService] Skipped duplicate event '$eventKey' (received within 2s window)");
              return;
            }
          }

          _recentEventTimestamps[eventKey] = now;
          // Clean up old timestamp entries after 10 seconds
          _recentEventTimestamps.removeWhere((_, time) => now - time > 10000);

          onEvent(payload);
        });

        debugPrint("⚡ [PusherService] Subscribed to channel '$channelName' listening for '$eventName'.");
      }
    } catch (e) {
      debugPrint("❌ [PusherService] Subscription error on '$channelName': $e");
    }
  }

  /// Safely parse payload string or map
  static Map<String, dynamic> parsePayload(dynamic rawData) {
    if (rawData == null) return {};
    if (rawData is Map<String, dynamic>) return rawData;
    if (rawData is Map) return Map<String, dynamic>.from(rawData);
    
    if (rawData is String) {
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return {'raw': rawData.toString()};
  }

  /// Extract student_id from payload safely if present
  static String? extractStudentId(Map<String, dynamic> payload) {
    if (payload.containsKey('student_id') && payload['student_id'] != null) {
      return payload['student_id'].toString();
    }
    if (payload.containsKey('data') && payload['data'] is Map) {
      final inner = payload['data'] as Map;
      if (inner.containsKey('student_id') && inner['student_id'] != null) {
        return inner['student_id'].toString();
      }
    }
    return null;
  }

  /// Extract parent_id from payload safely if present
  static String? extractParentId(Map<String, dynamic> payload) {
    if (payload.containsKey('parent_id') && payload['parent_id'] != null) {
      return payload['parent_id'].toString();
    }
    if (payload.containsKey('data') && payload['data'] is Map) {
      final inner = payload['data'] as Map;
      if (inner.containsKey('parent_id') && inner['parent_id'] != null) {
        return inner['parent_id'].toString();
      }
    }
    return null;
  }

  String _buildEventDeduplicationKey(String eventName, Map<String, dynamic> payload) {
    final studentId = extractStudentId(payload) ?? '';
    final parentId = extractParentId(payload) ?? '';
    final type = payload['type']?.toString() ?? payload['title']?.toString() ?? '';
    return '${eventName}_${parentId}_${studentId}_$type';
  }
}
