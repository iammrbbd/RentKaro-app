import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/favorite_service.dart';


// ============================================================
// FAVORITE SERVICE PROVIDER
// ============================================================

final favoriteServiceProvider = Provider<FavoriteService>((ref) {
  return FavoriteService();
});


// ============================================================
// MY FAVORITES PROVIDER
// ============================================================
//
// Returns:
// [
//   {
//     "favorite_id": ...,
//     "created_at": ...,
//     "vehicle": {...}
//   }
// ]
//

final myFavoritesProvider =
FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.read(favoriteServiceProvider);

  return service.getMyFavorites();
});


// ============================================================
// FAVORITE STATUS PROVIDER
// ============================================================
//
// Usage:
//
// ref.watch(favoriteStatusProvider(vehicleId));
//

final favoriteStatusProvider =
FutureProvider.family<bool, int>((ref, vehicleId) async {
  final service = ref.read(favoriteServiceProvider);

  return service.isFavorite(vehicleId);
});