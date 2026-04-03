import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class Identity {
  static const String _deviceIdKey = 'device_id';

  /// Returns the persistent device ID, generating it if it doesn't exist.
  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_deviceIdKey);

    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString(_deviceIdKey, deviceId);
    }

    return deviceId;
  }
}
