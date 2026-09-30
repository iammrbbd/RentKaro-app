import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/models/vehicle.dart';
import '../../vehicles/screens/vehicle_details_screen.dart';
import '../providers/favorite_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(myFavoritesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: favoritesAsync.when(
        // ======================================================
        // LOADING
        // ======================================================

        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },

        // ======================================================
        // ERROR
        // ======================================================

        error: (error, stackTrace) {
          return _ErrorView(
            error: error,
            onRetry: () {
              ref.invalidate(myFavoritesProvider);
            },
          );
        },

        // ======================================================
        // DATA
        // ======================================================

        data: (favorites) {
          if (favorites.isEmpty) {
            return const _EmptyFavoritesView();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(myFavoritesProvider);

              await ref.read(
                myFavoritesProvider.future,
              );
            },

            child: ListView.builder(
              physics:
              const AlwaysScrollableScrollPhysics(),

              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                100,
              ),

              itemCount: favorites.length,

              itemBuilder: (context, index) {
                final favorite = favorites[index];

                return _FavoriteCard(
                  favorite: favorite,
                );
              },
            ),
          );
        },
      ),
    );
  }
}


// ============================================================
// FAVORITE CARD
// ============================================================

class _FavoriteCard extends ConsumerWidget {
  final Map<String, dynamic> favorite;

