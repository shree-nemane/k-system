import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../services/routing_service.dart';

class NavigationState {
  final LatLng? destination;
  final String? destinationName;
  final bool isNavigating;
  final bool isLoadingRoute;
  final String? instruction;
  final List<LatLng> routePoints;

  NavigationState({
    this.destination,
    this.destinationName,
    this.isNavigating = false,
    this.isLoadingRoute = false,
    this.instruction,
    this.routePoints = const [],
  });

  NavigationState copyWith({
    LatLng? destination,
    String? destinationName,
    bool? isNavigating,
    bool? isLoadingRoute,
    String? instruction,
    List<LatLng>? routePoints,
  }) {
    return NavigationState(
      destination: destination ?? this.destination,
      destinationName: destinationName ?? this.destinationName,
      isNavigating: isNavigating ?? this.isNavigating,
      isLoadingRoute: isLoadingRoute ?? this.isLoadingRoute,
      instruction: instruction ?? this.instruction,
      routePoints: routePoints ?? this.routePoints,
    );
  }
}

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(NavigationState());

  /// Start navigation — fetches a road-following route from OSRM.
  /// [origin] is the user's current location.
  /// [destination] is the target point.
  /// [routePoints] is an optional fallback (predefined route from map data).
  Future<void> startNavigation(
    LatLng destination,
    String name, {
    LatLng? origin,
    List<LatLng> routePoints = const [],
  }) async {
    // Show loading state immediately
    state = state.copyWith(
      destination: destination,
      destinationName: name,
      isNavigating: true,
      isLoadingRoute: true,
      instruction: 'Finding best route to $name...',
      routePoints: routePoints,
    );

    // If we have the user's location, fetch a real road route
    if (origin != null) {
      final roadRoute = await RoutingService.getRoute(origin, destination);

      // Only use OSRM result if it returned more than a straight line
      if (roadRoute.length > 2) {
        state = state.copyWith(
          routePoints: roadRoute,
          isLoadingRoute: false,
          instruction: 'Proceeding towards $name',
        );
        return;
      }
    }

    // Fallback: use predefined route or straight line
    state = state.copyWith(
      isLoadingRoute: false,
      instruction: 'Proceeding towards $name',
    );
  }

  void stopNavigation() {
    state = NavigationState();
  }

  void updateInstruction(String instruction) {
    state = state.copyWith(instruction: instruction);
  }
}

final navigationProvider = StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
  return NavigationNotifier();
});
