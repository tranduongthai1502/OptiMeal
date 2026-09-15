/// Role of the user in the system:
/// - individual: Regular person / household donating or receiving food.
/// - store: Restaurant, bakery, grocery, supermarket.
/// - charityKitchen: Community kitchen, charity organization distributing free meals.
enum UserRole {
  individual,
  store,
  charityKitchen;

  bool get isStore => this == UserRole.store;
  bool get isIndividual => this == UserRole.individual;
  bool get isCharityKitchen => this == UserRole.charityKitchen;
}

/// Domain entity representing a user in OptiMeal.
class UserEntity {
  final String id;
  final String phoneNumber;
  final String? displayName;
  final String? avatarUrl;
  final UserRole? role;
  final double reputationScore;
  final int totalDonations;
  final int totalPickups;
  final int noShowCount;
  final bool isRestricted;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.phoneNumber,
    this.displayName,
    this.avatarUrl,
    this.role,
    this.reputationScore = 5.0,
    this.totalDonations = 0,
    this.totalPickups = 0,
    this.noShowCount = 0,
    this.isRestricted = false,
    required this.createdAt,
  });

  bool get hasSelectedRole => role != null;
}
