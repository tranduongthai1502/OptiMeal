import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/network_info.dart';
import '../../data/datasources/listings_remote_data_source.dart';
import '../../data/repositories/listings_repository_impl.dart';
import '../../domain/entities/food_listing.dart';
import '../../domain/repositories/listings_repository.dart';
import '../../domain/usecases/create_listing_usecase.dart';
import '../../domain/usecases/get_listings_usecase.dart';

// Providers
final listingsRemoteDataSourceProvider = Provider<ListingsRemoteDataSource>((ref) {
  return ListingsFirebaseDataSourceImpl();
});

final listingsRepositoryProvider = Provider<ListingsRepository>((ref) {
  return ListingsRepositoryImpl(
    remoteDataSource: ref.watch(listingsRemoteDataSourceProvider),
    networkInfo: NetworkInfoImpl(),
  );
});

final getListingsUseCaseProvider = Provider<GetListingsUseCase>((ref) {
  return GetListingsUseCase(ref.watch(listingsRepositoryProvider));
});

final getListingDetailUseCaseProvider = Provider<GetListingDetailUseCase>((ref) {
  return GetListingDetailUseCase(ref.watch(listingsRepositoryProvider));
});

final createListingUseCaseProvider = Provider<CreateListingUseCase>((ref) {
  return CreateListingUseCase(ref.watch(listingsRepositoryProvider));
});

final cancelListingUseCaseProvider = Provider<CancelListingUseCase>((ref) {
  return CancelListingUseCase(ref.watch(listingsRepositoryProvider));
});

// Nearby listings FutureProvider with auto-refresh
final nearbyListingsProvider = FutureProvider.autoDispose<List<FoodListing>>((ref) async {
  final useCase = ref.watch(getListingsUseCaseProvider);
  // Default coordinate (HCMC Ben Thanh market) for demo
  final result = await useCase(
    latitude: 10.7769,
    longitude: 106.7009,
    radiusKm: AppConstants.defaultSearchRadiusKm,
  );
  return result.fold(
    (failure) => throw Exception(failure.message),
    (listings) => listings,
  );
});

// Single listing detail provider
final listingDetailProvider = FutureProvider.family.autoDispose<FoodListing, String>((ref, id) async {
  final useCase = ref.watch(getListingDetailUseCaseProvider);
  final result = await useCase(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (listing) => listing,
  );
});
