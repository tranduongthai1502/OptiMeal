import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Centered loading indicator widget.
class AppLoadingIndicator extends StatelessWidget {
  final String? message;

  const AppLoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              style: const TextStyle(
                color: AppColors.textSecondaryLight,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
