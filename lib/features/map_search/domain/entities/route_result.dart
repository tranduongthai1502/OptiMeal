import 'package:latlong2/latlong.dart' hide Path;

/// Kết quả tuyến đường trả về từ OpenRouteService.
class RouteResult {
  /// Danh sách toạ độ để vẽ PolylineLayer.
  final List<LatLng> points;

  /// Tổng quãng đường (mét).
  final double distanceMeters;

  /// Tổng thời gian ước tính (giây).
  final double durationSeconds;

  const RouteResult({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  /// Hiển thị khoảng cách, ví dụ: "2.4 km".
  String get distanceLabel {
    final km = distanceMeters / 1000;
    return '${km.toStringAsFixed(1)} km';
  }

  /// Hiển thị thời gian, ví dụ: "7 phút".
  String get durationLabel {
    final minutes = (durationSeconds / 60).ceil();
    return '$minutes phút';
  }
}

