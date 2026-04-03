import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/logger_service.dart';
import '../services/sos_service.dart';
import '../models/sos_request.dart';
import '../models/emergency_contact.dart';
import '../models/ritual.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // IMPORTANT: Ensure binding for background plugins (Plan Emergency v2)
    WidgetsFlutterBinding.ensureInitialized();
    Log.info("Background Worker started for task: $task");

    try {
      await dotenv.load(fileName: ".env");
      Log.info("Background DotEnv loaded successfully");
    } catch (e) {
      Log.error("Background DotEnv load failed", e);
    }

    Isar? isar;
    try {
      final dir = await getApplicationDocumentsDirectory();
      Log.debug("Background Documents directory: ${dir.path}");
      
      isar = await Isar.open(
        [SOSRequestSchema, EmergencyContactSchema, RitualSchema],
        directory: dir.path,
      );
      Log.info("Background Isar opened successfully");

      if (task == SosService.syncTaskName) {
        final uuid = inputData?['uuid'] as String?;
        if (uuid == null) return true;

        final service = SosService(isar);
        return await service.syncPulse(uuid);
      }
      return true;
    } catch (e) {
      Log.error("Background task error", e);
      return false;
    } finally {
      await isar?.close();
      Log.info("Background Isar closed");
    }
  });
}
