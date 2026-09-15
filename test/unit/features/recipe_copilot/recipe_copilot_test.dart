import 'package:flutter_test/flutter_test.dart';
import 'package:optimeal/features/recipe_copilot/data/repositories/recipe_copilot_repository_impl.dart';

void main() {
  late RecipeCopilotRepositoryImpl repository;

  setUp(() {
    repository = RecipeCopilotRepositoryImpl();
  });

  group('Smart Recipe Copilot Tests', () {
    test(
        'should fetch cold storage ingredients and identify short-expiry items (< 24h)',
        () async {
      final result = await repository.getColdStorageIngredients();

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Should not fail'), (items) {
        expect(items.isNotEmpty, isTrue);
        final shortExpiryItems = items.where((i) => i.isShortExpiry).toList();
        expect(shortExpiryItems.isNotEmpty, isTrue);
        expect(shortExpiryItems.any((i) => i.name.contains('Đậu phụ')), isTrue);
      });
    });

    test(
      'should prioritize recipes utilizing short-expiry ingredients',
      () async {
        final result = await repository.generateBatchRecipes(
          targetPortions: 150,
        );

        expect(result.isRight(), isTrue);
        result.fold((_) => fail('Should not fail'), (recipes) {
          expect(recipes.isNotEmpty, isTrue);
          // First recipe must prioritize expiring ingredients
          final firstRecipe = recipes.first;
          expect(firstRecipe.usesExpiringIngredients, isTrue);
          expect(firstRecipe.targetPortions, equals(150));
          expect(
            firstRecipe.ingredients.any((ing) => ing.isShortExpiry),
            isTrue,
          );
        });
      },
    );

    test(
      'should scale ingredient quantities according to target portions',
      () async {
        final result100 = await repository.generateBatchRecipes(
          targetPortions: 100,
        );
        final result200 = await repository.generateBatchRecipes(
          targetPortions: 200,
        );

        double amount100 = 0.0;
        double amount200 = 0.0;

        result100.fold(
          (_) => fail('Failed 100'),
          (recipes) => amount100 = recipes.first.ingredients.first.amount,
        );

        result200.fold(
          (_) => fail('Failed 200'),
          (recipes) => amount200 = recipes.first.ingredients.first.amount,
        );

        expect(amount200, equals(amount100 * 2));
      },
    );
  });
}
