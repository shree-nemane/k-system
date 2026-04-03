import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/websocket_service.dart';

final crowdStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final service = WebSocketService();
  service.connect();
  
  ref.onDispose(() {
    // We don't dispose the singleton service here, 
    // but we could handle per-subscription logic if needed.
  });

  return service.stream.map((event) => event as Map<String, dynamic>);
});

final globalDensityProvider = Provider<double>((ref) {
  final stream = ref.watch(crowdStreamProvider);
  return stream.maybeWhen(
    data: (data) => (data['density'] ?? 0.0).toDouble(),
    orElse: () => 0.0,
  );
});
