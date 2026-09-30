import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/owner_vehicle.dart';
import '../providers/owner_vehicle_provider.dart';

class MyVehiclesScreen extends ConsumerStatefulWidget {
  const MyVehiclesScreen({
    super.key,
  });

  @override
  ConsumerState<MyVehiclesScreen> createState() =>
      _MyVehiclesScreenState();
}

class _MyVehiclesScreenState
    extends ConsumerState<MyVehiclesScreen> {
  final Set<int> _availabilityUpdating = {};

  // ==========================================================
  // REFRESH
  // ==========================================================

  Future<void> _refresh() async {
    await ref
        .read(ownerVehiclesProvider.notifier)
        .refreshVehicles();
  }

  // ==========================================================
  // ADD VEHICLE
  // ==========================================================

  void _addVehicle() {
    context.push('/host/vehicles/add');
  }

  // ==========================================================
  // EDIT VEHICLE
  // ==========================================================

  void _editVehicle(
      OwnerVehicle vehicle,
      ) {
    context.push(
      '/host/vehicles/edit/${vehicle.id}',
    );
  }

  // ==========================================================
  // DELETE VEHICLE
  // ==========================================================

  Future<void> _deleteVehicle(
      OwnerVehicle vehicle,
      ) async {
    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Vehicle',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Are you sure you want to delete '
                '${vehicle.fullName}?\n\n'
                'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor:
                const Color(0xFFDC2626),
                foregroundColor:
                Colors.white,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true ||
        !mounted) {
      return;
    }

    try {
      final success =
      await ref
          .read(
        ownerVehiclesProvider
            .notifier,
      )
          .deleteVehicle(
        vehicle.id,
      );

      if (!mounted) {
        return;
      }

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'Vehicle deleted successfully.',
            ),
            behavior:
            SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to delete vehicle.',
            ),
            backgroundColor:
            Color(0xFFDC2626),
            behavior:
            SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showError(error);
    }
  }

  // ==========================================================
  // UPDATE AVAILABILITY
  // ==========================================================

  Future<void> _updateAvailability(
      OwnerVehicle vehicle,
      bool value,
      ) async {
    if (_availabilityUpdating.contains(
      vehicle.id,
    )) {
      return;
    }

    // --------------------------------------------------------
    // Vehicle must be approved before owner can make it live.
    // --------------------------------------------------------

    if (value && !vehicle.isVerified) {
      _showError(
        'Vehicle must be approved by admin before it can be made available.',
      );
      return;
    }

    setState(() {
      _availabilityUpdating.add(
        vehicle.id,
      );
    });

    try {
      await ref
          .read(
        ownerVehiclesProvider
            .notifier,
      )
          .updateAvailability(
        vehicleId: vehicle.id,
        isAvailable: value,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? '${vehicle.fullName} is now available.'
                : '${vehicle.fullName} is now unavailable.',
          ),
          behavior:
          SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showError(error);
    } finally {
      if (mounted) {
        setState(() {
          _availabilityUpdating.remove(
            vehicle.id,
          );
        });
      }
    }
  }

  // ==========================================================
  // ERROR
  // ==========================================================

  void _showError(
      Object error,
      ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          error
              .toString()
              .replaceFirst(
            'Exception: ',
            '',
          ),
        ),
        backgroundColor:
        const Color(0xFFDC2626),
        behavior:
        SnackBarBehavior.floating,
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final vehiclesAsync =
    ref.watch(
      ownerVehiclesProvider,
    );

    return Scaffold(
      backgroundColor:
      const Color(0xFFF8FAFC),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor:
        const Color(0xFFF8FAFC),
        surfaceTintColor:
        Colors.transparent,
        elevation: 0,

        title: const Text(
          'My Vehicles',
          style: TextStyle(
            color:
            Color(0xFF111827),
            fontSize: 22,
            fontWeight:
            FontWeight.w800,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refresh,
            icon: const Icon(
              Icons.refresh_rounded,
              color:
              Color(0xFF111827),
            ),
          ),
        ],
      ),

      // ========================================================
      // ADD VEHICLE
      // ========================================================

      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: _addVehicle,
        backgroundColor:
        const Color(0xFF1565C0),
        foregroundColor:
        Colors.white,
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: const Text(
          'Add Vehicle',
          style: TextStyle(
            fontWeight:
            FontWeight.w700,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: RefreshIndicator(
        onRefresh: _refresh,

        child: vehiclesAsync.when(
          // ====================================================
          // LOADING
          // ====================================================

          loading: () {
            return const Center(
              child:
              CircularProgressIndicator(),
            );
          },

          // ====================================================
          // ERROR
          // ====================================================

          error: (
              error,
              stackTrace,
              ) {
            return _VehicleErrorView(
              error: error,
              onRetry: _refresh,
            );
          },

          // ====================================================
          // DATA
          // ====================================================

          data: (
              vehicles,
              ) {
            if (vehicles.isEmpty) {
              return _EmptyVehiclesView(
                onAddVehicle:
                _addVehicle,
              );
            }

            return ListView.separated(
              physics:
              const AlwaysScrollableScrollPhysics(),

              padding:
              const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                110,
              ),

              itemCount:
              vehicles.length,

              separatorBuilder:
                  (
                  context,
                  index,
                  ) {
                return const SizedBox(
                  height: 14,
                );
              },

              itemBuilder:
                  (
                  context,
                  index,
                  ) {
                final vehicle =
                vehicles[index];

                return _VehicleCard(
                  vehicle: vehicle,
                  isUpdatingAvailability:
                  _availabilityUpdating
                      .contains(
                    vehicle.id,
                  ),
                  onEdit: () {
                    _editVehicle(
                      vehicle,
                    );
                  },
                  onDelete: () {
                    _deleteVehicle(
                      vehicle,
                    );
                  },
                  onAvailabilityChanged:
                      (value) {
                    _updateAvailability(
                      vehicle,
                      value,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// =================================================================
// VEHICLE CARD
// =================================================================

class _VehicleCard
    extends StatelessWidget {
  final OwnerVehicle vehicle;
  final bool isUpdatingAvailability;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool>
  onAvailabilityChanged;

  const _VehicleCard({
    required this.vehicle,
    required this.isUpdatingAvailability,
    required this.onEdit,
    required this.onDelete,
    required this.onAvailabilityChanged,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final approved =
        vehicle.isVerified;

    final available =
        vehicle.isAvailable;

    return Container(
      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color:
          const Color(0xFFE5E7EB),
        ),
        boxShadow: const [
          BoxShadow(
            color:
            Color(0x08000000),
            blurRadius: 12,
            offset:
            Offset(0, 4),
          ),
        ],
      ),

      child: Padding(
        padding:
        const EdgeInsets.all(
          16,
        ),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                // ----------------------------------------------
                // IMAGE
                // ----------------------------------------------

                Container(
                  width: 72,
                  height: 72,
                  decoration:
                  BoxDecoration(
                    color:
                    const Color(
                      0xFFF1F5F9,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      14,
                    ),
                  ),

                  child:
                  vehicle.images.isNotEmpty
                      ? ClipRRect(
                    borderRadius:
                    BorderRadius.circular(
                      14,
                    ),
                    child:
                    Image.network(
                      vehicle
                          .images
                          .first,
                      fit:
                      BoxFit.cover,
                      errorBuilder:
                          (
                          context,
                          error,
                          stackTrace,
                          ) {
                        return const Icon(
                          Icons
                              .directions_car_rounded,
                          size: 34,
                          color:
                          Color(
                            0xFF64748B,
                          ),
                        );
                      },
                    ),
                  )
                      : const Icon(
                    Icons
                        .directions_car_rounded,
                    size: 34,
                    color:
                    Color(
                      0xFF64748B,
                    ),
                  ),
                ),

                const SizedBox(
                  width: 13,
                ),

                // ----------------------------------------------
                // VEHICLE NAME
                // ----------------------------------------------

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.fullName,
                        maxLines: 2,
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

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        vehicle
                            .registrationNumber,
                        style:
                        const TextStyle(
                          fontSize: 12,
                          fontWeight:
                          FontWeight.w600,
                          color:
                          Color(
                            0xFF6B7280,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(
                        '${vehicle.vehicleType} • '
                            '${vehicle.category}',
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style:
                        const TextStyle(
                          fontSize: 11,
                          color:
                          Color(
                            0xFF94A3B8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ----------------------------------------------
                // MENU
                // ----------------------------------------------

                PopupMenuButton<String>(
                  tooltip:
                  'Vehicle actions',

                  onSelected:
                      (value) {
                    if (value ==
                        'edit') {
                      onEdit();
                    }

                    if (value ==
                        'delete') {
                      onDelete();
                    }
                  },

                  itemBuilder:
                      (context) {
                    return const [
                      PopupMenuItem<
                          String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons
                                  .edit_outlined,
                              color:
                              Color(
                                0xFF1565C0,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Edit',
                              style:
                              TextStyle(
                                color:
                                Color(
                                  0xFF1565C0,
                                ),
                                fontWeight:
                                FontWeight
                                    .w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      PopupMenuItem<
                          String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons
                                  .delete_outline_rounded,
                              color:
                              Color(
                                0xFFDC2626,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Delete',
                              style:
                              TextStyle(
                                color:
                                Color(
                                  0xFFDC2626,
                                ),
                                fontWeight:
                                FontWeight
                                    .w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),

            const Divider(
              height: 1,
            ),

            const SizedBox(
              height: 14,
            ),

            // ==================================================
            // LOCATION
            // ==================================================

            Row(
              children: [
                const Icon(
                  Icons
                      .location_on_outlined,
                  size: 18,
                  color:
                  Color(0xFF64748B),
                ),

                const SizedBox(
                  width: 7,
                ),

                Expanded(
                  child: Text(
                    '${vehicle.area}, '
                        '${vehicle.city}',
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style:
                    const TextStyle(
                      fontSize: 13,
                      fontWeight:
                      FontWeight.w600,
                      color:
                      Color(
                        0xFF334155,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 14,
            ),

            // ==================================================
            // VEHICLE FEATURES
            // ==================================================

            Row(
              children: [
                if (vehicle.seats !=
                    null)
                  Expanded(
                    child:
                    _FeatureItem(
                      icon:
                      Icons
                          .event_seat_outlined,
                      text:
                      '${vehicle.seats} seats',
                    ),
                  ),

                if (vehicle.seats !=
                    null)
                  const SizedBox(
                    width: 8,
                  ),

                if (vehicle.fuelType !=
                    null)
                  Expanded(
                    child:
                    _FeatureItem(
                      icon:
                      Icons
                          .local_gas_station_outlined,
                      text:
                      vehicle.fuelType!,
                    ),
                  ),

                if (vehicle.fuelType !=
                    null)
                  const SizedBox(
                    width: 8,
                  ),

                if (vehicle
                    .transmission !=
                    null)
                  Expanded(
                    child:
                    _FeatureItem(
                      icon:
                      Icons
                          .settings_outlined,
                      text:
                      vehicle
                          .transmission!,
                    ),
                  ),
              ],
            ),

            const SizedBox(
              height: 14,
            ),

            // ==================================================
            // PRICING
            // ==================================================

            Container(
              width:
              double.infinity,
              padding:
              const EdgeInsets.all(
                13,
              ),
              decoration:
              BoxDecoration(
                color:
                const Color(
                  0xFFF8FAFC,
                ),
                borderRadius:
                BorderRadius.circular(
                  12,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child:
                    _PriceItem(
                      title: 'Hourly',
                      value:
                      '₹${vehicle.hourlyPrice.toStringAsFixed(0)}',
                    ),
                  ),

                  Expanded(
                    child:
                    _PriceItem(
                      title: '12 Hours',
                      value:
                      vehicle
                          .twelveHourPrice !=
                          null
                          ? '₹${vehicle.twelveHourPrice!.toStringAsFixed(0)}'
                          : 'N/A',
                    ),
                  ),

                  Expanded(
                    child:
                    _PriceItem(
                      title: 'Daily',
                      value:
                      '₹${vehicle.dailyPrice.toStringAsFixed(0)}',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            // ==================================================
            // SECURITY DEPOSIT
            // ==================================================

            Row(
              children: [
                const Icon(
                  Icons
                      .account_balance_wallet_outlined,
                  size: 17,
                  color:
                  Color(0xFF64748B),
                ),

                const SizedBox(
                  width: 7,
                ),

                const Text(
                  'Security Deposit',
                  style:
                  TextStyle(
                    fontSize: 12,
                    color:
                    Color(
                      0xFF64748B,
                    ),
                    fontWeight:
                    FontWeight.w500,
                  ),
                ),

                const Spacer(),

                Text(
                  '₹${vehicle.securityDeposit.toStringAsFixed(0)}',
                  style:
                  const TextStyle(
                    fontSize: 13,
                    fontWeight:
                    FontWeight.w700,
                    color:
                    Color(
                      0xFF111827,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 14,
            ),

            // ==================================================
            // VERIFICATION + AVAILABILITY
            // ==================================================

            Container(
              width:
              double.infinity,
              padding:
              const EdgeInsets
                  .symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration:
              BoxDecoration(
                color: approved
                    ? const Color(
                  0xFFF0FDF4,
                )
                    : const Color(
                  0xFFFFF7ED,
                ),
                borderRadius:
                BorderRadius.circular(
                  12,
                ),
              ),

              child: Row(
                children: [
                  // --------------------------------------------
                  // VERIFICATION
                  // --------------------------------------------

                  Icon(
                    approved
                        ? Icons
                        .verified_rounded
                        : Icons
                        .pending_outlined,
                    size: 19,
                    color: approved
                        ? const Color(
                      0xFF15803D,
                    )
                        : const Color(
                      0xFFC2410C,
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Text(
                          vehicle
                              .verificationStatus,
                          style:
                          TextStyle(
                            fontSize: 12,
                            fontWeight:
                            FontWeight
                                .w700,
                            color: approved
                                ? const Color(
                              0xFF15803D,
                            )
                                : const Color(
                              0xFFC2410C,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 2,
                        ),

                        Text(
                          approved
                              ? 'Vehicle can be listed to customers.'
                              : 'Admin approval is required.',
                          maxLines: 2,
                          overflow:
                          TextOverflow
                              .ellipsis,
                          style:
                          const TextStyle(
                            fontSize: 10,
                            color:
                            Color(
                              0xFF64748B,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  // --------------------------------------------
                  // AVAILABILITY SWITCH
                  // --------------------------------------------

                  Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Available',
                        style:
                        TextStyle(
                          fontSize: 10,
                          fontWeight:
                          FontWeight.w700,
                          color:
                          Color(
                            0xFF475569,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 2,
                      ),

                      if (isUpdatingAvailability)
                        const SizedBox(
                          width: 42,
                          height: 24,
                          child:
                          Center(
                            child:
                            SizedBox(
                              width: 18,
                              height: 18,
                              child:
                              CircularProgressIndicator(
                                strokeWidth:
                                2,
                              ),
                            ),
                          ),
                        )
                      else
                        Switch(
                          value:
                          available,
                          onChanged:
                          approved
                              ? onAvailabilityChanged
                              : null,
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            // ==================================================
            // CURRENT AVAILABILITY STATUS
            // ==================================================

            Row(
              mainAxisAlignment:
              MainAxisAlignment.end,
              children: [
                Icon(
                  available
                      ? Icons
                      .check_circle_outline_rounded
                      : Icons
                      .remove_circle_outline_rounded,
                  size: 15,
                  color: available
                      ? const Color(
                    0xFF15803D,
                  )
                      : const Color(
                    0xFF64748B,
                  ),
                ),

                const SizedBox(
                  width: 5,
                ),

                Text(
                  available
                      ? 'Currently available for booking'
                      : 'Currently not available for booking',
                  style:
                  TextStyle(
                    fontSize: 10,
                    fontWeight:
                    FontWeight.w600,
                    color: available
                        ? const Color(
                      0xFF15803D,
                    )
                        : const Color(
                      0xFF64748B,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// FEATURE ITEM
// =================================================================

class _FeatureItem
    extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 9,
      ),
      decoration:
      BoxDecoration(
        color:
        const Color(0xFFF8FAFC),
        borderRadius:
        BorderRadius.circular(
          10,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color:
            const Color(
              0xFF64748B,
            ),
          ),

          const SizedBox(
            width: 5,
          ),

          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style:
              const TextStyle(
                fontSize: 10,
                fontWeight:
                FontWeight.w600,
                color:
                Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// PRICE ITEM
// =================================================================

class _PriceItem
    extends StatelessWidget {
  final String title;
  final String value;

  const _PriceItem({
    required this.title,
    required this.value,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
          const TextStyle(
            fontSize: 10,
            color:
            Color(0xFF64748B),
            fontWeight:
            FontWeight.w500,
          ),
        ),

        const SizedBox(
          height: 4,
        ),

        Text(
          value,
          style:
          const TextStyle(
            fontSize: 15,
            fontWeight:
            FontWeight.w800,
            color:
            Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}

// =================================================================
// EMPTY VEHICLES
// =================================================================

class _EmptyVehiclesView
    extends StatelessWidget {
  final VoidCallback onAddVehicle;

  const _EmptyVehiclesView({
    required this.onAddVehicle,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return ListView(
      physics:
      const AlwaysScrollableScrollPhysics(),
      padding:
      const EdgeInsets.all(24),
      children: [
        const SizedBox(
          height: 90,
        ),

        Container(
          height: 90,
          width: 90,
          decoration:
          const BoxDecoration(
            color:
            Color(0xFFEFF6FF),
            shape:
            BoxShape.circle,
          ),
          child: const Icon(
            Icons
                .directions_car_outlined,
            size: 46,
            color:
            Color(0xFF1565C0),
          ),
        ),

        const SizedBox(
          height: 22,
        ),

        const Center(
          child: Text(
            'No vehicles added yet',
            textAlign:
            TextAlign.center,
            style:
            TextStyle(
              fontSize: 21,
              fontWeight:
              FontWeight.w800,
              color:
              Color(0xFF111827),
            ),
          ),
        ),

        const SizedBox(
          height: 9,
        ),

        const Center(
          child: Text(
            'Add your first vehicle and '
                'start earning with RentKaro.',
            textAlign:
            TextAlign.center,
            style:
            TextStyle(
              fontSize: 13,
              height: 1.5,
              color:
              Color(0xFF64748B),
            ),
          ),
        ),

        const SizedBox(
          height: 26,
        ),

        Center(
          child:
          FilledButton.icon(
            onPressed:
            onAddVehicle,
            icon: const Icon(
              Icons.add_rounded,
            ),
            label: const Text(
              'Add Vehicle',
            ),
          ),
        ),
      ],
    );
  }
}

// =================================================================
// ERROR VIEW
// =================================================================

class _VehicleErrorView
    extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _VehicleErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final message = error
        .toString()
        .replaceFirst(
      'Exception: ',
      '',
    );

    return ListView(
      physics:
      const AlwaysScrollableScrollPhysics(),
      padding:
      const EdgeInsets.all(24),
      children: [
        const SizedBox(
          height: 100,
        ),

        Container(
          height: 72,
          width: 72,
          decoration:
          const BoxDecoration(
            color:
            Color(0xFFFEE2E2),
            shape:
            BoxShape.circle,
          ),
          child: const Icon(
            Icons
                .error_outline_rounded,
            size: 38,
            color:
            Color(0xFFDC2626),
          ),
        ),

        const SizedBox(
          height: 18,
        ),

        const Center(
          child: Text(
            'Unable to load vehicles',
            textAlign:
            TextAlign.center,
            style:
            TextStyle(
              fontSize: 19,
              fontWeight:
              FontWeight.w800,
              color:
              Color(0xFF111827),
            ),
          ),
        ),

        const SizedBox(
          height: 9,
        ),

        Center(
          child: Text(
            message,
            textAlign:
            TextAlign.center,
            style:
            const TextStyle(
              fontSize: 13,
              height: 1.5,
              color:
              Color(0xFF64748B),
            ),
          ),
        ),

        const SizedBox(
          height: 22,
        ),

        Center(
          child:
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            label:
            const Text(
              'Retry',
            ),
          ),
        ),
      ],
    );
  }
}