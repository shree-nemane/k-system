import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';

class Camera {
  final String cameraId;
  final String name;
  final String locationLabel;
  final bool isActive;

  Camera({
    required this.cameraId,
    required this.name,
    required this.locationLabel,
    required this.isActive,
  });

  factory Camera.fromJson(Map<String, dynamic> json) {
    return Camera(
      cameraId: json['camera_id'],
      name: json['name'],
      locationLabel: json['location_label'] ?? 'Unknown',
      isActive: json['is_active'],
    );
  }
}

final cameraProvider = FutureProvider<List<Camera>>((ref) async {
  final client = ApiClient();
  final response = await client.get('/cameras/');
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return (data['cameras'] as List).map((c) => Camera.fromJson(c)).toList();
  } else {
    throw Exception('Failed to load cameras');
  }
});
