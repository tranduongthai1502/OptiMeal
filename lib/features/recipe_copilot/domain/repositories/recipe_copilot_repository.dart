import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/recipe_entity.dart';

abstract class RecipeCopilotRepository {
  /// Fetches ingredients currently logged in charity kitchen cold storage.
  Future<Either<Failure, List<ColdStorageIngredient>>>
      getColdStorageIngredients();

  /// AI Copilot generation: generates batch recipes tailored for 50-200 portions,
  /// with hard priority on short-expiry ingredients.
  Future<Either<Failure, List<BatchRecipe>>> generateBatchRecipes({
    required int targetPortions,
    List<String>? focusIngredients,
  });

  /// Fetches recipe detail by ID.
  Future<Either<Failure, BatchRecipe>> getRecipeById(String id);
}
