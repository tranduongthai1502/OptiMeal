import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/food_listing.dart';

/// Repository contract for Surplus Food Listings.
abstract class ListingsRepository {
  /// Fetches all active listings around a coordinate within a radius.
  Future<Either<Failure, List<FoodListing>>> getNearbyListings({
    required double latitude,
    required double longitude,
    required double radiusKm,
    FoodCondition? condition,
    FoodCategory? category,
  });

  /// Fetches single listing detail by ID.
  Future<Either<Failure, FoodListing>> getListingById(String id);

  /// Creates a new surplus food listing.
  Future<Either<Failure, FoodListing>> createListing(FoodListing listing);

  /// Updates listing status (e.g. reserved, completed, cancelled).
  Future<Either<Failure, FoodListing>> updateListingStatus(
    String id,
    ListingStatus newStatus,
  );

  /// Cancels a listing by owner.
  Future<Either<Failure, void>> cancelListing(String id, String ownerId);
}
