import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/location_utils.dart';

class LocationPickerResult {
  final double latitude;
  final double longitude;
  final double distanceKm;
  final String? address;

  const LocationPickerResult({
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    this.address,
  });
}

class LocationPickerDialog extends StatefulWidget {
  final double? userLatitude;
  final double? userLongitude;
  final double? initialLatitude;
  final double? initialLongitude;
  final double maxRadiusKm;

  const LocationPickerDialog({
    super.key,
    this.userLatitude,
    this.userLongitude,
    this.initialLatitude,
    this.initialLongitude,
    this.maxRadiusKm = 1.0,
  });

  static Future<LocationPickerResult?> show(
    BuildContext context, {
    double? userLatitude,
    double? userLongitude,
    double? initialLatitude,
    double? initialLongitude,
    double maxRadiusKm = 1.0,
  }) {
    return showDialog<LocationPickerResult>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => LocationPickerDialog(
        userLatitude: userLatitude,
        userLongitude: userLongitude,
        initialLatitude: initialLatitude,
        initialLongitude: initialLongitude,
        maxRadiusKm: maxRadiusKm,
      ),
    );
  }

  @override
  State<LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<LocationPickerDialog> {
  final MapController _mapController = MapController();

  LatLng? _userLocation;
  LatLng? _selectedLocation;
  double _distanceKm = 0.0;
  String? _addressText;

  bool _isLoadingGps = true;
  bool _hasRealGps = false;
  bool _isGeocoding = false;
  String? _gpsWarning;

  static const _kDefaultDanang = LatLng(16.0544, 108.2022);

  @override
  void initState() {
    super.initState();
    if (widget.userLatitude != null && widget.userLongitude != null) {
      final userPos = LatLng(widget.userLatitude!, widget.userLongitude!);
      final initialTarget =
          (widget.initialLatitude != null && widget.initialLongitude != null)
              ? LatLng(widget.initialLatitude!, widget.initialLongitude!)
              : userPos;
      final initialDist = LocationUtils.calculateDistanceKm(
        userPos.latitude,
        userPos.longitude,
        initialTarget.latitude,
        initialTarget.longitude,
      );
      _userLocation = userPos;
      _selectedLocation = initialTarget;
      _distanceKm = initialDist;
      _hasRealGps = true;
      _isLoadingGps = false;
      unawaited(_reverseGeocode(initialTarget));
    } else {
      _resolveUserLocation();
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _resolveUserLocation() async {
    setState(() => _isLoadingGps = true);

    LatLng userPos = _kDefaultDanang;
    bool gotRealGps = false;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _gpsWarning = 'Dịch vụ định vị đang tắt. Bạn có thể chọn điểm bàn giao tự do trên bản đồ.';
      } else {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          _gpsWarning =
              'Chưa cấp quyền GPS. Bạn có thể chọn điểm bàn giao tự do trên bản đồ.';
        } else {
          try {
            final position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.medium,
              timeLimit: const Duration(seconds: 5),
            );
            userPos = LatLng(position.latitude, position.longitude);
            gotRealGps = true;
            _gpsWarning = null;
          } catch (_) {
            try {
              final lastKnown = await Geolocator.getLastKnownPosition();
              if (lastKnown != null) {
                userPos = LatLng(lastKnown.latitude, lastKnown.longitude);
                gotRealGps = true;
                _gpsWarning = null;
              } else {
                _gpsWarning =
                    'Không lấy được GPS tức thời. Bạn có thể chọn điểm bàn giao tự do trên bản đồ.';
              }
            } catch (_) {
              _gpsWarning =
                  'Không lấy được GPS tức thời. Bạn có thể chọn điểm bàn giao tự do trên bản đồ.';
            }
          }
        }
      }
    } catch (_) {
      _gpsWarning = 'Không lấy được GPS tức thời. Bạn có thể chọn điểm bàn giao tự do trên bản đồ.';
    }

    final initialTarget =
        (widget.initialLatitude != null && widget.initialLongitude != null)
            ? LatLng(widget.initialLatitude!, widget.initialLongitude!)
            : userPos;

    final initialDist = gotRealGps
        ? LocationUtils.calculateDistanceKm(
            userPos.latitude,
            userPos.longitude,
            initialTarget.latitude,
            initialTarget.longitude,
          )
        : 0.0;

    if (!mounted) return;

    setState(() {
      _userLocation = userPos;
      _selectedLocation = initialTarget;
      _distanceKm = initialDist;
      _hasRealGps = gotRealGps;
      _isLoadingGps = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(initialTarget, 14.5);
    });

    unawaited(_reverseGeocode(initialTarget));
  }

  Future<void> _reverseGeocode(LatLng target) async {
    setState(() => _isGeocoding = true);
    try {
      final placemarks = await placemarkFromCoordinates(
        target.latitude,
        target.longitude,
      ).timeout(const Duration(seconds: 4));

      if (placemarks.isNotEmpty && mounted) {
        final p = placemarks.first;
        final parts = [
          p.street,
          p.subLocality,
          p.subAdministrativeArea ?? p.locality,
          p.administrativeArea,
        ].where((s) => s != null && s.trim().isNotEmpty).toList();

        setState(() {
          _addressText = parts.join(', ');
          _isGeocoding = false;
        });
        return;
      }
    } catch (_) {
      // Ignored: geocoding is optional / fallback
    }

    if (mounted) {
      setState(() => _isGeocoding = false);
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    final dist = (_hasRealGps && _userLocation != null)
        ? LocationUtils.calculateDistanceKm(
            _userLocation!.latitude,
            _userLocation!.longitude,
            point.latitude,
            point.longitude,
          )
        : 0.0;

    setState(() {
      _selectedLocation = point;
      _distanceKm = dist;
    });

    _reverseGeocode(point);
  }

  bool get _isWithinRange => !_hasRealGps || _distanceKm <= widget.maxRadiusKm;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: screenSize.width * 0.95,
        height: screenSize.height * 0.85,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.map_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chọn điểm bàn giao trên Bản đồ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          'Chạm để chọn điểm (tối đa cách bạn ${widget.maxRadiusKm.toInt()} km)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            if (_gpsWarning != null)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                color: AppColors.warning.withValues(alpha: 0.15),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 16, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _gpsWarning!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Map Area
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter:
                          _selectedLocation ?? const LatLng(10.7769, 106.7009),
                      initialZoom: 14.5,
                      minZoom: 4,
                      maxZoom: 18,
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
                      // Circle 1km quanh vị trí thực tế của người dùng (khi có GPS)
                      if (_hasRealGps && _userLocation != null)
                        CircleLayer(
                          circles: [
                            CircleMarker(
                              point: _userLocation!,
                              radius: widget.maxRadiusKm * 1000,
                              useRadiusInMeter: true,
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderColor: AppColors.primary,
                              borderStrokeWidth: 2,
                            ),
                          ],
                        ),
                      // Markers
                      MarkerLayer(
                        markers: [
                          // Điểm thực tế của người dùng
                          if (_userLocation != null)
                            Marker(
                              point: _userLocation!,
                              width: 36,
                              height: 36,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade600,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2.5),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.my_location_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          // Điểm được chọn
                          if (_selectedLocation != null)
                            Marker(
                              point: _selectedLocation!,
                              width: 44,
                              height: 44,
                              alignment: Alignment.topCenter,
                              child: Icon(
                                Icons.location_on_rounded,
                                size: 44,
                                color: _isWithinRange
                                    ? AppColors.primary
                                    : AppColors.error,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  if (_isLoadingGps)
                    Container(
                      color: Colors.black12,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),

                  // Floating Map Controls (Zoom + My Location)
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingActionButton.small(
                          heroTag: 'recenter_gps',
                          backgroundColor: Colors.white,
                          onPressed: () async {
                            if (_hasRealGps && _userLocation != null) {
                              _mapController.move(_userLocation!, 15);
                            } else {
                              await _resolveUserLocation();
                              if (_userLocation != null) {
                                _mapController.move(_userLocation!, 15);
                              }
                            }
                          },
                          child: const Icon(
                            Icons.my_location_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FloatingActionButton.small(
                          heroTag: 'zoom_in',
                          backgroundColor: Colors.white,
                          onPressed: () {
                            _mapController.move(
                              _mapController.camera.center,
                              _mapController.camera.zoom + 1,
                            );
                          },
                          child:
                              const Icon(Icons.add, color: AppColors.onSurface),
                        ),
                        const SizedBox(height: 8),
                        FloatingActionButton.small(
                          heroTag: 'zoom_out',
                          backgroundColor: Colors.white,
                          onPressed: () {
                            _mapController.move(
                              _mapController.camera.center,
                              _mapController.camera.zoom - 1,
                            );
                          },
                          child: const Icon(Icons.remove,
                              color: AppColors.onSurface),
                        ),
                      ],
                    ),
                  ),

                  // Gợi ý phạm vi vòng tròn
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.primary, width: 1.5),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Vòng tròn xanh: Vùng ${widget.maxRadiusKm.toInt()}km cho phép',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Confirmation & Distance Indicator
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status Distance Pill
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _isWithinRange
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _isWithinRange
                            ? AppColors.primary.withValues(alpha: 0.3)
                            : AppColors.error.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isWithinRange
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          size: 20,
                          color: _isWithinRange
                              ? AppColors.primary
                              : AppColors.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            !_hasRealGps
                                ? 'Chọn điểm bất kỳ trên bản đồ (Chưa có tín hiệu GPS thực tế)'
                                : _isWithinRange
                                    ? 'Cách bạn: ${LocationUtils.formatDistance(_distanceKm)} (Hợp lệ trong ${widget.maxRadiusKm.toInt()}km)'
                                    : 'Cách bạn: ${LocationUtils.formatDistance(_distanceKm)} — Quá xa! (Chỉ cho phép <= ${widget.maxRadiusKm.toInt()}km)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _isWithinRange
                                  ? AppColors.primary
                                  : AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Địa chỉ giải mã
                  if (_isGeocoding)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Đang định vị địa chỉ thực tế...',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (_addressText != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.place_outlined,
                            size: 16,
                            color: AppColors.textSecondaryLight,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _addressText!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Nút xác nhận
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      disabledForegroundColor: Colors.grey.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text(
                      'Xác nhận điểm bàn giao này',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    onPressed: (_selectedLocation != null && _isWithinRange)
                        ? () {
                            Navigator.of(context).pop(
                              LocationPickerResult(
                                latitude: _selectedLocation!.latitude,
                                longitude: _selectedLocation!.longitude,
                                distanceKm: _distanceKm,
                                address: _addressText,
                              ),
                            );
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
