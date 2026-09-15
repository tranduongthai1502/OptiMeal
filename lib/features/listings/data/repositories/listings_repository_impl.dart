import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/food_listing.dart';
import '../../domain/repositories/listings_repository.dart';
import '../datasources/listings_remote_data_source.dart';
import '../models/food_listing_model.dart';

class ListingsRepositoryImpl implements ListingsRepository {
  final ListingsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ListingsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<FoodListing>>> getNearbyListings({
    required double latitude,
    required double longitude,
    required double radiusKm,
    FoodCondition? condition,
    FoodCategory? category,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final models = await remoteDataSource.getNearbyListings(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        condition: condition,
        category: category,
      );
      return Right(models);
    } on AppException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FoodListing>> getListingById(String id) async {
    try {
      final model = await remoteDataSource.getListingById(id);
      return Right(model);
    } catch (e) {
      return Left(ServerFailure('Không tìm thấy tin đăng: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, FoodListing>> createListing(
      FoodListing listing) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final model = FoodListingModel.fromEntity(listing);
      final created = await remoteDataSource.createListing(model);
      return Right(created);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FoodListing>> updateListingStatus(
    String id,
    ListingStatus newStatus,
  ) async {
    try {
      final updated = await remoteDataSource.updateListingStatus(id, newStatus);
      return Right(updated);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelListing(String id, String ownerId) async {
    try {
      await remoteDataSource.cancelListing(id, ownerId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
