import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/models/vehicle.dart';
import '../services/search_service.dart';


// ============================================================
// SEARCH SERVICE PROVIDER
// ============================================================

final searchServiceProvider =
Provider<SearchService>((ref) {
  return SearchService();
});


// ============================================================
// SEARCH STATE
// ============================================================

class SearchState {
  final List<Vehicle> vehicles;
  final bool isLoading;
  final String? error;

  const SearchState({
    this.vehicles = const [],
    this.isLoading = false,
    this.error,
  });

  SearchState copyWith({
    List<Vehicle>? vehicles,
    bool? isLoading,
    String? error,
  }) {
    return SearchState(
      vehicles: vehicles ?? this.vehicles,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}


// ============================================================
// SEARCH NOTIFIER
// ============================================================

class SearchNotifier
    extends StateNotifier<SearchState> {
  final SearchService _searchService;

  SearchNotifier(
      this._searchService,
      ) : super(const SearchState());


  // ==========================================================
  // SEARCH VEHICLES
  // ==========================================================

  Future<void> searchVehicles({
    String? search,
    String? category,
    String? city,
    String? area,
    String? vehicleType,
    double? minPrice,
    double? maxPrice,
    int? seats,
    String? fuelType,
    String? transmission,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final vehicles =
      await _searchService.searchVehicles(
        search: search,
        category: category,
        city: city,
        area: area,
        vehicleType: vehicleType,
        minPrice: minPrice,
        maxPrice: maxPrice,
        seats: seats,
        fuelType: fuelType,
        transmission: transmission,
      );

      state = state.copyWith(
        vehicles: vehicles,
        isLoading: false,
        error: null,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }


  // ==========================================================
  // CLEAR SEARCH
  // ==========================================================

  void clear() {
    state = const SearchState();
  }
}


// ============================================================
// SEARCH PROVIDER
// ============================================================

final searchProvider = StateNotifierProvider<
    SearchNotifier,
    SearchState
>(
      (ref) {
    final searchService =
    ref.watch(searchServiceProvider);

    return SearchNotifier(
      searchService,
    );
  },
);
