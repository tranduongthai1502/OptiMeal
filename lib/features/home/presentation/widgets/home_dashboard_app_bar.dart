import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Sticky top app-bar for the Home dashboard.
/// Shows the brand logo, location selector, notification badge, and avatar.
class HomeDashboardAppBar extends StatelessWidget {
  final String locationLabel;
  final int notificationCount;
  final VoidCallback onLocationTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;

  const HomeDashboardAppBar({
    super.key,
    this.locationLabel = 'Da Nang, Vietnam',
    this.notificationCount = 0,
    required this.onLocationTap,
    required this.onNotificationTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgSurface.withValues(alpha: 0.95),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Brand logo (falls back to icon+text)
          Image.asset(
            'assets/images/logo.png',
            height: 38,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Row(
              children: [
                Icon(Icons.eco, color: AppColors.primary, size: 28),
                SizedBox(width: 4),
                Text(
                  'OptiMeal',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Location selector
          Expanded(
            child: InkWell(
              onTap: onLocationTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Pickup Location',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            locationLabel,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Notification bell + Profile avatar
          Row(
            children: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.onSurfaceVariant,
                    ),
                    onPressed: onNotificationTap,
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.notificationBadge,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$notificationCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              InkWell(
                onTap: onProfileTap,
                borderRadius: BorderRadius.circular(20),
                child: const CircleAvatar(
                  radius: 17,
                  backgroundColor: AppColors.surfaceHigh,
                  child: Icon(
                    Icons.person,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
