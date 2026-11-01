import 'package:pantry_quest/model/recipeIngredient.dart';

class Recipe {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final int cookingTime;
  final List<RecipeIngredient> ingredients;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.cookingTime,
    required this.ingredients,
  });
}