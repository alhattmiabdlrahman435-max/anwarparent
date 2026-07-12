import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class PusherService {
  static final PusherService _instance = PusherService._internal();
  factory PusherService() => _instance;
  PusherService._internal();

  PusherChannelsClient? _client;
  bool _initialized = false;

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
        // Reconnect after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          try {
            refresh();
          } catch (e) {
            debugPrint("❌ [PusherService] Reconnect failed: $e");
          }
        });
      },
    );

    // Listen to connection establishment
    _client?.onConnectionEstablished.listen((_) {
      debugPrint("⚡ [PusherService] Connection established successfully!");
    });

    _initialized = true;
    debugPrint("⚡ [PusherService] Initialized Reverb configuration (dart_pusher_channels).");
  }

  void connect() {
    if (!_initialized) init();
    _client?.connect();
    debugPrint("⚡ [PusherService] Connecting to Reverb...");
  }

  void disconnect() {
    _client?.disconnect();
    debugPrint("🔌 [PusherService] Disconnected.");
  }

  // Subscribe helper for public channels
  void subscribe(String channelName, String eventName, void Function(dynamic data) onEvent) {
    if (!_initialized) init();
    
    final channel = _client?.publicChannel(channelName);
    
    // Bind to the specific event and listen
    channel?.bind(eventName).listen((event) {
      debugPrint("⚡ [PusherService] Received event '$eventName' on channel '$channelName': ${event.data}");
      onEvent(event.data);
    });
    
    debugPrint("⚡ [PusherService] Subscribed to public channel '$channelName' listening for '$eventName'.");
  }
}
