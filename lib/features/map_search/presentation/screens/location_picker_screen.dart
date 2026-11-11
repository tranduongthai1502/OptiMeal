import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../../../core/theme/app_colors.dart';
import '../providers/location_provider.dart';
import '../widgets/map_pin_widgets.dart';

/// Màn hình chọn vị trí ghim đơn trên bản đồ.
///
/// Cách dùng:
/// ```dart
/// final picked = await Navigator.of(context).push<LatLng>(
///   MaterialPageRoute(builder: (_) => LocationPickerScreen()),
/// );
/// ```
/// Trả về [LatLng] khi người dùng xác nhận, hoặc null nếu huỷ.
class LocationPickerScreen extends ConsumerStatefulWidget {
  /// Vị trí khởi đầu (nếu đã chọn từ lần trước).
  final LatLng? initialPosition;

  const LocationPickerScreen({super.key, this.initialPosition});

  @override
  ConsumerState<LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  final _mapController = MapController();
  LatLng? _selectedPosition;

  static const _kDanang = LatLng(16.0544, 108.2022);

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialPosition;
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  // ── Handlers ───────────────────────────────────────────────────────────────

  void _onMapTap(TapPosition _, LatLng latLng) {
    setState(() => _selectedPosition = latLng);
  }

  void _useCurrentLocation() {
    final pos = ref.read(locationProvider).position;
    if (pos == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Chưa lấy được vị trí GPS. Hãy bật GPS và thử lại.',
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    final latlng = LatLng(pos.latitude, pos.longitude);
    setState(() => _selectedPosition = latlng);
    _mapController.move(latlng, 16.0);
  }

  void _confirm() {
    if (_selectedPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng bấm lên bản đồ để chọn vị trí.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    Navigator.of(context).pop(_selectedPosition);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final userLatLng = locationState.hasPosition
        ? LatLng(
            locationState.position!.latitude,
            locationState.position!.longitude,
          )
        : null;

    final initialCenter =
        widget.initialPosition ?? userLatLng ?? _kDanang;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn vị trí ghim đơn'),
        backgroundColor: AppColors.surfaceLowest,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _useCurrentLocation,
            icon: const Icon(Icons.my_location_rounded, size: 16),
            label: const Text('Vị trí của tôi'),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Bản đồ ────────────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 15.0,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.de/{z}/{x}/{y}.png',
                fallbackUrl:
                    'https://{s}.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.optimeal',
                errorTileCallback: (tile, error, stackTrace) {},
              ),
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('© OpenStreetMap contributors'),
                ],
                alignment: AttributionAlignment.bottomLeft,
              ),

              // Marker vị trí người dùng (nhỏ, không chiếm focus)
              if (userLatLng != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: userLatLng,
                      width: 20,
                      height: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              // Marker vị trí đã chọn
              if (_selectedPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedPosition!,
                      width: 100,
                      height: 80,
                      child: const MapPinWidget(
                        data: MapPinData(
                          id: 'picker',
                          label: 'Vị trí đơn',
                          icon: Icons.push_pin_rounded,
                          pinColor: AppColors.secondary,
                          ringColor: AppColors.secondaryFixed,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // ── Hướng dẫn ─────────────────────────────────────────────────────
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceLowest.withValues(alpha: 0.93),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(color: Color(0x0F000000), blurRadius: 6),
                ],
              ),
              child: const Text(
                'Bấm lên bản đồ để đặt ghim vị trí đơn.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // ── Toạ độ đã chọn ─────────────────────────────────────────────────
          if (_selectedPosition != null)
            Positioned(
              bottom: 88,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLowest,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(color: Color(0x0F000000), blurRadius: 6),
                  ],
                ),
                child: Text(
                  'Lat: ${_selectedPosition!.latitude.toStringAsFixed(6)}'
                  '   Lng: ${_selectedPosition!.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),

      // ── Nút xác nhận ────────────────────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _selectedPosition == null ? null : _confirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    AppColors.primary.withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text(
                'Xác nhận vị trí',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

