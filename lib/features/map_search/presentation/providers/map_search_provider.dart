import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../listings/domain/entities/food_listing.dart';
import '../../../listings/presentation/providers/listings_provider.dart';
import '../../domain/entities/search_filter.dart';
import '../../domain/usecases/search_nearby_listings_usecase.dart';

final searchNearbyListingsUseCaseProvider =
    Provider<SearchNearbyListingsUseCase>((ref) {
  return SearchNearbyListingsUseCase(ref.watch(listingsRepositoryProvider));
});

// Current active filter provider
final searchFilterProvider = StateProvider<SearchFilter>((ref) {
  return const SearchFilter();
});

// Mode: Map view vs List view
final isMapViewProvider = StateProvider<bool>((ref) => false);

// Filtered listings provider
final filteredNearbyListingsProvider =
    FutureProvider.autoDispose<List<FoodListing>>((ref) async {
  final useCase = ref.watch(searchNearbyListingsUseCaseProvider);
  final filter = ref.watch(searchFilterProvider);

  // Default coordinate (HCMC central coordinates)
  final result = await useCase(
    latitude: 10.7769,
    longitude: 106.7009,
    filter: filter,
  );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (listings) => listings,
  );
});
