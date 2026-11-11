import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

/// Utilities for distance calculation and coordinates.
class LocationUtils {
  LocationUtils._();

  /// Lấy toạ độ vị trí địa lý thông qua REST API IP Geolocation.
  /// Rất hữu ích trên môi trường Web/PC không có chip GPS thực tế hoặc bị Google Chrome
  /// định tuyến sai sang Đài Loan.
  static Future<({double latitude, double longitude})?> getIpCoordinates() async {
    // 1. Thử qua HTTPS ipwho.is (hỗ trợ tốt trên web)
    try {
      final res = await http
          .get(Uri.parse('https://ipwho.is/'))
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true &&
            data['latitude'] != null &&
            data['longitude'] != null) {
          final lat = (data['latitude'] as num).toDouble();
          final lon = (data['longitude'] as num).toDouble();
          return (latitude: lat, longitude: lon);
        }
      }
    } catch (_) {}

    // 2. Fallback qua http://ip-api.com/json
    try {
      final res = await http
          .get(Uri.parse('http://ip-api.com/json'))
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'success' &&
            data['lat'] != null &&
            data['lon'] != null) {
          final lat = (data['lat'] as num).toDouble();
          final lon = (data['lon'] as num).toDouble();
          return (latitude: lat, longitude: lon);
        }
      }
    } catch (_) {}

    return null;
  }

  /// Calculates distance in meters between two lat/lng points using the Haversine formula.
  static double calculateDistanceMeters(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    const earthRadiusMeters = 6371000.0;
    final dLat = _toRadians(endLatitude - startLatitude);
    final dLon = _toRadians(endLongitude - startLongitude);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(startLatitude)) *
            math.cos(_toRadians(endLatitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  /// Calculates distance in kilometers.
  static double calculateDistanceKm(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return calculateDistanceMeters(
          startLatitude,
          startLongitude,
          endLatitude,
          endLongitude,
        ) /
        1000.0;
  }

  /// Formats distance into friendly text e.g. "450 m" or "2.4 km"
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1.0) {
      final meters = (distanceInKm * 1000).round();
      return '$meters m';
    }
    return '${distanceInKm.toStringAsFixed(1)} km';
  }

  static double _toRadians(double degree) {
    return degree * math.pi / 180.0;
  }
}
