import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../home/presentation/widgets/home_dashboard_app_bar.dart';
import '../../../listings/domain/entities/food_listing.dart';
import '../providers/location_provider.dart';
import '../providers/map_search_provider.dart';
import '../providers/routing_provider.dart';
import '../widgets/listing_bottom_sheet.dart';
import '../widgets/map_controls.dart';
import '../widgets/map_pin_widgets.dart';

/// Toạ độ trung tâm mặc định: Đà Nẵng.
const _kDefaultCenter = LatLng(16.0544, 108.2022);

/// Màn hình bản đồ chính — hiển thị marker món ăn, vị trí người dùng,
/// bán kính tìm kiếm, và tuyến đường ORS.
class HomeMapSearchScreen extends ConsumerStatefulWidget {
  const HomeMapSearchScreen({super.key});

  @override
  ConsumerState<HomeMapSearchScreen> createState() =>
      _HomeMapSearchScreenState();
}

class _HomeMapSearchScreenState extends ConsumerState<HomeMapSearchScreen>
    with TickerProviderStateMixin {
  final _mapController = MapController();
  final _searchController = TextEditingController();

  /// AnimationController cho UserLocationBeacon và marker đang sắp hết hạn.
  late final AnimationController _beaconController;

  String _searchQuery = '';

  /// Đảm bảo chỉ auto-pan về vị trí người dùng một lần khi GPS lần đầu có kết quả.
  bool _hasCenteredOnUser = false;

  @override
  void initState() {
    super.initState();
    _beaconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    _beaconController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _moveToUser(LatLng pos) {
    _mapController.move(pos, 15.5);
  }

  /// Fit camera để thấy trọn tuyến đường.
  void _fitRouteBounds(List<LatLng> points) {
    if (points.isEmpty) return;
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: const EdgeInsets.all(52),
      ),
    );
  }

  void _clearRoute() {
    ref.read(routeTargetProvider.notifier).state = null;
  }

  void _openListingSheet(FoodListing listing) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ListingBottomSheet(listing: listing),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final listingsAsync = ref.watch(nearbyListingsStreamProvider);
    final routeTarget = ref.watch(routeTargetProvider);

    // Auto-pan lần đầu khi GPS có kết quả
    if (!_hasCenteredOnUser && locationState.hasPosition) {
      _hasCenteredOnUser = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _moveToUser(LatLng(
          locationState.position!.latitude,
          locationState.position!.longitude,
        ));
      });
    }

    final userLatLng = locationState.hasPosition
        ? LatLng(
            locationState.position!.latitude,
            locationState.position!.longitude,
          )
        : null;

    // Lọc theo từ khoá tìm kiếm
    final allListings = listingsAsync.valueOrNull ?? const <FoodListing>[];
    final query = _searchQuery.trim().toLowerCase();
    final visibleListings = query.isEmpty
        ? allListings
        : allListings
            .where(
              (l) =>
                  l.title.toLowerCase().contains(query) ||
                  l.description.toLowerCase().contains(query),
            )
            .toList();

    // Chuẩn bị params cho routing (chỉ khi có GPS + có target)
    RouteParams? routeParams;
    if (routeTarget != null && userLatLng != null) {
      routeParams = RouteParams(from: userLatLng, to: routeTarget);
    }

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
                    // ── Bản đồ ────────────────────────────────────────────────
                    Positioned.fill(
                      child: _buildMap(
                        visibleListings: visibleListings,
                        userLatLng: userLatLng,
                        routeParams: routeParams,
                      ),
                    ),

                    // ── Thanh tìm kiếm ────────────────────────────────────────
                    Positioned(
                      top: 12,
                      left: 16,
                      right: 16,
                      child: MapSearchBar(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),

                    // ── Cảnh báo GPS (nếu có) ─────────────────────────────────
                    if (locationState.errorMessage != null)
                      Positioned(
                        top: 72,
                        left: 16,
                        right: 16,
                        child: _GpsWarningBanner(
                          message: locationState.errorMessage!,
                        ),
                      ),

                    // ── Chip tuyến đường ──────────────────────────────────────
                    if (routeParams != null)
                      Positioned(
                        top: locationState.errorMessage != null ? 120 : 72,
                        left: 16,
                        right: 68,
                        child: _RouteInfoChip(
                          params: routeParams,
                          onClose: _clearRoute,
                          onFit: _fitRouteBounds,
                        ),
                      ),

                    // ── Nút vị trí + zoom ─────────────────────────────────────
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MapFloatingButton(
                            icon: Icons.my_location_rounded,
                            iconColor: userLatLng != null
                                ? AppColors.primary
                                : AppColors.onSurfaceVariant,
                            onTap: () {
                              if (userLatLng != null) {
                                _moveToUser(userLatLng);
                              } else {
                                ref.read(locationProvider.notifier).refresh();
                              }
                            },
                          ),
                          const SizedBox(height: 8),
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

                    // ── Đếm kết quả ───────────────────────────────────────────
                    Positioned(
                      left: 16,
                      right: 76,
                      bottom: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLowest,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0F000000),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: listingsAsync.when(
                          loading: () => const Text(
                            'Đang tải đơn thực phẩm...',
                            style: TextStyle(fontSize: 12),
                          ),
                          error: (_, __) => const Text(
                            'Không tải được dữ liệu. Kiểm tra mạng.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.error,
                            ),
                          ),
                          data: (_) => Text(
                            visibleListings.isEmpty
                                ? 'Không có đơn phù hợp gần đây.'
                                : 'Có ${visibleListings.length} đơn gần bạn.',
                            style: const TextStyle(fontSize: 12),
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

          // ── App bar ──────────────────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: HomeDashboardAppBar(
              onProfileTap: () => context.push(RoutePaths.profile),
            ),
          ),

          // ── Bottom nav bar ───────────────────────────────────────────────────
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

  // ── Map builder ────────────────────────────────────────────────────────────

  Widget _buildMap({
    required List<FoodListing> visibleListings,
    required LatLng? userLatLng,
    required RouteParams? routeParams,
  }) {
    final filter = ref.watch(searchFilterProvider);
    final radiusMeters = filter.radiusKm * 1000.0;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _kDefaultCenter,
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
        // ── OSM tile — userAgentPackageName phải khớp applicationId ──────────
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.optimeal',
          // Tile lỗi (mất mạng): nuốt lỗi, không crash
          errorTileCallback: (tile, error, stackTrace) {},
        ),

        // ── Ghi nguồn OSM (bắt buộc theo ToS OpenStreetMap) ─────────────────
        const RichAttributionWidget(
          attributions: [
            TextSourceAttribution('© OpenStreetMap contributors'),
          ],
          alignment: AttributionAlignment.bottomLeft,
        ),

        // ── Vòng bán kính tìm kiếm ───────────────────────────────────────────
        if (userLatLng != null)
          CircleLayer(
            circles: [
              CircleMarker(
                point: userLatLng,
                radius: radiusMeters,
                useRadiusInMeter: true,
                color: AppColors.primary.withValues(alpha: 0.06),
                borderColor: AppColors.primary.withValues(alpha: 0.22),
                borderStrokeWidth: 1.5,
              ),
            ],
          ),

        // ── Polyline tuyến đường ORS ─────────────────────────────────────────
        if (routeParams != null)
          _RoutePolylineLayer(params: routeParams),

        // ── Marker món ăn ────────────────────────────────────────────────────
        MarkerLayer(
          markers: [
            for (final listing in visibleListings)
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
                    ringColor: listing.category.isCharityMealPoint
                        ? AppColors.primaryFixed
                        : AppColors.secondaryFixed,
                    isPulsing: listing.isExpiringSoon,
                  ),
                  animation:
                      listing.isExpiringSoon ? _beaconController : null,
                  onTap: () => _openListingSheet(listing),
                ),
              ),
          ],
        ),

        // ── Marker vị trí người dùng ─────────────────────────────────────────
        if (userLatLng != null)
          MarkerLayer(
            markers: [
              Marker(
                point: userLatLng,
                width: 60,
                height: 60,
                child: UserLocationBeacon(animation: _beaconController),
              ),
            ],
          ),
      ],
    );
  }
}

