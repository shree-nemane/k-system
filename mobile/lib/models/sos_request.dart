import 'package:isar/isar.dart';

part 'sos_request.g.dart';

@collection
class SOSRequest {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late double latitude;
  late double longitude;
  late double? altitude;
  late double? batteryLevel;
  
  late String category; // MEDICAL, LOST, FIRE, GENERAL
  
  @Index()
  late DateTime createdAt;

  late String status; // pending, sent, received, dispatched

  String? responderName;
}
