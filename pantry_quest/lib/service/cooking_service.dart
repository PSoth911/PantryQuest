import '../model/cookingRecord.dart';

import 'pantry_service.dart';
import 'recipe_service.dart';
import 'cooking_record_service.dart';

class CookingService {
  final PantryService _pantryService;
  final RecipeService _recipeService;
  final CookingRecordService _recordService;

  CookingService({
    required PantryService pantryService,
    required RecipeService recipeService,
    required CookingRecordService recordService,
  }) : _pantryService = pantryService,
       _recipeService = recipeService,
       _recordService = recordService;

  CookingRecord recordMeal({
    required String recipeId,
    required String recordId,
    DateTime? cookedAt,
  }) {
    if (recordId.trim().isEmpty) {
      throw ArgumentError('Record ID cannot be empty.');
    }

    final recipe = _recipeService.getRecipeById(recipeId);

    if (recipe == null) {
      throw StateError('Recipe not found.');
    }

    if (_recordService.getCookingRecordById(recordId) != null) {
      throw StateError('Cooking record already exists.');
    }

    final missingIngredients = _recipeService.getMissingIngredients(
      recipe,
      _pantryService,
    );

    if (missingIngredients.isNotEmpty) {
      final missingNames = missingIngredients
          .map(
            (item) =>
                '${item.ingredientName}: '
                '${item.requiredQuantity} ${item.unit}',
          )
          .join(', ');

      throw StateError('Insufficient ingredients: $missingNames');
    }

    final record = CookingRecord(
      id: recordId.trim(),
      recipeId: recipe.id,
      recipeName: recipe.name,
      cookedAt: cookedAt ?? DateTime.now(),
    );

    _pantryService.deductIngredients(recipe.ingredients);

    _recordService.addCookingRecord(record);

    return record;
  }
}
