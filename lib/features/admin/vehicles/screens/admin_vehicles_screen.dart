import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/admin_vehicle_model.dart';
import '../services/admin_vehicle_service.dart';

// ============================================================
// PROVIDERS
// ============================================================

final adminVehicleServiceProvider =
Provider<AdminVehicleService>((ref) {
  return AdminVehicleService();
});

// ============================================================
// ALL VEHICLES
// ============================================================

final adminVehiclesProvider =
FutureProvider<List<AdminVehicle>>((ref) async {
  final service =
  ref.read(adminVehicleServiceProvider);

  return service.getVehicles();
});

// ============================================================
// SCREEN
// ============================================================

class AdminVehiclesScreen
    extends ConsumerWidget {
  const AdminVehiclesScreen({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final vehiclesAsync =
    ref.watch(adminVehiclesProvider);

    return Scaffold(
      backgroundColor:
      const Color(0xFFF7F8FA),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor:
        const Color(0xFF111827),
        elevation: 0,

        title: const Text(
          'Vehicles',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),

        centerTitle: true,

        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              ref.invalidate(
                adminVehiclesProvider,
              );
            },
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),

          const SizedBox(width: 4),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(
            adminVehiclesProvider,
          );

          await ref.read(
            adminVehiclesProvider.future,
          );
        },

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
            return ListView(
              physics:
              const AlwaysScrollableScrollPhysics(),

              children: [
                SizedBox(
                  height:
                  MediaQuery.of(context)
                      .size
                      .height *
                      0.28,
                ),

                const Icon(
                  Icons.cloud_off_rounded,
                  size: 64,
                  color:
                  Color(0xFF9CA3AF),
                ),

                const SizedBox(
                  height: 16,
                ),

                const Center(
                  child: Text(
                    'Unable to load vehicles',

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Padding(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 28,
                  ),

                  child: Text(
                    error
                        .toString()
                        .replaceFirst(
                      'Exception: ',
                      '',
                    ),

                    textAlign:
                    TextAlign.center,

                    style:
                    const TextStyle(
                      color:
                      Color(0xFF6B7280),
                      fontSize: 12,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                Center(
                  child:
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.invalidate(
                        adminVehiclesProvider,
                      );
                    },

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
          },

          // ====================================================
          // DATA
          // ====================================================

          data: (vehicles) {

            if (vehicles.isEmpty) {
              return ListView(
                physics:
                const AlwaysScrollableScrollPhysics(),

                children: [
                  SizedBox(
                    height:
                    MediaQuery.of(context)
                        .size
                        .height *
                        0.28,
                  ),

                  const Icon(
                    Icons.directions_car_outlined,
                    size: 64,
                    color:
                    Color(0xFF9CA3AF),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  const Center(
                    child: Text(
                      'No vehicles found',

                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  const Center(
                    child: Text(
                      'There are no vehicles in the database.',

                      textAlign:
                      TextAlign.center,

                      style: TextStyle(
                        color:
                        Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              );
            }

            // ==================================================
            // VEHICLES LIST
            // ==================================================

            return ListView.builder(
              physics:
              const AlwaysScrollableScrollPhysics(),

              padding:
              const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                30,
              ),

              itemCount:
              vehicles.length + 1,

              itemBuilder:
                  (context, index) {

                // ==============================================
                // HEADER
                // ==============================================

                if (index == 0) {
                  final approvedCount =
                      vehicles
                          .where(
                            (vehicle) =>
                        vehicle.isVerified,
                      )
                          .length;

                  final pendingCount =
                      vehicles
                          .where(
                            (vehicle) =>
                        !vehicle.isVerified,
                      )
                          .length;

                  return Padding(
                    padding:
                    const EdgeInsets.only(
                      bottom: 16,
                    ),

                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [

                        Row(
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                                children: [
                                  Text(
                                    'All Vehicles',

                                    style:
                                    TextStyle(
                                      color:
                                      Color(
                                        0xFF111827,
                                      ),
                                      fontSize:
                                      18,
                                      fontWeight:
                                      FontWeight
                                          .w800,
                                    ),
                                  ),

                                  SizedBox(
                                    height: 4,
                                  ),

                                  Text(
                                    'Manage and review all vehicles',

                                    style:
                                    TextStyle(
                                      color:
                                      Color(
                                        0xFF6B7280,
                                      ),
                                      fontSize:
                                      12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              padding:
                              const EdgeInsets
                                  .symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),

                              decoration:
                              BoxDecoration(
                                color:
                                const Color(
                                  0xFFEFF6FF,
                                ),

                                borderRadius:
                                BorderRadius
                                    .circular(
                                  20,
                                ),
                              ),

                              child: Text(
                                '${vehicles.length}',

                                style:
                                const TextStyle(
                                  color:
                                  Color(
                                    0xFF2563EB,
                                  ),
                                  fontSize:
                                  13,
                                  fontWeight:
                                  FontWeight
                                      .w800,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        Row(
                          children: [

                            Expanded(
                              child:
                              _SummaryChip(
                                icon:
                                Icons
                                    .directions_car_rounded,

                                label:
                                'Total',

                                value:
                                vehicles
                                    .length
                                    .toString(),

                                iconColor:
                                const Color(
                                  0xFF2563EB,
                                ),

                                backgroundColor:
                                const Color(
                                  0xFFEFF6FF,
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Expanded(
                              child:
                              _SummaryChip(
                                icon:
                                Icons
                                    .verified_rounded,

                                label:
                                'Approved',

                                value:
                                approvedCount
                                    .toString(),

                                iconColor:
                                const Color(
                                  0xFF16A34A,
                                ),

                                backgroundColor:
                                const Color(
                                  0xFFECFDF5,
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Expanded(
                              child:
                              _SummaryChip(
                                icon:
                                Icons
                                    .pending_outlined,

                                label:
                                'Pending',

                                value:
                                pendingCount
                                    .toString(),

                                iconColor:
                                const Color(
                                  0xFFD97706,
                                ),

                                backgroundColor:
                                const Color(
                                  0xFFFFF7ED,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }

                // ==============================================
                // VEHICLE
                // ==============================================

                final vehicle =
                vehicles[index - 1];

                return _VehicleCard(
                  vehicle: vehicle,

                  onTap: () {
                    _showVehicleDetails(
                      context,
                      ref,
                      vehicle,
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

  // ============================================================
  // VEHICLE DETAILS
  // ============================================================

  static void _showVehicleDetails(
      BuildContext context,
      WidgetRef ref,
      AdminVehicle vehicle,
      ) {
    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor:
      Colors.transparent,

      builder: (sheetContext) {
        return _VehicleDetailsSheet(
          vehicle: vehicle,
          ref: ref,
        );
      },
    );
  }
}

// ============================================================================
// VEHICLE CARD
// ============================================================================

class _VehicleCard
    extends StatelessWidget {

  final AdminVehicle vehicle;

  final VoidCallback onTap;

  const _VehicleCard({
    required this.vehicle,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final bool approved =
        vehicle.isVerified;

    final String imageUrl =
    vehicle.images.isNotEmpty
        ? vehicle.images.first
        : '';

    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 12,
      ),

      child: Material(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(18),

        child: InkWell(
          onTap: onTap,

          borderRadius:
          BorderRadius.circular(18),

          child: Container(
            padding:
            const EdgeInsets.all(13),

            decoration:
            BoxDecoration(
              color: Colors.white,

              borderRadius:
              BorderRadius.circular(18),

              border: Border.all(
                color:
                const Color(
                  0xFFE5E7EB,
                ),
              ),
            ),

            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                // ==================================================
                // IMAGE
                // ==================================================

                ClipRRect(
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),

                  child: Container(
                    width: 88,
                    height: 88,

                    color:
                    const Color(
                      0xFFF3F4F6,
                    ),

                    child:
                    imageUrl.isNotEmpty
                        ? Image.network(
                      imageUrl,

                      fit: BoxFit.cover,

                      errorBuilder:
                          (
                          context,
                          error,
                          stackTrace,
                          ) {
                        return const Icon(
                          Icons
                              .directions_car_rounded,
                          size: 38,
                          color:
                          Color(
                            0xFF9CA3AF,
                          ),
                        );
                      },
                    )
                        : const Icon(
                      Icons
                          .directions_car_rounded,
                      size: 38,
                      color:
                      Color(
                        0xFF9CA3AF,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  width: 13,
                ),

                // ==================================================
                // INFO
                // ==================================================

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          Expanded(
                            child: Text(
                              vehicle.fullName,

                              maxLines: 1,

                              overflow:
                              TextOverflow
                                  .ellipsis,

                              style:
                              const TextStyle(
                                color:
                                Color(
                                  0xFF111827,
                                ),

                                fontSize:
                                15,

                                fontWeight:
                                FontWeight
                                    .w800,
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 7,
                          ),

                          _StatusBadge(
                            approved:
                            approved,
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        vehicle.registrationNumber,

                        style:
                        const TextStyle(
                          color:
                          Color(
                            0xFF6B7280,
                          ),

                          fontSize:
                          11,

                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Row(
                        children: [

                          const Icon(
                            Icons
                                .location_on_outlined,

                            size: 14,

                            color:
                            Color(
                              0xFF6B7280,
                            ),
                          ),

                          const SizedBox(
                            width: 3,
                          ),

                          Expanded(
                            child: Text(
                              '${vehicle.area}, ${vehicle.city}',

                              maxLines: 1,

                              overflow:
                              TextOverflow
                                  .ellipsis,

                              style:
                              const TextStyle(
                                color:
                                Color(
                                  0xFF6B7280,
                                ),

                                fontSize:
                                10,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 7,
                      ),

                      Row(
                        children: [

                          _MiniInfo(
                            icon:
                            Icons
                                .schedule_outlined,

                            text:
                            '₹${_formatPrice(vehicle.hourlyPrice)}/hr',
                          ),

                          const SizedBox(
                            width: 9,
                          ),

                          if (vehicle.seats !=
                              null)
                            _MiniInfo(
                              icon:
                              Icons
                                  .event_seat_outlined,

                              text:
                              '${vehicle.seats} seats',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  width: 4,
                ),

                const Padding(
                  padding:
                  EdgeInsets.only(
                    top: 35,
                  ),

                  child: Icon(
                    Icons
                        .arrow_forward_ios_rounded,

                    size: 13,

                    color:
                    Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatPrice(
      double value,
      ) {
    if (value ==
        value.roundToDouble()) {
      return value
          .toInt()
          .toString();
    }

    return value.toStringAsFixed(2);
  }
}

// ============================================================================
// STATUS BADGE
// ============================================================================

class _StatusBadge
    extends StatelessWidget {

  final bool approved;

  const _StatusBadge({
    required this.approved,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),

      decoration:
      BoxDecoration(
        color: approved
            ? const Color(
          0xFFECFDF5,
        )
            : const Color(
          0xFFFFF7ED,
        ),

        borderRadius:
        BorderRadius.circular(
          20,
        ),
      ),

      child: Text(
        approved
            ? 'Approved'
            : 'Pending',

        style:
        TextStyle(
          color: approved
              ? const Color(
            0xFF16A34A,
          )
              : const Color(
            0xFFD97706,
          ),

          fontSize: 9,

          fontWeight:
          FontWeight.w800,
        ),
      ),
    );
  }
}

// ============================================================================
// MINI INFO
// ============================================================================

class _MiniInfo
    extends StatelessWidget {

  final IconData icon;
  final String text;

  const _MiniInfo({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Row(
      mainAxisSize:
      MainAxisSize.min,

      children: [
        Icon(
          icon,
          size: 13,
          color:
          const Color(
            0xFF6B7280,
          ),
        ),

        const SizedBox(
          width: 3,
        ),

        Text(
          text,

          style:
          const TextStyle(
            color:
            Color(0xFF374151),
            fontSize: 10,
            fontWeight:
            FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// SUMMARY CHIP
// ============================================================================

class _SummaryChip
    extends StatelessWidget {

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color backgroundColor;

  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.backgroundColor,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      const EdgeInsets.all(10),

      decoration:
      BoxDecoration(
        color:
        backgroundColor,

        borderRadius:
        BorderRadius.circular(
          13,
        ),
      ),

      child: Row(
        children: [

          Icon(
            icon,
            size: 18,
            color:
            iconColor,
          ),

          const SizedBox(
            width: 6,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  label,

                  style:
                  const TextStyle(
                    color:
                    Color(
                      0xFF6B7280,
                    ),

                    fontSize: 9,
                  ),
                ),

                const SizedBox(
                  height: 2,
                ),

                Text(
                  value,

                  style:
                  const TextStyle(
                    color:
                    Color(
                      0xFF111827,
                    ),

                    fontSize: 13,

                    fontWeight:
                    FontWeight.w800,
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

// ============================================================================
// VEHICLE DETAILS SHEET
// ============================================================================

class _VehicleDetailsSheet
    extends StatefulWidget {

  final AdminVehicle vehicle;
  final WidgetRef ref;

  const _VehicleDetailsSheet({
    required this.vehicle,
    required this.ref,
  });

  @override
  State<_VehicleDetailsSheet>
  createState() =>
      _VehicleDetailsSheetState();
}

class _VehicleDetailsSheetState
    extends State<_VehicleDetailsSheet> {

  bool _processing = false;

  // ============================================================
  // APPROVE
  // ============================================================

  Future<void> _approve() async {
    final confirmed =
    await showDialog<bool>(
      context: context,

      builder:
          (dialogContext) {
        return AlertDialog(
          title:
          const Text(
            'Approve Vehicle',
          ),

          content: Text(
            'Are you sure you want to approve '
                '${widget.vehicle.fullName}?',
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },

              child:
              const Text(
                'Cancel',
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },

              child:
              const Text(
                'Approve',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _processing = true;
    });

    try {
      final service =
      widget.ref.read(
        adminVehicleServiceProvider,
      );

      await service.approveVehicle(
        widget.vehicle.id,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context);

      widget.ref.invalidate(
        adminVehiclesProvider,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Vehicle approved successfully',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

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
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _processing = false;
        });
      }
    }
  }

  // ============================================================
  // REJECT
  // ============================================================

  Future<void> _reject() async {
    final controller =
    TextEditingController();

    final reason =
    await showDialog<String>(
      context: context,

      builder:
          (dialogContext) {
        return AlertDialog(
          title:
          const Text(
            'Reject Vehicle',
          ),

          content:
          TextField(
            controller:
            controller,

            maxLines: 4,

            decoration:
            const InputDecoration(
              labelText:
              'Rejection reason',

              hintText:
              'Enter rejection reason',

              border:
              OutlineInputBorder(),
            ),
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },

              child:
              const Text(
                'Cancel',
              ),
            ),

            ElevatedButton(
              onPressed: () {
                final value =
                controller.text.trim();

                if (value.isEmpty) {
                  ScaffoldMessenger.of(
                    dialogContext,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter a rejection reason',
                      ),
                    ),
                  );

                  return;
                }

                Navigator.pop(
                  dialogContext,
                  value,
                );
              },

              child:
              const Text(
                'Reject',
              ),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (reason == null ||
        reason.trim().isEmpty) {
      return;
    }

    setState(() {
      _processing = true;
    });

    try {
      final service =
      widget.ref.read(
        adminVehicleServiceProvider,
      );

      await service.rejectVehicle(
        widget.vehicle.id,
        reason: reason,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context);

      widget.ref.invalidate(
        adminVehiclesProvider,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Vehicle rejected successfully',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

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
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _processing = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final vehicle =
        widget.vehicle;

    return SafeArea(
      child: Container(
        constraints:
        BoxConstraints(
          maxHeight:
          MediaQuery.of(context)
              .size
              .height *
              0.92,
        ),

        padding:
        const EdgeInsets.fromLTRB(
          18,
          10,
          18,
          20,
        ),

        decoration:
        const BoxDecoration(
          color: Colors.white,

          borderRadius:
          BorderRadius.vertical(
            top:
            Radius.circular(
              26,
            ),
          ),
        ),

        child: Column(
          children: [

            // ==================================================
            // HANDLE
            // ==================================================

            Container(
              width: 42,
              height: 4,

              decoration:
              BoxDecoration(
                color:
                const Color(
                  0xFFD1D5DB,
                ),

                borderRadius:
                BorderRadius.circular(
                  10,
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            // ==================================================
            // HEADER
            // ==================================================

            Row(
              children: [

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                    children: [

                      Text(
                        vehicle.fullName,

                        style:
                        const TextStyle(
                          color:
                          Color(
                            0xFF111827,
                          ),

                          fontSize: 20,

                          fontWeight:
                          FontWeight
                              .w800,
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(
                        vehicle
                            .registrationNumber,

                        style:
                        const TextStyle(
                          color:
                          Color(
                            0xFF6B7280,
                          ),

                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                _StatusBadge(
                  approved:
                  vehicle.isVerified,
                ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),

            // ==================================================
            // CONTENT
            // ==================================================

            Expanded(
              child:
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [

                    // ==========================================
                    // IMAGE
                    // ==========================================

                    if (vehicle
                        .images
                        .isNotEmpty)
                      SizedBox(
                        height: 190,

                        child:
                        ListView
                            .separated(
                          scrollDirection:
                          Axis.horizontal,

                          itemCount:
                          vehicle
                              .images
                              .length,

                          separatorBuilder:
                              (
                              _,
                              __,
                              ) {
                            return const SizedBox(
                              width: 10,
                            );
                          },

                          itemBuilder:
                              (
                              context,
                              index,
                              ) {
                            return ClipRRect(
                              borderRadius:
                              BorderRadius
                                  .circular(
                                16,
                              ),

                              child:
                              Image.network(
                                vehicle
                                    .images[index],

                                width: 260,

                                fit: BoxFit
                                    .cover,

                                errorBuilder:
                                    (
                                    context,
                                    error,
                                    stackTrace,
                                    ) {
                                  return Container(
                                    width:
                                    260,

                                    color:
                                    const Color(
                                      0xFFF3F4F6,
                                    ),

                                    child:
                                    const Icon(
                                      Icons
                                          .broken_image_outlined,

                                      size:
                                      45,

                                      color:
                                      Color(
                                        0xFF9CA3AF,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(
                      height: 18,
                    ),

                    // ==========================================
                    // VEHICLE DETAILS
                    // ==========================================

                    _Section(
                      title:
                      'Vehicle Details',

                      children: [

                        _DetailRow(
                          title:
                          'Vehicle Type',

                          value:
                          vehicle
                              .vehicleType,
                        ),

                        _DetailRow(
                          title:
                          'Category',

                          value:
                          vehicle
                              .category,
                        ),

                        _DetailRow(
                          title:
                          'Brand',

                          value:
                          vehicle
                              .brand,
                        ),

                        _DetailRow(
                          title:
                          'Model',

                          value:
                          vehicle
                              .model,
                        ),

                        _DetailRow(
                          title:
                          'Registration',

                          value:
                          vehicle
                              .registrationNumber,
                        ),

                        _DetailRow(
                          title:
                          'Seats',

                          value:
                          vehicle
                              .seats
                              ?.toString() ??
                              'Not provided',
                        ),

                        _DetailRow(
                          title:
                          'Fuel Type',

                          value:
                          vehicle
                              .fuelType ??
                              'Not provided',
                        ),

                        _DetailRow(
                          title:
                          'Transmission',

                          value:
                          vehicle
                              .transmission ??
                              'Not provided',
                        ),
                      ],
                    ),

                    // ==========================================
                    // PRICING
                    // ==========================================

                    _Section(
                      title:
                      'Pricing',

                      children: [

                        _DetailRow(
                          title:
                          'Hourly',

                          value:
                          '₹${_formatPrice(vehicle.hourlyPrice)}',
                        ),

                        _DetailRow(
                          title:
                          '12 Hours',

                          value:
                          vehicle
                              .twelveHourPrice !=
                              null
                              ? '₹${_formatPrice(vehicle.twelveHourPrice!)}'
                              : 'Not provided',
                        ),

                        _DetailRow(
                          title:
                          'Daily',

                          value:
                          '₹${_formatPrice(vehicle.dailyPrice)}',
                        ),

                        _DetailRow(
                          title:
                          'Security',

                          value:
                          '₹${_formatPrice(vehicle.securityDeposit)}',
                        ),
                      ],
                    ),

                    // ==========================================
                    // LOCATION
                    // ==========================================

                    _Section(
                      title:
                      'Location',

                      children: [

                        _DetailRow(
                          title:
                          'City',

                          value:
                          vehicle.city,
                        ),

                        _DetailRow(
                          title:
                          'Area',

                          value:
                          vehicle.area,
                        ),

                        _DetailRow(
                          title:
                          'Latitude',

                          value:
                          vehicle
                              .latitude
                              ?.toString() ??
                              'Not provided',
                        ),

                        _DetailRow(
                          title:
                          'Longitude',

                          value:
                          vehicle
                              .longitude
                              ?.toString() ??
                              'Not provided',
                        ),
                      ],
                    ),

                    // ==========================================
                    // OWNER
                    // ==========================================

                    _Section(
                      title:
                      'Owner',

                      children: [

                        _DetailRow(
                          title:
                          'Owner ID',

                          value:
                          vehicle
                              .ownerId
                              .toString(),
                        ),
                      ],
                    ),

                    // ==========================================
                    // STATUS
                    // ==========================================

                    _Section(
                      title:
                      'Status',

                      children: [

                        _DetailRow(
                          title:
                          'Approval',

                          value:
                          vehicle
                              .approvalStatus,
                        ),

                        _DetailRow(
                          title:
                          'Availability',

                          value:
                          vehicle
                              .isAvailable
                              ? 'Available'
                              : 'Unavailable',
                        ),
                      ],
                    ),

                    // ==========================================
                    // DESCRIPTION
                    // ==========================================

                    if (vehicle
                        .description !=
                        null &&
                        vehicle
                            .description!
                            .trim()
                            .isNotEmpty)
                      _Section(
                        title:
                        'Description',

                        children: [
                          Text(
                            vehicle
                                .description!,

                            style:
                            const TextStyle(
                              color:
                              Color(
                                0xFF374151,
                              ),

                              fontSize:
                              13,

                              height:
                              1.5,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(
                      height: 10,
                    ),

                    // ==========================================
                    // ACTIONS
                    // ==========================================

                    if (!vehicle
                        .isVerified)
                      Row(
                        children: [

                          Expanded(
                            child:
                            OutlinedButton(
                              onPressed:
                              _processing
                                  ? null
                                  : _reject,

                              style:
                              OutlinedButton
                                  .styleFrom(
                                foregroundColor:
                                const Color(
                                  0xFFDC2626,
                                ),

                                side:
                                const BorderSide(
                                  color:
                                  Color(
                                    0xFFDC2626,
                                  ),
                                ),

                                padding:
                                const EdgeInsets
                                    .symmetric(
                                  vertical:
                                  13,
                                ),
                              ),

                              child:
                              const Text(
                                'Reject',
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child:
                            ElevatedButton(
                              onPressed:
                              _processing
                                  ? null
                                  : _approve,

                              style:
                              ElevatedButton
                                  .styleFrom(
                                backgroundColor:
                                const Color(
                                  0xFF16A34A,
                                ),

                                foregroundColor:
                                Colors.white,

                                padding:
                                const EdgeInsets
                                    .symmetric(
                                  vertical:
                                  13,
                                ),
                              ),

                              child:
                              _processing
                                  ? const SizedBox(
                                width:
                                20,
                                height:
                                20,
                                child:
                                CircularProgressIndicator(
                                  strokeWidth:
                                  2,
                                  color:
                                  Colors.white,
                                ),
                              )
                                  : const Text(
                                'Approve',
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FORMAT PRICE
  // ============================================================

  String _formatPrice(
      double value,
      ) {
    if (value ==
        value.roundToDouble()) {
      return value
          .toInt()
          .toString();
    }

    return value.toStringAsFixed(
      2,
    );
  }
}

// ============================================================================
// SECTION
// ============================================================================

class _Section
    extends StatelessWidget {

  final String title;
  final List<Widget> children;

  const _Section({
    required this.title,
    required this.children,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      width: double.infinity,

      margin:
      const EdgeInsets.only(
        bottom: 14,
      ),

      padding:
      const EdgeInsets.all(
        15,
      ),

      decoration:
      BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(
          15,
        ),

        border: Border.all(
          color:
          const Color(
            0xFFE5E7EB,
          ),
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Text(
            title,

            style:
            const TextStyle(
              color:
              Color(0xFF111827),

              fontSize: 14,

              fontWeight:
              FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          ...children,
        ],
      ),
    );
  }
}

// ============================================================================
// DETAIL ROW
// ============================================================================

class _DetailRow
    extends StatelessWidget {

  final String title;
  final String value;

  const _DetailRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 10,
      ),

      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          SizedBox(
            width: 105,

            child: Text(
              title,

              style:
              const TextStyle(
                color:
                Color(0xFF6B7280),

                fontSize: 11,

                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Text(
              value,

              style:
              const TextStyle(
                color:
                Color(0xFF111827),

                fontSize: 12,

                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}