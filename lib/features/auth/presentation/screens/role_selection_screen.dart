import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/auth_provider.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  UserRole _selectedRole = UserRole.individual;
  final _nameController = TextEditingController(text: 'Nguyễn Văn A');

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirmRole() async {
    final success = await ref.read(authStateProvider.notifier).selectRole(
          _selectedRole,
          displayName: _nameController.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      context.go(RoutePaths.home);
    } else {
      final error = ref.read(authStateProvider).errorMessage;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn vai trò sử dụng'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Bạn tham gia OptiMeal với tư cách nào?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Điều này giúp chúng tôi cá nhân hóa trải nghiệm chia sẻ thực phẩm phù hợp với bạn.',
                style: TextStyle(
                    fontSize: 14, color: AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 28),

              // Individual Card Option
              _buildRoleCard(
                role: UserRole.individual,
                title: 'Cá nhân / Hộ gia đình',
                description:
                    'Chia sẻ thức ăn còn dư hoặc tìm kiếm món ăn miễn phí/giá rẻ quanh bạn.',
                icon: Icons.person_rounded,
              ),

              const SizedBox(height: 16),

              // Store Card Option
              _buildRoleCard(
                role: UserRole.store,
                title: 'Cửa hàng / Nhà hàng',
                description:
                    'Tiệm bánh, quán ăn, siêu thị muốn giải cứu thực phẩm cuối ngày và giảm lãng phí.',
                icon: Icons.storefront_rounded,
              ),

              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: _selectedRole == UserRole.store
                      ? 'Tên cửa hàng / thương hiệu'
                      : 'Họ và tên của bạn',
                  prefixIcon: const Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Bắt đầu sử dụng',
                isLoading: authState.isLoading,
                onPressed: _handleConfirmRole,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryContainer.withValues(alpha: 0.4)
              : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isSelected ? AppColors.primary : AppColors.backgroundLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.primaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondaryLight,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            RadioGroup<UserRole>(
              groupValue: _selectedRole,
              onChanged: (val) {
                if (val != null) setState(() => _selectedRole = val);
              },
              child: Radio<UserRole>(
                value: role,
                activeColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
