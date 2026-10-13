import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class StoreProfileScreen extends StatelessWidget {
  final String storeId;

  const StoreProfileScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ cửa hàng đối tác')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.storefront_outlined,
                size: 56,
                color: AppColors.textSecondaryLight,
              ),
              const SizedBox(height: 16),
              Text(
                'Chưa có dữ liệu cửa hàng cho mã $storeId.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondaryLight,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
