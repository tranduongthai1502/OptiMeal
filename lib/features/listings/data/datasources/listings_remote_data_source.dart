import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';

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
    String id,
    ListingStatus newStatus,
  );

  Future<void> cancelListing(String id, String ownerId);
}

/// Firestore implementation for Listings (food_listings collection).
///
/// NOTE: Geo-radius filtering is done client-side for now.
/// For production scale, replace with GeoFlutterFire or a Cloud Function
/// that queries a geohash index.
class ListingsFirebaseDataSourceImpl implements ListingsRemoteDataSource {
  final FirebaseFirestore _firestore;

  ListingsFirebaseDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('food_listings');

  @override
  Future<List<FoodListingModel>> getNearbyListings({
    required double latitude,
    required double longitude,
    required double radiusKm,
    FoodCondition? condition,
    FoodCategory? category,
  }) async {
    // Build base query: only available, not expired
    Query<Map<String, dynamic>> query = _col
        .where('status', isEqualTo: ListingStatus.available.name)
        .where(
          'expiresAt',
          isGreaterThan: DateTime.now().millisecondsSinceEpoch,
        )
        .orderBy('expiresAt')
        .orderBy('createdAt', descending: true)
        .limit(100);

    if (condition != null) {
      query = query.where('condition', isEqualTo: condition.name);
    }
    if (category != null) {
      query = query.where('category', isEqualTo: category.name);
    }

    final snapshot = await query.get();
    final listings = snapshot.docs
        .map((doc) => FoodListingModel.fromMap(doc.data(), doc.id))
        .toList();

    // Client-side geo filter (Haversine approximation)
    return listings.where((listing) {
      final dist = _haversineKm(
        latitude,
        longitude,
        listing.latitude,
        listing.longitude,
      );
      return dist <= radiusKm;
    }).toList();
  }

  @override
  Future<FoodListingModel> getListingById(String id) async {
    final snapshot = await _col.doc(id).get();
    if (!snapshot.exists) throw Exception('Listing $id not found');
    return FoodListingModel.fromMap(snapshot.data()!, snapshot.id);
  }

  @override
  Future<FoodListingModel> createListing(FoodListingModel listing) async {
    final docRef = listing.id.isEmpty ? _col.doc() : _col.doc(listing.id);
    final data = listing.toMap();
    await docRef.set(data);

    final saved = FoodListingModel.fromMap(
      {...data, 'id': docRef.id},
      docRef.id,
    );
    return saved;
  }

  @override
  Future<FoodListingModel> updateListingStatus(
    String id,
    ListingStatus newStatus,
  ) async {
    await _col.doc(id).update({'status': newStatus.name});
    final snapshot = await _col.doc(id).get();
    return FoodListingModel.fromMap(snapshot.data()!, snapshot.id);
  }

  @override
  Future<void> cancelListing(String id, String ownerId) async {
    // Verify ownership before cancelling
    final snapshot = await _col.doc(id).get();
    if (!snapshot.exists) throw Exception('Listing not found');

    final data = snapshot.data()!;
    if (data['ownerId'] != ownerId) {
      throw Exception('Unauthorized: only the owner can cancel this listing');
    }

    await _col.doc(id).update({'status': ListingStatus.cancelled.name});
  }

  /// Haversine formula — returns distance in km between two lat/lng points.
  double _haversineKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371.0; // Earth radius in km
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.pow(math.sin(dLon / 2), 2);
    final c = 2 * math.asin(math.sqrt(a));
    return r * c;
  }

  double _toRad(double deg) => deg * math.pi / 180;
}
