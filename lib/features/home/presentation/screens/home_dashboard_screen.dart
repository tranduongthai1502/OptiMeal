import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_paths.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() =>
      _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  int _selectedFilterIndex = 0;
  final Set<String> _reservedCards = {};
  final Set<String> _holdingCards = {};

  final List<String> _filters = [
    'All Rescues (24)',
    'Bakery & Bread',
    'Prepared Bento',
    'Fresh Produce',
  ];

  void _handleReserve(String cardId) {
    if (_reservedCards.contains(cardId) || _holdingCards.contains(cardId)) return;

    setState(() {
      _holdingCards.add(cardId);
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _holdingCards.remove(cardId);
          _reservedCards.add(cardId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã giữ chỗ thành công! Mã QR nhận hàng đã lưu vào mục Hồ sơ.'),
            backgroundColor: Color(0xFF006B2C),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Exact Tailwind Colors from Figma exported HTML
    const bgSurface = Color(0xFFFAF8FF);
    const surfaceLowest = Color(0xFFFFFFFF);
    const surfaceLow = Color(0xFFF2F3FF);
    const surfaceHigh = Color(0xFFE2E7FF);
    const primary = Color(0xFF006B2C);
    const primaryContainer = Color(0xFF00873A);
    const primaryFixed = Color(0xFF7FFC97);
    const onPrimaryFixed = Color(0xFF002109);
    const secondaryFixed = Color(0xFFFFDDB8);
    const onSecondaryFixed = Color(0xFF2A1700);
    const secondaryContainer = Color(0xFFFEA619);
    const onSecondaryContainer = Color(0xFF684000);
    const onSurface = Color(0xFF131B2E);
    const onSurfaceVariant = Color(0xFF3E4A3D);
    const errorColor = Color(0xFFBA1A1A);

    return Scaffold(
      backgroundColor: bgSurface,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Main scrollable content
            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 80, bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Community Food Rescue Impact Hero Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surfaceLowest,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.eco, color: primary, size: 20),
                                  SizedBox(width: 6),
                                  Text(
                                    'COMMUNITY IMPACT',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                      color: onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: primaryFixed.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  children: [
                                    CircleAvatar(
                                        radius: 3.5, backgroundColor: primary),
                                    SizedBox(width: 5),
                                    Text(
                                      'Live Da Nang',
                                      style: TextStyle(
                                        color: primary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // 2 Metrics Grid
                          Row(
                            children: [
                              // Metric 1
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: surfaceLow.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.psychology_alt_rounded,
                                              size: 16, color: primary),
                                          SizedBox(width: 4),
                                          Text(
                                            'Rescued Today',
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: onSurfaceVariant),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 6),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text(
                                            '320',
                                            style: TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.w800,
                                              color: primary,
                                              height: 1.0,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'kg',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: onSurfaceVariant),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Metric 2
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: surfaceLow.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.volunteer_activism_rounded,
                                              size: 16, color: Color(0xFF855300)),
                                          SizedBox(width: 4),
                                          Text(
                                            'Active Kitchens',
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: onSurfaceVariant),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 6),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text(
                                            '12',
                                            style: TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.w800,
                                              color: onSurface,
                                              height: 1.0,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'hubs',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: onSurfaceVariant),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // CO2 Reduction Callout
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.eco_outlined,
                                    color: primaryFixed, size: 18),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '780 kg CO₂ emissions prevented',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Icon(Icons.trending_up,
                                    color: Colors.white70, size: 18),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Quick Action Hub (4 Circular Buttons)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildQuickActionCircle(
                          bgColor: primaryFixed,
                          iconColor: onPrimaryFixed,
                          icon: Icons.add_location_alt_rounded,
                          label: 'Pin Surplus',
                          onTap: () => context.push(RoutePaths.createListing),
                        ),
                        _buildQuickActionCircle(
                          bgColor: secondaryFixed,
                          iconColor: onSecondaryFixed,
                          icon: Icons.radar_rounded,
                          label: 'Food Map',
                          onTap: () => context.push(RoutePaths.mapSearch),
                        ),
                        _buildQuickActionCircle(
                          bgColor: surfaceHigh,
                          iconColor: primary,
                          icon: Icons.soup_kitchen_rounded,
                          label: 'AI Copilot',
                          badge: 'New',
                          onTap: () => context.push('/recipe-copilot'),
                        ),
                        _buildQuickActionCircle(
                          bgColor: surfaceLow,
                          iconColor: onSurface,
                          icon: Icons.qr_code_scanner_rounded,
                          label: 'Scan QR',
                          onTap: () => context.push(RoutePaths.qrScannerPath('active')),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Active Filter Microchips
                  SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filters.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedFilterIndex == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedFilterIndex = index;
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? onSurface : surfaceLowest,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  _filters[index],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? bgSurface : onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Section Header: Urgent Nearby Rescues
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            CircleAvatar(radius: 4, backgroundColor: secondaryContainer),
                            SizedBox(width: 8),
                            Text(
                              'Rescue Nearby (< 24h Left)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: onSurface,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () => context.push(RoutePaths.mapSearch),
                          child: const Row(
                            children: [
                              Text(
                                'See all',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: primary,
                                ),
                              ),
                              Icon(Icons.chevron_right, size: 16, color: primary),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Feed Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        // Card 1
                        _buildRescueFeedCard(
                          cardId: 'card-1',
                          imageUrl:
                              'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&auto=format&fit=crop&q=80',
                          urgentTag: '4h left',
                          urgentColor: errorColor,
                          title: 'Boulangerie Bakery',
                          distanceText: '1.2 km away • An Hai Bac',
                          surplusBadge: '🥖 5 kg leftover bread & pastries',
                          tagLeft: 'Self-Pickup Only • No Fees',
                          tagRight: '3 bags remaining',
                          scheduleText: 'Today: 18:00 - 20:30 (QR pickup code)',
                        ),
                        const SizedBox(height: 12),

                        // Card 2
                        _buildRescueFeedCard(
                          cardId: 'card-2',
                          imageUrl:
                              'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600&auto=format&fit=crop&q=80',
                          urgentTag: '7h left',
                          urgentColor: const Color(0xFF855300),
                          title: 'Green Garden Organic',
                          distanceText: '0.8 km • 10 min walk',
                          surplusBadge: '🥗 8 kg organic greens & tomatoes',
                          tagLeft: '100% Organic Rescue',
                          tagRight: '5 bundles remaining',
                          scheduleText: 'Today: 17:00 - 21:00 (Counter 2)',
                        ),
                        const SizedBox(height: 12),

                        // Card 3
                        _buildRescueFeedCard(
                          cardId: 'card-3',
                          imageUrl:
                              'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&auto=format&fit=crop&q=80',
                          urgentTag: '2h left',
                          urgentColor: errorColor,
                          title: 'Sunburst Eatery',
                          distanceText: '1.8 km away • My Khe Beach',
                          surplusBadge: '🍱 14 packaged prepared meals',
                          tagLeft: '⚡ Urgent Clearance',
                          tagRight: 'Only 4 left',
                          scheduleText: 'Ends at: 15:30 sharp (Pickup window)',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Community Donor Banner
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: surfaceHigh.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: const BoxDecoration(
                              color: primaryFixed,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.store_rounded,
                                color: onPrimaryFixed, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Have leftover food?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: onSurface,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'List surplus in 45 seconds & feed locals',
                                  style: TextStyle(
                                      fontSize: 12, color: onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => context.push(RoutePaths.createListing),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: surfaceLowest,
                              foregroundColor: primary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Post Now',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Top Fixed Header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: bgSurface.withValues(alpha: 0.95),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    // Brand Logo
                    Image.asset(
                      'assets/images/logo.png',
                      height: 38,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Row(
                        children: [
                          Icon(Icons.eco, color: primary, size: 28),
                          SizedBox(width: 4),
                          Text('OptiMeal',
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: primary)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Location dropdown
                    Expanded(
                      child: InkWell(
                        onTap: () => context.push(RoutePaths.mapSearch),
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_on, color: primary, size: 20),
                              SizedBox(width: 4),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Pickup Location',
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: onSurfaceVariant),
                                    ),
                                    Text(
                                      'Da Nang, Vietnam',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: onSurface),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.keyboard_arrow_down,
                                  size: 18, color: onSurfaceVariant),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Notification & Profile
                    Row(
                      children: [
                        Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined,
                                  color: onSurfaceVariant),
                              onPressed: () {},
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFDA3437),
                                  shape: BoxShape.circle,
                                ),
                                child: const Text(
                                  '2',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () => context.push(RoutePaths.profile),
                          borderRadius: BorderRadius.circular(20),
                          child: const CircleAvatar(
                            radius: 17,
                            backgroundColor: surfaceHigh,
                            child: Icon(Icons.person, size: 20, color: primary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar with Center Floating Button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: bgSurface.withValues(alpha: 0.96),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      icon: Icons.eco,
                      label: 'Home',
                      isActive: true,
                      onTap: () {},
                    ),
                    _buildNavItem(
                      icon: Icons.near_me_outlined,
                      label: 'Food Map',
                      isActive: false,
                      onTap: () => context.push(RoutePaths.mapSearch),
                    ),

                    // Elevated Center Add Button
                    GestureDetector(
                      onTap: () => context.push(RoutePaths.createListing),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 28),
                      ),
                    ),

                    _buildNavItem(
                      icon: Icons.auto_awesome_outlined,
                      label: 'AI Copilot',
                      isActive: false,
                      onTap: () => context.push('/recipe-copilot'),
                    ),
                    _buildNavItem(
                      icon: Icons.person_outline,
                      label: 'Profile',
                      isActive: false,
                      onTap: () => context.push(RoutePaths.profile),
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

  Widget _buildQuickActionCircle({
    required Color bgColor,
    required Color iconColor,
    required IconData icon,
    required String label,
    String? badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              if (badge != null)
                Positioned(
                  top: -3,
                  right: -3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEA619),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF684000),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF131B2E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRescueFeedCard({
    required String cardId,
    required String imageUrl,
    required String urgentTag,
    required Color urgentColor,
    required String title,
    required String distanceText,
    required String surplusBadge,
    required String tagLeft,
    required String tagRight,
    required String scheduleText,
  }) {
    const primary = Color(0xFF006B2C);
    const primaryFixed = Color(0xFF7FFC97);
    const surfaceLowest = Color(0xFFFFFFFF);
    const surfaceLow = Color(0xFFF2F3FF);
    const onSurface = Color(0xFF131B2E);
    const onSurfaceVariant = Color(0xFF3E4A3D);

    final isReserved = _reservedCards.contains(cardId);
    final isHolding = _holdingCards.contains(cardId);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail with Urgent Tag
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 90,
                        height: 90,
                        color: surfaceLow,
                        child: const Icon(Icons.fastfood, size: 36),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: urgentColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(radius: 2.5, backgroundColor: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            urgentTag,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Card details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, color: primary, size: 16),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.near_me, size: 14, color: primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            distanceText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Surplus details badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: surfaceLow,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        surplusBadge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Specs row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: primaryFixed.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tagLeft,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF005320),
                  ),
                ),
              ),
              Text(
                tagRight,
                style: const TextStyle(
                  fontSize: 11,
                  color: onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Schedule line
          Row(
            children: [
              const Icon(Icons.schedule, size: 14, color: onSurfaceVariant),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  scheduleText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Reserve CTA Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () => _handleReserve(cardId),
              style: ElevatedButton.styleFrom(
                backgroundColor: isReserved
                    ? const Color(0xFF00873A)
                    : primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isHolding
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Holding slot...',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    )
                  : isReserved
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, size: 18),
                            SizedBox(width: 6),
                            Text('Reserved! QR in Profile',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Reserve (Self-Pickup)',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
            ),
          ),
        ],
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive ? primary : onSurfaceVariant,
            ),
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
}
