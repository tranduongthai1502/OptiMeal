import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ReputationBadge extends StatelessWidget {
  final double score;
  final int totalReviews;

  const ReputationBadge({
    super.key,
    required this.score,
    required this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
          const SizedBox(width: 4),
          Text(
            score.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE65100),
            ),
          ),
          if (totalReviews > 0) ...[
            const SizedBox(width: 4),
            Text(
              '($totalReviews)',
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondaryLight),
            ),
          ],
        ],
      ),
    );
  }
}
