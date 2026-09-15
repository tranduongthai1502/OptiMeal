import '../../../auth/domain/entities/user_entity.dart';

/// Condition of the food listing: free (0 VND) or paid (discounted price).
enum FoodCondition {
  free,
  paid;

  bool get isFree => this == FoodCondition.free;
  bool get isPaid => this == FoodCondition.paid;
}

/// Category classification for surplus ingredients and charity meals.
enum FoodCategory {
  vegetables, // Rau củ & Nông sản
  dryGoods, // Đồ khô & Ngũ cốc
  freshMeatFish, // Thực phẩm tươi sống
  cookedMeals, // Đồ ăn nấu sẵn
  charityMealPoint; // Điểm phát cơm từ thiện miễn phí

  String get displayName {
    switch (this) {
      case FoodCategory.vegetables:
        return 'Rau củ & Nông sản';
      case FoodCategory.dryGoods:
        return 'Đồ khô & Ngũ cốc';
      case FoodCategory.freshMeatFish:
        return 'Tươi sống';
      case FoodCategory.cookedMeals:
        return 'Đồ ăn nấu sẵn';
      case FoodCategory.charityMealPoint:
        return 'Điểm phát cơm từ thiện';
    }
  }

  bool get isCharityMealPoint => this == FoodCategory.charityMealPoint;
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
  final int quantity; // e.g. 2 portions / 3 boxes / 30 kg
  final String unit; // 'kg', 'phần', 'hộp', 'suất'
  final FoodCategory category;
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
  final bool isCharityPoint;
  final DateTime createdAt;

  const FoodListing({
    required this.id,
    required this.title,
    required this.description,
    required this.photos,
    required this.quantity,
    this.unit = 'phần',
    this.category = FoodCategory.cookedMeals,
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
    this.isCharityPoint = false,
    required this.createdAt,
  });

  bool get isStillValid =>
      status == ListingStatus.available && DateTime.now().isBefore(expiresAt);

  Duration get remainingTime => expiresAt.difference(DateTime.now());

  bool get isExpiringSoon =>
      remainingTime.inHours <= 24 && remainingTime.inHours >= 0;
}
