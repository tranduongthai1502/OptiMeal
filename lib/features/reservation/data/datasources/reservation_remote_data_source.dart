import 'package:cloud_firestore/cloud_firestore.dart';

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

/// Firestore implementation for Reservation data source.
/// Collection: `reservations`
class ReservationFirebaseDataSourceImpl implements ReservationRemoteDataSource {
  final FirebaseFirestore _firestore;

  ReservationFirebaseDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('reservations');

  @override
  Future<ReservationModel> createHoldReservation({
    required String listingId,
    required String claimerId,
    required String ownerId,
  }) async {
    final docRef = _col.doc(); // auto-generated ID
    final id = docRef.id;
    final now = DateTime.now();

    final model = ReservationModel(
      id: id,
      listingId: listingId,
      claimerId: claimerId,
      ownerId: ownerId,
      status: ReservationStatus.held,
      heldAt: now,
      expiresAt: now.add(const Duration(minutes: 20)),
      qrCodeData: 'OPTIMEAL-HANDSHAKE-RECEIVER-$id-$claimerId',
      donorQrCodeData: 'OPTIMEAL-HANDSHAKE-DONOR-$id-$ownerId',
    );

    await docRef.set(model.toMap());
    return model;
  }

  @override
  Future<ReservationModel> getReservationById(String id) async {
    final snapshot = await _col.doc(id).get();
    if (!snapshot.exists) {
      throw Exception('Reservation $id not found');
    }
    return ReservationModel.fromMap(snapshot.data()!, snapshot.id);
  }

  @override
  Future<ReservationModel> confirmPickup({
    required String reservationId,
    required String qrCodeData,
  }) async {
    final docRef = _col.doc(reservationId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) throw Exception('Reservation not found');

    final current = ReservationModel.fromMap(snapshot.data()!, snapshot.id);

    // Double-handshake: determine which side is confirming
    final isReceiverQr = qrCodeData.contains('RECEIVER');
    final updatedReceiverConfirmed =
        isReceiverQr ? true : current.receiverConfirmed;
    final updatedDonorConfirmed = !isReceiverQr ? true : current.donorConfirmed;
    final isCompleted = updatedReceiverConfirmed && updatedDonorConfirmed;

    final updates = <String, dynamic>{
      'receiverConfirmed': updatedReceiverConfirmed,
      'donorConfirmed': updatedDonorConfirmed,
      'status':
          isCompleted ? ReservationStatus.completed.name : current.status.name,
      if (isCompleted) 'completedAt': DateTime.now().millisecondsSinceEpoch,
    };

    await docRef.update(updates);

    final updated = await docRef.get();
    return ReservationModel.fromMap(updated.data()!, updated.id);
  }

  @override
  Future<void> cancelReservation(String reservationId) async {
    await _col.doc(reservationId).update({
      'status': ReservationStatus.cancelled.name,
    });
  }

  @override
  Future<ReservationModel> markAsExpired(String reservationId) async {
    await _col.doc(reservationId).update({
      'status': ReservationStatus.expired.name,
    });
    final snapshot = await _col.doc(reservationId).get();
    return ReservationModel.fromMap(snapshot.data()!, snapshot.id);
  }
}
