import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../models/ritual.dart';
import '../services/sync_service.dart';
import 'isar_provider.dart';

final syncServiceProvider = Provider<SyncService?>((ref) {
  final isarAsync = ref.watch(isarProvider);
  return isarAsync.when(
    data: (isar) => SyncService(isar),
    loading: () => null,
    error: (_, __) => null,
  );
});

final ritualsProvider = StreamProvider<List<Ritual>>((ref) async* {
  final isarAsync = ref.watch(isarProvider);
  
  if (isarAsync is AsyncData) {
    final isar = isarAsync.value!;
    yield* isar.rituals.where().sortByStartTime().watch(fireImmediately: true);
  } else {
    yield [];
  }
});
