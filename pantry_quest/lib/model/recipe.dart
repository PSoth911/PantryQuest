import 'recipeIngredient.dart';

class Recipe {
  final String _id;
  String _name;
  String? _description;
  String _imagePath;
  List<RecipeIngredient> _ingredients;

  Recipe({
    required String id,
    required String name,
    String? description,
    required String imagePath,
    required List<RecipeIngredient> ingredients,
  }) : _id = _validateId(id),
       _name = _validateName(name),
       _description = description,
       _imagePath = _validateImagePath(imagePath),
       _ingredients = List.of(ingredients);

  String get id => _id;
  String get name => _name;
  String? get description => _description;
  String get imagePath => _imagePath;
  List<RecipeIngredient> get ingredients => List.unmodifiable(_ingredients);

  static String _validateId(String value) {
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      throw ArgumentError('ID cannot be empty.');
    }
    return trimmedValue;
  }

  static String _validateName(String value) {
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      throw ArgumentError('Name cannot be empty.');
    }
    return trimmedValue;
  }

  static String _validateImagePath(String value) {
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      throw ArgumentError('Image path cannot be empty.');
    }
    return trimmedValue;
  }

  set name(String value) {
    _name = _validateName(value);
  }

  set description(String? value) {
    _description = value;
  }

  set imagePath(String value) {
    _imagePath = _validateImagePath(value);
  }

  set ingredients(List<RecipeIngredient> value) {
    _ingredients = List.of(value);
  }

  Recipe copy() {
    return Recipe(
      id: id,
      name: name,
      imagePath: imagePath,
     ingredients: ingredients.map((ingredient) => ingredient.copy()).toList(),
    );
  }
}
