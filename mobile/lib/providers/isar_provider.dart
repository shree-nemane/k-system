import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/sos_request.dart';
import '../models/emergency_contact.dart';
import '../models/ritual.dart';

final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open(
    [SOSRequestSchema, EmergencyContactSchema, RitualSchema],
    directory: dir.path,
  );
});
