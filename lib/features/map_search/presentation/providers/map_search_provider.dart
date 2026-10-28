import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../../listings/domain/entities/food_listing.dart';
import '../../../listings/presentation/providers/listings_provider.dart';
import '../../domain/entities/search_filter.dart';
import '../../domain/usecases/search_nearby_listings_usecase.dart';
import 'location_provider.dart';

/// Toạ độ mặc định: trung tâm Đà Nẵng.
const kDefaultCenter = LatLng(16.0544, 108.2022);
const kDefaultCenterLat = 16.0544;
const kDefaultCenterLng = 108.2022;

// ── Use case provider ────────────────────────────────────────────────────────

final searchNearbyListingsUseCaseProvider =
    Provider<SearchNearbyListingsUseCase>((ref) {
  return SearchNearbyListingsUseCase(ref.watch(listingsRepositoryProvider));
});

// ── Filter & view mode ───────────────────────────────────────────────────────

/// Bộ lọc hiện tại (bán kính, loại, v.v.)
final searchFilterProvider = StateProvider<SearchFilter>((ref) {
  return const SearchFilter();
});

/// Mode: Map view vs List view.
final isMapViewProvider = StateProvider<bool>((ref) => false);

// ── Stream realtime các đơn gần đây ─────────────────────────────────────────

/// StreamProvider lắng nghe Firestore realtime.
/// Tự dùng vị trí GPS nếu có, fallback về Đà Nẵng.
/// Khi người dùng di chuyển > 30m, locationProvider cập nhật
/// → provider này rebuild → stream mới với trung tâm mới.
final nearbyListingsStreamProvider =
    StreamProvider.autoDispose<List<FoodListing>>((ref) {
  final locationState = ref.watch(locationProvider);
  final filter = ref.watch(searchFilterProvider);
  final repo = ref.watch(listingsRepositoryProvider);

  final lat = locationState.position?.latitude ?? kDefaultCenterLat;
  final lng = locationState.position?.longitude ?? kDefaultCenterLng;

  return repo.watchNearbyListings(
    latitude: lat,
    longitude: lng,
    radiusKm: filter.radiusKm,
  );
});

/// Alias backward-compat: provider cũ vẫn hoạt động,
/// nay trỏ vào AsyncValue của stream mới.
final filteredNearbyListingsProvider =
    Provider.autoDispose<AsyncValue<List<FoodListing>>>((ref) {
  return ref.watch(nearbyListingsStreamProvider);
});
