import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/reservation.dart';
import '../repositories/reservation_repository.dart';

class CheckReservationExpiryUseCase {
  final ReservationRepository repository;

  CheckReservationExpiryUseCase(this.repository);

  /// Validates if a reservation has passed the 20-minute limit.
  /// If expired, updates status to expired and releases the listing.
  Future<Either<Failure, Reservation>> call(Reservation reservation,
      {DateTime? currentTime}) async {
    final now = currentTime ?? DateTime.now();

    if (reservation.isExpiredAt(now)) {
      if (reservation.status != ReservationStatus.expired) {
        return repository.markAsExpired(reservation.id);
      }
      return const Left(ReservationExpiredFailure());
    }

    return Right(reservation);
  }
}

class CreateReservationUseCase {
  final ReservationRepository repository;

  CreateReservationUseCase(this.repository);

  Future<Either<Failure, Reservation>> call({
    required String listingId,
    required String claimerId,
    required String ownerId,
  }) async {
    if (claimerId == ownerId) {
      return const Left(ReservationFailure(
          'Bạn không thể tự giữ chỗ thực phẩm của chính mình.'));
    }
    return repository.createHoldReservation(
      listingId: listingId,
      claimerId: claimerId,
      ownerId: ownerId,
    );
  }
}
