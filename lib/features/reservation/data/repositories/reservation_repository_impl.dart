import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/repositories/reservation_repository.dart';
import '../datasources/reservation_remote_data_source.dart';

class ReservationRepositoryImpl implements ReservationRepository {
  final ReservationRemoteDataSource remoteDataSource;

  ReservationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Reservation>> createHoldReservation({
    required String listingId,
    required String claimerId,
    required String ownerId,
  }) async {
    try {
      final model = await remoteDataSource.createHoldReservation(
        listingId: listingId,
        claimerId: claimerId,
        ownerId: ownerId,
      );
      return Right(model);
    } catch (e) {
      return Left(ReservationFailure('Lỗi tạo giữ chỗ: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Reservation>> getReservationById(String id) async {
    try {
      final model = await remoteDataSource.getReservationById(id);
      return Right(model);
    } catch (e) {
      return const Left(
          ReservationFailure('Không tìm thấy thông tin giữ chỗ.'));
    }
  }

  @override
  Future<Either<Failure, Reservation>> confirmPickup({
    required String reservationId,
    required String qrCodeData,
  }) async {
    try {
      final model = await remoteDataSource.confirmPickup(
        reservationId: reservationId,
        qrCodeData: qrCodeData,
      );
      return Right(model);
    } catch (e) {
      return const Left(ReservationFailure('Xác nhận giao nhận thất bại.'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelReservation(String reservationId) async {
    try {
      await remoteDataSource.cancelReservation(reservationId);
      return const Right(null);
    } catch (e) {
      return Left(ReservationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Reservation>> markAsExpired(
      String reservationId) async {
    try {
      final model = await remoteDataSource.markAsExpired(reservationId);
      return Right(model);
    } catch (e) {
      return Left(ReservationFailure(e.toString()));
    }
  }
}
