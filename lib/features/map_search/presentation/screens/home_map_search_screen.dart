import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../home/presentation/widgets/home_dashboard_app_bar.dart';
import '../widgets/map_bottom_peek_sheet.dart';
import '../widgets/map_controls.dart';
import '../widgets/map_pin_widgets.dart';

// ── Demo selected-pin data ────────────────────────────────────────────────────
const _selectedPin = MapSelectedPinData(
  name: 'Phuoc Thien Charity Kitchen',
  address: '128 Nguyen Tri Phuong, Hai Chau, Da Nang',
  badge: 'Verified Charity Kitchen',
  rating: 4.9,
  rescueCount: 142,
  walkDistance: '850m',
  walkTime: '10 min',
  servingWindow: 'Serving hot lunch (11:00 - 13:00)',
  timeLeftLabel: '45m left',
  portionsAvailable: 60,
  portionsTotal: 100,
);

// ── Map pin dataset ───────────────────────────────────────────────────────────
const _mapPins = <(LatLng, MapPinData)>[
  (
    LatLng(16.0685, 108.2210),
    MapPinData(
      id: 'phuoc_thien',
      label: 'Phuoc Thien Charity • 60 left',
      icon: Icons.soup_kitchen_rounded,
      pinColor: AppColors.primary,
      ringColor: AppColors.primaryFixed,
      isPulsing: true,
    ),
  ),
  (
    LatLng(16.0620, 108.2275),
    MapPinData(
      id: 'boulangerie',
      label: 'Boulangerie Bakery',
      icon: Icons.bakery_dining_rounded,
      pinColor: Color(0xFFFEA619),
      ringColor: Color(0xFFFFDDB8),
    ),
  ),
  (
    LatLng(16.0600, 108.2180),
    MapPinData(
      id: 'green_garden',
      label: 'Green Garden Organic',
      icon: Icons.eco_rounded,
      pinColor: AppColors.primaryContainer,
      ringColor: AppColors.primaryFixed,
    ),
  ),
  (
    LatLng(16.0660, 108.2140),
    MapPinData(
      id: 'sunburst',
      label: 'Sunburst Eatery',
      icon: Icons.lunch_dining_rounded,
      pinColor: Color(0xFFB61722),
      ringColor: Color(0xFFFFDAD6),
    ),
  ),
];

/// Food Map screen — interactive OpenStreetMap with food rescue pins,
/// floating search/category controls, and a bottom peek sheet.
///
/// Widgets are imported from features/map_search/presentation/widgets/:
///   • [MapSearchBar]          – search + filter button
///   • [MapCategoryPills]      – category pill row
///   • [RadiusSelectorPill]    – radius dropdown
///   • [MapPinWidget]          – individual pin on map
///   • [UserLocationBeacon]    – pulsing user dot
///   • [MapFloatingButton]     – floating action buttons
///   • [MapBottomPeekSheet]    – selected-pin bottom card
///   • [AppBottomNavBar]       – shared navigation bar
class HomeMapSearchScreen extends ConsumerStatefulWidget {
  const HomeMapSearchScreen({super.key});

  @override
  ConsumerState<HomeMapSearchScreen> createState() =>
      _HomeMapSearchScreenState();
}

