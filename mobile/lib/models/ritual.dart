import 'package:isar/isar.dart';

part 'ritual.g.dart';

@collection
class Ritual {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String ritualId;

  late String title;
  late String description;
  late String location;
  
  // Stored as [lat, lng]
  late List<double> locationCoord;

  late String category;
  
  late DateTime startTime;
  
  late String importance; // 'low', 'high', 'critical'
}
