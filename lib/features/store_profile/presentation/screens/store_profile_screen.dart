import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../reputation/presentation/widgets/reputation_badge.dart';

class StoreProfileScreen extends StatelessWidget {
  final String storeId;

  const StoreProfileScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ cửa hàng đối tác')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 140,
              color: AppColors.secondary,
              child: const Center(
                child: Icon(
                  Icons.storefront_rounded,
                  size: 64,
                  color: Colors.white70,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tous Les Jours Hai Bà Trưng',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tiệm bánh ngọt & bánh mì tươi Pháp',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      ReputationBadge(score: 4.9, totalReviews: 84),
                      SizedBox(width: 12),
                      Text(
                        '124 phần ăn đã giải cứu',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  const Text(
                    'Thông tin hoạt động',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.access_time_rounded,
                      color: AppColors.primary,
                    ),
                    title: Text('Giờ mở cửa: 06:30 - 22:00'),
                    subtitle: Text(
                      'Khung giờ đăng thực phẩm dư: 19:30 - 21:00 hàng ngày',
                    ),
                  ),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      '180 Hai Bà Trưng, Phường Đa Kao, Quận 1, TP.HCM',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.event_repeat_rounded,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Cửa hàng có lịch đăng tin tự động lặp lại định kỳ vào lúc 20:00 mỗi tối.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
