import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/ritual.dart';

class SyncService {
  final Isar isar;

  SyncService(this.isar);

  /// Load initial data from bundled assets if Isar is empty (D-25).
  Future<void> loadInitialData() async {
    final count = await isar.rituals.count();
    if (count > 0) return;

    try {
      final String response = await rootBundle.loadString('assets/data/rituals.json');
      final List<dynamic> data = json.decode(response);
      
      final rituals = data.map((json) => _jsonToRitual(json)).toList();
      
      await isar.writeTxn(() async {
        for (var ritual in rituals) {
          await isar.rituals.putByRitualId(ritual);
        }
      });
    } catch (e) {
      // In a real app, use a logger
      debugPrint('Error loading initial ritual data: $e');
    }
  }

  /// Sync rituals from the backend API (Optional Sync).
  Future<void> syncWithBackend() async {
    final baseUrl = dotenv.get('API_BASE_URL', fallback: 'http://10.0.2.2:8000');
    final url = Uri.parse('$baseUrl/rituals/');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final rituals = data.map((json) => _jsonToRitual(json)).toList();
        
        await isar.writeTxn(() async {
          for (var ritual in rituals) {
            await isar.rituals.putByRitualId(ritual);
          }
        });
      }
    } catch (e) {
      debugPrint('Sync failed: $e');
    }
  }

  Ritual _jsonToRitual(Map<String, dynamic> json) {
    return Ritual()
      ..ritualId = json['ritualId']
      ..title = json['title']
      ..description = json['description']
      ..location = json['location']
      ..locationCoord = List<double>.from(json['locationCoord'])
      ..category = json['category']
      ..startTime = DateTime.parse(json['startTime'])
      ..importance = json['importance'];
  }
}
