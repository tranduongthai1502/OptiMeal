import '../../domain/entities/reservation.dart';

class ReservationModel extends Reservation {
  const ReservationModel({
    required super.id,
    required super.listingId,
    required super.claimerId,
    required super.ownerId,
    required super.status,
    required super.heldAt,
    required super.expiresAt,
    required super.qrCodeData,
    super.completedAt,
  });

  factory ReservationModel.fromEntity(Reservation entity) {
    return ReservationModel(
      id: entity.id,
      listingId: entity.listingId,
      claimerId: entity.claimerId,
      ownerId: entity.ownerId,
      status: entity.status,
      heldAt: entity.heldAt,
      expiresAt: entity.expiresAt,
      qrCodeData: entity.qrCodeData,
      completedAt: entity.completedAt,
    );
  }

  factory ReservationModel.fromMap(Map<String, dynamic> map, String id) {
    return ReservationModel(
      id: id,
      listingId: map['listingId'] as String? ?? '',
      claimerId: map['claimerId'] as String? ?? '',
      ownerId: map['ownerId'] as String? ?? '',
      status: ReservationStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => ReservationStatus.held,
      ),
      heldAt: map['heldAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['heldAt'] as int)
          : DateTime.now(),
      expiresAt: map['expiresAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['expiresAt'] as int)
          : DateTime.now().add(const Duration(minutes: 20)),
      qrCodeData: map['qrCodeData'] as String? ?? '',
      completedAt: map['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'] as int)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'listingId': listingId,
      'claimerId': claimerId,
      'ownerId': ownerId,
      'status': status.name,
      'heldAt': heldAt.millisecondsSinceEpoch,
      'expiresAt': expiresAt.millisecondsSinceEpoch,
      'qrCodeData': qrCodeData,
      'completedAt': completedAt?.millisecondsSinceEpoch,
    };
  }
}
