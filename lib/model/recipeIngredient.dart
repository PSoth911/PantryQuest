class RecipeIngredient {
  String _ingredientName;
  double _requiredQuantity;
  String _unit;

  RecipeIngredient({
    required String ingredientName,
    required double requiredQuantity,
    required String unit,
  }) : _ingredientName = _validateName(ingredientName),
       _requiredQuantity = _validateQuantity(requiredQuantity),
       _unit = _validateUnit(unit);

  String get ingredientName => _ingredientName;
  double get requiredQuantity => _requiredQuantity;
  String get unit => _unit;

  static String _validateName(String value) {
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      throw ArgumentError('Ingredient name cannot be empty.');
    }
    return trimmedValue;
  }

  static double _validateQuantity(double value) {
    if (value <= 0 || !value.isFinite) {
      throw ArgumentError('Required quantity must be greater than zero.');
    }
    return value;
  }

  static String _validateUnit(String value) {
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      throw ArgumentError('Unit cannot be empty.');
    }
    return trimmedValue;
  }

  set ingredientName(String value) {
    _ingredientName = _validateName(value);
  }

  set requiredQuantity(double value) {
    _requiredQuantity = _validateQuantity(value);
  }

  set unit(String value) {
    _unit = _validateUnit(value);
  }

  RecipeIngredient copy() {
    return RecipeIngredient(
      ingredientName: ingredientName,
      requiredQuantity: requiredQuantity,
      unit: unit,
    );
  }
}
