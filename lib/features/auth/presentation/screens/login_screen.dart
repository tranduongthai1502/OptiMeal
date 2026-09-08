import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController(text: '0987654321');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref
        .read(authStateProvider.notifier)
        .sendOtp(_phoneController.text.trim());

    if (!mounted) return;

    if (success) {
      await context.push(RoutePaths.otpVerification);
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  AppConstants.appName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  AppConstants.appTagline,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 48),
                const Text(
                  'Đăng nhập / Đăng ký',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Nhập số điện thoại của bạn để nhận mã xác thực OTP.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại',
                    hintText: '0912 345 678',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập số điện thoại';
                    }
                    if (value.trim().length < 9) {
                      return 'Số điện thoại không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: 'Tiếp tục',
                  isLoading: authState.isLoading,
                  icon: Icons.arrow_forward_rounded,
                  onPressed: _handleSendOtp,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Bằng việc đăng nhập, bạn đồng ý với Điều khoản sử dụng và Chính sách bảo vệ thực phẩm bền vững của OptiMeal.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
