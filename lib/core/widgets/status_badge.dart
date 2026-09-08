import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable badge for listing / reservation statuses.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  factory StatusBadge.available() => const StatusBadge(
        label: 'Còn thực phẩm',
        backgroundColor: Color(0xFFE8F5E9),
        textColor: AppColors.statusAvailable,
      );

  factory StatusBadge.reserved() => const StatusBadge(
        label: 'Đang giữ chỗ',
        backgroundColor: Color(0xFFFFF3E0),
        textColor: AppColors.statusReserved,
      );

  factory StatusBadge.completed() => const StatusBadge(
        label: 'Đã hoàn tất',
        backgroundColor: Color(0xFFE3F2FD),
        textColor: AppColors.statusCompleted,
      );

  factory StatusBadge.expired() => const StatusBadge(
        label: 'Đã hết hạn',
        backgroundColor: Color(0xFFEEEEEE),
        textColor: AppColors.statusExpired,
      );

  factory StatusBadge.free() => const StatusBadge(
        label: 'MIỄN PHÍ',
        backgroundColor: Color(0xFFE8F5E9),
        textColor: AppColors.primaryDark,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
