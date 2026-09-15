import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../reputation/presentation/widgets/reputation_badge.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;

    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ cá nhân')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // User Avatar & Name
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.primaryContainer,
                    child: Icon(
                      Icons.person,
                      size: 52,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.displayName ?? 'Nguyễn Văn A',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.phoneNumber ?? '0987654321',
                    style: const TextStyle(color: AppColors.textSecondaryLight),
                  ),
                  const SizedBox(height: 8),
                  const ReputationBadge(score: 4.9, totalReviews: 12),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Metrics overview
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Đã chia sẻ',
                    value: '14 phần',
                    icon: Icons.volunteer_activism_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Đã nhận',
                    value: '6 lần',
                    icon: Icons.shopping_bag_outlined,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Vắng mặt (No-show)',
                    value: '0 lần',
                    icon: Icons.report_problem_outlined,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),
            const Divider(),

            ListTile(
              leading: const Icon(
                Icons.history_rounded,
                color: AppColors.primary,
              ),
              title: const Text('Lịch sử trao đổi thực phẩm'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(
                Icons.storefront_rounded,
                color: AppColors.primary,
              ),
              title: const Text('Hồ sơ cửa hàng liên kết'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(
                RoutePaths.storeProfilePath('store-touslesjours'),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.security_rounded,
                color: AppColors.primary,
              ),
              title: const Text('Quy tắc uy tín & phòng tránh No-show'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(
                Icons.language_rounded,
                color: AppColors.primary,
              ),
              title: const Text('Ngôn ngữ: Tiếng Việt (Mặc định)'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),

            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authStateProvider.notifier).signOut();
                if (context.mounted) {
                  context.go(RoutePaths.login);
                }
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Đăng xuất'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
