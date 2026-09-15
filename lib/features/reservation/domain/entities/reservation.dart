import '../../../../core/constants/app_constants.dart';

/// Status of a food hold/pickup reservation.
enum ReservationStatus {
  held, // 20-min hold timer running
  confirmed, // Receiver is on the way / confirmed pickup intent
  completed, // QR scanned / pickup confirmed by donor
  expired, // 20 minutes passed without pickup
  noShow, // User failed to show up without cancelling
  cancelled; // Cancelled by receiver or donor

  bool get isHeld => this == ReservationStatus.held;
  bool get isConfirmed => this == ReservationStatus.confirmed;
  bool get isCompleted => this == ReservationStatus.completed;
  bool get isExpired => this == ReservationStatus.expired;
  bool get isNoShow => this == ReservationStatus.noShow;
  bool get isCancelled => this == ReservationStatus.cancelled;
}

/// Domain entity representing a temporary claim/reservation for self-pickup with Double-handshake QR.
class Reservation {
  final String id;
  final String listingId;
  final String claimerId;
  final String ownerId;
  final ReservationStatus status;
  final DateTime heldAt;
  final DateTime expiresAt;
  final String qrCodeData;
  final String donorQrCodeData;
  final bool receiverConfirmed;
  final bool donorConfirmed;
  final DateTime? completedAt;

  const Reservation({
    required this.id,
    required this.listingId,
    required this.claimerId,
    required this.ownerId,
    required this.status,
    required this.heldAt,
    required this.expiresAt,
    required this.qrCodeData,
    this.donorQrCodeData = '',
    this.receiverConfirmed = true,
    this.donorConfirmed = false,
    this.completedAt,
  });

  /// Factory creating a fresh claim reservation for self-pickup
  factory Reservation.createHold({
    required String id,
    required String listingId,
    required String claimerId,
    required String ownerId,
    int durationMinutes = AppConstants.defaultReservationDurationMinutes,
  }) {
    final now = DateTime.now();
    return Reservation(
      id: id,
      listingId: listingId,
      claimerId: claimerId,
      ownerId: ownerId,
      status: ReservationStatus.held,
      heldAt: now,
      expiresAt: now.add(Duration(minutes: durationMinutes)),
      qrCodeData: 'OPTIMEAL-HANDSHAKE-RECEIVER-$id-$claimerId',
      donorQrCodeData: 'OPTIMEAL-HANDSHAKE-DONOR-$id-$ownerId',
      receiverConfirmed: true,
      donorConfirmed: false,
    );
  }

  bool get isDoubleHandshakeCompleted => receiverConfirmed && donorConfirmed;

  /// Checks if the reservation has passed its expiration time
  bool isExpiredAt(DateTime currentTime) {
    if (status == ReservationStatus.completed ||
        status == ReservationStatus.cancelled) {
      return false;
    }
    return currentTime.isAfter(expiresAt);
  }

  Duration remainingTimeFrom(DateTime currentTime) {
    if (isExpiredAt(currentTime)) return Duration.zero;
    return expiresAt.difference(currentTime);
  }

  Reservation copyWith({
    ReservationStatus? status,
    bool? receiverConfirmed,
    bool? donorConfirmed,
    DateTime? completedAt,
  }) {
    final updatedReceiverConfirmed = receiverConfirmed ?? this.receiverConfirmed;
    final updatedDonorConfirmed = donorConfirmed ?? this.donorConfirmed;
    final isFullyCompleted = updatedReceiverConfirmed && updatedDonorConfirmed;

    return Reservation(
      id: id,
      listingId: listingId,
      claimerId: claimerId,
      ownerId: ownerId,
      status: isFullyCompleted ? ReservationStatus.completed : (status ?? this.status),
      heldAt: heldAt,
      expiresAt: expiresAt,
      qrCodeData: qrCodeData,
      donorQrCodeData: donorQrCodeData,
      receiverConfirmed: updatedReceiverConfirmed,
      donorConfirmed: updatedDonorConfirmed,
      completedAt: isFullyCompleted ? (completedAt ?? DateTime.now()) : this.completedAt,
    );
  }
}