// ── Route polyline layer ─────────────────────────────────────────────────────

/// Lắng nghe routeProvider và vẽ polyline; không hiện gì khi loading/error
/// (trạng thái được hiển thị ở _RouteInfoChip).
class _RoutePolylineLayer extends ConsumerWidget {
  final RouteParams params;
  const _RoutePolylineLayer({required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routeAsync = ref.watch(routeProvider(params));
    return routeAsync.maybeWhen(
      data: (route) => PolylineLayer(
        polylines: [
          Polyline(
            points: route.points,
            strokeWidth: 4.5,
            color: AppColors.info,
            borderStrokeWidth: 1.5,
            borderColor: Colors.white,
          ),
        ],
      ),
      orElse: SizedBox.shrink,
    );
  }
}

// ── Route info chip ──────────────────────────────────────────────────────────

/// Chip hiển thị trạng thái tuyến đường (loading / lỗi / km·phút).
class _RouteInfoChip extends ConsumerWidget {
  final RouteParams params;
  final VoidCallback onClose;
  final void Function(List<LatLng>) onFit;

  const _RouteInfoChip({
    required this.params,
    required this.onClose,
    required this.onFit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routeAsync = ref.watch(routeProvider(params));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.directions_car_rounded,
            size: 16,
            color: AppColors.info,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: routeAsync.when(
              loading: () => const Text(
                'Đang tính tuyến đường...',
                style: TextStyle(fontSize: 12),
              ),
              error: (error, _) => Text(
                error.toString(),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.error,
                ),
                maxLines: 2,
              ),
              data: (route) {
                // Fit camera sau khi tuyến đường tải xong
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  onFit(route.points);
                });
                return Text(
                  '${route.distanceLabel} · ${route.durationLabel}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onClose,
            child: const Icon(
              Icons.close,
              size: 16,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── GPS warning banner ────────────────────────────────────────────────────────

class _GpsWarningBanner extends StatelessWidget {
  final String message;
  const _GpsWarningBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_off_rounded,
            size: 14,
            color: AppColors.warning,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
