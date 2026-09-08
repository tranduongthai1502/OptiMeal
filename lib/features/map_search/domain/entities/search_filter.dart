import '../../../../core/constants/app_constants.dart';
import '../../../listings/domain/entities/food_listing.dart';

/// Filter parameters for searching surplus food on map & list.
class SearchFilter {
  final double radiusKm;
  final FoodCondition? condition; // null = all, free, or paid
  final int? maxRemainingHours;
  final List<String> excludedAllergens;

  const SearchFilter({
    this.radiusKm = AppConstants.defaultSearchRadiusKm,
    this.condition,
    this.maxRemainingHours,
    this.excludedAllergens = const [],
  });

  SearchFilter copyWith({
    double? radiusKm,
    FoodCondition? condition,
    int? maxRemainingHours,
    List<String>? excludedAllergens,
  }) {
    return SearchFilter(
      radiusKm: radiusKm ?? this.radiusKm,
      condition: condition ?? this.condition,
      maxRemainingHours: maxRemainingHours ?? this.maxRemainingHours,
      excludedAllergens: excludedAllergens ?? this.excludedAllergens,
    );
  }
}
