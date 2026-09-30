import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/review.dart';
import '../services/review_service.dart';

// ==========================================================
// REVIEW SERVICE PROVIDER
// ==========================================================

final reviewServiceProvider = Provider<ReviewService>((ref) {
  return ReviewService();
});

// ==========================================================
// SECURE STORAGE PROVIDER
// ==========================================================

final reviewStorageProvider =
Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

// ==========================================================
// VEHICLE REVIEWS PROVIDER
// ==========================================================

final vehicleReviewsProvider = FutureProvider.family<
    VehicleReviews,
    int>((ref, vehicleId) async {
  final service = ref.read(reviewServiceProvider);

  return service.getVehicleReviews(vehicleId);
});

// ==========================================================
// MY REVIEWS PROVIDER
// ==========================================================

final myReviewsProvider =
FutureProvider<List<Review>>((ref) async {
  final service = ref.read(reviewServiceProvider);
  final storage = ref.read(reviewStorageProvider);

  final token = await storage.read(
    key: 'access_token',
  );

  if (token == null || token.isEmpty) {
    throw Exception(
      'Authentication token not found.',
    );
  }

  return service.getMyReviews(
    token: token,
  );
});

// ==========================================================
// REVIEW STATE
// ==========================================================

class ReviewState {
  final bool isSubmitting;
  final Review? submittedReview;
  final String? error;

  const ReviewState({
    this.isSubmitting = false,
    this.submittedReview,
    this.error,
  });

  ReviewState copyWith({
    bool? isSubmitting,
    Review? submittedReview,
    String? error,
    bool clearError = false,
    bool clearSubmittedReview = false,
  }) {
    return ReviewState(
      isSubmitting:
      isSubmitting ?? this.isSubmitting,
      submittedReview: clearSubmittedReview
          ? null
          : submittedReview ?? this.submittedReview,
      error: clearError
          ? null
          : error ?? this.error,
    );
  }
}

// ==========================================================
// REVIEW NOTIFIER
// ==========================================================

final reviewProvider =
NotifierProvider<ReviewNotifier, ReviewState>(
  ReviewNotifier.new,
);

class ReviewNotifier
    extends Notifier<ReviewState> {
  late final ReviewService _service;
  late final FlutterSecureStorage _storage;

  @override
  ReviewState build() {
    _service = ref.read(
      reviewServiceProvider,
    );

    _storage = ref.read(
      reviewStorageProvider,
    );

    return const ReviewState();
  }

  // ========================================================
  // CREATE REVIEW
  // ========================================================

  Future<Review?> createReview({
    required int bookingId,
    required int rating,
    String? comment,
  }) async {
    if (state.isSubmitting) {
      return null;
    }

    // ------------------------------------------------------
    // LOCAL VALIDATION
    // ------------------------------------------------------

    if (rating < 1 || rating > 5) {
      state = const ReviewState(
        error: 'Rating must be between 1 and 5.',
      );

      return null;
    }

    final token = await _storage.read(
      key: 'access_token',
    );

    if (token == null || token.isEmpty) {
      state = const ReviewState(
        error:
        'Authentication token not found.',
      );

      return null;
    }

    // ------------------------------------------------------
    // START SUBMISSION
    // ------------------------------------------------------

    state = const ReviewState(
      isSubmitting: true,
    );

    try {
      final review = await _service.createReview(
        token: token,
        bookingId: bookingId,
        rating: rating,
        comment: comment,
      );

      // ----------------------------------------------------
      // SUCCESS
      // ----------------------------------------------------

      state = ReviewState(
        submittedReview: review,
      );

      // ----------------------------------------------------
      // REFRESH MY REVIEWS
      // ----------------------------------------------------

      ref.invalidate(
        myReviewsProvider,
      );

      return review;
    } catch (error) {
      final message = error
          .toString()
          .replaceFirst(
        'Exception: ',
        '',
      );

      state = ReviewState(
        error: message,
      );

      return null;
    }
  }

  // ========================================================
  // CLEAR STATE
  // ========================================================

  void clearState() {
    state = const ReviewState();
  }

  // ========================================================
  // REFRESH VEHICLE REVIEWS
  // ========================================================

  void refreshVehicleReviews(
      int vehicleId,
      ) {
    ref.invalidate(
      vehicleReviewsProvider(vehicleId),
    );
  }
}