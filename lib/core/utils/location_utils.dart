import 'dart:math' as math;

/// Utilities for distance calculation and coordinates.
class LocationUtils {
  LocationUtils._();

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
