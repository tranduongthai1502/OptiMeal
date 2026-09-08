import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optimeal/features/auth/domain/entities/user_entity.dart';
import 'package:optimeal/features/listings/domain/entities/food_listing.dart';
import 'package:optimeal/features/listings/domain/repositories/listings_repository.dart';
import 'package:optimeal/features/listings/domain/usecases/create_listing_usecase.dart';

class MockListingsRepository extends Mock implements ListingsRepository {}

void main() {
  late MockListingsRepository mockRepository;
  late CreateListingUseCase useCase;

  setUp(() {
    mockRepository = MockListingsRepository();
    useCase = CreateListingUseCase(mockRepository);
  });

  group('CreateListingUseCase Tests', () {
    final now = DateTime.now();

    FoodListing createSampleListing({
      String title = 'Bánh mì sandwich',
      int quantity = 2,
      FoodCondition condition = FoodCondition.free,
      double? price,
      DateTime? expiresAt,
      DateTime? pickupStart,
      DateTime? pickupEnd,
    }) {
      return FoodListing(
        id: 'listing-test',
        title: title,
        description: 'Bánh mì tươi trong ngày',
        photos: const [],
        quantity: quantity,
        condition: condition,
        price: price,
        expiresAt: expiresAt ?? now.add(const Duration(hours: 4)),
        pickupWindowStart: pickupStart ?? now,
        pickupWindowEnd: pickupEnd ?? now.add(const Duration(hours: 2)),
        latitude: 10.7769,
        longitude: 106.7009,
        addressText: '180 Hai Bà Trưng, Quận 1',
        allergenTags: const [],
        ownerId: 'owner-1',
        ownerName: 'Cửa hàng bánh mì',
        ownerType: UserRole.store,
        status: ListingStatus.available,
        createdAt: now,
      );
    }

    test('should return failure when title is empty', () async {
      final listing = createSampleListing(title: '   ');
      final result = await useCase(listing);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.code, 'INVALID_TITLE'),
        (_) => fail('Should have failed'),
      );
    });

    test('should return failure when quantity <= 0', () async {
      final listing = createSampleListing(quantity: 0);
      final result = await useCase(listing);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.code, 'INVALID_QUANTITY'),
        (_) => fail('Should have failed'),
      );
    });

    test('should return failure when paid listing has no price or price <= 0',
        () async {
      final listing = createSampleListing(
        condition: FoodCondition.paid,
        price: 0,
      );
      final result = await useCase(listing);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.code, 'INVALID_PRICE'),
        (_) => fail('Should have failed'),
      );
    });

    test('should return created listing when inputs are valid', () async {
      final validListing = createSampleListing();
      when(() => mockRepository.createListing(validListing))
          .thenAnswer((_) async => Right(validListing));

      final result = await useCase(validListing);

      verify(() => mockRepository.createListing(validListing)).called(1);
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be right'),
        (created) => expect(created.title, 'Bánh mì sandwich'),
      );
    });
  });
}
