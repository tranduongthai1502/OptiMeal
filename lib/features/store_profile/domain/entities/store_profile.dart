class StoreProfile {
  final String id;
  final String storeName;
  final String storeType; // Bakery, Restaurant, Supermarket, Cafe
  final String address;
  final String operatingHours;
  final double rating;
  final int totalRescuedMeals;
  final String? bannerUrl;
  final bool hasRecurringSchedule;

  const StoreProfile({
    required this.id,
    required this.storeName,
    required this.storeType,
    required this.address,
    required this.operatingHours,
    this.rating = 4.8,
    this.totalRescuedMeals = 120,
    this.bannerUrl,
    this.hasRecurringSchedule = true,
  });
}
