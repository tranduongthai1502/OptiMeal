import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../listings/domain/entities/food_listing.dart';
import '../../../home/presentation/widgets/home_dashboard_app_bar.dart';
import '../providers/map_search_provider.dart';
import '../widgets/map_controls.dart';
import '../widgets/map_pin_widgets.dart';

class HomeMapSearchScreen extends ConsumerStatefulWidget {
  const HomeMapSearchScreen({super.key});

  @override
  ConsumerState<HomeMapSearchScreen> createState() =>
      _HomeMapSearchScreenState();
}

class _HomeMapSearchScreenState extends ConsumerState<HomeMapSearchScreen> {
  final _mapController = MapController();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(filteredNearbyListingsProvider);
    final listings = listingsAsync.valueOrNull ?? const <FoodListing>[];
    final query = _searchQuery.trim().toLowerCase();
    final visibleListings = query.isEmpty
        ? listings
        : listings
            .where(
              (listing) =>
                  listing.title.toLowerCase().contains(query) ||
                  listing.description.toLowerCase().contains(query),
            )
            .toList();

    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 104),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(child: _buildMap(visibleListings)),
                    Positioned(
                      top: 12,
                      left: 16,
                      right: 16,
                      child: MapSearchBar(
                        controller: _searchController,
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MapFloatingButton(
                            icon: Icons.add,
                            iconColor: AppColors.onSurface,
                            onTap: () => _mapController.move(
                              _mapController.camera.center,
                              _mapController.camera.zoom + 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          MapFloatingButton(
                            icon: Icons.remove,
                            iconColor: AppColors.onSurface,
                            onTap: () => _mapController.move(
                              _mapController.camera.center,
                              _mapController.camera.zoom - 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 76,
                      bottom: 16,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: listingsAsync.when(
                          loading: () =>
                              const Text('Đang tải tin thực phẩm...'),
                          error: (_, __) =>
                              const Text('Không tải được tin thực phẩm.'),
                          data: (_) => Text(
                            visibleListings.isEmpty
                                ? 'Không có tin phù hợp.'
                                : 'Có ${visibleListings.length} tin thực phẩm.',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 64),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: HomeDashboardAppBar(
              onProfileTap: () => context.push(RoutePaths.profile),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AppBottomNavBar(
              centerIndex: 2,
              items: [
                AppBottomNavItem(
                  icon: Icons.eco_rounded,
                  label: 'Home',
                  onTap: () => context.go(RoutePaths.home),
                ),
                AppBottomNavItem(
                  icon: Icons.near_me_rounded,
                  label: 'Food Map',
                  isActive: true,
                  onTap: () {},
                ),
                AppBottomNavItem(
                  icon: Icons.add,
                  label: '',
                  isCenter: true,
                  onTap: () => context.push(RoutePaths.createListing),
                ),
                AppBottomNavItem(
                  icon: Icons.auto_awesome_rounded,
                  label: 'AI Copilot',
                  onTap: () => context.go(RoutePaths.recipeCopilot),
                ),
                AppBottomNavItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
                  onTap: () => context.push(RoutePaths.profile),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(List<FoodListing> listings) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(10.7769, 106.7009),
        initialZoom: 14.5,
        minZoom: 5,
        maxZoom: 18,
        cameraConstraint: CameraConstraint.containCenter(
          bounds: LatLngBounds(
            const LatLng(8.18, 102.14),
            const LatLng(23.39, 109.46),
          ),
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.de/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.optimeal',
        ),
        MarkerLayer(
          markers: [
            for (final listing in listings)
              Marker(
                point: LatLng(listing.latitude, listing.longitude),
                width: 100,
                height: 80,
                child: MapPinWidget(
                  data: MapPinData(
                    id: listing.id,
                    label: listing.title,
                    icon: listing.category.isCharityMealPoint
                        ? Icons.volunteer_activism_rounded
                        : Icons.fastfood_rounded,
                    pinColor: listing.category.isCharityMealPoint
                        ? AppColors.primary
                        : AppColors.secondary,
                    ringColor: AppColors.primaryFixed,
                  ),
                  onTap: () => context.push(
                    RoutePaths.listingDetailPath(listing.id),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
