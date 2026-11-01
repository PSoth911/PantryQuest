import 'package:pantry_quest/model/recipe.dart';
import 'package:pantry_quest/model/recipeIngredient.dart';

class RecipeAvailability {
  final Recipe recipe;
  final bool isCookable;
  final List<RecipeIngredient> missingIngredients;

  RecipeAvailability({
    required this.recipe,
    required this.isCookable,
    required this.missingIngredients,
  });
}