import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/date_time_utils.dart';

/// ── Shared Widgets ──────────────────────────────────────────────────────────
///
/// All reusable UI components that can appear in more than one feature screen.
/// Import this barrel file instead of individual widget files:
///   import 'package:optimeal/core/widgets/app_widgets.dart';

export 'app_error_view.dart';
export 'app_loading_indicator.dart';
export 'primary_button.dart';
export 'status_badge.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SectionHeader
// ─────────────────────────────────────────────────────────────────────────────

/// A titled section row with an optional "See all" action link.
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  final Color dotColor;

  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
    this.dotColor = AppColors.secondaryContainer,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(radius: 4, backgroundColor: dotColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
        if (onSeeAll != null)
          InkWell(
            onTap: onSeeAll,
            child: const Row(
              children: [
                Text(
                  'See all',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Icon(Icons.chevron_right, size: 16, color: AppColors.primary),
              ],
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UrgentTag
// ─────────────────────────────────────────────────────────────────────────────

/// Small coloured label used on feed card images (e.g. "4h left").
class UrgentTag extends StatelessWidget {
  final String label;
  final Color color;

  const UrgentTag({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(radius: 2.5, backgroundColor: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FilterChipBar
// ─────────────────────────────────────────────────────────────────────────────

/// Horizontally scrollable list of pill filter chips.
class FilterChipBar extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const FilterChipBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: labels.length,
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () => onSelected(index),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.onSurface
                      : AppColors.surfaceLowest,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  labels[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.bgSurface
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CountdownTimer (countdown text widget, rebuilt every second)
// ─────────────────────────────────────────────────────────────────────────────

/// Builds a text that counts down a [Duration] and rebuilds every second.
class CountdownText extends StatefulWidget {
  final Duration duration;
  final TextStyle? style;

  const CountdownText({super.key, required this.duration, this.style});

  @override
  State<CountdownText> createState() => _CountdownTextState();
}

class _CountdownTextState extends State<CountdownText> {
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.duration;
    _tick();
  }

  void _tick() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _remaining = _remaining <= Duration.zero
            ? Duration.zero
            : _remaining - const Duration(seconds: 1);
      });
      if (_remaining > Duration.zero) _tick();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      DateTimeUtils.formatCountdown(_remaining),
      style: widget.style,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppBottomNavBar
// ─────────────────────────────────────────────────────────────────────────────

class AppBottomNavItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final bool isCenter;

  const AppBottomNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.isCenter = false,
  });
}

/// Shared bottom navigation bar used across Home, Map, AI Copilot, Profile.
class AppBottomNavBar extends StatelessWidget {
  final List<AppBottomNavItem> items;
  final int centerIndex;

  const AppBottomNavBar({
    super.key,
    required this.items,
    this.centerIndex = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.bgSurface.withValues(alpha: 0.96),
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
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          if (i == centerIndex) {
            return GestureDetector(
              onTap: item.onTap,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(item.icon, color: Colors.white, size: 28),
              ),
            );
          }
          return _NavItem(item: item);
        }).toList(),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final AppBottomNavItem item;
  const _NavItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              size: 22,
              color: item.isActive
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    item.isActive ? FontWeight.bold : FontWeight.normal,
                color: item.isActive
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
