import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/reservation.dart';
import '../repositories/reservation_repository.dart';

class ConfirmPickupUseCase {
  final ReservationRepository repository;

  ConfirmPickupUseCase(this.repository);

  Future<Either<Failure, Reservation>> call({
    required String reservationId,
    required String qrCodeData,
  }) async {
    if (qrCodeData.trim().isEmpty) {
      return const Left(ReservationFailure('Mã QR không hợp lệ.'));
    }
    return repository.confirmPickup(
      reservationId: reservationId,
      qrCodeData: qrCodeData,
    );
  }
}

class CancelReservationUseCase {
  final ReservationRepository repository;

  CancelReservationUseCase(this.repository);

  Future<Either<Failure, void>> call(String reservationId) {
    return repository.cancelReservation(reservationId);
  }
}
