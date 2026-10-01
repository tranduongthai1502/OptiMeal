import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Community-impact metrics card shown at the top of the Home dashboard.
class CommunityImpactCard extends StatelessWidget {
  final String city;
  final int rescuedKg;
  final int activeKitchens;
  final int co2PreventedKg;

  const CommunityImpactCard({
    super.key,
    this.city = 'Da Nang',
    this.rescuedKg = 320,
    this.activeKitchens = 12,
    this.co2PreventedKg = 780,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
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
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.eco, color: AppColors.primary, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'COMMUNITY IMPACT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              _LiveBadge(city: city),
            ],
          ),
          const SizedBox(height: 12),

          // Metrics row
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  icon: Icons.psychology_alt_rounded,
                  label: 'Rescued Today',
                  value: '$rescuedKg',
                  unit: 'kg',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricTile(
                  icon: Icons.volunteer_activism_rounded,
                  iconColor: const Color(0xFF855300),
                  label: 'Active Kitchens',
                  value: '$activeKitchens',
                  unit: 'hubs',
                  valueColor: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // CO2 bar
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.eco_outlined,
                  color: AppColors.primaryFixed,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '$co2PreventedKg kg CO₂ emissions prevented',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Icon(
                  Icons.trending_up,
                  color: Colors.white70,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  final String city;
  const _LiveBadge({required this.city});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryFixed.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 3.5,
            backgroundColor: AppColors.primary,
          ),
          const SizedBox(width: 5),
          Text(
            'Live $city',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String unit;
  final Color valueColor;

  const _MetricTile({
    required this.icon,
    this.iconColor = AppColors.primary,
    required this.label,
    required this.value,
    required this.unit,
    this.valueColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: valueColor,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
