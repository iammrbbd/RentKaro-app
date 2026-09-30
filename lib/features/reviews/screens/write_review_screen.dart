import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/review_provider.dart';

class WriteReviewScreen extends ConsumerStatefulWidget {
  final int bookingId;
  final int vehicleId;
  final String vehicleName;

  const WriteReviewScreen({
    super.key,
    required this.bookingId,
    required this.vehicleId,
    required this.vehicleName,
  });

  @override
  ConsumerState<WriteReviewScreen> createState() =>
      _WriteReviewScreenState();
}

class _WriteReviewScreenState
    extends ConsumerState<WriteReviewScreen> {
  final TextEditingController _commentController =
  TextEditingController();

  int _rating = 5;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // ==========================================================
  // SUBMIT REVIEW
  // ==========================================================

  Future<void> _submitReview() async {
    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final review = await ref
          .read(reviewProvider.notifier)
          .createReview(
        bookingId: widget.bookingId,
        rating: _rating,
        comment: _commentController.text,
      );

      if (!mounted) {
        return;
      }

      if (review != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Review submitted successfully.',
            ),
          ),
        );

        Navigator.of(context).pop(true);
      } else {
        final error =
            ref.read(reviewProvider).error;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error?.toString() ??
                  'Unable to submit review.',
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error
                .toString()
                .replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // ==========================================================
  // STAR
  // ==========================================================

  Widget _buildStar(int index) {
    final selected = index <= _rating;

    return IconButton(
      onPressed: _isSubmitting
          ? null
          : () {
        setState(() {
          _rating = index;
        });
      },
      icon: Icon(
        selected
            ? Icons.star_rounded
            : Icons.star_border_rounded,
        size: 42,
      ),
    );
  }

  // ==========================================================
  // UI
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Write a Review',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // ==================================================
              // VEHICLE
              // ==================================================

              Text(
                widget.vehicleName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'How was your rental experience?',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 28),

              // ==================================================
              // RATING
              // ==================================================

              const Center(
                child: Text(
                  'Rate your experience',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  for (int i = 1; i <= 5; i++)
                    _buildStar(i),
                ],
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  _rating == 1
                      ? 'Poor'
                      : _rating == 2
                      ? 'Below Average'
                      : _rating == 3
                      ? 'Average'
                      : _rating == 4
                      ? 'Good'
                      : 'Excellent',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // ==================================================
              // COMMENT
              // ==================================================

              const Text(
                'Your Review',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: _commentController,
                enabled: !_isSubmitting,
                maxLines: 6,
                maxLength: 1000,
                textCapitalization:
                TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText:
                  'Tell us about your experience...',
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                      width: 2,
                    ),
                  ),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // SUBMIT
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed:
                  _isSubmitting
                      ? null
                      : _submitReview,
                  child: _isSubmitting
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2.5,
                    ),
                  )
                      : const Text(
                    'Submit Review',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}