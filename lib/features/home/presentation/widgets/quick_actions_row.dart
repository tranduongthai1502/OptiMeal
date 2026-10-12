import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Model for a single quick-action button on the Home dashboard.
class QuickAction {
  final Color bgColor;
  final Color iconColor;
  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback onTap;

  const QuickAction({
    required this.bgColor,
    required this.iconColor,
    required this.icon,
    required this.label,
    this.badge,
    required this.onTap,
  });
}

/// Row of circular icon buttons (Pin Surplus, Food Map, AI Copilot, Scan QR).
class QuickActionsRow extends StatelessWidget {
  final List<QuickAction> actions;

  const QuickActionsRow({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: actions.map((a) => _QuickActionCircle(action: a)).toList(),
    );
  }
}

class _QuickActionCircle extends StatelessWidget {
  final QuickAction action;
  const _QuickActionCircle({required this.action});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: action.bgColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(action.icon, color: action.iconColor, size: 26),
              ),
              if (action.badge != null)
                Positioned(
                  top: -3,
                  right: -3,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      action.badge!,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF684000),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            action.label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
