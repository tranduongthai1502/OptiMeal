import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../reservation/presentation/providers/reservation_provider.dart';
import '../../domain/entities/food_listing.dart';
import '../providers/listings_provider.dart';

class ListingDetailScreen extends ConsumerWidget {
  final String listingId;

  const ListingDetailScreen({super.key, required this.listingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingAsync = ref.watch(listingDetailProvider(listingId));

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết thực phẩm')),
      body: listingAsync.when(
        loading: () =>
            const AppLoadingIndicator(message: 'Đang tải thông tin...'),
        error: (err, _) => AppErrorView(
          message: err.toString(),
          onRetry: () => ref.refresh(listingDetailProvider(listingId)),
        ),
        data: (listing) => _buildBody(context, ref, listing),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, FoodListing listing) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Carousel / Hero Image
                Container(
                  height: 240,
                  width: double.infinity,
                  color: AppColors.backgroundLight,
                  child: listing.photos.isNotEmpty
                      ? Image.network(
                          listing.photos.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.fastfood,
                            size: 64,
                            color: Colors.grey,
                          ),
                        )
                      : const Icon(
                          Icons.fastfood,
                          size: 64,
                          color: Colors.grey,
                        ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (listing.condition == FoodCondition.free)
                            StatusBadge.free()
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${listing.price?.toInt() ?? 0} đ',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          const Spacer(),
                          StatusBadge.available(),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        listing.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Hạn sử dụng: ${DateTimeUtils.formatDateTime(listing.expiresAt)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryDark,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Mô tả thực phẩm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        listing.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondaryLight,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Self-pickup details box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.directions_walk_rounded,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Thông tin tự đến lấy (Self-pickup)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Text(
                              'Địa điểm: ${listing.addressText}',
                              style: const TextStyle(fontSize: 13, height: 1.4),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Khung giờ nhận: ${DateTimeUtils.formatPickupWindow(listing.pickupWindowStart, listing.pickupWindowEnd)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (listing.allergenTags.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Thành phần có thể gây dị ứng',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: listing.allergenTags
                              .map(
                                (tag) => Chip(
                                  label: Text(
                                    tag,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  backgroundColor: AppColors.backgroundLight,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom Claim action bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                IconButton.outlined(
                  onPressed: () {
                    // Quick Chat with owner
                    context.push(RoutePaths.chatPath('res-${listing.id}'));
                  },
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                    foregroundColor: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: 'Giữ chỗ ngay (20 phút)',
                    icon: Icons.bookmark_add_rounded,
                    onPressed: () async {
                      final resNotifier = ref.read(
                        reservationNotifierProvider.notifier,
                      );
                      final success = await resNotifier.holdReservation(
                        listingId: listing.id,
                        ownerId: listing.ownerId,
                        claimerId: 'current-user-id',
                      );
                      if (context.mounted && success) {
                        final reservation = ref
                            .read(reservationNotifierProvider)
                            .activeReservation;
                        if (reservation != null) {
                          await context.push(
                            RoutePaths.reservationDetailPath(reservation.id),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
