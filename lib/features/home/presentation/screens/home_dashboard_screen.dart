import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../widgets/community_impact_card.dart';
import '../widgets/donor_callout_banner.dart';
import '../widgets/home_dashboard_app_bar.dart';
import '../widgets/quick_actions_row.dart';
import '../widgets/rescue_feed_card.dart';

// ── Static feed data (replace with Riverpod provider when backend is wired) ──
final _feedItems = <RescueFeedItem>[
  const RescueFeedItem(
    id: 'card-1',
    imageUrl:
        'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&auto=format&fit=crop&q=80',
    urgentTag: '4h left',
    urgentColor: AppColors.error,
    title: 'Boulangerie Bakery',
    distanceText: '1.2 km away • An Hai Bac',
    surplusBadge: '🥖 5 kg leftover bread & pastries',
    tagLeft: 'Self-Pickup Only • No Fees',
    tagRight: '3 bags remaining',
    scheduleText: 'Today: 18:00 - 20:30 (QR pickup code)',
  ),
  const RescueFeedItem(
    id: 'card-2',
    imageUrl:
        'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600&auto=format&fit=crop&q=80',
    urgentTag: '7h left',
    urgentColor: AppColors.secondary,
    title: 'Green Garden Organic',
    distanceText: '0.8 km • 10 min walk',
    surplusBadge: '🥗 8 kg organic greens & tomatoes',
    tagLeft: '100% Organic Rescue',
    tagRight: '5 bundles remaining',
    scheduleText: 'Today: 17:00 - 21:00 (Counter 2)',
  ),
  const RescueFeedItem(
    id: 'card-3',
    imageUrl:
        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&auto=format&fit=crop&q=80',
    urgentTag: '2h left',
    urgentColor: AppColors.error,
    title: 'Sunburst Eatery',
    distanceText: '1.8 km away • My Khe Beach',
    surplusBadge: '🍱 14 packaged prepared meals',
    tagLeft: '⚡ Urgent Clearance',
    tagRight: 'Only 4 left',
    scheduleText: 'Ends at: 15:30 sharp (Pickup window)',
  ),
];

const _filters = [
  'All Rescues (24)',
  'Bakery & Bread',
  'Prepared Bento',
  'Fresh Produce',
];

/// Home Dashboard — entry screen shown after successful login.
///
/// Responsibilities:
///   • Render community impact metrics
///   • Expose quick-action shortcuts (Pin Surplus, Food Map, AI Copilot, Scan QR)
///   • Render the nearby rescue food feed with hold/reserve state
///   • Provide bottom navigation
///
/// State is minimal: only filter selection + per-card hold/reserve status.
/// All widgets are imported from features/home/presentation/widgets/.
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

  // ── Reserve action ─────────────────────────────────────────────────────────

  void _handleReserve(String cardId) {
    if (_reservedCards.contains(cardId) || _holdingCards.contains(cardId)) {
      return;
    }
    setState(() => _holdingCards.add(cardId));

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _holdingCards.remove(cardId);
        _reservedCards.add(cardId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Đã giữ chỗ thành công! Mã QR nhận hàng đã lưu vào mục Hồ sơ.',
          ),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  // ── Quick-action data (defined here so context.push is accessible) ─────────

  List<QuickAction> _buildQuickActions() {
    return [
      QuickAction(
        bgColor: AppColors.primaryFixed,
        iconColor: AppColors.onPrimaryFixed,
        icon: Icons.add_location_alt_rounded,
        label: 'Pin Surplus',
        onTap: () => context.push(RoutePaths.createListing),
      ),
      QuickAction(
        bgColor: AppColors.secondaryFixed,
        iconColor: AppColors.onSecondaryFixed,
        icon: Icons.radar_rounded,
        label: 'Food Map',
        onTap: () => context.push(RoutePaths.mapSearch),
      ),
      QuickAction(
        bgColor: AppColors.surfaceHigh,
        iconColor: AppColors.primary,
        icon: Icons.soup_kitchen_rounded,
        label: 'AI Copilot',
        badge: 'New',
        onTap: () => context.push(RoutePaths.recipeCopilot),
      ),
      QuickAction(
        bgColor: AppColors.surfaceLow,
        iconColor: AppColors.onSurface,
        icon: Icons.qr_code_scanner_rounded,
        label: 'Scan QR',
        onTap: () => context.push(RoutePaths.qrScannerPath('active')),
      ),
    ];
  }

  // ── Bottom-nav items ────────────────────────────────────────────────────────

  List<AppBottomNavItem> _buildNavItems() {
    return [
      AppBottomNavItem(
        icon: Icons.eco,
        label: 'Home',
        isActive: true,
        onTap: () {},
      ),
      AppBottomNavItem(
        icon: Icons.near_me_outlined,
        label: 'Food Map',
        onTap: () => context.push(RoutePaths.mapSearch),
      ),
      AppBottomNavItem(
        icon: Icons.add,
        label: '',
        isCenter: true,
        onTap: () => context.push(RoutePaths.createListing),
      ),
      AppBottomNavItem(
        icon: Icons.auto_awesome_outlined,
        label: 'AI Copilot',
        onTap: () => context.push(RoutePaths.recipeCopilot),
      ),
      AppBottomNavItem(
        icon: Icons.person_outline,
        label: 'Profile',
        onTap: () => context.push(RoutePaths.profile),
      ),
    ];
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // ── Scrollable content ──
            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 80, bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Impact metrics
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: CommunityImpactCard(),
                  ),
                  const SizedBox(height: 18),

                  // Quick actions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: QuickActionsRow(actions: _buildQuickActions()),
                  ),
                  const SizedBox(height: 18),

                  // Filter chips
                  FilterChipBar(
                    labels: _filters,
                    selectedIndex: _selectedFilterIndex,
                    onSelected: (i) => setState(() => _selectedFilterIndex = i),
                  ),
                  const SizedBox(height: 18),

                  // Section header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SectionHeader(
                      title: 'Rescue Nearby (< 24h Left)',
                      onSeeAll: () => context.push(RoutePaths.mapSearch),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Feed cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        for (int i = 0; i < _feedItems.length; i++) ...[
                          if (i > 0) const SizedBox(height: 12),
                          RescueFeedCard(
                            item: _feedItems[i],
                            isReserved:
                                _reservedCards.contains(_feedItems[i].id),
                            isHolding: _holdingCards.contains(_feedItems[i].id),
                            onReserve: () => _handleReserve(_feedItems[i].id),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Donor callout
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: DonorCalloutBanner(
                      onPostNow: () => context.push(RoutePaths.createListing),
                    ),
                  ),
                ],
              ),
            ),

            // ── Fixed top app-bar ──
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: HomeDashboardAppBar(
                notificationCount: 2,
                onLocationTap: () => context.push(RoutePaths.mapSearch),
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
                items: _buildNavItems(),
                centerIndex: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
