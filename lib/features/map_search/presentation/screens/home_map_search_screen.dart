import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../listings/domain/entities/food_listing.dart';
import '../../../listings/presentation/widgets/listing_card.dart';
import '../../domain/entities/search_filter.dart';
import '../providers/map_search_provider.dart';

class HomeMapSearchScreen extends ConsumerStatefulWidget {
  const HomeMapSearchScreen({super.key});

  @override
  ConsumerState<HomeMapSearchScreen> createState() =>
      _HomeMapSearchScreenState();
}

class _HomeMapSearchScreenState extends ConsumerState<HomeMapSearchScreen> {
  GoogleMapController? _mapController;
  final LatLng _initialPosition = const LatLng(10.7769, 106.7009);

  Set<Marker> _buildMarkers(List<FoodListing> listings) {
    return listings.map((item) {
      return Marker(
        markerId: MarkerId(item.id),
        position: LatLng(item.latitude, item.longitude),
        infoWindow: InfoWindow(
          title: item.title,
          snippet: item.condition.isFree
              ? 'MIỄN PHÍ - Còn ${item.quantity} phần'
              : '${item.price?.toInt() ?? 0} đ',
          onTap: () {
            context.push(RoutePaths.listingDetailPath(item.id));
          },
        ),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final isMapView = ref.watch(isMapViewProvider);
    final filter = ref.watch(searchFilterProvider);
    final listingsAsync = ref.watch(filteredNearbyListingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.eco, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 8),
            const Text(
              AppConstants.appName,
              style: TextStyle(
                  fontWeight: FontWeight.w800, color: AppColors.primary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isMapView
                ? Icons.format_list_bulleted_rounded
                : Icons.map_outlined),
            tooltip: isMapView ? 'Xem danh sách' : 'Xem bản đồ',
            onPressed: () {
              ref.read(isMapViewProvider.notifier).state = !isMapView;
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Hồ sơ cá nhân',
            onPressed: () => context.push(RoutePaths.profile),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Row
          _buildFilterBar(filter),

          // Main View (Map or List)
          Expanded(
            child: listingsAsync.when(
              loading: () => const AppLoadingIndicator(
                  message: 'Đang tìm thực phẩm quanh bạn...'),
              error: (err, _) => AppErrorView(
                message: err.toString(),
                onRetry: () => ref.refresh(filteredNearbyListingsProvider),
              ),
              data: (listings) {
                if (listings.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'Không có thực phẩm nào trong bán kính tìm kiếm. Thử mở rộng bán kính hoặc quay lại sau nhé!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondaryLight),
                      ),
                    ),
                  );
                }

                if (isMapView) {
                  return Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _initialPosition,
                          zoom: 14.5,
                        ),
                        markers: _buildMarkers(listings),
                        onMapCreated: (controller) =>
                            _mapController = controller,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                      ),
                      // Floating horizontal preview carousel at bottom of map
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        height: 110,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: listings.length,
                          itemBuilder: (context, index) {
                            final item = listings[index];
                            return InkWell(
                              onTap: () => context
                                  .push(RoutePaths.listingDetailPath(item.id)),
                              child: Container(
                                width: 280,
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.12),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        item.photos.first,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.fastfood,
                                                size: 40),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            item.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item.condition.isFree
                                                ? 'MIỄN PHÍ'
                                                : '${item.price?.toInt()} đ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: item.condition.isFree
                                                  ? AppColors.primary
                                                  : AppColors.secondary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item.addressText,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors
                                                    .textSecondaryLight),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }

                // List View
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: listings.length,
                  itemBuilder: (context, index) {
                    final item = listings[index];
                    return ListingCard(
                      listing: item,
                      onTap: () =>
                          context.push(RoutePaths.listingDetailPath(item.id)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RoutePaths.createListing),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Đăng tin dư',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFilterBar(SearchFilter filter) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Radius Chip
            ActionChip(
              avatar: const Icon(Icons.radar_rounded,
                  size: 16, color: AppColors.primary),
              label: Text('Bán kính ${filter.radiusKm.toInt()} km'),
              onPressed: () => _showRadiusDialog(filter.radiusKm),
            ),
            const SizedBox(width: 8),

            // All condition
            ChoiceChip(
              label: const Text('Tất cả'),
              selected: filter.condition == null,
              onSelected: (selected) {
                if (selected) {
                  ref.read(searchFilterProvider.notifier).state =
                      filter.copyWith(condition: null);
                }
              },
            ),
            const SizedBox(width: 8),

            // Free condition
            ChoiceChip(
              label: const Text('Miễn phí 0đ'),
              selected: filter.condition == FoodCondition.free,
              onSelected: (selected) {
                ref.read(searchFilterProvider.notifier).state = filter.copyWith(
                  condition: selected ? FoodCondition.free : null,
                );
              },
            ),
            const SizedBox(width: 8),

            // Paid condition
            ChoiceChip(
              label: const Text('Có phí cứu hộ'),
              selected: filter.condition == FoodCondition.paid,
              onSelected: (selected) {
                ref.read(searchFilterProvider.notifier).state = filter.copyWith(
                  condition: selected ? FoodCondition.paid : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRadiusDialog(double currentRadius) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Chọn bán kính tìm kiếm thực phẩm',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    children: [1.0, 3.0, 5.0, 10.0, 15.0].map((r) {
                      final isSelected =
                          ref.watch(searchFilterProvider).radiusKm == r;
                      return ChoiceChip(
                        label: Text('${r.toInt()} km'),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            ref.read(searchFilterProvider.notifier).state = ref
                                .read(searchFilterProvider)
                                .copyWith(radiusKm: r);
                            Navigator.pop(ctx);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
