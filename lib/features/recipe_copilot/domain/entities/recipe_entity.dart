/// Domain entities for the Smart Recipe Copilot feature.

class ColdStorageIngredient {
  final String id;
  final String name;
  final double quantityKg;
  final DateTime expiryDate;
  final String category; // 'Rau củ', 'Đồ khô', 'Tươi sống', 'Gia vị'

  const ColdStorageIngredient({
    required this.id,
    required this.name,
    required this.quantityKg,
    required this.expiryDate,
    required this.category,
  });

  Duration get remainingTime => expiryDate.difference(DateTime.now());

  /// True if item will expire within 24 hours
  bool get isShortExpiry => remainingTime.inHours <= 24 && remainingTime.inHours >= 0;
}

class BatchIngredient {
  final String name;
  final double amount;
  final String unit;
  final bool isFromColdStorage;
  final bool isShortExpiry;

  const BatchIngredient({
    required this.name,
    required this.amount,
    required this.unit,
    this.isFromColdStorage = true,
    this.isShortExpiry = false,
  });
}

class BatchRecipe {
  final String id;
  final String title;
  final String description;
  final int targetPortions; // e.g. 50, 100, 150, 200
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final List<BatchIngredient> ingredients;
  final List<String> safetyNotes;
  final List<String> cookingSteps;
  final bool usesExpiringIngredients;
  final String photoUrl;

  const BatchRecipe({
    required this.id,
    required this.title,
    required this.description,
    required this.targetPortions,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.ingredients,
    required this.safetyNotes,
    required this.cookingSteps,
    required this.usesExpiringIngredients,
    required this.photoUrl,
  });
}
