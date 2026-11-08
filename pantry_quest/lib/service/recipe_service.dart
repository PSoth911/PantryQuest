import '../model/recipe.dart';

class RecipeService {
  final List<Recipe> _recipes = [];

  void _validateRecipe(Recipe recipe) {
    if (recipe.id.trim().isEmpty || recipe.name.trim().isEmpty) {
      throw ArgumentError('Recipe information cannot be empty.');
    }

    _validateIngredients(recipe);
  }

  void _validateIngredients(Recipe recipe) {
    if (recipe.ingredients.isEmpty) {
      throw ArgumentError('A recipe must have at least one ingredient.');
    }

    for (final ingredient in recipe.ingredients) {
      if (ingredient.ingredientName.trim().isEmpty ||
          ingredient.unit.trim().isEmpty ||
          ingredient.requiredQuantity <= 0) {
        throw ArgumentError('Invalid recipe ingredient.');
      }
    }
  }

  void addRecipe(Recipe recipe) {
    _validateRecipe(recipe);

    if (_recipes.any((existing)=>existing.id==recipe.id)) {
      throw StateError('Recipe with this ID already exists.');
    }

    _recipes.add(recipe.copy());
  }

  List<Recipe> getAllRecipes() {
    return List.unmodifiable(_recipes.map((rec)=>rec.copy()));
  }

  Recipe? getRecipeById(String id) {
    for (final recipe in _recipes) {
      if (recipe.id == id) {
        return recipe.copy();
      }
    }

    return null;
  }

  bool updateRecipe(Recipe updatedRecipe) {
    final index = _recipes.indexWhere(
      (recipe) => recipe.id == updatedRecipe.id,
    );

    if (index == -1) {
      return false;
    }

    _validateRecipe(updatedRecipe);

    _recipes[index] = updatedRecipe.copy();

    return true;
  }

  bool deleteRecipe(String id) {
    final index = _recipes.indexWhere((recipe) => recipe.id == id);

    if (index == -1) {
      return false;
    }

    _recipes.removeAt(index);

    return true;
  }
}
