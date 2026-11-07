class RecipeIngredient {
  String _ingredientName;
  double _requiredQuantity;
  String _unit;

  RecipeIngredient({
    required String ingredientName,
    required double requiredQuantity,
    required String unit,
  })  : _ingredientName = ingredientName,
        _requiredQuantity = requiredQuantity,
        _unit = unit;

  String get ingredientName => _ingredientName;
  double get requiredQuantity => _requiredQuantity;
  String get unit => _unit;

  set ingredientName(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError('Ingredient name cannot be empty.');
    }
    _ingredientName = value;
  }

  set requiredQuantity(double value) {
    if (value <= 0) {
      throw ArgumentError('Required quantity must be greater than zero.');
    }
    _requiredQuantity = value;
  }

  set unit(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError('Unit cannot be empty.');
    }
    _unit = value;
  }
}