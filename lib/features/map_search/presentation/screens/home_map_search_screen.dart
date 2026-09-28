// ignore_for_file: unused_element, unused_field, unused_local_variable
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';

class HomeMapSearchScreen extends ConsumerStatefulWidget {
  const HomeMapSearchScreen({super.key});

  @override
  ConsumerState<HomeMapSearchScreen> createState() =>
      _HomeMapSearchScreenState();
}

class _HomeMapSearchScreenState extends ConsumerState<HomeMapSearchScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _pulseController;
  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController(
    text: 'Charity kitchens near me',
  );
  final bool _isWalkingMode = true;
  String _selectedRadius = 'Within 5 km';

  final List<Map<String, dynamic>> _categories = [
    {'label': 'All', 'icon': Icons.check},
    {
      'label': 'Charity Kitchens',
      'icon': Icons.volunteer_activism_rounded,
      'color': const Color(0xFFB61722),
    },
    {
      'label': 'Cooked Meals',
      'icon': Icons.lunch_dining_rounded,
      'color': const Color(0xFF855300),
    },
    {
      'label': 'Bakery',
      'icon': Icons.bakery_dining_rounded,
      'color': const Color(0xFFFEA619),
    },
    {
      'label': 'Vegetables',
      'icon': Icons.eco_rounded,
      'color': const Color(0xFF006B2C),
    },
  ];

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

  void _onPinSelected(String pinId) {}

  @override
  Widget build(BuildContext context) {
    // Tailwind Color Tokens
    const bgSurface = Color(0xFFFAF8FF);
    const surfaceLowest = Color(0xFFFFFFFF);
    const surfaceLow = Color(0xFFF2F3FF);
    const primary = Color(0xFF006B2C);
    const primaryFixed = Color(0xFF7FFC97);
    const secondary = Color(0xFF855300);
    const onSurface = Color(0xFF131B2E);
    const onSurfaceVariant = Color(0xFF3E4A3D);

    return Scaffold(
      backgroundColor: bgSurface,
      body: Stack(
        children: [
          // Scrollable Map & Content
          Column(
            children: [
              // Top Safe Area Spacer for Fixed Header
              const SizedBox(height: 104),

              // Interactive Stylized Map View
              Expanded(
                child: Stack(
                  children: [
                    // Interactive Real OpenStreetMap
                    Positioned.fill(
                      child: FlutterMap(
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
                        ],
                      ),
                    ),

                    // Top Floating Controls: Search & Categories
                    Positioned(
                      top: 12,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search bar & Filter button
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: surfaceLowest,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.08,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.search,
                                        color: primary,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller: _searchController,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: onSurface,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          decoration: const InputDecoration(
                                            hintText:
                                                'Search bread, meals, kitchens...',
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ),
                                      ),
                                      if (_searchController.text.isNotEmpty)
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _searchController.clear();
                                            });
                                          },
                                          child: Container(
                                            width: 24,
                                            height: 24,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: surfaceLow,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              size: 14,
                                              color: onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Filter Button with '3' badge
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Material(
                                    color: surfaceLowest,
                                    borderRadius: BorderRadius.circular(12),
                                    elevation: 2,
                                    shadowColor: Colors.black.withValues(
                                      alpha: 0.1,
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        _showFilterBottomSheet(context);
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: const SizedBox(
                                        width: 48,
                                        height: 48,
                                        child: Icon(
                                          Icons.tune,
                                          color: onSurface,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: -4,
                                    right: -4,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: const BoxDecoration(
                                        color: primary,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        '3',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Horizontal Scrolling Category Pills
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(_categories.length, (
                                index,
                              ) {
                                final cat = _categories[index];
                                final isSelected =
                                    _selectedCategoryIndex == index;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Material(
                                    color: isSelected ? primary : surfaceLowest,
                                    borderRadius: BorderRadius.circular(20),
                                    elevation: 1,
                                    shadowColor: Colors.black.withValues(
                                      alpha: 0.08,
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedCategoryIndex = index;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        height: 34,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              cat['icon'] as IconData,
                                              size: 16,
                                              color: isSelected
                                                  ? Colors.white
                                                  : (cat['color'] ?? onSurface)
                                                      as Color,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              cat['label'] as String,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: isSelected
                                                    ? Colors.white
                                                    : onSurface,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Top Right Radius Pill Selector
                    Positioned(
                      top: 116,
                      right: 16,
                      child: Material(
                        color: surfaceLowest.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(20),
                        elevation: 2,
                        shadowColor: Colors.black.withValues(alpha: 0.1),
                        child: InkWell(
                          onTap: () {
                            _showRadiusSelector(context);
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.radar,
                                  color: primary,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _selectedRadius,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: onSurface,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(
                                  Icons.expand_more,
                                  color: onSurfaceVariant,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),

              // BOTTOM PEEK SHEET / PIN PREVIEW CARD
              _buildBottomPeekSheet(context),

              // Space for bottom nav bar
              const SizedBox(height: 64),
            ],
          ),

          // Fixed Top Header (Status bar + Logo + Location + Profile)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildFixedHeader(context),
          ),

          // Fixed Bottom Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNavigationBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedHeader(BuildContext context) {
    const bgSurface = Color(0xFFFAF8FF);
    const onSurface = Color(0xFF131B2E);
    const onSurfaceVariant = Color(0xFF3E4A3D);
    const primary = Color(0xFF006B2C);
    const tertiaryContainer = Color(0xFFDA3437);

    return Container(
      decoration: BoxDecoration(
        color: bgSurface.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Status bar info row
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '9:41',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: onSurface,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.signal_cellular_alt,
                        size: 16,
                        color: onSurface,
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.wifi, size: 16, color: onSurface),
                      SizedBox(width: 4),
                      Icon(Icons.battery_full, size: 18, color: onSurface),
                    ],
                  ),
                ],
              ),
            ),
            // Header main bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 32,
                        errorBuilder: (context, error, stackTrace) {
                          return const Row(
                            children: [
                              Icon(Icons.eco_rounded, color: primary, size: 26),
                              SizedBox(width: 4),
                              Text(
                                'OptiMeal',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primary,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Khu vực hiện tại: Hải Châu, Đà Nẵng, Việt Nam',
                              ),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: primary,
                                size: 18,
                              ),
                              SizedBox(width: 4),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pickup Location',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Da Nang, Vietnam',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 16,
                                color: onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_none,
                              color: onSurface,
                            ),
                            onPressed: () {},
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: tertiaryContainer,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: const Text(
                                '2',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => context.push(RoutePaths.profile),
                        child: const CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFFDAE2FD),
                          child: Icon(
                            Icons.person,
                            size: 18,
                            color: Color(0xFF006B2C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPin({
    required String id,
    required String label,
    required IconData icon,
    required Color pinColor,
    required Color ringColor,
    bool isPulsing = false,
  }) {
    return GestureDetector(
      onTap: () => _onPinSelected(id),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPulsing) ...[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: pinColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF131B2E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          // Circular Pin Body
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: pinColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: ringColor.withValues(alpha: 0.5),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: pinColor.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          // Pin Tip Triangle
          Transform.rotate(
            angle: math.pi / 4,
            child: Container(width: 8, height: 8, color: pinColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedCharityPin() {
    const primary = Color(0xFF006B2C);
    const primaryFixed = Color(0xFF7FFC97);

    return GestureDetector(
      onTap: () => _onPinSelected('phuoc_thien'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Label Pill with Verified Icon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.volunteer_activism_rounded,
                  color: primary,
                  size: 14,
                ),
                SizedBox(width: 4),
                Text(
                  'Phuoc Thien Charity • 60 left',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          // Pulsing Glow Ring + Pin
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 44 + (_pulseController.value * 14),
                    height: 44 + (_pulseController.value * 14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primary.withValues(
                        alpha: 0.25 * (1 - _pulseController.value),
                      ),
                    ),
                  );
                },
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryFixed, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.soup_kitchen_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          // Tip
          Transform.rotate(
            angle: math.pi / 4,
            child: Container(width: 10, height: 10, color: primary),
          ),
        ],
      ),
    );
  }

  Widget _buildClusterPin(String count, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        count,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildUserLocationBeacon() {
    const primary = Color(0xFF006B2C);

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Radar pulse ring
            Container(
              width: 36 + (_pulseController.value * 24),
              height: 36 + (_pulseController.value * 24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withValues(
                  alpha: 0.2 * (1 - _pulseController.value),
                ),
              ),
            ),
            // User Dot
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFloatingMapButton({
    required IconData icon,
    required Color iconColor,
    Color backgroundColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: iconColor, size: 22),
        ),
      ),
    );
  }

  Widget _buildBottomPeekSheet(BuildContext context) {
    const surfaceLowest = Color(0xFFFFFFFF);
    const surfaceLow = Color(0xFFF2F3FF);
    const surfaceHighest = Color(0xFFDAE2FD);
    const primary = Color(0xFF006B2C);
    const onSurface = Color(0xFF131B2E);
    const onSurfaceVariant = Color(0xFF3E4A3D);
    const secondary = Color(0xFF855300);

    return Container(
      decoration: BoxDecoration(
        color: surfaceLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFBDCABA).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Charity Badge & Proximity row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, size: 13, color: primary),
                        SizedBox(width: 4),
                        Text(
                          'Verified Charity Kitchen',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Row(
                    children: [
                      Icon(Icons.star, size: 13, color: secondary),
                      SizedBox(width: 2),
                      Text(
                        '4.9',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: secondary,
                        ),
                      ),
                      Text(
                        ' (142 rescues)',
                        style: TextStyle(fontSize: 11, color: onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
              // Live ETA & Distance Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAEDFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.directions_walk, size: 15, color: primary),
                    SizedBox(width: 4),
                    Text(
                      '850m • 10 min',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Kitchen Title & Address & Thumbnail
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phuoc Thien Charity Kitchen',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: onSurface,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 15,
                          color: Color(0xFF6E7B6C),
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '128 Nguyen Tri Phuong, Hai Chau, Da Nang',
                            style: TextStyle(
                              fontSize: 13,
                              color: onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 56,
                  height: 56,
                  color: const Color(0xFFE2E7FF),
                  child: const Icon(
                    Icons.soup_kitchen_rounded,
                    size: 32,
                    color: primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Urgency & Portion Availability Stats Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: surfaceLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Serving hot lunch (11:00 - 13:00)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: onSurface,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEA619).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 13,
                            color: Color(0xFF684000),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '45m left',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF684000),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Portions Available',
                      style: TextStyle(fontSize: 11, color: onSurfaceVariant),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '60',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                          TextSpan(
                            text: ' / 100 meals left',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Progress Bar (60%)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    value: 0.6,
                    backgroundColor: surfaceHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(primary),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Primary Action CTA Row
          Row(
            children: [
              // Share button
              Material(
                color: const Color(0xFFEAEDFF),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Đã sao chép liên kết chia sẻ điểm cứu trợ!',
                        ),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(Icons.share, color: onSurface, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Reserve Meal & Route Button
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      _showReserveConfirmation(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Reserve Meal & Route',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    const bgSurface = Color(0xFFFAF8FF);
    const primary = Color(0xFF006B2C);
    const primaryContainer = Color(0xFF00873A);

    return Container(
      decoration: BoxDecoration(
        color: bgSurface.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Icons.eco_rounded,
                    label: 'Home',
                    isActive: false,
                    onTap: () => context.go(RoutePaths.home),
                  ),
                  _buildNavItem(
                    icon: Icons.near_me_rounded,
                    label: 'Food Map',
                    isActive: true,
                    onTap: () {},
                  ),
                  // Center Add Listing FAB
                  Transform.translate(
                    offset: const Offset(0, -10),
                    child: GestureDetector(
                      onTap: () => context.push(RoutePaths.createListing),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryContainer.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  _buildNavItem(
                    icon: Icons.auto_awesome_rounded,
                    label: 'AI Copilot',
                    isActive: false,
                    onTap: () => context.go(RoutePaths.recipeCopilot),
                  ),
                  _buildNavItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Profile',
                    isActive: false,
                    onTap: () => context.push(RoutePaths.profile),
                  ),
                ],
              ),
            ),
            // Home indicator pill
            Container(
              width: 120,
              height: 4,
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    const primary = Color(0xFF006B2C);
    const onSurfaceVariant = Color(0xFF3E4A3D);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: isActive ? primary : onSurfaceVariant),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? primary : onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
                activeColor: const Color(0xFF006B2C),
              ),
              CheckboxListTile(
                title: const Text('Cửa hàng & Siêu thị dư thừa (Surplus)'),
                value: true,
                onChanged: (_) {},
                activeColor: const Color(0xFF006B2C),
              ),
              CheckboxListTile(
                title: const Text('Ưu tiên thực phẩm cận date (< 6h)'),
                value: true,
                onChanged: (_) {},
                activeColor: const Color(0xFF006B2C),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006B2C),
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
      },
    );
  }

  void _showRadiusSelector(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final options = [
          'Within 1 km',
          'Within 3 km',
          'Within 5 km',
          'Within 10 km',
        ];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((opt) {
              return ListTile(
                title: Text(
                  opt,
                  style: TextStyle(
                    fontWeight: _selectedRadius == opt
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                trailing: _selectedRadius == opt
                    ? const Icon(Icons.check, color: Color(0xFF006B2C))
                    : null,
                onTap: () {
                  setState(() {
                    _selectedRadius = opt;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showReserveConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF006B2C),
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
            'Bạn đã giữ 1 suất ăn trưa tại Bếp ăn Từ thiện Phước Thiện.\n\nMã QR nhận thức ăn đã được lưu vào mục Hồ sơ. Lộ trình đi bộ (850m • 10 phút) đã sẵn sàng!',
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006B2C),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                context.push(RoutePaths.profile);
              },
              child: const Text('Xem Mã QR'),
            ),
          ],
        );
      },
    );
  }
}
