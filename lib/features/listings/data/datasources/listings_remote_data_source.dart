import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/food_listing.dart';
import '../models/food_listing_model.dart';

abstract class ListingsRemoteDataSource {
  Future<List<FoodListingModel>> getNearbyListings({
    required double latitude,
    required double longitude,
    required double radiusKm,
    FoodCondition? condition,
  });

  Future<FoodListingModel> getListingById(String id);

  Future<FoodListingModel> createListing(FoodListingModel listing);

  Future<FoodListingModel> updateListingStatus(
      String id, ListingStatus newStatus);

  Future<void> cancelListing(String id, String ownerId);
}

class ListingsFirebaseDataSourceImpl implements ListingsRemoteDataSource {
  // In-memory mock list for initial scaffold and development testing
  final List<FoodListingModel> _mockListings = [
    FoodListingModel(
      id: 'listing-001',
      title: 'Bánh mì ngũ cốc & Croissant cuối ngày',
      description:
          'Còn dư 5 ổ bánh mì ngũ cốc và 3 bánh sừng trâu nướng mới sáng nay từ tiệm bánh Tous Les Jours. Đóng gói sạch sẽ trong túi giấy thực phẩm.',
      photos: [
        'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&auto=format&fit=crop&q=80',
      ],
      quantity: 5,
      condition: FoodCondition.free,
      expiresAt: DateTime.now().add(const Duration(hours: 3)),
      pickupWindowStart: DateTime.now(),
      pickupWindowEnd: DateTime.now().add(const Duration(hours: 3)),
      latitude: 10.7769, // Ho Chi Minh City center
      longitude: 106.7009,
      addressText: '180 Hai Bà Trưng, Phường Đa Kao, Quận 1, TP.HCM',
      allergenTags: ['Gluten', 'Sữa', 'Trứng'],
      ownerId: 'store-touslesjours',
      ownerName: 'Tous Les Jours Hai Bà Trưng',
      ownerType: UserRole.store,
      status: ListingStatus.available,
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    FoodListingModel(
      id: 'listing-002',
      title: 'Cơm trưa văn phòng (Suất cơm gà xối mỡ)',
      description:
          'Cơm phần văn phòng chưa qua sử dụng, chuẩn bị dư do khách hủy tiệc trưa. Kèm canh rong biển và rau luộc.',
      photos: [
        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&auto=format&fit=crop&q=80',
      ],
      quantity: 3,
      condition: FoodCondition.paid,
      price: 15000, // 15k rescue price
      expiresAt: DateTime.now().add(const Duration(hours: 2)),
      pickupWindowStart: DateTime.now(),
      pickupWindowEnd: DateTime.now().add(const Duration(hours: 2)),
      latitude: 10.7725,
      longitude: 106.6980,
      addressText: '45 Lê Duẩn, Bến Nghé, Quận 1, TP.HCM',
      allergenTags: ['Đậu phộng'],
      ownerId: 'store-comtam',
      ownerName: 'Quán Cơm Mẹ Nấu',
      ownerType: UserRole.store,
      status: ListingStatus.available,
      createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
    FoodListingModel(
      id: 'listing-003',
      title: 'Táo Envy & Cam sành tươi dư từ giỏ quà Tết',
      description:
          'Gia đình được tặng giỏ trái cây nhiều không dùng hết. Trái cây còn rất tươi ngon, cuống xanh.',
      photos: [
        'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=600&auto=format&fit=crop&q=80',
      ],
      quantity: 4,
      condition: FoodCondition.free,
      expiresAt: DateTime.now().add(const Duration(hours: 8)),
      pickupWindowStart: DateTime.now(),
      pickupWindowEnd: DateTime.now().add(const Duration(hours: 6)),
      latitude: 10.7812,
      longitude: 106.6954,
      addressText: 'Chung cư Horizon, 214 Trần Quang Khải, Quận 1',
      allergenTags: [],
      ownerId: 'user-family-12',
      ownerName: 'Chị Mai Lan',
      ownerType: UserRole.individual,
      status: ListingStatus.available,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  @override
  Future<List<FoodListingModel>> getNearbyListings({
    required double latitude,
    required double longitude,
    required double radiusKm,
    FoodCondition? condition,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    var results = _mockListings
        .where((item) => item.status == ListingStatus.available)
        .toList();
    if (condition != null) {
      results = results.where((item) => item.condition == condition).toList();
    }
    return results;
  }

  @override
  Future<FoodListingModel> getListingById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final item = _mockListings.firstWhere(
      (element) => element.id == id,
      orElse: () => _mockListings.first,
    );
    return item;
  }

  @override
  Future<FoodListingModel> createListing(FoodListingModel listing) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _mockListings.insert(0, listing);
    return listing;
  }

  @override
  Future<FoodListingModel> updateListingStatus(
      String id, ListingStatus newStatus) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final index = _mockListings.indexWhere((e) => e.id == id);
    if (index != -1) {
      final updated = FoodListingModel(
        id: _mockListings[index].id,
        title: _mockListings[index].title,
        description: _mockListings[index].description,
        photos: _mockListings[index].photos,
        quantity: _mockListings[index].quantity,
        condition: _mockListings[index].condition,
        price: _mockListings[index].price,
        expiresAt: _mockListings[index].expiresAt,
        pickupWindowStart: _mockListings[index].pickupWindowStart,
        pickupWindowEnd: _mockListings[index].pickupWindowEnd,
        latitude: _mockListings[index].latitude,
        longitude: _mockListings[index].longitude,
        addressText: _mockListings[index].addressText,
        allergenTags: _mockListings[index].allergenTags,
        ownerId: _mockListings[index].ownerId,
        ownerName: _mockListings[index].ownerName,
        ownerType: _mockListings[index].ownerType,
        status: newStatus,
        createdAt: _mockListings[index].createdAt,
      );
      _mockListings[index] = updated;
      return updated;
    }
    throw Exception('Listing not found');
  }

  @override
  Future<void> cancelListing(String id, String ownerId) async {
    await updateListingStatus(id, ListingStatus.cancelled);
  }
}
