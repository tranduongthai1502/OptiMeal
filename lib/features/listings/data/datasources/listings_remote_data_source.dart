import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/food_listing.dart';
import '../models/food_listing_model.dart';

abstract class ListingsRemoteDataSource {
  Future<List<FoodListingModel>> getNearbyListings({
    required double latitude,
    required double longitude,
    required double radiusKm,
    FoodCondition? condition,
    FoodCategory? category,
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
      title: '30kg Cải thảo, Cà chua bi & Bắp cải Đà Lạt',
      description:
          'Nông sản tươi xanh giải cứu từ chuyến xe Lâm Đồng. Rau củ còn tươi nguyên, phù hợp cho bếp ăn thiện nguyện hoặc quán ăn nấu suất lớn.',
      photos: [
        'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600&auto=format&fit=crop&q=80',
      ],
      quantity: 30,
      unit: 'kg',
      category: FoodCategory.vegetables,
      condition: FoodCondition.free,
      expiresAt: DateTime.now().add(const Duration(hours: 18)),
      pickupWindowStart: DateTime.now(),
      pickupWindowEnd: DateTime.now().add(const Duration(hours: 6)),
      latitude: 10.7769, // Ho Chi Minh City center
      longitude: 106.7009,
      addressText: 'Siêu thị Nông Sản Sạch, 180 Hai Bà Trưng, Quận 1, TP.HCM',
      allergenTags: [],
      ownerId: 'store-nongsan',
      ownerName: 'Siêu thị Nông Sản Xanh',
      ownerType: UserRole.store,
      status: ListingStatus.available,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    FoodListingModel(
      id: 'listing-002',
      title: '50kg Gạo ST25 & Đậu xanh khô nguyên bao',
      description:
          'Gạo và đậu khô sạch từ nhà hảo tâm tặng cho bếp ăn hoặc người có hoàn cảnh khó khăn.',
      photos: [
        'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600&auto=format&fit=crop&q=80',
      ],
      quantity: 50,
      unit: 'kg',
      category: FoodCategory.dryGoods,
      condition: FoodCondition.free,
      expiresAt: DateTime.now().add(const Duration(days: 30)),
      pickupWindowStart: DateTime.now(),
      pickupWindowEnd: DateTime.now().add(const Duration(hours: 12)),
      latitude: 10.7725,
      longitude: 106.6980,
      addressText: '45 Lê Duẩn, Bến Nghé, Quận 1, TP.HCM',
      allergenTags: [],
      ownerId: 'user-donor-nguyen',
      ownerName: 'Quỹ Thiện Nguyện Bồ Đề',
      ownerType: UserRole.individual,
      status: ListingStatus.available,
      createdAt: DateTime.now().subtract(const Duration(minutes: 50)),
    ),
    FoodListingModel(
      id: 'listing-003',
      title: 'Bếp Cơm Nụ Cười - Phát 150 Suất Cơm Chay Miễn Phí',
      description:
          'Điểm phát cơm từ thiện trưa hàng ngày cho bà con lao động nghèo, người khuyết tật và người vô gia cư. Cơm nóng kèm canh rau củ dinh dưỡng.',
      photos: [
        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&auto=format&fit=crop&q=80',
      ],
      quantity: 150,
      unit: 'suất',
      category: FoodCategory.charityMealPoint,
      isCharityPoint: true,
      condition: FoodCondition.free,
      expiresAt: DateTime.now().add(const Duration(hours: 3)),
      pickupWindowStart: DateTime.now().add(const Duration(minutes: 30)),
      pickupWindowEnd: DateTime.now().add(const Duration(hours: 2)),
      latitude: 10.7812,
      longitude: 106.6954,
      addressText: 'Chùa Vĩnh Nghiêm, 339 Nam Kỳ Khởi Nghĩa, Quận 3, TP.HCM',
      allergenTags: ['Đậu nành'],
      ownerId: 'kitchen-nucuoi',
      ownerName: 'Bếp Cơm Từ Thiện Nụ Cười',
      ownerType: UserRole.charityKitchen,
      status: ListingStatus.available,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    FoodListingModel(
      id: 'listing-004',
      title: 'Bánh mì ngũ cốc & Croissant cuối ngày',
      description:
          'Còn dư 5 ổ bánh mì ngũ cốc và 3 bánh sừng trâu nướng mới sáng nay. Đóng gói sạch sẽ trong túi giấy thực phẩm.',
      photos: [
        'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&auto=format&fit=crop&q=80',
      ],
      quantity: 8,
      unit: 'hộp',
      category: FoodCategory.cookedMeals,
      condition: FoodCondition.free,
      expiresAt: DateTime.now().add(const Duration(hours: 4)),
      pickupWindowStart: DateTime.now(),
      pickupWindowEnd: DateTime.now().add(const Duration(hours: 3)),
      latitude: 10.7745,
      longitude: 106.7020,
      addressText: 'Tiệm Bánh Tous Les Jours, Quận 1',
      allergenTags: ['Gluten', 'Sữa'],
      ownerId: 'store-bakery',
      ownerName: 'Tous Les Jours Bakery',
      ownerType: UserRole.store,
      status: ListingStatus.available,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
  ];

  @override
  Future<List<FoodListingModel>> getNearbyListings({
    required double latitude,
    required double longitude,
    required double radiusKm,
    FoodCondition? condition,
    FoodCategory? category,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    var results = _mockListings
        .where((item) => item.status == ListingStatus.available)
        .toList();
    if (condition != null) {
      results = results.where((item) => item.condition == condition).toList();
    }
    if (category != null) {
      results = results.where((item) => item.category == category).toList();
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
