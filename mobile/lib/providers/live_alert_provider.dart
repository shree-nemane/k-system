import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../services/websocket_service.dart';
import '../core/logger_service.dart';
import './alert_provider.dart';

class LiveAlertNotifier extends StateNotifier<AsyncValue<List<Alert>>> {
  StreamSubscription? _subscription;
  
  LiveAlertNotifier() : super(const AsyncLoading()) {
    _init();
  }

  void _init() async {
    // 1. Ensure WebSocket is open
    WebSocketService().connect();

    try {
      // 2. Initial Fetch (Historical)
      final client = ApiClient();
      final response = await client.get('/alerts/recent');
      
      List<Alert> historical = [];
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        historical = (data['alerts'] as List).map((a) => Alert.fromJson(a as Map<String, dynamic>)).toList();
        state = AsyncData(historical);
      } else {
        Log.error("Failed to sync security history: ${response.statusCode}");
      }

      // 3. Listen to WebSocket (Live Updates)
      _subscription?.cancel();
      _subscription = WebSocketService().stream.listen((message) {
        if (message is! Map<String, dynamic>) return;

        final type = message['type'] as String?;
        Alert? newAlert;

        if (type == 'alert') {
          // Sustained Breach Alert (D-28)
          newAlert = Alert(
            id: DateTime.now().millisecondsSinceEpoch,
            eventType: message['event'] ?? 'incident',
            cameraId: message['camera_id'] ?? 'unknown',
            severity: message['severity'] ?? 'high',
            firedAt: DateTime.now(),
          );
        } else if (type == 'density_update') {
          // Ordinary Density Update (D-09) - Shown as info
          newAlert = Alert(
            id: DateTime.now().millisecondsSinceEpoch,
            eventType: "density_check",
            cameraId: message['camera_id'] ?? 'unknown',
            severity: "medium", // Shown as Saffron in AlertsScreen
            firedAt: DateTime.now(),
          );
        }

        if (newAlert != null) {
          final currentAlerts = state.value ?? [];
          // Keep only the last 50 alerts in the live view
          final updatedAlerts = [newAlert, ...currentAlerts].take(50).toList();
          state = AsyncData(updatedAlerts);
        }
      }, onError: (e) {
        Log.error("LiveAlert stream error", e);
      });
      
    } catch (e, stack) {
      Log.error("Failed to initialize safety feed", e, stack);
      state = AsyncError(e, stack);
    }
  }

  void refresh() {
    state = const AsyncLoading();
    _init();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final liveAlertProvider = StateNotifierProvider<LiveAlertNotifier, AsyncValue<List<Alert>>>((ref) {
  return LiveAlertNotifier();
});
