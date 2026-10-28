import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// Trạng thái vị trí GPS của người dùng.
class LocationState {
  final Position? position;

  /// Thông báo lỗi thân thiện (null = đang tải hoặc đã có vị trí).
  final String? errorMessage;

  final bool isLoading;

  const LocationState({
    this.position,
    this.errorMessage,
    this.isLoading = false,
  });

  bool get hasPosition => position != null;
}

/// Notifier lắng nghe GPS realtime, xin quyền và xử lý từ chối gracefully.
/// StreamSubscription được huỷ trong dispose() — không bị leak.
class LocationNotifier extends StateNotifier<LocationState> {
  StreamSubscription<Position>? _positionSub;

  LocationNotifier() : super(const LocationState(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    // 1. Kiểm tra service GPS
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = const LocationState(
        errorMessage: 'GPS đang tắt. Bản đồ hiển thị mặc định tại Đà Nẵng.',
      );
      return;
    }

    // 2. Xin quyền vị trí
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      state = const LocationState(
        errorMessage:
            'Chưa cấp quyền vị trí. Bản đồ hiển thị mặc định tại Đà Nẵng.',
      );
      return;
    }

    // 3. Bắt đầu stream vị trí — cập nhật mỗi 30m di chuyển
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 30,
      ),
    ).listen(
      (pos) => state = LocationState(position: pos),
      onError: (Object e) {
        if (kDebugMode) debugPrint('[LocationNotifier] GPS error: $e');
        state = const LocationState(
          errorMessage: 'Không lấy được vị trí. Bản đồ dùng vị trí mặc định.',
        );
      },
      cancelOnError: false,
    );
  }

  /// Gọi lại để refresh vị trí (ví dụ khi người dùng bấm "về vị trí của tôi").
  Future<void> refresh() async {
    await _positionSub?.cancel();
    _positionSub = null;
    state = const LocationState(isLoading: true);
    await _init();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }
}

/// Provider vị trí GPS toàn cục (không autoDispose để giữ stream giữa các route).
final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationState>(
  (ref) => LocationNotifier(),
);

