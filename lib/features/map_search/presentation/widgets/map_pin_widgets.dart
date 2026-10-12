import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Data for one marker/pin on the food map.
class MapPinData {
  final String id;
  final String label;
  final IconData icon;
  final Color pinColor;
  final Color ringColor;
  final bool isPulsing;

  const MapPinData({
    required this.id,
    required this.label,
    required this.icon,
    required this.pinColor,
    required this.ringColor,
    this.isPulsing = false,
  });
}

/// A static food-map pin widget.
/// Pass [animation] (0.0 → 1.0) when [isPulsing] is true.
class MapPinWidget extends StatelessWidget {
  final MapPinData data;
  final Animation<double>? animation;
  final VoidCallback? onTap;

  const MapPinWidget({
    super.key,
    required this.data,
    this.animation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (data.isPulsing) ...[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: data.pinColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  data.label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),

          // Pin body (with optional pulse ring)
          if (data.isPulsing && animation != null)
            AnimatedBuilder(
              animation: animation!,
              builder: (ctx, child) => Stack(
                alignment: Alignment.center,
                children: [
                  // Pulse ring
                  Container(
                    width: 44 + (animation!.value * 14),
                    height: 44 + (animation!.value * 14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: data.pinColor.withValues(
                        alpha: 0.25 * (1 - animation!.value),
                      ),
                    ),
                  ),
                  _PinBody(data: data),
                ],
              ),
            )
          else
            _PinBody(data: data),

          // Tip
          Transform.rotate(
            angle: 3.14159 / 4,
            child: Container(width: 8, height: 8, color: data.pinColor),
          ),
        ],
      ),
    );
  }
}

class _PinBody extends StatelessWidget {
  final MapPinData data;
  const _PinBody({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: data.pinColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: data.ringColor.withValues(alpha: 0.5),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: data.pinColor.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(data.icon, color: Colors.white, size: 20),
    );
  }
}

/// Pulsing user-location beacon used on the food map.
class UserLocationBeacon extends StatelessWidget {
  final Animation<double> animation;

  const UserLocationBeacon({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (ctx, child) => Stack(
        alignment: Alignment.center,
        children: [
          // Radar pulse ring
          Container(
            width: 36 + (animation.value * 24),
            height: 36 + (animation.value * 24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(
                alpha: 0.2 * (1 - animation.value),
              ),
            ),
          ),
          // White outer dot
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Floating circular action button on the map.
class MapFloatingButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  const MapFloatingButton({
    super.key,
    required this.icon,
    required this.iconColor,
    this.backgroundColor = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: iconColor, size: 22),
        ),
      ),
    );
  }
}

/// Cluster pin showing how many food spots are grouped in an area.
class ClusterPinWidget extends StatelessWidget {
  final String count;
  final Color color;

  const ClusterPinWidget({super.key, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        count,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
