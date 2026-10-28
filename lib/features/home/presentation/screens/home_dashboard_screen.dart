import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../listings/presentation/providers/listings_provider.dart';
import '../../../listings/presentation/widgets/listing_card.dart';
import '../widgets/donor_callout_banner.dart';
import '../widgets/home_dashboard_app_bar.dart';
import '../widgets/quick_actions_row.dart';

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
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final user = ref.watch(authStateProvider).user;
    final locationLabel = user != null
        ? (user.displayName != null && user.displayName!.isNotEmpty
            ? user.displayName
            : (user.phoneNumber.isNotEmpty ? user.phoneNumber : 'Đã đăng nhập'))
        : 'Chưa đăng nhập';

    return Scaffold(
      backgroundColor: AppColors.bgSurface,
      // ── Bottom nav ghim cứng — Scaffold tự tính safe-area ──
      bottomNavigationBar: AppBottomNavBar(
        items: _buildNavItems(),
        centerIndex: 2,
      ),
      body: Stack(
        children: [
          // ── Scrollable content với kéo để làm mới (Pull to refresh) ──
          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(nearbyListingsProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              // top: chỗ cho app bar (~58 + safe area top)
              // bottom: chỗ cho bottom nav (70) + device safe area
              padding: EdgeInsets.only(
                top: 72,
                bottom: 70 + bottomInset + 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Quick actions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: QuickActionsRow(actions: _buildQuickActions()),
                  ),
                  const SizedBox(height: 18),

                  // Section header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SectionHeader(
                      title: 'Tin thực phẩm đang có',
                      onSeeAll: () => context.push(RoutePaths.mapSearch),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ref.watch(nearbyListingsProvider).when(
                          loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          error: (error, _) => Text(
                            'Không tải được tin thực phẩm: $error',
                            style: const TextStyle(color: AppColors.error),
                          ),
                          data: (listings) {
                            if (listings.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24.0),
                                child: Text(
                                  'Chưa có tin thực phẩm nào được ghim. Bạn hãy là người đầu tiên ghim thực phẩm nhé!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                              );
                            }
                            return Column(
                              children: [
                                for (final listing in listings)
                                  ListingCard(
                                    listing: listing,
                                    onTap: () => context.push(
                                      RoutePaths.listingDetailPath(listing.id),
                                    ),
                                  ),
                              ],
                            );
                          },
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
          ),

          // ── Fixed top app-bar (overlay trên scroll content) ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: HomeDashboardAppBar(
                locationLabel: locationLabel,
                onLocationTap: () => context.push(RoutePaths.mapSearch),
                onProfileTap: () => context.push(RoutePaths.profile),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
