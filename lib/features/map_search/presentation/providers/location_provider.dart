import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/utils/location_utils.dart';

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
/// Hỗ trợ fallback thông minh qua IP Geolocation (trên Web / khi Chrome bị lệch sang Đài Loan).
class LocationNotifier extends StateNotifier<LocationState> {
  StreamSubscription<Position>? _positionSub;

  LocationNotifier() : super(const LocationState(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    // 1. Trên Web: Thử lấy ngay vị trí qua REST API IP Geolocation trước
    // Vì máy tính/Chrome không có GPS phần cứng và hay bị Google định tuyến nhầm sang Đài Loan.
    if (kIsWeb) {
      final ipCoords = await LocationUtils.getIpCoordinates();
      if (ipCoords != null) {
        final pos = Position(
          latitude: ipCoords.latitude,
          longitude: ipCoords.longitude,
          timestamp: DateTime.now(),
          accuracy: 100.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
        state = LocationState(position: pos);
        return;
      }
    }

    // 2. Kiểm tra service GPS
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Nếu GPS tắt, thử lấy qua IP
      final ipCoords = await LocationUtils.getIpCoordinates();
      if (ipCoords != null) {
        final pos = Position(
          latitude: ipCoords.latitude,
          longitude: ipCoords.longitude,
          timestamp: DateTime.now(),
          accuracy: 100.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
        state = LocationState(position: pos);
        return;
      }
      state = const LocationState(
        errorMessage: 'GPS đang tắt. Bản đồ hiển thị mặc định tại Đà Nẵng.',
      );
      return;
    }

    // 3. Xin quyền vị trí
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // Nếu bị từ chối quyền, fallback qua IP để người dùng vẫn dùng được app
      final ipCoords = await LocationUtils.getIpCoordinates();
      if (ipCoords != null) {
        final pos = Position(
          latitude: ipCoords.latitude,
          longitude: ipCoords.longitude,
          timestamp: DateTime.now(),
          accuracy: 100.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
        state = LocationState(position: pos);
        return;
      }
      state = const LocationState(
        errorMessage:
            'Chưa cấp quyền vị trí. Bản đồ hiển thị mặc định tại Đà Nẵng.',
      );
      return;
    }

    // 4. Lấy ngay vị trí hiện tại với độ chính xác cao
    try {
      final currentPos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Nếu vị trí trả về ở Đài Loan (lat ~21-26, lng ~119-123) do Chrome định tuyến nhầm:
      final isTaiwan = currentPos.latitude >= 21.0 &&
          currentPos.latitude <= 26.0 &&
          currentPos.longitude >= 119.0 &&
          currentPos.longitude <= 123.0;

      if (isTaiwan) {
        final ipCoords = await LocationUtils.getIpCoordinates();
        if (ipCoords != null) {
          final pos = Position(
            latitude: ipCoords.latitude,
            longitude: ipCoords.longitude,
            timestamp: DateTime.now(),
            accuracy: 100.0,
            altitude: 0.0,
            altitudeAccuracy: 0.0,
            heading: 0.0,
            headingAccuracy: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
          );
          state = LocationState(position: pos);
          return;
        }
      }

      state = LocationState(position: currentPos);
    } catch (e) {
      if (kDebugMode) debugPrint('[LocationNotifier] getCurrentPosition initial error: $e');
      final ipCoords = await LocationUtils.getIpCoordinates();
      if (ipCoords != null) {
        final pos = Position(
          latitude: ipCoords.latitude,
          longitude: ipCoords.longitude,
          timestamp: DateTime.now(),
          accuracy: 100.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
        state = LocationState(position: pos);
        return;
      }
      try {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          state = LocationState(position: lastKnown);
        }
      } catch (_) {}
    }

    // 5. Bắt đầu stream vị trí — accuracy: high, cập nhật mỗi 10m
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen(
      (pos) {
        final isTaiwan = pos.latitude >= 21.0 &&
            pos.latitude <= 26.0 &&
            pos.longitude >= 119.0 &&
            pos.longitude <= 123.0;
        if (!isTaiwan) {
          state = LocationState(position: pos);
        }
      },
      onError: (Object e) {
        if (kDebugMode) debugPrint('[LocationNotifier] GPS error: $e');
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

/// Provider vị trí GPS riêng cho màn hình Food Map.
/// Dùng autoDispose để chỉ khởi tạo và xin GPS khi người dùng mở Food Map,
/// và tự động giải phóng GPS khi người dùng rời khỏi Food Map.
final locationProvider =
    StateNotifierProvider.autoDispose<LocationNotifier, LocationState>(
  (ref) => LocationNotifier(),
);
