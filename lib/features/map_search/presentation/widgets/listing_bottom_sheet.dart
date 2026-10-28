import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/location_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../listings/domain/entities/food_listing.dart';
import '../../../listings/presentation/providers/listings_provider.dart';
import '../providers/location_provider.dart';
import '../providers/routing_provider.dart';

/// Bottom sheet hiện khi bấm marker món ăn trên bản đồ.
///
/// Chức năng:
/// - Hiển thị ảnh, tên, mô tả, khoảng cách ước tính, thời hạn, danh mục.
/// - Nút "Nhận đơn" — Firestore transaction, an toàn khi nhiều người cùng nhận.
/// - Nút "Xem đường đi" — đặt routeTargetProvider → map vẽ polyline ORS.
/// - Nút "Mở app bản đồ" — url_launcher với link Google Maps (không tốn phí API).
class ListingBottomSheet extends ConsumerStatefulWidget {
  final FoodListing listing;

  const ListingBottomSheet({super.key, required this.listing});

  @override
  ConsumerState<ListingBottomSheet> createState() =>
      _ListingBottomSheetState();
}

class _ListingBottomSheetState extends ConsumerState<ListingBottomSheet> {
  bool _isClaiming = false;

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _distanceLabel() {
    final pos = ref.read(locationProvider).position;
    if (pos == null) return '?';
    final km = LocationUtils.calculateDistanceKm(
      pos.latitude,
      pos.longitude,
      widget.listing.latitude,
      widget.listing.longitude,
    );
    return LocationUtils.formatDistance(km);
  }

  String _timeLeftLabel() {
    final remaining = widget.listing.remainingTime;
    if (remaining <= Duration.zero) return 'Đã hết hạn';
    if (remaining.inHours >= 24) return '${remaining.inDays} ngày';
    if (remaining.inHours >= 1) {
      return '${remaining.inHours}h ${remaining.inMinutes.remainder(60)}phút';
    }
    return '${remaining.inMinutes} phút';
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _handleClaim() async {
    final user = ref.read(authStateProvider).user;
    if (user == null) {
      _showSnack('Vui lòng đăng nhập để nhận đơn.', isError: true);
      return;
    }

    setState(() => _isClaiming = true);

    final claimFn = ref.read(claimListingProvider);
    final result = await claimFn(widget.listing.id, user.id);

    if (!mounted) return;
    setState(() => _isClaiming = false);

    result.fold(
      (failure) => _showSnack(failure.message, isError: true),
      (success) {
        if (success) {
          _showSnack('Nhận đơn thành công! Hãy đến lấy trước hạn.');
          Navigator.of(context).pop();
        } else {
          _showSnack(
            'Đơn này vừa được người khác nhận mất rồi. Tìm đơn khác nhé!',
            isError: true,
          );
          Navigator.of(context).pop();
        }
      },
    );
  }

  void _handleShowRoute() {
    final pos = ref.read(locationProvider).position;
    if (pos == null) {
      _showSnack(
        'Chưa lấy được vị trí GPS. Bật GPS rồi thử lại.',
        isError: true,
      );
      return;
    }
    // Đặt target → map_screen sẽ watch và vẽ polyline
    ref.read(routeTargetProvider.notifier).state = LatLng(
      widget.listing.latitude,
      widget.listing.longitude,
    );
    Navigator.of(context).pop();
  }

  /// Mở Google Maps bằng link (không phải Maps SDK, không tốn phí).
  Future<void> _handleOpenInMaps() async {
    final lat = widget.listing.latitude;
    final lng = widget.listing.longitude;
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=$lat,$lng'
      '&travelmode=driving',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        _showSnack('Không mở được ứng dụng bản đồ.', isError: true);
      }
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    final isExpired = !listing.isStillValid;
    final distLabel = _distanceLabel();
    final timeLabel = _timeLeftLabel();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.borderLight.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Ảnh + tiêu đề ─────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: listing.photos.isNotEmpty
                    ? Image.network(
                        listing.photos.first,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _PlaceholderImage(category: listing.category),
                      )
                    : _PlaceholderImage(category: listing.category),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.ownerName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Chips thông tin
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _InfoChip(
                          icon: Icons.near_me_rounded,
                          label: distLabel,
                          color: AppColors.info,
                        ),
                        _InfoChip(
                          icon: Icons.timer_outlined,
                          label: timeLabel,
                          color: isExpired
                              ? AppColors.statusExpired
                              : listing.isExpiringSoon
                                  ? AppColors.warning
                                  : AppColors.statusAvailable,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Mô tả ──────────────────────────────────────────────────────────
          if (listing.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              listing.description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // ── Metadata chips ─────────────────────────────────────────────────
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _InfoChip(
                icon: Icons.inventory_2_outlined,
                label: '${listing.quantity} ${listing.unit}',
                color: AppColors.secondary,
              ),
              _InfoChip(
                icon: Icons.category_outlined,
                label: listing.category.displayName,
                color: AppColors.primaryContainer,
              ),
              if (listing.condition.isFree)
                const _InfoChip(
                  icon: Icons.volunteer_activism_rounded,
                  label: 'Miễn phí',
                  color: AppColors.statusAvailable,
                ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 16),

          // ── Hành động ─────────────────────────────────────────────────────
          if (isExpired)
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.statusExpired.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Đơn này đã hết hạn hoặc đã được nhận.',
                style: TextStyle(color: AppColors.statusExpired),
              ),
            )
          else ...[
            // Nút Nhận đơn
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isClaiming ? null : _handleClaim,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _isClaiming
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline, size: 18),
                label: Text(
                  _isClaiming ? 'Đang xử lý...' : 'Nhận đơn',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Hàng nút phụ
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: _handleShowRoute,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.directions_rounded, size: 16),
                      label: const Text(
                        'Xem đường đi',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: _handleOpenInMaps,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.onSurface,
                      side: const BorderSide(color: AppColors.borderLight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.open_in_new, size: 14),
                    label: const Text(
                      'App bản đồ',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Private helpers ──────────────────────────────────────────────────────────

class _PlaceholderImage extends StatelessWidget {
  final FoodCategory category;
  const _PlaceholderImage({required this.category});

  @override
  Widget build(BuildContext context) {
    final icon = switch (category) {
      FoodCategory.vegetables => Icons.eco_rounded,
      FoodCategory.dryGoods => Icons.inventory_2_rounded,
      FoodCategory.freshMeatFish => Icons.set_meal_rounded,
      FoodCategory.cookedMeals => Icons.lunch_dining_rounded,
      FoodCategory.charityMealPoint => Icons.volunteer_activism_rounded,
    };
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColors.primary, size: 32),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

