import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/auth_provider.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _otpController = TextEditingController(text: '123456');

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ 6 chữ số OTP.')),
      );
      return;
    }

    final success = await ref.read(authStateProvider.notifier).verifyOtp(code);

    if (!mounted) return;

    if (success) {
      final user = ref.read(authStateProvider).user;
      if (user != null && user.hasSelectedRole) {
        context.go(RoutePaths.home);
      } else {
        context.go(RoutePaths.onboardingRole);
      }
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
      appBar: AppBar(title: const Text('Xác thực OTP')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Icon(
                Icons.mark_email_read_outlined,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              const Text(
                'Nhập mã xác nhận',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Mã OTP 6 số đã được gửi qua tin nhắn SMS đến số điện thoại của bạn.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 36),
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  letterSpacing: 12,
                  fontWeight: FontWeight.w700,
                ),
                decoration: const InputDecoration(
                  counterText: '',
                  hintText: '••••••',
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Xác nhận',
                isLoading: authState.isLoading,
                onPressed: _handleVerify,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã gửi lại mã OTP.')),
                  );
                },
                child: const Text(
                  'Chưa nhận được mã? Gửi lại',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
