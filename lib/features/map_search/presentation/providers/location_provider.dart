import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  static const _savedLatitudeKey = 'last_location_latitude';
  static const _savedLongitudeKey = 'last_location_longitude';

  LocationNotifier() : super(const LocationState(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    // Luôn xin quyền GPS trước IP geolocation để trình duyệt hiện prompt
    // "Allow location" ngay khi người dùng vào ứng dụng.
    final savedPosition = await _loadSavedPosition();

    // 1. Kiểm tra service GPS (web không có service toggle như mobile).
    final serviceEnabled =
        kIsWeb ? true : await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (savedPosition != null) {
        state = LocationState(
          position: savedPosition,
          errorMessage: 'Định vị đang tắt. Đang dùng vị trí đã lưu.',
        );
        return;
      }
      state = const LocationState(
        errorMessage: 'Hãy bật định vị để tìm món ăn gần bạn.',
      );
      return;
    }

    // 2. Xin quyền vị trí. Không dùng IP trước bước này vì sẽ không hiện prompt.
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (savedPosition != null) {
        state = LocationState(
          position: savedPosition,
          errorMessage: 'Chưa cấp quyền định vị. Đang dùng vị trí đã lưu.',
        );
        return;
      }
      state = const LocationState(
        errorMessage: 'Hãy cho phép truy cập vị trí để tìm món ăn gần bạn.',
      );
      return;
    }

    // 3. Lấy ngay vị trí hiện tại với độ chính xác cao.
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
          final pos = _positionFromCoordinates(
            ipCoords.latitude,
            ipCoords.longitude,
          );
          state = LocationState(position: pos);
          await _savePosition(pos);
          return;
        }
      }

      state = LocationState(position: currentPos);
      await _savePosition(currentPos);
    } catch (e) {
      if (kDebugMode)
        debugPrint('[LocationNotifier] getCurrentPosition initial error: $e');
      final ipCoords = await LocationUtils.getIpCoordinates();
      if (ipCoords != null) {
        final pos = _positionFromCoordinates(
          ipCoords.latitude,
          ipCoords.longitude,
        );
        state = LocationState(position: pos);
        await _savePosition(pos);
        return;
      }
      try {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          state = LocationState(position: lastKnown);
          await _savePosition(lastKnown);
        } else if (savedPosition != null) {
          state = LocationState(
            position: savedPosition,
            errorMessage: 'Không lấy được GPS. Đang dùng vị trí đã lưu.',
          );
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
          unawaited(_savePosition(pos));
        }
      },
      onError: (Object e) {
        if (kDebugMode) debugPrint('[LocationNotifier] GPS error: $e');
      },
      cancelOnError: false,
    );
  }

  Position _positionFromCoordinates(double latitude, double longitude) {
    return Position(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
      accuracy: 100.0,
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );
  }

  Future<Position?> _loadSavedPosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble(_savedLatitudeKey);
      final lng = prefs.getDouble(_savedLongitudeKey);
      if (lat == null || lng == null) return null;
      return _positionFromCoordinates(lat, lng);
    } catch (_) {
      return null;
    }
  }

  Future<void> _savePosition(Position position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_savedLatitudeKey, position.latitude);
      await prefs.setDouble(_savedLongitudeKey, position.longitude);
    } catch (_) {
      // Local persistence is optional; GPS still works when it is unavailable.
    }
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

/// Provider dùng chung cho Home, Food Map và màn chọn vị trí.
/// Không autoDispose để giữ vị trí đã lấy trong suốt phiên ứng dụng.
final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>(
  (ref) => LocationNotifier(),
);
