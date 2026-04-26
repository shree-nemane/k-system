import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class NavigationState {
  final LatLng? destination;
  final String? destinationName;
  final bool isNavigating;
  final String? instruction;
  final List<LatLng> routePoints;

  NavigationState({
    this.destination,
    this.destinationName,
    this.isNavigating = false,
    this.instruction,
    this.routePoints = const [],
  });

  NavigationState copyWith({
    LatLng? destination,
    String? destinationName,
    bool? isNavigating,
    String? instruction,
    List<LatLng>? routePoints,
  }) {
    return NavigationState(
      destination: destination ?? this.destination,
      destinationName: destinationName ?? this.destinationName,
      isNavigating: isNavigating ?? this.isNavigating,
      instruction: instruction ?? this.instruction,
      routePoints: routePoints ?? this.routePoints,
    );
  }
}

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(NavigationState());

  void startNavigation(LatLng destination, String name, {List<LatLng> routePoints = const []}) {
    state = state.copyWith(
      destination: destination,
      destinationName: name,
      isNavigating: true,
      instruction: 'Proceeding towards $name',
      routePoints: routePoints,
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
