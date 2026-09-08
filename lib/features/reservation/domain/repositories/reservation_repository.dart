import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/reservation.dart';

abstract class ReservationRepository {
  Future<Either<Failure, Reservation>> createHoldReservation({
    required String listingId,
    required String claimerId,
    required String ownerId,
  });

  Future<Either<Failure, Reservation>> getReservationById(String id);

  /// Confirms pickup (e.g. via QR code match or manual button)
  Future<Either<Failure, Reservation>> confirmPickup({
    required String reservationId,
    required String qrCodeData,
  });

  /// Cancels reservation (releases food back to available)
  Future<Either<Failure, void>> cancelReservation(String reservationId);

  /// Checks and marks expired reservation, releasing listing
  Future<Either<Failure, Reservation>> markAsExpired(String reservationId);
}
