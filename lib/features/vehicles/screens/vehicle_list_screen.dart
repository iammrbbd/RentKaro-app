import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/providers/home_provider.dart';
import '../../home/widgets/vehicle_card.dart';
import 'vehicle_details_screen.dart';

class VehicleListScreen extends ConsumerStatefulWidget {
  const VehicleListScreen({super.key});

  @override
  ConsumerState<VehicleListScreen> createState() =>
      _VehicleListScreenState();
}

class _VehicleListScreenState
    extends ConsumerState<VehicleListScreen> {
  String selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'Cars',
    'Bikes',
    'SUV',
    'Premium',
  ];

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(homeVehiclesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Available Vehicles',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: vehiclesAsync.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return _buildErrorState(error);
        },
        data: (vehicles) {
          final filteredVehicles = vehicles.where((vehicle) {
            if (selectedCategory == 'All') {
              return true;
            }

            if (selectedCategory == 'Premium') {
              return vehicle.isPremium;
            }

            if (selectedCategory == 'Bikes') {
              return vehicle.category == 'Bikes';
            }

            if (selectedCategory == 'Cars') {
              return vehicle.category == 'Cars' ||
                  vehicle.category == 'SUV';
            }

            return vehicle.category == selectedCategory;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  14,
                ),
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Search vehicles',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.tune_rounded,
                        color: Color(0xFF1565C0),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                height: 45,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (context, index) {
                    return const SizedBox(width: 8);
                  },
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final selected =
                        category == selectedCategory;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 17,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF1565C0)
                              : Colors.white,
                          borderRadius:
                              BorderRadius.circular(13),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF1565C0)
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : const Color(0xFF374151),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Row(
                  children: [
                    Text(
                      '${filteredVehicles.length} vehicles found',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.sort_rounded,
                      size: 19,
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Sort',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: filteredVehicles.isEmpty
                    ? const Center(
                        child: Text(
                          'No vehicles available',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(
                          20,
                          0,
                          20,
                          30,
                        ),
                        itemCount: filteredVehicles.length,
                        separatorBuilder:
                            (context, index) {
                          return const SizedBox(
                            height: 14,
                          );
                        },
                        itemBuilder: (context, index) {
                          final vehicle =
                              filteredVehicles[index];

                          return VehicleCard(
                            vehicle: vehicle,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      VehicleDetailsScreen(
                                    vehicle: vehicle,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load vehicles',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(homeVehiclesProvider);
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
            const SizedBox(height: 10),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
