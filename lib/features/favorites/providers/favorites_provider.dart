import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final favoriteVehicleIdsProvider =
StateNotifierProvider<
    FavoriteVehicleIdsNotifier,
    Set<int>
>((ref) {
  return FavoriteVehicleIdsNotifier();
});

class FavoriteVehicleIdsNotifier
    extends StateNotifier<Set<int>> {
  FavoriteVehicleIdsNotifier()
      : super(<int>{}) {
    loadFavorites();
  }

  static const FlutterSecureStorage _storage =
  FlutterSecureStorage();

  static const String _key =
      'favorite_vehicle_ids';

  Future<void> loadFavorites() async {
    final value = await _storage.read(
      key: _key,
    );

    if (value == null || value.isEmpty) {
      return;
    }

    final ids = value
        .split(',')
        .map(int.tryParse)
        .whereType<int>()
        .toSet();

    state = ids;
  }

  Future<void> toggleFavorite(
      int vehicleId,
      ) async {
    final updated = Set<int>.from(state);

    if (updated.contains(vehicleId)) {
      updated.remove(vehicleId);
    } else {
      updated.add(vehicleId);
    }

    state = updated;

    await _storage.write(
      key: _key,
      value: updated.join(','),
    );
  }

  bool isFavorite(int vehicleId) {
    return state.contains(vehicleId);
  }
}