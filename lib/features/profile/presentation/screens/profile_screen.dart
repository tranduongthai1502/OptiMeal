import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final storeId = user?.role?.isStore == true ? user!.id : null;

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
                    user?.displayName ?? 'Chưa cập nhật tên',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.phoneNumber.isNotEmpty == true
                        ? user!.phoneNumber
                        : 'Chưa có số điện thoại',
                    style: const TextStyle(color: AppColors.textSecondaryLight),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            const Text(
              'Thống kê hoạt động sẽ hiển thị khi có dữ liệu giao dịch.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondaryLight),
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
            if (storeId != null)
              ListTile(
                leading: const Icon(
                  Icons.storefront_rounded,
                  color: AppColors.primary,
                ),
                title: const Text('Hồ sơ cửa hàng'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push(
                  RoutePaths.storeProfilePath(storeId),
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
}
