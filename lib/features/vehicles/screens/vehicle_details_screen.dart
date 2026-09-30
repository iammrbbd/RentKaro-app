import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../booking/screens/booking_screen.dart';
import '../../favorites/providers/favorite_provider.dart';
import '../../home/models/vehicle.dart';
import '../../reviews/providers/review_provider.dart';
import '../../reviews/models/review.dart';

class VehicleDetailsScreen extends ConsumerStatefulWidget {
  final Vehicle vehicle;

  const VehicleDetailsScreen({
    super.key,
    required this.vehicle,
  });

  @override
  ConsumerState<VehicleDetailsScreen> createState() =>
      _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState
    extends ConsumerState<VehicleDetailsScreen> {
  bool _isFavorite = false;
  bool _favoriteLoading = true;
  bool _favoriteActionLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  void _openFullScreenImage() {
    final imageUrl = widget.vehicle.imageUrl.trim();
    if (imageUrl.isEmpty) return;
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black,
      pageBuilder: (_, __, ___) => _VehicleDetailsFullScreenImage(imageUrl: imageUrl, heroTag: 'vehicle-details-image-${widget.vehicle.id}'),
      transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
    ));
  }

  // ==========================================================
  // LOAD FAVORITE STATUS
  // ==========================================================

  Future<void> _loadFavoriteStatus() async {
    try {
      final isFavorite = await ref
          .read(favoriteServiceProvider)
          .isFavorite(widget.vehicle.id);

      if (!mounted) return;

      setState(() {
        _isFavorite = isFavorite;
        _favoriteLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _favoriteLoading = false;
      });
    }
  }

  // ==========================================================
  // TOGGLE FAVORITE
  // ==========================================================

  Future<void> _toggleFavorite() async {
    if (_favoriteActionLoading) {
      return;
    }

    setState(() {
      _favoriteActionLoading = true;
    });

    try {
      if (_isFavorite) {
        await ref
            .read(favoriteServiceProvider)
            .removeFavorite(widget.vehicle.id);

        if (!mounted) return;

        setState(() {
          _isFavorite = false;
        });

        ref.invalidate(myFavoritesProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Removed from favorites',
            ),
          ),
        );
      } else {
        await ref
            .read(favoriteServiceProvider)
            .addFavorite(widget.vehicle.id);

        if (!mounted) return;

        setState(() {
          _isFavorite = true;
        });

        ref.invalidate(myFavoritesProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Added to favorites',
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update favorite: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _favoriteActionLoading = false;
        });
      }
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final vehicle = widget.vehicle;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: CustomScrollView(
        slivers: [
          // ==================================================
          // APP BAR + VEHICLE IMAGE
          // ==================================================

          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,

            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                  ),
                ),
              ),
            ),

            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed:
                    _favoriteLoading ||
                        _favoriteActionLoading
                        ? null
                        : _toggleFavorite,
                    icon:
                    _favoriteLoading ||
                        _favoriteActionLoading
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : Icon(
                      _isFavorite
                          ? Icons.favorite_rounded
                          : Icons
                          .favorite_border_rounded,
                      color: _isFavorite
                          ? Colors.red
                          : Colors.black,
                    ),
                  ),
                ),
              ),
            ],

            flexibleSpace: FlexibleSpaceBar(
              background: vehicle.imageUrl.isEmpty
                  ? const ColoredBox(
                color: Color(0xFFE5E7EB),
                child: Center(
                  child: Icon(
                    Icons.directions_car,
                    size: 70,
                    color: Colors.grey,
                  ),
                ),
              )
                  : GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _openFullScreenImage,
                child: Hero(
                  tag: 'vehicle-details-image-${vehicle.id}',
                  child: Image.network(
                    vehicle.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (
                        context,
                        error,
                        stackTrace,
                        ) {
                      return const ColoredBox(
                        color: Color(0xFFE5E7EB),
                        child: Center(
                          child: Icon(
                            Icons.directions_car,
                            size: 70,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // ==================================================
          // BODY
          // ==================================================

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                130,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  // ==========================================
                  // NAME
                  // ==========================================

                  Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          vehicle.name,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight:
                            FontWeight.w800,
                            color:
                            Color(0xFF111827),
                          ),
                        ),
                      ),

                      if (vehicle.isPremium)
                        Container(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration:
                          BoxDecoration(
                            color:
                            const Color(
                              0xFF111827,
                            ),
                            borderRadius:
                            BorderRadius.circular(
                              8,
                            ),
                          ),
                          child: const Text(
                            'PREMIUM',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ==========================================
                  // VERIFICATION
                  // ==========================================

                  if (vehicle.isVerified)
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          color:
                          Color(0xFF1565C0),
                          size: 18,
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'Verified vehicle',
                          style: TextStyle(
                            color:
                            Color(0xFF1565C0),
                            fontWeight:
                            FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 8),

                  // ==========================================
                  // LOCATION
                  // ==========================================

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color:
                        Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          vehicle.location,
                          style: const TextStyle(
                            color:
                            Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ==========================================
                  // REVIEWS & RATINGS
                  // ==========================================

                  const _SectionTitle(
                    title: 'Reviews & Ratings',
                  ),

                  const SizedBox(height: 14),

                  _VehicleReviewsSection(
                    vehicleId: vehicle.id,
                  ),

                  const SizedBox(height: 25),

                  // ==========================================
                  // DESCRIPTION
                  // ==========================================

                  if (vehicle.description.isNotEmpty) ...[
                    const _SectionTitle(
                      title: 'About this vehicle',
                    ),

                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      padding:
                      const EdgeInsets.all(16),
                      decoration:
                      BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(
                          16,
                        ),
                        border: Border.all(
                          color:
                          const Color(
                            0xFFE5E7EB,
                          ),
                        ),
                      ),
                      child: Text(
                        vehicle.description,
                        style: const TextStyle(
                          color:
                          Color(0xFF4B5563),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),
                  ],

                  // ==========================================
                  // VEHICLE INFORMATION
                  // ==========================================

                  const _SectionTitle(
                    title: 'Vehicle information',
                  ),

                  const SizedBox(height: 14),

                  Container(
                    padding:
                    const EdgeInsets.all(16),
                    decoration:
                    BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(
                        16,
                      ),
                      border: Border.all(
                        color:
                        const Color(
                          0xFFE5E7EB,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _InfoItem(
                                icon: Icons
                                    .category_outlined,
                                title: 'Category',
                                value:
                                vehicle.category,
                              ),
                            ),
                            Expanded(
                              child: _InfoItem(
                                icon: Icons
                                    .people_outline,
                                title: 'Seats',
                                value:
                                vehicle.seats
                                    .toString(),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        Row(
                          children: [
                            Expanded(
                              child: _InfoItem(
                                icon: Icons
                                    .local_gas_station_outlined,
                                title: 'Fuel',
                                value:
                                vehicle.fuelType,
                              ),
                            ),
                            Expanded(
                              child: _InfoItem(
                                icon: Icons
                                    .settings_outlined,
                                title:
                                'Transmission',
                                value:
                                vehicle.transmission,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ==========================================
                  // PRICING
                  // ==========================================

                  const _SectionTitle(
                    title: 'Rental pricing',
                  ),

                  const SizedBox(height: 14),

                  _PriceOption(
                    title: 'Hourly',
                    price:
                    '₹${vehicle.pricePerHour.toStringAsFixed(0)}',
                    suffix: '/ hour',
                  ),

                  const SizedBox(height: 10),

                  _PriceOption(
                    title: '12 Hours',
                    price:
                    '₹${vehicle.price12Hours.toStringAsFixed(0)}',
                    suffix: '/ 12 hours',
                  ),

                  const SizedBox(height: 10),

                  _PriceOption(
                    title: '24 Hours',
                    price:
                    '₹${vehicle.price24Hours.toStringAsFixed(0)}',
                    suffix: '/ day',
                    highlighted: true,
                  ),

                  const SizedBox(height: 25),

                  // ==========================================
                  // SECURITY DEPOSIT
                  // ==========================================

                  const _SectionTitle(
                    title: 'Security deposit',
                  ),

                  const SizedBox(height: 14),

                  Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets.all(16),
                    decoration:
                    BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(
                        14,
                      ),
                      border: Border.all(
                        color:
                        const Color(
                          0xFFE5E7EB,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons
                              .account_balance_wallet_outlined,
                          color:
                          Color(0xFF1565C0),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            vehicle.securityDeposit >
                                0
                                ? '₹${vehicle.securityDeposit.toStringAsFixed(0)}'
                                : 'No deposit specified',
                            style:
                            const TextStyle(
                              fontWeight:
                              FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ==========================================
                  // IMPORTANT INFORMATION
                  // ==========================================

                  const _SectionTitle(
                    title: 'Important information',
                  ),

                  const SizedBox(height: 14),

                  const _InfoRow(
                    icon:
                    Icons.check_circle_outline,
                    text:
                    'Valid driving licence required',
                  ),

                  const _InfoRow(
                    icon:
                    Icons.check_circle_outline,
                    text:
                    'Vehicle must be returned on time',
                  ),

                  const _InfoRow(
                    icon:
                    Icons.check_circle_outline,
                    text:
                    'Security deposit may apply',
                  ),

                  const _InfoRow(
                    icon:
                    Icons.check_circle_outline,
                    text:
                    'Terms depend on the vehicle owner',
                  ),

                  if (!vehicle.isAvailable)
                    const _InfoRow(
                      icon:
                      Icons.cancel_outlined,
                      text:
                      'This vehicle is currently unavailable',
                    ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ======================================================
      // BOOK NOW
      // ======================================================

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            12,
          ),
          decoration:
          const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 15,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize:
                  MainAxisSize.min,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Starting from',
                      style: TextStyle(
                        color:
                        Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '₹${vehicle.pricePerHour.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed:
                  vehicle.isAvailable
                      ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                            BookingScreen(
                              vehicle:
                              vehicle,
                            ),
                      ),
                    );
                  }
                      : null,
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(
                      0xFF1565C0,
                    ),
                    foregroundColor:
                    Colors.white,
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 28,
                    ),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                  child: Text(
                    vehicle.isAvailable
                        ? 'Book Now'
                        : 'Unavailable',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ============================================================
// VEHICLE REVIEWS SECTION
// ============================================================

class _VehicleReviewsSection
    extends ConsumerWidget {
  final int vehicleId;

  const _VehicleReviewsSection({
    required this.vehicleId,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final reviewsAsync = ref.watch(
      vehicleReviewsProvider(vehicleId),
    );

    return reviewsAsync.when(
      loading: () {
        return Container(
          width: double.infinity,
          padding:
          const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(16),
            border: Border.all(
              color:
              const Color(0xFFE5E7EB),
            ),
          ),
          child: const Center(
            child: SizedBox(
              height: 24,
              width: 24,
              child:
              CircularProgressIndicator(
                strokeWidth: 2.5,
              ),
            ),
          ),
        );
      },

      error: (error, stackTrace) {
        return Container(
          width: double.infinity,
          padding:
          const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(16),
            border: Border.all(
              color:
              const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color:
                Color(0xFF6B7280),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Reviews are currently unavailable.',
                  style: const TextStyle(
                    color:
                    Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  ref.invalidate(
                    vehicleReviewsProvider(
                      vehicleId,
                    ),
                  );
                },
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
              ),
            ],
          ),
        );
      },

      data: (vehicleReviews) {
        return _ReviewsContent(
          vehicleReviews: vehicleReviews,
        );
      },
    );
  }
}


// ============================================================
// REVIEWS CONTENT
// ============================================================

class _ReviewsContent extends StatelessWidget {
  final VehicleReviews vehicleReviews;

  const _ReviewsContent({
    required this.vehicleReviews,
  });

  @override
  Widget build(BuildContext context) {
    final hasReviews =
        vehicleReviews.reviews.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          // ==================================================
          // RATING SUMMARY
          // ==================================================

          Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color:
                  const Color(0xFFFFF7ED),
                  borderRadius:
                  BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Text(
                      vehicleReviews
                          .averageRating
                          .toStringAsFixed(1),
                      style:
                      const TextStyle(
                        fontSize: 21,
                        fontWeight:
                        FontWeight.w800,
                        color:
                        Color(0xFF111827),
                      ),
                    ),
                    const Icon(
                      Icons.star_rounded,
                      size: 19,
                      color:
                      Color(0xFFF59E0B),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer rating',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${vehicleReviews.reviewCount} ${vehicleReviews.reviewCount == 1 ? 'review' : 'reviews'}',
                      style:
                      const TextStyle(
                        color:
                        Color(0xFF6B7280),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (hasReviews) ...[
            const SizedBox(height: 18),
            const Divider(
              height: 1,
              color: Color(0xFFE5E7EB),
            ),
            const SizedBox(height: 6),

            // ================================================
            // REVIEW LIST
            // ================================================

            ...vehicleReviews.reviews
                .map(
                  (review) =>
                  _ReviewTile(
                    review: review,
                  ),
            ),
          ] else ...[
            const SizedBox(height: 18),
            const Divider(
              height: 1,
              color: Color(0xFFE5E7EB),
            ),
            const SizedBox(height: 18),

            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.rate_review_outlined,
                    size: 38,
                    color:
                    Color(0xFF9CA3AF),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No reviews yet',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                      FontWeight.w600,
                      color:
                      Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Be the first to review this vehicle.',
                    textAlign:
                    TextAlign.center,
                    style: TextStyle(
                      color:
                      Color(0xFF6B7280),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}


// ============================================================
// REVIEW TILE
// ============================================================

class _ReviewTile extends StatelessWidget {
  final Review review;

  const _ReviewTile({
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical: 14,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor:
                const Color(0xFFEFF6FF),
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0]
                      .toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color:
                    Color(0xFF1565C0),
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName.isNotEmpty
                          ? review.userName
                          : 'Customer',
                      style:
                      const TextStyle(
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        _StarRow(
                          rating:
                          review.rating,
                          size: 16,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          _formatDate(
                            review.createdAt,
                          ),
                          style:
                          const TextStyle(
                            color:
                            Color(0xFF9CA3AF),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (review.comment != null &&
              review.comment!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment!,
              style: const TextStyle(
                color:
                Color(0xFF4B5563),
                fontSize: 14,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatDate(
      DateTime date,
      ) {
    final localDate = date.toLocal();

    return '${localDate.day.toString().padLeft(2, '0')}/'
        '${localDate.month.toString().padLeft(2, '0')}/'
        '${localDate.year}';
  }
}


// ============================================================
// STAR ROW
// ============================================================

class _StarRow extends StatelessWidget {
  final int rating;
  final double size;

  const _StarRow({
    required this.rating,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
            (index) {
          final starNumber = index + 1;

          return Icon(
            starNumber <= rating
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            size: size,
            color:
            const Color(0xFFF59E0B),
          );
        },
      ),
    );
  }
}


// ============================================================
// SECTION TITLE
// ============================================================

class _SectionTitle
    extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 19,
        fontWeight:
        FontWeight.w800,
        color:
        Color(0xFF111827),
      ),
    );
  }
}


// ============================================================
// INFO ITEM
// ============================================================

class _InfoItem
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Row(
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color:
            const Color(0xFFEFF6FF),
            borderRadius:
            BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color:
            const Color(0xFF1565C0),
            size: 20,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color:
                  Color(0xFF6B7280),
                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                overflow:
                TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight:
                  FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


// ============================================================
// PRICE OPTION
// ============================================================

class _PriceOption
    extends StatelessWidget {
  final String title;
  final String price;
  final String suffix;
  final bool highlighted;

  const _PriceOption({
    required this.title,
    required this.price,
    required this.suffix,
    this.highlighted = false,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: highlighted
            ? const Color(0xFFEFF6FF)
            : Colors.white,
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color: highlighted
              ? const Color(0xFF1565C0)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),

          Text(
            price,
            style: const TextStyle(
              fontSize: 17,
              fontWeight:
              FontWeight.w800,
            ),
          ),

          const SizedBox(width: 4),

          Text(
            suffix,
            style: const TextStyle(
              color:
              Color(0xFF6B7280),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}


// ============================================================
// INFO ROW
// ============================================================

class _InfoRow
    extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 19,
            color:
            const Color(0xFF16A34A),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color:
                Color(0xFF4B5563),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleDetailsFullScreenImage extends StatelessWidget {
  final String imageUrl;
  final String heroTag;
  const _VehicleDetailsFullScreenImage({required this.imageUrl, required this.heroTag});

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
