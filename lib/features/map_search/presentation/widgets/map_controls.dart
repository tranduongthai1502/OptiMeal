import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Category pill model for the horizontal category filter on the map.
class MapCategory {
  final String label;
  final IconData icon;
  final Color? color;

  const MapCategory({
    required this.label,
    required this.icon,
    this.color,
  });
}

/// Default categories for the food map.
const kDefaultMapCategories = <MapCategory>[
  MapCategory(label: 'All', icon: Icons.check),
  MapCategory(
    label: 'Charity Kitchens',
    icon: Icons.volunteer_activism_rounded,
    color: Color(0xFFB61722),
  ),
  MapCategory(
    label: 'Cooked Meals',
    icon: Icons.lunch_dining_rounded,
    color: AppColors.secondary,
  ),
  MapCategory(
    label: 'Bakery',
    icon: Icons.bakery_dining_rounded,
    color: AppColors.secondaryContainer,
  ),
  MapCategory(
    label: 'Vegetables',
    icon: Icons.eco_rounded,
    color: AppColors.primary,
  ),
];

/// Floating search bar + filter button used on the map screen.
class MapSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final int activeFilterCount;
  final VoidCallback onFilterTap;

  const MapSearchBar({
    super.key,
    required this.controller,
    required this.activeFilterCount,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceLowest,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurface,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Search bread, meals, kitchens...',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (controller.text.isNotEmpty)
                  GestureDetector(
                    onTap: controller.clear,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceLow,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Filter button with badge
        Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: AppColors.surfaceLowest,
              borderRadius: BorderRadius.circular(12),
              elevation: 2,
              shadowColor: Colors.black.withValues(alpha: 0.1),
              child: InkWell(
                onTap: onFilterTap,
                borderRadius: BorderRadius.circular(12),
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(Icons.tune, color: AppColors.onSurface, size: 22),
                ),
              ),
            ),
            if (activeFilterCount > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$activeFilterCount',
                    style: const TextStyle(
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
    );
  }
}

/// Horizontal scrolling category pills for the map screen.
class MapCategoryPills extends StatelessWidget {
  final List<MapCategory> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const MapCategoryPills({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < categories.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _CategoryPill(
                category: categories[i],
                isSelected: selectedIndex == i,
                onTap: () => onSelected(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final MapCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.onSurface : AppColors.surfaceLowest,
      borderRadius: BorderRadius.circular(20),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                category.icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : (category.color ?? AppColors.onSurface),
              ),
              const SizedBox(width: 6),
              Text(
                category.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Floating radius selector pill (top-right of map).
class RadiusSelectorPill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const RadiusSelectorPill({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceLowest.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.radar, color: AppColors.primary, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.expand_more,
                color: AppColors.onSurfaceVariant,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
