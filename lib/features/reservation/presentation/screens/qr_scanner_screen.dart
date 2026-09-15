import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/reservation_provider.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  final String reservationId;

  const QrScannerScreen({super.key, required this.reservationId});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    await _processCode(rawValue);
  }

  Future<void> _processCode(String code) async {
    setState(() => _isProcessing = true);

    final success = await ref
        .read(reservationNotifierProvider.notifier)
        .confirmPickup(code);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xác nhận giao nhận thành công! Đã hoàn tất chia sẻ.'),
          backgroundColor: AppColors.primary,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mã QR không khớp với lượt giữ chỗ này.'),
          backgroundColor: AppColors.error,
        ),
      );
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét mã QR xác nhận'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder<MobileScannerState>(
              valueListenable: _scannerController,
              builder: (context, state, child) {
                return Icon(
                  state.torchState == TorchState.on
                      ? Icons.flash_on
                      : Icons.flash_off,
                  color: state.torchState == TorchState.on
                      ? Colors.amber
                      : Colors.grey,
                );
              },
            ),
            onPressed: () => _scannerController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleBarcode,
          ),

          // Focus Target Overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryLight, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Hướng camera về phía mã QR trên điện thoại người nhận',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 16),
                // Manual confirmation fallback button
                PrimaryButton(
                  label: 'Xác nhận thủ công (Không quét mã)',
                  icon: Icons.check_circle_outline,
                  isLoading: _isProcessing,
                  backgroundColor: AppColors.secondary,
                  onPressed: () => _processCode('MANUAL_CONFIRMATION'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
