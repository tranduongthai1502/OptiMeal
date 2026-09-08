import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/food_listing.dart';

class FoodListingModel extends FoodListing {
  const FoodListingModel({
    required super.id,
    required super.title,
    required super.description,
    required super.photos,
    required super.quantity,
    required super.condition,
    super.price,
    required super.expiresAt,
    required super.pickupWindowStart,
    required super.pickupWindowEnd,
    required super.latitude,
    required super.longitude,
    required super.addressText,
    required super.allergenTags,
    required super.ownerId,
    required super.ownerName,
    required super.ownerType,
    required super.status,
    required super.createdAt,
  });

  factory FoodListingModel.fromEntity(FoodListing entity) {
    return FoodListingModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      photos: entity.photos,
      quantity: entity.quantity,
      condition: entity.condition,
      price: entity.price,
      expiresAt: entity.expiresAt,
      pickupWindowStart: entity.pickupWindowStart,
      pickupWindowEnd: entity.pickupWindowEnd,
      latitude: entity.latitude,
      longitude: entity.longitude,
      addressText: entity.addressText,
      allergenTags: entity.allergenTags,
      ownerId: entity.ownerId,
      ownerName: entity.ownerName,
      ownerType: entity.ownerType,
      status: entity.status,
      createdAt: entity.createdAt,
    );
  }

  factory FoodListingModel.fromMap(Map<String, dynamic> map, String id) {
    return FoodListingModel(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      photos: (map['photos'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      condition:
          map['condition'] == 'paid' ? FoodCondition.paid : FoodCondition.free,
      price: (map['price'] as num?)?.toDouble(),
      expiresAt: map['expiresAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['expiresAt'] as int)
          : DateTime.now().add(const Duration(hours: 4)),
      pickupWindowStart: map['pickupWindowStart'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['pickupWindowStart'] as int)
          : DateTime.now(),
      pickupWindowEnd: map['pickupWindowEnd'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['pickupWindowEnd'] as int)
          : DateTime.now().add(const Duration(hours: 2)),
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      addressText: map['addressText'] as String? ?? '',
      allergenTags: (map['allergenTags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      ownerId: map['ownerId'] as String? ?? '',
      ownerName: map['ownerName'] as String? ?? 'Người dùng',
      ownerType:
          map['ownerType'] == 'store' ? UserRole.store : UserRole.individual,
      status: ListingStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => ListingStatus.available,
      ),
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'photos': photos,
      'quantity': quantity,
      'condition': condition.name,
      'price': price,
      'expiresAt': expiresAt.millisecondsSinceEpoch,
      'pickupWindowStart': pickupWindowStart.millisecondsSinceEpoch,
      'pickupWindowEnd': pickupWindowEnd.millisecondsSinceEpoch,
      'latitude': latitude,
      'longitude': longitude,
      'addressText': addressText,
      'allergenTags': allergenTags,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerType': ownerType.name,
      'status': status.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
