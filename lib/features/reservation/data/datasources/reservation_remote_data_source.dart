import '../../domain/entities/reservation.dart';
import '../models/reservation_model.dart';

abstract class ReservationRemoteDataSource {
  Future<ReservationModel> createHoldReservation({
    required String listingId,
    required String claimerId,
    required String ownerId,
  });

  Future<ReservationModel> getReservationById(String id);

  Future<ReservationModel> confirmPickup({
    required String reservationId,
    required String qrCodeData,
  });

  Future<void> cancelReservation(String reservationId);

  Future<ReservationModel> markAsExpired(String reservationId);
}

class ReservationFirebaseDataSourceImpl implements ReservationRemoteDataSource {
  final Map<String, ReservationModel> _mockStorage = {};

  @override
  Future<ReservationModel> createHoldReservation({
    required String listingId,
    required String claimerId,
    required String ownerId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final id = 'res-${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();
    final model = ReservationModel(
      id: id,
      listingId: listingId,
      claimerId: claimerId,
      ownerId: ownerId,
      status: ReservationStatus.held,
      heldAt: now,
      expiresAt: now.add(const Duration(minutes: 20)),
      qrCodeData: 'OPTIMEAL-PICKUP-$id-$listingId',
    );
    _mockStorage[id] = model;
    return model;
  }

  @override
  Future<ReservationModel> getReservationById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (_mockStorage.containsKey(id)) {
      return _mockStorage[id]!;
    }
    // Return sample reservation if not found in mock storage
    final now = DateTime.now();
    return ReservationModel(
      id: id,
      listingId: 'listing-001',
      claimerId: 'user-claimer-01',
      ownerId: 'store-touslesjours',
      status: ReservationStatus.held,
      heldAt: now.subtract(const Duration(minutes: 5)),
      expiresAt: now.add(const Duration(minutes: 15)),
      qrCodeData: 'OPTIMEAL-PICKUP-$id-listing-001',
    );
  }

  @override
  Future<ReservationModel> confirmPickup({
    required String reservationId,
    required String qrCodeData,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final current = await getReservationById(reservationId);
    final confirmed = ReservationModel(
      id: current.id,
      listingId: current.listingId,
      claimerId: current.claimerId,
      ownerId: current.ownerId,
      status: ReservationStatus.completed,
      heldAt: current.heldAt,
      expiresAt: current.expiresAt,
      qrCodeData: current.qrCodeData,
      completedAt: DateTime.now(),
    );
    _mockStorage[reservationId] = confirmed;
    return confirmed;
  }

  @override
  Future<void> cancelReservation(String reservationId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (_mockStorage.containsKey(reservationId)) {
      final current = _mockStorage[reservationId]!;
      _mockStorage[reservationId] = ReservationModel(
        id: current.id,
        listingId: current.listingId,
        claimerId: current.claimerId,
        ownerId: current.ownerId,
        status: ReservationStatus.cancelled,
        heldAt: current.heldAt,
        expiresAt: current.expiresAt,
        qrCodeData: current.qrCodeData,
      );
    }
  }

  @override
  Future<ReservationModel> markAsExpired(String reservationId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final current = await getReservationById(reservationId);
    final expired = ReservationModel(
      id: current.id,
      listingId: current.listingId,
      claimerId: current.claimerId,
      ownerId: current.ownerId,
      status: ReservationStatus.expired,
      heldAt: current.heldAt,
      expiresAt: current.expiresAt,
      qrCodeData: current.qrCodeData,
    );
    _mockStorage[reservationId] = expired;
    return expired;
  }
}
