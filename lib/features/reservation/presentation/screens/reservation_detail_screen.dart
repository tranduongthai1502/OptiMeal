import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/reservation.dart';
import '../providers/reservation_provider.dart';

class ReservationDetailScreen extends ConsumerWidget {
  final String reservationId;

  const ReservationDetailScreen({super.key, required this.reservationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveState = ref.watch(reservationNotifierProvider);
    final reservationAsync = ref.watch(reservationByIdProvider(reservationId));

    // Prefer live active state if matching ID, otherwise load from provider
    final reservation = (liveState.activeReservation?.id == reservationId)
        ? liveState.activeReservation
        : null;

    if (reservation != null) {
      return _buildContent(context, ref, reservation, liveState.remainingTime);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Thông tin giữ chỗ')),
      body: reservationAsync.when(
        loading: () => const AppLoadingIndicator(message: 'Đang tải thông tin giữ chỗ...'),
        error: (err, _) => AppErrorView(
          message: err.toString(),
          onRetry: () => ref.refresh(reservationByIdProvider(reservationId)),
        ),
        data: (res) => _buildContent(
          context,
          ref,
          res,
          res.remainingTimeFrom(DateTime.now()),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    Reservation reservation,
    Duration remainingTime,
  ) {
    final isExpired = reservation.status == ReservationStatus.expired ||
        (reservation.status == ReservationStatus.held && remainingTime <= Duration.zero);
    final isCompleted = reservation.status == ReservationStatus.completed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giữ chỗ nhận thực phẩm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_outlined),
            onPressed: () => context.push(RoutePaths.chatPath(reservation.id)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status & Countdown Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.primaryContainer
                      : isExpired
                          ? const Color(0xFFFFEBEE)
                          : const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCompleted
                        ? AppColors.primary
                        : isExpired
                            ? AppColors.error
                            : AppColors.warning,
                  ),
                ),
                child: Column(
                  children: [
                    if (isCompleted) ...[
                      const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 48),
                      const SizedBox(height: 8),
                      const Text(
                        'GIAO NHẬN THÀNH CÔNG',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryDark),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Cảm ơn bạn đã đồng hành cứu trợ thực phẩm cùng cộng đồng!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                      ),
                    ] else if (isExpired) ...[
                      const Icon(Icons.timer_off_outlined, color: AppColors.error, size: 48),
                      const SizedBox(height: 8),
                      const Text(
                        'ĐÃ HẾT HẠN GIỮ CHỖ',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.error),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Thời gian giữ chỗ 20 phút đã kết thúc. Thực phẩm đã được trả lại danh sách cộng đồng.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                      ),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.timer_outlined, color: AppColors.warning, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            DateTimeUtils.formatCountdown(remainingTime),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: AppColors.warning,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Thời gian giữ chỗ còn lại (Tự đến lấy)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Vui lòng di chuyển đến địa điểm nhận trước khi đồng hồ về 00:00.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // QR Code Section for pickup verification
              if (!isExpired) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'MÃ XÁC NHẬN GIAO NHẬN',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Xuất trình mã này cho người cho thực phẩm quét khi bạn đến lấy.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: QrImageView(
                          data: reservation.qrCodeData,
                          version: QrVersions.auto,
                          size: 180.0,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: AppColors.secondary,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Mã: ${reservation.id.toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Donor/Store action to scan QR
              OutlinedButton.icon(
                onPressed: () {
                  context.push(RoutePaths.qrScannerPath(reservation.id));
                },
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: const Text('Người cho quét mã xác nhận tại đây'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.secondary),
                  foregroundColor: AppColors.secondary,
                ),
              ),

              const SizedBox(height: 12),

              if (reservation.status == ReservationStatus.held && !isExpired) ...[
                TextButton(
                  onPressed: () async {
                    await ref.read(reservationNotifierProvider.notifier).cancelReservation();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã hủy giữ chỗ.')),
                      );
                      context.pop();
                    }
                  },
                  child: const Text(
                    'Hủy giữ chỗ (Nhường cho người khác)',
                    style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
