import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' hide Path;

import '../../domain/entities/route_result.dart';

/// Lỗi chỉ đường — luôn có thông báo tiếng Việt dễ hiểu.
class RoutingException implements Exception {
  final String userMessage;
  const RoutingException(this.userMessage);

  @override
  String toString() => userMessage;
}

/// Gọi OpenRouteService Directions API (driving-car, GeoJSON).
///
/// Key đọc qua --dart-define=ORS_API_KEY=... khi chạy/build.
/// Không hardcode key ở đây.
class OrsRoutingService {
  static const _url =
      'https://api.openrouteservice.org/v2/directions/driving-car/geojson';

  final http.Client _client;

  OrsRoutingService({http.Client? client})
      : _client = client ?? http.Client();

  /// Tính tuyến đường lái xe từ [from] đến [to].
  /// Ném [RoutingException] với thông báo tiếng Việt cho mọi tình huống lỗi.
  Future<RouteResult> getRoute({
    required LatLng from,
    required LatLng to,
  }) async {
    // Đọc key — không bao giờ hardcode
    const apiKey = String.fromEnvironment('ORS_API_KEY');
    if (apiKey.isEmpty) {
      throw const RoutingException(
        'Chưa cấu hình ORS_API_KEY. Xem hướng dẫn trong README.md.',
      );
    }

    // ORS nhận [lng, lat] — ngược với LatLng(lat, lng)
    final body = jsonEncode({
      'coordinates': [
        [from.longitude, from.latitude],
        [to.longitude, to.latitude],
      ],
    });

    try {
      final response = await _client
          .post(
            Uri.parse(_url),
            headers: {
              'Authorization': apiKey,
              'Content-Type': 'application/json; charset=utf-8',
              'Accept':
                  'application/json, application/geo+json, application/gpx+xml',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      switch (response.statusCode) {
        case 200:
          return _parse(response.body);
        case 403:
          throw const RoutingException(
            'Đã vượt hạn mức miễn phí ORS hôm nay (403). Thử lại vào ngày mai.',
          );
        case 429:
          throw const RoutingException(
            'Gọi API quá nhanh (429). Vui lòng đợi vài giây rồi thử lại.',
          );
        case 404:
          throw const RoutingException(
            'Không tìm được đường đi giữa hai điểm này (404).',
          );
        default:
          throw RoutingException(
            'Lỗi dịch vụ chỉ đường (HTTP ${response.statusCode}). Thử lại sau.',
          );
      }
    } on RoutingException {
      rethrow;
    } catch (e) {
      if (kDebugMode) debugPrint('[ORS] Network error: $e');
      throw const RoutingException(
        'Mất kết nối hoặc hết thời gian chờ. Kiểm tra mạng rồi thử lại.',
      );
    }
  }

  RouteResult _parse(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final features = json['features'] as List<dynamic>;

      if (features.isEmpty) {
        throw const RoutingException(
          'Không tìm được tuyến đường phù hợp.',
        );
      }

      final feature = features[0] as Map<String, dynamic>;
      final geometry = feature['geometry'] as Map<String, dynamic>;
      final coords = geometry['coordinates'] as List<dynamic>;
      final summary =
          (feature['properties'] as Map<String, dynamic>)['summary']
              as Map<String, dynamic>;

      // ORS trả [lng, lat] → chuyển sang LatLng(lat, lng)
      final points = coords.map<LatLng>((c) {
        final pair = c as List<dynamic>;
        return LatLng(
          (pair[1] as num).toDouble(),
          (pair[0] as num).toDouble(),
        );
      }).toList();

      return RouteResult(
        points: points,
        distanceMeters: (summary['distance'] as num).toDouble(),
        durationSeconds: (summary['duration'] as num).toDouble(),
      );
    } on RoutingException {
      rethrow;
    } catch (e) {
      if (kDebugMode) debugPrint('[ORS] Parse error: $e');
      throw const RoutingException(
        'Lỗi xử lý dữ liệu tuyến đường. Thử lại sau.',
      );
    }
  }
}

