import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/recipe_copilot_repository_impl.dart';
import '../../domain/entities/recipe_entity.dart';
import '../../domain/repositories/recipe_copilot_repository.dart';

final recipeCopilotRepositoryProvider =
    Provider<RecipeCopilotRepository>((ref) {
  return RecipeCopilotRepositoryImpl();
});

/// Target batch portions (50, 100, 150, 200 portions)
final targetPortionsProvider = StateProvider<int>((ref) => 100);

/// Cold storage ingredients provider
final coldStorageIngredientsProvider =
    FutureProvider.autoDispose<List<ColdStorageIngredient>>((ref) async {
  final repo = ref.watch(recipeCopilotRepositoryProvider);
  final result = await repo.getColdStorageIngredients();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (items) => items,
  );
});

/// Smart AI generated recipes provider
final generatedRecipesProvider =
    FutureProvider.autoDispose<List<BatchRecipe>>((ref) async {
  final repo = ref.watch(recipeCopilotRepositoryProvider);
  final portions = ref.watch(targetPortionsProvider);
  final result = await repo.generateBatchRecipes(targetPortions: portions);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (recipes) => recipes,
  );
});

/// Recipe detail provider by ID
final recipeDetailProvider =
    FutureProvider.family.autoDispose<BatchRecipe, String>((ref, id) async {
  final repo = ref.watch(recipeCopilotRepositoryProvider);
  final result = await repo.getRecipeById(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (recipe) => recipe,
  );
});