class _HomeMapSearchScreenState extends ConsumerState<HomeMapSearchScreen>
    with SingleTickerProviderStateMixin {
  final _mapController = MapController();
  late AnimationController _pulseController;

  int _selectedCategoryIndex = 0;
  String _selectedRadius = 'Within 5 km';
  final _searchController = TextEditingController(
    text: 'Charity kitchens near me',
  );

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _pulseController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Bottom-sheet helpers ────────────────────────────────────────────────────

  void _showFilterBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _FilterSheet(),
    );
  }

  void _showRadiusSelector() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _RadiusSheet(
        selected: _selectedRadius,
        onSelected: (v) => setState(() => _selectedRadius = v),
      ),
    );
  }

  void _showReserveConfirmation() {
    showDialog<void>(
      context: context,
      builder: (_) => _ReserveDialog(
        onViewQr: () => context.push(RoutePaths.profile),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      body: Stack(
        children: [
          // ── Map + bottom content ──
          Column(
            children: [
              const SizedBox(height: 104), // header spacer

              // Interactive OSM map
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(child: _buildMap()),
                    // Floating top controls (search + category pills)
                    Positioned(
                      top: 12,
                      left: 16,
                      right: 16,
                      child: Column(
                        children: [
                          MapSearchBar(
                            controller: _searchController,
                            activeFilterCount: 3,
                            onFilterTap: _showFilterBottomSheet,
                          ),
                          const SizedBox(height: 10),
                          MapCategoryPills(
                            categories: kDefaultMapCategories,
                            selectedIndex: _selectedCategoryIndex,
                            onSelected: (i) =>
                                setState(() => _selectedCategoryIndex = i),
                          ),
                        ],
                      ),
                    ),
                    // Radius pill
                    Positioned(
                      top: 116,
                      right: 16,
                      child: RadiusSelectorPill(
                        label: _selectedRadius,
                        onTap: _showRadiusSelector,
                      ),
                    ),
                    // Floating right-side action buttons
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MapFloatingButton(
                            icon: Icons.my_location_rounded,
                            iconColor: AppColors.primary,
                            onTap: () => _mapController.move(
                              const LatLng(16.0650, 108.2200),
                              15.0,
                            ),
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
                  ],
                ),
              ),

              // Bottom peek sheet
              MapBottomPeekSheet(
                data: _selectedPin,
                onShare: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã sao chép liên kết chia sẻ!'),
                    duration: Duration(seconds: 1),
                  ),
                ),
                onReserve: _showReserveConfirmation,
              ),

              // Nav bar spacer
              const SizedBox(height: 64),
            ],
          ),

          // ── Fixed top header ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: HomeDashboardAppBar(
              notificationCount: 2,
              onLocationTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Khu vực hiện tại: Hải Châu, Đà Nẵng, Việt Nam'),
                  duration: Duration(seconds: 1),
                ),
              ),
              onNotificationTap: () {},
              onProfileTap: () => context.push(RoutePaths.profile),
            ),
          ),

          // ── Fixed bottom nav ──
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

  // ── Map widget ──────────────────────────────────────────────────────────────

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(16.0650, 108.2200),
        initialZoom: 14.5,
        minZoom: 5.0,
        maxZoom: 18.0,
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
            // User location beacon
            const Marker(
              point: LatLng(16.0650, 108.2200),
              width: 60,
              height: 60,
              child: _UserBeaconMarker(),
            ),
            // Food pins
            for (final (latLng, pin) in _mapPins)
              Marker(
                point: latLng,
                width: 80,
                height: 80,
                child: MapPinWidget(
                  data: pin,
                  animation:
                      pin.isPulsing ? _pulseController.view : null,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ── Static marker wrapper ─────────────────────────────────────────────────────

/// Wraps [UserLocationBeacon] in a [_PulseWrapper] for the marker layer.
/// Must be stateless — animation is driven by the screen's AnimationController.
class _UserBeaconMarker extends StatefulWidget {
  const _UserBeaconMarker();

  @override
  State<_UserBeaconMarker> createState() => _UserBeaconMarkerState();
}

class _UserBeaconMarkerState extends State<_UserBeaconMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      UserLocationBeacon(animation: _ctrl.view);
}

// ── Sheet / Dialog private widgets ───────────────────────────────────────────

class _FilterSheet extends StatelessWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lọc Điểm Cứu Trợ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('Bếp ăn từ thiện (Charity Kitchens)'),
            value: true,
            onChanged: (_) {},
            activeColor: AppColors.primary,
          ),
          CheckboxListTile(
            title: const Text('Cửa hàng & Siêu thị dư thừa (Surplus)'),
            value: true,
            onChanged: (_) {},
            activeColor: AppColors.primary,
          ),
          CheckboxListTile(
            title: const Text('Ưu tiên thực phẩm cận date (< 6h)'),
            value: true,
            onChanged: (_) {},
            activeColor: AppColors.primary,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Áp Dụng'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadiusSheet extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _RadiusSheet({required this.selected, required this.onSelected});

  static const _options = [
    'Within 1 km',
    'Within 3 km',
    'Within 5 km',
    'Within 10 km',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _options
            .map(
              (opt) => ListTile(
                title: Text(
                  opt,
                  style: TextStyle(
                    fontWeight: selected == opt
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                trailing: selected == opt
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  onSelected(opt);
                  Navigator.pop(context);
                },
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ReserveDialog extends StatelessWidget {
  final VoidCallback onViewQr;
  const _ReserveDialog({required this.onViewQr});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: AppColors.primary,
            size: 24,
          ),
          SizedBox(width: 8),
          Text(
            'Xác Nhận Giữ Chỗ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: const Text(
        'Bạn đã giữ 1 suất ăn trưa tại Bếp ăn Từ thiện Phước Thiện.\n\n'
        'Mã QR nhận thức ăn đã được lưu vào mục Hồ sơ. '
        'Lộ trình đi bộ (850m • 10 phút) đã sẵn sàng!',
        style: TextStyle(fontSize: 14, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
            onViewQr();
          },
          child: const Text('Xem Mã QR'),
        ),
      ],
    );
  }
}


