import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/food_listing.dart';
import '../repositories/listings_repository.dart';

class GetListingsUseCase {
  final ListingsRepository repository;

  GetListingsUseCase(this.repository);

  Future<Either<Failure, List<FoodListing>>> call({
    required double latitude,
    required double longitude,
    required double radiusKm,
    FoodCondition? condition,
  }) {
    return repository.getNearbyListings(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      condition: condition,
    );
  }
}

class GetListingDetailUseCase {
  final ListingsRepository repository;

  GetListingDetailUseCase(this.repository);

  Future<Either<Failure, FoodListing>> call(String id) {
    if (id.isEmpty) {
      return Future.value(const Left(ServerFailure('Mã tin đăng không hợp lệ.')));
    }
    return repository.getListingById(id);
  }
}

class CancelListingUseCase {
  final ListingsRepository repository;

  CancelListingUseCase(this.repository);

  Future<Either<Failure, void>> call(String id, String ownerId) {
    return repository.cancelListing(id, ownerId);
  }
}
