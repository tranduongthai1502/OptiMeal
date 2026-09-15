import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/food_listing.dart';

class ListingCard extends StatelessWidget {
  final FoodListing listing;
  final VoidCallback onTap;

  const ListingCard({super.key, required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = listing.photos.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image header with badges
            Stack(
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  color: AppColors.backgroundLight,
                  child: hasPhoto
                      ? Image.network(
                          listing.photos.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.fastfood,
                            size: 48,
                            color: Colors.grey,
                          ),
                        )
                      : const Icon(
                          Icons.fastfood,
                          size: 48,
                          color: Colors.grey,
                        ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: listing.condition == FoodCondition.free
                      ? StatusBadge.free()
                      : Container(
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
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time_filled_rounded,
                          color: Colors.amber,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Còn ${listing.remainingTime.inHours}h',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Content body
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        listing.ownerType.isStore
                            ? Icons.storefront_rounded
                            : Icons.person_rounded,
                        size: 15,
                        color: AppColors.textSecondaryLight,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          listing.ownerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                      Text(
                        'Số lượng: ${listing.quantity}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        size: 15,
                        color: AppColors.textSecondaryLight,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          listing.addressText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 15,
                        color: AppColors.textSecondaryLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Giờ lấy: ${DateTimeUtils.formatTime(listing.pickupWindowStart)} - ${DateTimeUtils.formatTime(listing.pickupWindowEnd)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
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
}
