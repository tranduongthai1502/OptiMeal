import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../data/datasources/listings_remote_data_source.dart';
import '../../data/repositories/listings_repository_impl.dart';
import '../../domain/entities/food_listing.dart';
import '../../domain/repositories/listings_repository.dart';
import '../../domain/usecases/create_listing_usecase.dart';
import '../../domain/usecases/get_listings_usecase.dart';

// ── Infrastructure providers ────────────────────────────────────────────────

final listingsRemoteDataSourceProvider = Provider<ListingsRemoteDataSource>((
  ref,
) {
  return ListingsFirebaseDataSourceImpl();
});

final listingsRepositoryProvider = Provider<ListingsRepository>((ref) {
  return ListingsRepositoryImpl(
    remoteDataSource: ref.watch(listingsRemoteDataSourceProvider),
    networkInfo: NetworkInfoImpl(),
  );
});

// ── UseCase providers ────────────────────────────────────────────────────────

final getListingsUseCaseProvider = Provider<GetListingsUseCase>((ref) {
  return GetListingsUseCase(ref.watch(listingsRepositoryProvider));
});

final getListingDetailUseCaseProvider = Provider<GetListingDetailUseCase>((
  ref,
) {
  return GetListingDetailUseCase(ref.watch(listingsRepositoryProvider));
});

final createListingUseCaseProvider = Provider<CreateListingUseCase>((ref) {
  return CreateListingUseCase(ref.watch(listingsRepositoryProvider));
});

final cancelListingUseCaseProvider = Provider<CancelListingUseCase>((ref) {
  return CancelListingUseCase(ref.watch(listingsRepositoryProvider));
});

// ── Nearby listings (one-shot FutureProvider) ───────────────────────────────

/// FutureProvider one-shot (dùng cho màn hình detail và các nơi không cần realtime).
final nearbyListingsProvider = FutureProvider.autoDispose<List<FoodListing>>(
  (ref) async {
    final useCase = ref.watch(getListingsUseCaseProvider);
    final result = await useCase(
      latitude: 10.7769,
      longitude: 106.7009,
      radiusKm: AppConstants.defaultSearchRadiusKm,
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (listings) => listings,
    );
  },
);

// ── Single listing detail ────────────────────────────────────────────────────

final listingDetailProvider =
    FutureProvider.family.autoDispose<FoodListing, String>((ref, id) async {
  final useCase = ref.watch(getListingDetailUseCaseProvider);
  final result = await useCase(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (listing) => listing,
  );
});

// ── Claim listing (Firestore transaction) ────────────────────────────────────

/// Typedef hàm nhận đơn để inject vào widget.
typedef ClaimListingFn = Future<Either<Failure, bool>> Function(
  String id,
  String receiverId,
);

/// Provider trả về hàm claimListing từ repository.
/// Dùng trong ListingBottomSheet: ref.read(claimListingProvider)(id, userId).
final claimListingProvider = Provider<ClaimListingFn>((ref) {
  final repo = ref.watch(listingsRepositoryProvider);
  return (String id, String receiverId) => repo.claimListing(id, receiverId);
});
