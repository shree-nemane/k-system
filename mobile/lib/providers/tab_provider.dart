import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to manage the global active tab of the MainScaffold.
/// 0: Home (Dashboard), 1: Live Map, 2: Alerts, 3: SOS
final tabProvider = StateProvider<int>((ref) => 0);
