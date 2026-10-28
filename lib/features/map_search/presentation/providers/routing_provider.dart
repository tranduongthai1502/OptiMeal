import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../data/services/ors_routing_service.dart';
import '../../domain/entities/route_result.dart';

/// Đích đến đang được xem tuyến đường.
/// null = không hiển thị tuyến.
final routeTargetProvider = StateProvider<LatLng?>((ref) => null);

/// Tham số cặp (from, to) dùng làm key cho routeProvider.family.
/// Implements == và hashCode để cache đúng cách.
class RouteParams {
  final LatLng from;
  final LatLng to;

  const RouteParams({required this.from, required this.to});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RouteParams &&
        from.latitude == other.from.latitude &&
        from.longitude == other.from.longitude &&
        to.latitude == other.to.latitude &&
        to.longitude == other.to.longitude;
  }

  @override
  int get hashCode => Object.hash(
        from.latitude,
        from.longitude,
        to.latitude,
        to.longitude,
      );
}

/// FutureProvider lấy tuyến đường ORS.
/// - autoDispose: huỷ khi không còn được lắng nghe.
/// - family: cache riêng theo từng cặp (from, to) — tránh gọi lặp.
/// - Chỉ gọi API khi người dùng chủ động bấm nút "Xem đường đi".
final routeProvider = FutureProvider.autoDispose
    .family<RouteResult, RouteParams>((ref, params) {
  final service = OrsRoutingService();
  return service.getRoute(from: params.from, to: params.to);
});

