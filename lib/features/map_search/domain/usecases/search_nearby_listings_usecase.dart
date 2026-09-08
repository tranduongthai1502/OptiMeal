import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../listings/domain/entities/food_listing.dart';
import '../../../listings/domain/repositories/listings_repository.dart';
import '../entities/search_filter.dart';

class SearchNearbyListingsUseCase {
  final ListingsRepository listingsRepository;

  SearchNearbyListingsUseCase(this.listingsRepository);

  Future<Either<Failure, List<FoodListing>>> call({
    required double latitude,
    required double longitude,
    required SearchFilter filter,
  }) async {
    final result = await listingsRepository.getNearbyListings(
      latitude: latitude,
      longitude: longitude,
      radiusKm: filter.radiusKm,
      condition: filter.condition,
    );

    return result.map((listings) {
      return listings.where((item) {
        // Filter by remaining hours if specified
        if (filter.maxRemainingHours != null) {
          if (item.remainingTime.inHours > filter.maxRemainingHours!) {
            return false;
          }
        }
        // Filter excluded allergens
        if (filter.excludedAllergens.isNotEmpty) {
          for (final excluded in filter.excludedAllergens) {
            if (item.allergenTags.contains(excluded)) {
              return false;
            }
          }
        }
        return true;
      }).toList();
    });
  }
}
