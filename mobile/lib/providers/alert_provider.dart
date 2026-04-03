import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';

class Alert {
  final int id;
  final String eventType;
  final String cameraId;
  final String severity;
  final DateTime firedAt;

  Alert({
    required this.id,
    required this.eventType,
    required this.cameraId,
    required this.severity,
    required this.firedAt,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'],
      eventType: json['event_type'],
      cameraId: json['camera_id'],
      severity: json['severity'],
      firedAt: DateTime.parse(json['fired_at']),
    );
  }
}

final alertProvider = FutureProvider<List<Alert>>((ref) async {
  final client = ApiClient();
  final response = await client.get('/alerts/recent');
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return (data['alerts'] as List).map((a) => Alert.fromJson(a)).toList();
  } else {
    throw Exception('Failed to load alerts');
  }
});
