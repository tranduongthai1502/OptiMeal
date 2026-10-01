import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';

/// Data model for one item in the surplus food rescue feed.
class RescueFeedItem {
  final String id;
  final String imageUrl;
  final String urgentTag;
  final Color urgentColor;
  final String title;
  final String distanceText;
  final String surplusBadge;
  final String tagLeft;
  final String tagRight;
  final String scheduleText;

  const RescueFeedItem({
    required this.id,
    required this.imageUrl,
    required this.urgentTag,
    required this.urgentColor,
    required this.title,
    required this.distanceText,
    required this.surplusBadge,
    required this.tagLeft,
    required this.tagRight,
    required this.scheduleText,
  });
}

/// Feed card for one surplus food listing shown on the Home dashboard.
class RescueFeedCard extends StatelessWidget {
  final RescueFeedItem item;
  final bool isReserved;
  final bool isHolding;
  final VoidCallback onReserve;

  const RescueFeedCard({
    super.key,
    required this.item,
    required this.isReserved,
    required this.isHolding,
    required this.onReserve,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
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
          // ── Top row: thumbnail + text details ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Thumbnail(imageUrl: item.imageUrl, urgentTag: item.urgentTag, urgentColor: item.urgentColor),
              const SizedBox(width: 12),
              Expanded(child: _CardDetails(item: item)),
            ],
          ),
          const SizedBox(height: 10),

          // ── Specs row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.tagLeft,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF005320),
                  ),
                ),
              ),
              Text(
                item.tagRight,
                style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // ── Schedule ──
          Row(
            children: [
              const Icon(Icons.schedule, size: 14, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item.scheduleText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Reserve button ──
          _ReserveButton(
            isReserved: isReserved,
            isHolding: isHolding,
            onPressed: onReserve,
          ),
        ],
      ),
    );
  }
}

// ── Private sub-widgets ────────────────────────────────────────────────────

class _Thumbnail extends StatelessWidget {
  final String imageUrl;
  final String urgentTag;
  final Color urgentColor;

  const _Thumbnail({
    required this.imageUrl,
    required this.urgentTag,
    required this.urgentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
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
              color: AppColors.surfaceLow,
              child: const Icon(Icons.fastfood, size: 36),
            ),
          ),
        ),
        Positioned(
          top: 6,
          left: 6,
          child: UrgentTag(label: urgentTag, color: urgentColor),
        ),
      ],
    );
  }
}

class _CardDetails extends StatelessWidget {
  final RescueFeedItem item;
  const _CardDetails({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.verified, color: AppColors.primary, size: 16),
          ],
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            const Icon(Icons.near_me, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                item.distanceText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceLow,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            item.surplusBadge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReserveButton extends StatelessWidget {
  final bool isReserved;
  final bool isHolding;
  final VoidCallback onPressed;

  const _ReserveButton({
    required this.isReserved,
    required this.isHolding,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isReserved ? AppColors.primaryContainer : AppColors.primary,
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
                  Text('Holding slot...', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              )
            : isReserved
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 18),
                      SizedBox(width: 6),
                      Text('Reserved! QR in Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Reserve (Self-Pickup)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
      ),
    );
  }
}
