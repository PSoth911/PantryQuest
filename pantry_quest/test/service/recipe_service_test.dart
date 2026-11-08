import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../../lib/model/recipe.dart';
import '../../lib/model/recipeIngredient.dart';

import '../../lib/service/recipe_service.dart';

void main() {
  group(('Recipe Service Tests'), () {
    late RecipeService recipeService;
    final uuid = Uuid();

    setUp(() {
      recipeService = RecipeService();
    });

    Recipe createValidRecipe({
      String? id,
      String name = 'Pasta',
      List<RecipeIngredient>? ingredients,
    }) {
      return Recipe(
        id: id ?? uuid.v4(),
        name: name,
        description: 'Delicious pasta recipe',
        imagePath: '',
        ingredients:
            ingredients ??
            [
              RecipeIngredient(
                ingredientName: 'Pasta',
                requiredQuantity: 200.0,
                unit: 'grams',
              ),
              RecipeIngredient(
                ingredientName: 'Tomato Sauce',
                requiredQuantity: 100.0,
                unit: 'ml',
              ),
            ],
      );
    }

    test(('Should add a valid recipe successfully'), () {
      final recipe = createValidRecipe();

      recipeService.addRecipe(recipe);

      final recipes = recipeService.getAllRecipes();
      expect(recipes.length, equals(1));
      expect(recipes.first.name, equals('Pasta'));
      expect(recipes.first.ingredients.length, equals(2));
    });

    test(('Should reject with empty name'), () {
      final recipe = createValidRecipe(name: '');

      expect(
        () => recipeService.addRecipe(recipe),
        throwsA(isA<ArgumentError>),
      );

      expect(recipeService.getAllRecipes().isEmpty, isTrue);
    });

    test(('Should reject recipe with no ingredient'), () {
      final badIngredients = [
        RecipeIngredient(
          ingredientName: 'Salt',
          requiredQuantity: 0,
          unit: 'g',
        ),
      ];

      final recipe = createValidRecipe(ingredients: badIngredients);

      expect(
        () => recipeService.addRecipe(recipe),
        throwsA(isA<ArgumentError>),
      );
    });

    test(('Should reject with duplicate ID'), () {
      final id = 'duplicate-recipe-id-123';
      final recipe1 = createValidRecipe(id: id);
      final recipe2 = createValidRecipe(id: id);

      recipeService.addRecipe(recipe1);

      expect(() => recipeService.addRecipe(recipe2), throwsA(isA<StateError>));

      expect(recipeService.getAllRecipes().length, equals(1));
      expect(recipeService.getAllRecipes().first.name, equals('Pasta'));
    });
  });
}
