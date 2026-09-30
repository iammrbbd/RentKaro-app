import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/host_earnings.dart';
import '../providers/host_earnings_provider.dart';

class HostEarningsScreen extends ConsumerWidget {
  const HostEarningsScreen({
    super.key,
  });

  String _money(double value) {
    return '₹${value.toStringAsFixed(0)}';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }

  Future<void> _refresh(
      WidgetRef ref,
      ) async {
    ref.invalidate(hostEarningsProvider);
    await ref.read(hostEarningsProvider.future);
  }

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final earningsAsync =
    ref.watch(hostEarningsProvider);

    return Scaffold(
      backgroundColor:
      const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Earnings',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              _refresh(ref);
            },
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: earningsAsync.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return _ErrorView(
            error: error.toString(),
            onRetry: () {
              ref.invalidate(
                hostEarningsProvider,
              );
            },
          );
        },
        data: (earnings) {
          return RefreshIndicator(
            onRefresh: () {
              return _refresh(ref);
            },
            child: ListView(
              padding:
              const EdgeInsets.all(16),
              children: [
                _MainBalanceCard(
                  earnings: earnings,
                  money: _money,
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon:
                        Icons.trending_up,
                        title:
                        'This Month',
                        value:
                        _money(
                          earnings.thisMonth,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon:
                        Icons.check_circle_outline,
                        title:
                        'Completed Trips',
                        value:
                        earnings
                            .completedTrips
                            .toString(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _StatCard(
                  icon:
                  Icons.account_balance_wallet_outlined,
                  title:
                  'Available Balance',
                  value:
                  _money(
                    earnings.availableBalance,
                  ),
                  fullWidth: true,
                ),

                const SizedBox(height: 28),

                const Text(
                  'Earning History',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 12),

                if (earnings.bookings.isEmpty)
                  _EmptyEarnings()
                else
                  ...earnings.bookings.map(
                        (booking) {
                      return Padding(
                        padding:
                        const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child:
                        _EarningCard(
                          booking: booking,
                          money: _money,
                          formatDate:
                          _formatDate,
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}


class _MainBalanceCard
    extends StatelessWidget {
  final HostEarnings earnings;
  final String Function(double) money;

  const _MainBalanceCard({
    required this.earnings,
    required this.money,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF111827),
            Color(0xFF374151),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Earned',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            money(
              earnings.totalEarned,
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight:
              FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 7),
              Text(
                '${earnings.completedTrips} completed trips',
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class _StatCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool fullWidth;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color:
              Colors.grey.shade100,
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 23,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _EarningCard
    extends StatelessWidget {
  final HostEarningTransaction booking;
  final String Function(double) money;
  final String Function(DateTime) formatDate;

  const _EarningCard({
    required this.booking,
    required this.money,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color:
              Colors.grey.shade100,
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_car_outlined,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  booking.vehicleName,
                  style: const TextStyle(
                    fontWeight:
                    FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  booking.bookingReference,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatDate(
                    booking.completedAt,
                  ),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '+${money(booking.earnedAmount)}',
            style: const TextStyle(
              fontWeight:
              FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}


class _EmptyEarnings
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        vertical: 40,
        horizontal: 20,
      ),
      child: const Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 52,
            color: Colors.grey,
          ),
          SizedBox(height: 12),
          Text(
            'No earnings yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight:
              FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Completed rentals will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}


class _ErrorView
    extends StatelessWidget {
  final String error;
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
        const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 50,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load earnings',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.replaceFirst(
                'Exception: ',
                '',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text(
                'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }
}