import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optimeal/core/errors/failures.dart';
import 'package:optimeal/features/reservation/domain/entities/reservation.dart';
import 'package:optimeal/features/reservation/domain/repositories/reservation_repository.dart';
import 'package:optimeal/features/reservation/domain/usecases/check_reservation_expiry_usecase.dart';
import 'package:optimeal/features/reservation/domain/usecases/confirm_pickup_usecase.dart';

class MockReservationRepository extends Mock implements ReservationRepository {}

void main() {
  late MockReservationRepository mockRepository;

  setUp(() {
    mockRepository = MockReservationRepository();
  });

  group('CreateReservationUseCase', () {
    test('rejects a user reserving their own listing', () async {
      final useCase = CreateReservationUseCase(mockRepository);

      final result = await useCase(
        listingId: 'listing-1',
        claimerId: 'user-1',
        ownerId: 'user-1',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ReservationFailure>()),
        (_) => fail('Expected a reservation failure'),
      );
      verifyNever(
        () => mockRepository.createHoldReservation(
          listingId: any(named: 'listingId'),
          claimerId: any(named: 'claimerId'),
          ownerId: any(named: 'ownerId'),
        ),
      );
    });

    test('creates a hold for another user', () async {
      final useCase = CreateReservationUseCase(mockRepository);
      final reservation = Reservation.createHold(
        id: 'reservation-1',
        listingId: 'listing-1',
        claimerId: 'claimer-1',
        ownerId: 'owner-1',
      );
      when(
        () => mockRepository.createHoldReservation(
          listingId: 'listing-1',
          claimerId: 'claimer-1',
          ownerId: 'owner-1',
        ),
      ).thenAnswer((_) async => Right(reservation));

      final result = await useCase(
        listingId: 'listing-1',
        claimerId: 'claimer-1',
        ownerId: 'owner-1',
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected a created reservation'),
        (created) => expect(created.id, reservation.id),
      );
      verify(
        () => mockRepository.createHoldReservation(
          listingId: 'listing-1',
          claimerId: 'claimer-1',
          ownerId: 'owner-1',
        ),
      ).called(1);
    });
  });

  group('ConfirmPickupUseCase', () {
    late ConfirmPickupUseCase useCase;

    setUp(() {
      useCase = ConfirmPickupUseCase(mockRepository);
    });

    test('rejects an empty QR code without calling the repository', () async {
      final result = await useCase(
        reservationId: 'reservation-1',
        qrCodeData: '  ',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ReservationFailure>()),
        (_) => fail('Expected an invalid QR failure'),
      );
      verifyNever(
        () => mockRepository.confirmPickup(
          reservationId: any(named: 'reservationId'),
          qrCodeData: any(named: 'qrCodeData'),
        ),
      );
    });

    test('forwards a QR code and returns the confirmed reservation', () async {
      final reservation = Reservation.createHold(
        id: 'reservation-1',
        listingId: 'listing-1',
        claimerId: 'claimer-1',
        ownerId: 'owner-1',
      );
      const qrCodeData = 'OPTIMEAL-HANDSHAKE-RECEIVER-reservation-1-claimer-1';
      when(
        () => mockRepository.confirmPickup(
          reservationId: 'reservation-1',
          qrCodeData: qrCodeData,
        ),
      ).thenAnswer((_) async => Right(reservation));

      final result = await useCase(
        reservationId: 'reservation-1',
        qrCodeData: qrCodeData,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected pickup confirmation'),
        (confirmed) => expect(confirmed.id, reservation.id),
      );
      verify(
        () => mockRepository.confirmPickup(
          reservationId: 'reservation-1',
          qrCodeData: qrCodeData,
        ),
      ).called(1);
    });

    test('returns a repository failure when QR confirmation fails', () async {
      const failure = ReservationFailure('QR code không khớp.');
      when(
        () => mockRepository.confirmPickup(
          reservationId: 'reservation-1',
          qrCodeData: 'invalid-qr',
        ),
      ).thenAnswer((_) async => const Left(failure));

      final result = await useCase(
        reservationId: 'reservation-1',
        qrCodeData: 'invalid-qr',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (returnedFailure) => expect(returnedFailure, failure),
        (_) => fail('Expected the repository failure'),
      );
    });
  });
}
