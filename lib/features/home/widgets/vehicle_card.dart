import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../favorites/providers/favorite_provider.dart';
import '../models/vehicle.dart';
import '../../vehicles/screens/vehicle_details_screen.dart';

class VehicleCard extends ConsumerWidget {
  final Vehicle vehicle;
  final VoidCallback? onTap;
  final int imageCacheVersion;

  const VehicleCard({
    super.key,
    required this.vehicle,
    this.onTap,
    this.imageCacheVersion = 0,
  });

  String _imageUrlWithCacheBust() {
    final url = vehicle.imageUrl.trim();

    if (url.isEmpty || imageCacheVersion == 0) {
      return url;
    }

    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}rk_cache=$imageCacheVersion';
  }

  void _openFullScreenImage(BuildContext context) {
    final imageUrl = _imageUrlWithCacheBust();

    if (imageUrl.isEmpty) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) => _VehicleCardFullScreenImage(
          imageUrl: imageUrl,
          heroTag: 'vehicle-card-image-${vehicle.id}',
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  // ==========================================================
  // TOGGLE FAVORITE
  // ==========================================================

  Future<void> _toggleFavorite(
      BuildContext context,
      WidgetRef ref,
      bool isFavorite,
      ) async {
    try {
      final service = ref.read(
        favoriteServiceProvider,
      );

      if (isFavorite) {
        await service.removeFavorite(
          vehicle.id,
        );

        ref.invalidate(
          favoriteStatusProvider(
            vehicle.id,
          ),
        );

        ref.invalidate(
          myFavoritesProvider,
        );

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Removed from favorites',
            ),
            duration: Duration(
              milliseconds: 1200,
            ),
          ),
        );
      } else {
        await service.addFavorite(
          vehicle.id,
        );

        ref.invalidate(
          favoriteStatusProvider(
            vehicle.id,
          ),
        );

        ref.invalidate(
          myFavoritesProvider,
        );

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Added to favorites',
            ),
            duration: Duration(
              milliseconds: 1200,
            ),
          ),
        );
      }
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update favorite',
          ),
          duration: const Duration(
            milliseconds: 1800,
          ),
        ),
      );
    }
  }

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    // ========================================================
    // FAVORITE STATUS FROM BACKEND
    // ========================================================

    final favoriteAsync = ref.watch(
      favoriteStatusProvider(
        vehicle.id,
      ),
    );

    final isFavorite =
        favoriteAsync.value ?? false;

    final isFavoriteLoading =
        favoriteAsync.isLoading;

    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: 270,

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
          BorderRadius.circular(18),

          border: Border.all(
            color: const Color(
              0xFFE5E7EB,
            ),
          ),
        ),

        clipBehavior:
        Clip.antiAlias,

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            // =================================================
            // IMAGE
            // =================================================

            Stack(
              children: [
                SizedBox(
                  height: 165,
                  width: double.infinity,

                  child: vehicle.imageUrl.isEmpty
                      ? const ColoredBox(
                    color: Color(
                      0xFFE5E7EB,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.directions_car,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  )
                      : GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _openFullScreenImage(context),
                    child: Hero(
                      tag: 'vehicle-card-image-${vehicle.id}',
                      child: Image.network(
                        _imageUrlWithCacheBust(),

                        fit: BoxFit.cover,

                        errorBuilder: (
                            BuildContext context,
                            Object error,
                            StackTrace? stackTrace,
                            ) {
                          return const ColoredBox(
                            color: Color(
                              0xFFE5E7EB,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.directions_car,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // =================================================
                // PREMIUM BADGE
                // =================================================

                if (vehicle.isPremium)
                  Positioned(
                    top: 12,
                    left: 12,

                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.black87,

                        borderRadius:
                        BorderRadius.circular(8),
                      ),

                      child: const Text(
                        'PREMIUM',

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // =================================================
                // FAVORITE BUTTON
                // =================================================

                Positioned(
                  top: 10,
                  right: 10,

                  child: Material(
                    color: Colors.transparent,

                    child: InkWell(
                      onTap: isFavoriteLoading
                          ? null
                          : () {
                        _toggleFavorite(
                          context,
                          ref,
                          isFavorite,
                        );
                      },

                      borderRadius:
                      BorderRadius.circular(30),

                      child: Container(
                        width: 40,
                        height: 40,

                        decoration:
                        const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),

                        child: Center(
                          child:
                          isFavoriteLoading
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                            CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                              : Icon(
                            isFavorite
                                ? Icons
                                .favorite_rounded
                                : Icons
                                .favorite_border_rounded,

                            size: 21,

                            color: isFavorite
                                ? Colors.red
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // =================================================
            // DETAILS
            // =================================================

            Padding(
              padding:
              const EdgeInsets.all(14),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  // =================================================
                  // VEHICLE NAME
                  // =================================================

                  Text(
                    vehicle.name,

                    maxLines: 1,

                    overflow:
                    TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  // =================================================
                  // RATING
                  // =================================================

                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,

                        size: 18,

                        color:
                        Colors.amber,
                      ),

                      const SizedBox(
                        width: 4,
                      ),

                      Text(
                        vehicle.rating
                            .toStringAsFixed(1),

                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),

                      Text(
                        ' (${vehicle.reviewCount})',

                        style:
                        const TextStyle(
                          color:
                          Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  // =================================================
                  // LOCATION
                  // =================================================

                  Row(
                    children: [
                      const Icon(
                        Icons
                            .location_on_outlined,

                        size: 16,

                        color:
                        Colors.grey,
                      ),

                      const SizedBox(
                        width: 4,
                      ),

                      Expanded(
                        child: Text(
                          vehicle.location,

                          maxLines: 1,

                          overflow:
                          TextOverflow
                              .ellipsis,

                          style:
                          const TextStyle(
                            color:
                            Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  // =================================================
                  // PRICE
                  // =================================================

                  Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.end,

                    children: [
                      Text(
                        '₹${vehicle.price24Hours.toStringAsFixed(0)}',

                        style:
                        const TextStyle(
                          fontSize: 18,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        width: 5,
                      ),

                      const Text(
                        '/ 24h',

                        style:
                        TextStyle(
                          color:
                          Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleCardFullScreenImage extends StatelessWidget {
  final String imageUrl;
  final String heroTag;
  const _VehicleCardFullScreenImage({required this.imageUrl, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Center(
              child: Hero(
                tag: heroTag,
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4.0,
                  panEnabled: true,
                  child: Image.network(imageUrl, fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined, color: Colors.white70, size: 64)),
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                child: IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
