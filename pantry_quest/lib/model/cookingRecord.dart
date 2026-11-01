enum IngredientCategory {
  vegetables,
  fruits,
  meat,
  seafood,
  dairy,
  grains,
  spices,
  other,
}

class CookingRecord {
  final String id;
  final String recipeId;
  final String recipeName;
  final DateTime cookedAt;

  CookingRecord({
    required this.id,
    required this.recipeId,
    required this.recipeName,
    required this.cookedAt,
  });
}