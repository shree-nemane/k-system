import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class NavigationState {
  final LatLng? destination;
  final String? destinationName;
  final bool isNavigating;
  final String? instruction;

  NavigationState({
    this.destination,
    this.destinationName,
    this.isNavigating = false,
    this.instruction,
  });

  NavigationState copyWith({
    LatLng? destination,
    String? destinationName,
    bool? isNavigating,
    String? instruction,
  }) {
    return NavigationState(
      destination: destination ?? this.destination,
      destinationName: destinationName ?? this.destinationName,
      isNavigating: isNavigating ?? this.isNavigating,
      instruction: instruction ?? this.instruction,
    );
  }
}

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(NavigationState());

  void startNavigation(LatLng destination, String name) {
    state = state.copyWith(
      destination: destination,
      destinationName: name,
      isNavigating: true,
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
