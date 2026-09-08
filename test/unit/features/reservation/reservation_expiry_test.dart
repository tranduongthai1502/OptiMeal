import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optimeal/core/constants/app_constants.dart';
import 'package:optimeal/core/errors/failures.dart';
import 'package:optimeal/features/reservation/domain/entities/reservation.dart';
import 'package:optimeal/features/reservation/domain/repositories/reservation_repository.dart';
import 'package:optimeal/features/reservation/domain/usecases/check_reservation_expiry_usecase.dart';

class MockReservationRepository extends Mock implements ReservationRepository {}

void main() {
  late MockReservationRepository mockRepository;
  late CheckReservationExpiryUseCase useCase;

  setUp(() {
    mockRepository = MockReservationRepository();
    useCase = CheckReservationExpiryUseCase(mockRepository);
  });

  group('Reservation Expiry Logic Tests', () {
    final baseTime = DateTime(2026, 9, 8, 12, 0, 0);

    test('should NOT be expired when within 20 minutes window', () async {
      final reservation = Reservation.createHold(
        id: 'res-test-1',
        listingId: 'listing-001',
        claimerId: 'user-claimer',
        ownerId: 'store-owner',
        durationMinutes: AppConstants.defaultReservationDurationMinutes,
      );

      // Check after 10 minutes
      final checkTime = reservation.heldAt.add(const Duration(minutes: 10));
      expect(reservation.isExpiredAt(checkTime), isFalse);
      expect(reservation.remainingTimeFrom(checkTime).inMinutes, 10);

      final result = await useCase(reservation, currentTime: checkTime);
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be right'),
        (res) => expect(res.status, ReservationStatus.held),
      );
    });

    test('should be expired when 20 minutes have elapsed and mark on repository', () async {
      final reservation = Reservation(
        id: 'res-test-2',
        listingId: 'listing-001',
        claimerId: 'user-claimer',
        ownerId: 'store-owner',
        status: ReservationStatus.held,
        heldAt: baseTime,
        expiresAt: baseTime.add(const Duration(minutes: 20)),
        qrCodeData: 'TEST-QR',
      );

      // Check after 21 minutes (expired)
      final checkTime = baseTime.add(const Duration(minutes: 21));
      expect(reservation.isExpiredAt(checkTime), isTrue);

      final expiredReservation = reservation.copyWith(status: ReservationStatus.expired);
      when(() => mockRepository.markAsExpired(reservation.id))
          .thenAnswer((_) async => Right(expiredReservation));

      final result = await useCase(reservation, currentTime: checkTime);

      verify(() => mockRepository.markAsExpired(reservation.id)).called(1);
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be right with expired reservation'),
        (res) => expect(res.status, ReservationStatus.expired),
      );
    });

    test('should return Failure if already marked as expired', () async {
      final alreadyExpired = Reservation(
        id: 'res-test-3',
        listingId: 'listing-001',
        claimerId: 'user-claimer',
        ownerId: 'store-owner',
        status: ReservationStatus.expired,
        heldAt: baseTime,
        expiresAt: baseTime.add(const Duration(minutes: 20)),
        qrCodeData: 'TEST-QR',
      );

      final checkTime = baseTime.add(const Duration(minutes: 25));
      final result = await useCase(alreadyExpired, currentTime: checkTime);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ReservationExpiredFailure>()),
        (_) => fail('Should fail with ReservationExpiredFailure'),
      );
    });
  });
}
