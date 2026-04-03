import 'package:isar/isar.dart';

part 'emergency_contact.g.dart';

@collection
class EmergencyContact {
  Id id = 1; // Fixed ID as we only store one primary contact in Phase 3

  late String name;
  late String phone;
  late String relationship;

  late DateTime lastUpdated;
}