  const _FavoriteCard({
    required this.favorite,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    // ========================================================
    // VEHICLE DATA
    // ========================================================

    final vehicleData = favorite['vehicle'];

    if (vehicleData is! Map) {
      return const SizedBox.shrink();
    }

    final vehicleJson =
    Map<String, dynamic>.from(
      vehicleData,
    );

    // ========================================================
    // USE YOUR EXISTING VEHICLE MODEL
    // ========================================================

    final Vehicle vehicle =
    Vehicle.fromJson(vehicleJson);

    // ========================================================
    // IMAGE
    // ========================================================

    final imageUrl = vehicle.imageUrl;

    // ========================================================
    // LOCATION
    // ========================================================

    String location = '';

    if (vehicle.area.isNotEmpty &&
        vehicle.city.isNotEmpty) {
      location =
      '${vehicle.area}, ${vehicle.city}';
    } else if (vehicle.city.isNotEmpty) {
      location = vehicle.city;
    } else if (vehicle.area.isNotEmpty) {
      location = vehicle.area;
    }

    // ========================================================
    // REMOVE FAVORITE
    // ========================================================

    Future<void> removeFavorite() async {
      try {
        await ref
            .read(favoriteServiceProvider)
            .removeFavorite(vehicle.id);

        ref.invalidate(
          myFavoritesProvider,
        );

        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Removed from favorites',
            ),
          ),
        );
      } catch (error) {
        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              _cleanError(error),
            ),
          ),
        );
      }
    }

    // ========================================================
    // OPEN DETAILS
    // ========================================================

    void openDetails() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              VehicleDetailsScreen(
                vehicle: vehicle,
              ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(18),

        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),

        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),

      child: InkWell(
        onTap: openDetails,

        borderRadius:
        BorderRadius.circular(18),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            // ==================================================
            // IMAGE
            // ==================================================

            SizedBox(
              height: 190,
              width: double.infinity,

              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                    const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),

                    child: imageUrl.isNotEmpty
                        ? Image.network(
                      imageUrl,

                      width:
                      double.infinity,

                      height:
                      double.infinity,

                      fit: BoxFit.cover,

                      errorBuilder:
                          (
                          context,
                          error,
                          stackTrace,
                          ) {
                        return _imagePlaceholder();
                      },
                    )
                        : _imagePlaceholder(),
                  ),

                  // ==================================================
                  // FAVORITE BUTTON
                  // ==================================================

                  Positioned(
                    top: 12,
                    right: 12,

                    child: Material(
                      color: Colors.white,
                      shape:
                      const CircleBorder(),

                      elevation: 2,

                      child: InkWell(
                        customBorder:
                        const CircleBorder(),

                        onTap: removeFavorite,

                        child: const SizedBox(
                          height: 44,
                          width: 44,

                          child: Icon(
                            Icons.favorite_rounded,
                            color: Colors.red,
                            size: 23,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ==================================================
                  // VERIFIED
                  // ==================================================

                  if (vehicle.isVerified)
                    Positioned(
                      left: 12,
                      bottom: 12,

                      child: Container(
                        padding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),

                        decoration:
                        BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(
                            8,
                          ),
                        ),

                        child: const Row(
                          mainAxisSize:
                          MainAxisSize.min,

                          children: [
                            Icon(
                              Icons.verified,
                              size: 15,
                              color:
                              Color(0xFF1565C0),
                            ),

                            SizedBox(width: 4),

                            Text(
                              'Verified',
                              style:
                              TextStyle(
                                fontSize: 11,
                                fontWeight:
                                FontWeight.w700,
                                color:
                                Color(
                                  0xFF1565C0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ==================================================
            // DETAILS
            // ==================================================

            Padding(
              padding:
              const EdgeInsets.all(14),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  // ==================================================
                  // NAME + CATEGORY
                  // ==================================================

                  Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [
                      Expanded(
                        child: Text(
                          vehicle.name,

                          maxLines: 1,

                          overflow:
                          TextOverflow.ellipsis,

                          style:
                          const TextStyle(
                            fontSize: 18,
                            fontWeight:
                            FontWeight.w800,
                            color:
                            Color(
                              0xFF111827,
                            ),
                          ),
                        ),
                      ),

                      if (vehicle.category
                          .isNotEmpty)
                        Container(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),

                          decoration:
                          BoxDecoration(
                            color:
                            const Color(
                              0xFFF3F4F6,
                            ),
                            borderRadius:
                            BorderRadius
                                .circular(
                              7,
                            ),
                          ),

                          child: Text(
                            vehicle.category,

                            style:
                            const TextStyle(
                              fontSize: 10,
                              fontWeight:
                              FontWeight.w700,
                              color:
                              Color(
                                0xFF374151,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 7),

                  // ==================================================
                  // LOCATION
                  // ==================================================

                  if (location.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 17,
                          color:
                          Color(
                            0xFF6B7280,
                          ),
                        ),

                        const SizedBox(
                          width: 4,
                        ),

                        Expanded(
                          child: Text(
                            location,

                            maxLines: 1,

                            overflow:
                            TextOverflow
                                .ellipsis,

                            style:
                            const TextStyle(
                              fontSize: 13,
                              color:
                              Color(
                                0xFF6B7280,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 12),

                  // ==================================================
                  // PRICE
                  // ==================================================

                  Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.end,

                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                          children: [
                            const Text(
                              'Starting from',
                              style:
                              TextStyle(
                                fontSize: 11,
                                color:
                                Color(
                                  0xFF9CA3AF,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 3,
                            ),

                            Text(
                              '₹${vehicle.pricePerHour.toStringAsFixed(0)}',

                              style:
                              const TextStyle(
                                fontSize: 19,
                                fontWeight:
                                FontWeight.w800,
                                color:
                                Color(
                                  0xFF111827,
                                ),
                              ),
                            ),

                            const Text(
                              '/ hour',
                              style:
                              TextStyle(
                                fontSize: 11,
                                color:
                                Color(
                                  0xFF6B7280,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ==================================================
                      // AVAILABILITY
                      // ==================================================

                      Container(
                        padding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),

                        decoration:
                        BoxDecoration(
                          color:
                          vehicle.isAvailable
                              ? const Color(
                            0xFFECFDF5,
                          )
                              : const Color(
                            0xFFFEF2F2,
                          ),

                          borderRadius:
                          BorderRadius
                              .circular(
                            8,
                          ),
                        ),

                        child: Text(
                          vehicle.isAvailable
                              ? 'Available'
                              : 'Unavailable',

                          style:
                          TextStyle(
                            fontSize: 11,
                            fontWeight:
                            FontWeight.w700,

                            color: vehicle
                                .isAvailable
                                ? const Color(
                              0xFF15803D,
                            )
                                : const Color(
                              0xFFDC2626,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ==================================================
                  // 12 HOURS / 24 HOURS
                  // ==================================================

                  Row(
                    children: [
                      Expanded(
                        child: _PriceBox(
                          title: '12 Hours',
                          price:
                          vehicle.price12Hours,
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: _PriceBox(
                          title: '24 Hours',
                          price:
                          vehicle.price24Hours,
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


// ============================================================
// PRICE BOX
// ============================================================

class _PriceBox extends StatelessWidget {
  final String title;
  final double price;

  const _PriceBox({
    required this.title,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color:
        const Color(0xFFF8FAFC),

        borderRadius:
        BorderRadius.circular(10),

        border: Border.all(
          color:
          const Color(0xFFE5E7EB),
        ),
      ),

      child: Row(
        children: [
          Expanded(
            child: Text(
              title,

              style:
              const TextStyle(
                fontSize: 11,
                color:
                Color(0xFF6B7280),
              ),
            ),
          ),

          Text(
            '₹${price.toStringAsFixed(0)}',

            style:
            const TextStyle(
              fontSize: 12,
              fontWeight:
              FontWeight.w700,
              color:
              Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}


// ============================================================
// EMPTY FAVORITES
// ============================================================

class _EmptyFavoritesView
    extends StatelessWidget {
  const _EmptyFavoritesView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [
            Container(
              height: 90,
              width: 90,

              decoration:
              BoxDecoration(
                color:
                const Color(
                  0xFFFFF1F2,
                ),

                shape:
                BoxShape.circle,
              ),

              child: const Icon(
                Icons.favorite_border_rounded,
                size: 45,
                color: Colors.red,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            const Text(
              'No favorites yet',

              style:
              TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.w800,
                color:
                Color(0xFF111827),
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            const Text(
              'Save vehicles you like and find them here.',

              textAlign:
              TextAlign.center,

              style:
              TextStyle(
                fontSize: 14,
                color:
                Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ============================================================
// ERROR VIEW
// ============================================================

class _ErrorView
    extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(28),

        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 58,
              color:
              Colors.redAccent,
            ),

            const SizedBox(
              height: 18,
            ),

            const Text(
              'Unable to load favorites',

              textAlign:
              TextAlign.center,

              style:
              TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.w700,
                color:
                Color(0xFF111827),
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              _cleanError(error),

              textAlign:
              TextAlign.center,

              style:
              const TextStyle(
                fontSize: 12,
                color:
                Color(0xFF6B7280),
                height: 1.4,
              ),
            ),

            const SizedBox(
              height: 22,
            ),

            OutlinedButton(
              onPressed: onRetry,

              child:
              const Text(
                'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ============================================================
// IMAGE PLACEHOLDER
// ============================================================

Widget _imagePlaceholder() {
  return Container(
    width: double.infinity,
    height: double.infinity,

    color:
    const Color(0xFFE5E7EB),

    child: const Center(
      child: Icon(
        Icons.directions_car_rounded,
        size: 65,
        color:
        Color(0xFF9CA3AF),
      ),
    ),
  );
}


// ============================================================
// ERROR CLEANER
// ============================================================

String _cleanError(Object error) {
  final message =
  error.toString();

  if (message.startsWith(
    'Exception: ',
  )) {
    return message.substring(
      11,
    );
  }

  return message;
}