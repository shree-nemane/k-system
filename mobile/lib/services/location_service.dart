import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

class LocationService {
  final _logger = Logger();

  Stream<Position> get locationStream => Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      );

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _logger.e('Location services are disabled.');
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _logger.e('Location permissions are denied');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _logger.e('Location permissions are permanently denied.');
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }
}
