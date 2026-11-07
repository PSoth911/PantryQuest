
import 'recipeIngredient.dart';

class Recipe {
  final String _id;
  String _name;
  String _description;
  String _imagePath;
  List<RecipeIngredient> _ingredients;

  Recipe({
    required String id,
    required String name,
    required String description,
    required String imagePath,
    required List<RecipeIngredient> ingredients,
  })  : _id = id,
        _name = name,
        _description = description,
        _imagePath = imagePath,
        _ingredients = List.of(ingredients);

  String get id => _id;
  String get name => _name;
  String get description => _description;
  String get imagePath => _imagePath;

  List<RecipeIngredient> get ingredients =>
      List.unmodifiable(_ingredients);

  set name(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError('Recipe name cannot be empty.');
    }

    _name = value;
  }

  set description(String value) {
    _description = value;
  }

  set imagePath(String value) {
    _imagePath = value;
  }

  set ingredients(List<RecipeIngredient> value) {
    _ingredients = List.of(value);
  }
}
