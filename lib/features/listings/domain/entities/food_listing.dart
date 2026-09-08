import '../../../auth/domain/entities/user_entity.dart';

/// Condition of the food listing: free (0 VND) or paid (discounted price).
enum FoodCondition {
  free,
  paid;

  bool get isFree => this == FoodCondition.free;
  bool get isPaid => this == FoodCondition.paid;
}

/// Status lifecycle of a surplus food listing.
enum ListingStatus {
  available,
  reserved,
  completed,
  expired,
  cancelled;

  bool get isAvailable => this == ListingStatus.available;
  bool get isReserved => this == ListingStatus.reserved;
  bool get isCompleted => this == ListingStatus.completed;
  bool get isExpired => this == ListingStatus.expired;
  bool get isCancelled => this == ListingStatus.cancelled;
}

/// Domain entity representing a surplus food item published for self-pickup.
class FoodListing {
  final String id;
  final String title;
  final String description;
  final List<String> photos;
  final int quantity; // e.g. 2 portions / 3 boxes
  final FoodCondition condition;
  final double? price; // Nullable if condition is free
  final DateTime expiresAt;
  final DateTime pickupWindowStart;
  final DateTime pickupWindowEnd;
  final double latitude;
  final double longitude;
  final String addressText;
  final List<String> allergenTags;
  final String ownerId;
  final String ownerName;
  final UserRole ownerType;
  final ListingStatus status;
  final DateTime createdAt;

  const FoodListing({
    required this.id,
    required this.title,
    required this.description,
    required this.photos,
    required this.quantity,
    required this.condition,
    this.price,
    required this.expiresAt,
    required this.pickupWindowStart,
    required this.pickupWindowEnd,
    required this.latitude,
    required this.longitude,
    required this.addressText,
    required this.allergenTags,
    required this.ownerId,
    required this.ownerName,
    required this.ownerType,
    required this.status,
    required this.createdAt,
  });

  bool get isStillValid =>
      status == ListingStatus.available && DateTime.now().isBefore(expiresAt);

  Duration get remainingTime => expiresAt.difference(DateTime.now());
}
