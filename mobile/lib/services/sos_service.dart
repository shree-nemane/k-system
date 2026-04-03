import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import 'package:workmanager/workmanager.dart';
import '../models/sos_request.dart';
import '../core/api_client.dart';

class SosService {
  final Isar isar;
  static const String syncTaskName = "sosSyncTask";

  SosService(this.isar);

  /// Triggers a new SOS request by queuing it locally and scheduling a background sync.
  Future<void> triggerSOS({
    required double latitude,
    required double longitude,
    double? altitude,
    double? batteryLevel,
    required String category,
  }) async {
    final pulse = SOSRequest()
      ..uuid = const Uuid().v4()
      ..latitude = latitude
      ..longitude = longitude
      ..altitude = altitude
      ..batteryLevel = batteryLevel
      ..category = category
      ..status = 'pending'
      ..createdAt = DateTime.now();

    // 1. Persist locally immediately
    await isar.writeTxn(() async {
      await isar.sOSRequests.put(pulse);
    });

    // 2. Schedule background sync with WorkManager
    await Workmanager().registerOneOffTask(
      const Uuid().v4(), // Unique task ID
      syncTaskName,
      inputData: {'uuid': pulse.uuid},
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(seconds: 30),
    );

    // 3. Attempt immediate sync in-process
    await syncPulse(pulse.uuid);
  }

  /// Attempts to transmit a specific pulse to the backend.
  Future<bool> syncPulse(String uuid) async {
    final pulse = await isar.sOSRequests.filter().uuidEqualTo(uuid).findFirst();
    if (pulse == null || pulse.status == 'sent') return true;

    try {
      final client = ApiClient();
      // Enriched payload (Plan 03-02 Task 2)
      final response = await client.post('/sos/request', {
        'device_id': pulse.uuid,
        'latitude': pulse.latitude,
        'longitude': pulse.longitude,
        'altitude': pulse.altitude,
        'battery_level': pulse.batteryLevel,
        'category': pulse.category,
      });

      if (response.statusCode == 200) {
        await isar.writeTxn(() async {
          pulse.status = 'sent';
          await isar.sOSRequests.put(pulse);
        });
        return true;
      }
    } catch (e) {
      // Log failure, WorkManager will retry
      debugPrint("Sync failure for SOS $uuid: $e");
    }
    return false;
  }
}
