import 'package:flutter_test/flutter_test.dart';
import 'package:pantry_quest/model/ingredient_category.dart';
import 'package:pantry_quest/model/pantryItem.dart';
import 'package:pantry_quest/model/recipe.dart';
import 'package:pantry_quest/model/recipeIngredient.dart';
import 'package:pantry_quest/service/pantry_service.dart';
import 'package:pantry_quest/service/recipe_service.dart';

void main() {
  group('RecipeService Tests', () {
    late RecipeService recipeService;
    late PantryService pantryService;

    setUp(() {
      recipeService = RecipeService();
      pantryService = PantryService();
    });

    Recipe createRecipe({
      String id = 'recipe-1',
      String name = 'Pasta Bolognese',
      String? description = 'Delicious pasta recipe',
      String imagePath = 'assets/images/pasta.png',
      List<RecipeIngredient>? ingredients,
    }) {
      return Recipe(
        id: id,
        name: name,
        description: description,
        imagePath: imagePath,
        ingredients: ingredients ??
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

    PantryItem createPantryItem({
      String id = 'item-1',
      String name = 'Pasta',
      double quantity = 500.0,
      String unit = 'grams',
      DateTime? expiryDate,
      IngredientCategory category = IngredientCategory.grains,
    }) {
      return PantryItem(
        id: id,
        name: name,
        quantity: quantity,
        unit: unit,
        expiryDate: expiryDate ?? DateTime.now().add(const Duration(days: 10)),
        category: category,
      );
    }

    group('Task 5.1: Normal Scenarios', () {
      test('Add a valid recipe (addRecipe)', () {
        final recipe = createRecipe(
          id: 'rec-1',
          name: 'Spaghetti Bolognese',
          description: 'A classic Italian meal',
          imagePath: 'assets/images/spaghetti.png',
        );

        recipeService.addRecipe(recipe);

        final all = recipeService.getAllRecipes();
        expect(all.length, equals(1));
        expect(all.first.id, equals('rec-1'));
        expect(all.first.name, equals('Spaghetti Bolognese'));
        expect(all.first.description, equals('A classic Italian meal'));
        expect(all.first.imagePath, equals('assets/images/spaghetti.png'));
        expect(all.first.ingredients.length, equals(2));
      });

      test('Retrieve all recipes (getAllRecipes)', () {
        final recipe1 = createRecipe(id: 'r-1', name: 'Pasta');
        final recipe2 = createRecipe(id: 'r-2', name: 'Fried Rice');

        recipeService.addRecipe(recipe1);
        recipeService.addRecipe(recipe2);

        final recipes = recipeService.getAllRecipes();
        expect(recipes.length, equals(2));
        expect(recipes[0].id, equals('r-1'));
        expect(recipes[1].id, equals('r-2'));

        // Verify returned list is unmodifiable
        expect(
          () => recipes.add(createRecipe(id: 'r-3')),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('Retrieve recipe by ID (getRecipeById)', () {
        final recipe1 = createRecipe(id: 'r-1', name: 'Pasta');
        final recipe2 = createRecipe(id: 'r-2', name: 'Fried Rice');

        recipeService.addRecipe(recipe1);
        recipeService.addRecipe(recipe2);

        final found1 = recipeService.getRecipeById('r-1');
        expect(found1, isNotNull);
        expect(found1!.name, equals('Pasta'));

        final found2 = recipeService.getRecipeById('r-2');
        expect(found2, isNotNull);
        expect(found2!.name, equals('Fried Rice'));

        final notFound = recipeService.getRecipeById('non-existent');
        expect(notFound, isNull);
      });

      test('Update an existing recipe (updateRecipe)', () {
        final recipe = createRecipe(id: 'r-1', name: 'Original Pasta');
        recipeService.addRecipe(recipe);

        final updated = createRecipe(
          id: 'r-1',
          name: 'Updated Garlic Pasta',
          description: 'With extra roasted garlic',
          ingredients: [
            RecipeIngredient(
              ingredientName: 'Pasta',
              requiredQuantity: 250.0,
              unit: 'grams',
            ),
          ],
        );

        final success = recipeService.updateRecipe(updated);
        expect(success, isTrue);

        final retrieved = recipeService.getRecipeById('r-1');
        expect(retrieved, isNotNull);
        expect(retrieved!.name, equals('Updated Garlic Pasta'));
        expect(retrieved.description, equals('With extra roasted garlic'));
        expect(retrieved.ingredients.length, equals(1));
        expect(retrieved.ingredients.first.requiredQuantity, equals(250.0));
      });

      test('Delete an existing recipe (deleteRecipe)', () {
        final recipe1 = createRecipe(id: 'r-1', name: 'Pasta');
        final recipe2 = createRecipe(id: 'r-2', name: 'Pizza');

        recipeService.addRecipe(recipe1);
        recipeService.addRecipe(recipe2);

        final deleted = recipeService.deleteRecipe('r-1');
        expect(deleted, isTrue);

        expect(recipeService.getRecipeById('r-1'), isNull);
        final remaining = recipeService.getAllRecipes();
        expect(remaining.length, equals(1));
        expect(remaining.first.id, equals('r-2'));

        expect(recipeService.deleteRecipe('r-1'), isFalse);
      });

      test('Identify a recipe that can be prepared (isRecipeAvailable)', () {
        pantryService.addItem(
          createPantryItem(
            id: 'p-1',
            name: 'Pasta',
            quantity: 300.0,
            unit: 'grams',
          ),
        );
        pantryService.addItem(
          createPantryItem(
            id: 'p-2',
            name: 'Tomato Sauce',
            quantity: 150.0,
            unit: 'ml',
            category: IngredientCategory.other,
          ),
        );

        final recipe = createRecipe(id: 'recipe-1');
        recipeService.addRecipe(recipe);

        // Sufficient stock
        expect(recipeService.isRecipeAvailable(recipe, pantryService), isTrue);

        // Deduct/remove some pantry stock so it becomes insufficient
        pantryService.deleteItem('p-2');
        expect(recipeService.isRecipeAvailable(recipe, pantryService), isFalse);
      });

      test('Calculate missing ingredients (getMissingIngredients)', () {
        // Pantry has partial pasta (150g out of 200g needed) and no sauce
        pantryService.addItem(
          createPantryItem(
            id: 'p-1',
            name: 'Pasta',
            quantity: 150.0,
            unit: 'grams',
          ),
        );

        final recipe = createRecipe(
          id: 'recipe-1',
          ingredients: [
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
        recipeService.addRecipe(recipe);

        final missing = recipeService.getMissingIngredients(recipe, pantryService);
        expect(missing.length, equals(2));

        final pastaMissing = missing.firstWhere((i) => i.ingredientName == 'Pasta');
        expect(pastaMissing.requiredQuantity, equals(50.0));
        expect(pastaMissing.unit, equals('grams'));

        final sauceMissing = missing.firstWhere((i) => i.ingredientName == 'Tomato Sauce');
        expect(sauceMissing.requiredQuantity, equals(100.0));
        expect(sauceMissing.unit, equals('ml'));

        // Verify returned list is unmodifiable
        expect(
          () => missing.clear(),
          throwsA(isA<UnsupportedError>()),
        );
      });
    });

    group('Task 5.2: Invalid Scenarios', () {
      test('Reject recipe with empty or whitespace name (ArgumentError)', () {
        expect(
          () => createRecipe(name: ''),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => createRecipe(name: '   '),
          throwsA(isA<ArgumentError>()),
        );

        final validRecipe = createRecipe(name: 'Good Name');
        expect(
          () => validRecipe.name = '',
          throwsA(isA<ArgumentError>()),
        );
      });

      test('Reject recipe with duplicate ID (StateError)', () {
        final recipe1 = createRecipe(id: 'dup-recipe-id', name: 'Pasta');
        final recipe2 = createRecipe(id: 'dup-recipe-id', name: 'Lasagna');

        recipeService.addRecipe(recipe1);

        expect(
          () => recipeService.addRecipe(recipe2),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('Recipe with this ID already exists'),
            ),
          ),
        );

        expect(recipeService.getAllRecipes().length, equals(1));
        expect(recipeService.getAllRecipes().first.name, equals('Pasta'));
      });

      test('Reject recipe with ingredient quantity <= 0 or invalid (ArgumentError)', () {
        expect(
          () => RecipeIngredient(
            ingredientName: 'Salt',
            requiredQuantity: 0.0,
            unit: 'grams',
          ),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => RecipeIngredient(
            ingredientName: 'Pepper',
            requiredQuantity: -2.0,
            unit: 'grams',
          ),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => RecipeIngredient(
            ingredientName: 'Oil',
            requiredQuantity: double.nan,
            unit: 'ml',
          ),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => RecipeIngredient(
            ingredientName: 'Oil',
            requiredQuantity: double.infinity,
            unit: 'ml',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('Reject recipe with empty ingredients list (ArgumentError)', () {
        final recipeWithoutIngredients = createRecipe(ingredients: []);

        expect(
          () => recipeService.addRecipe(recipeWithoutIngredients),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('A recipe must have at least one ingredient'),
            ),
          ),
        );

        expect(recipeService.getAllRecipes(), isEmpty);
      });

      test('Reject updating a non-existent recipe (returns false)', () {
        final ghostRecipe = createRecipe(id: 'ghost-recipe');

        final updated = recipeService.updateRecipe(ghostRecipe);
        expect(updated, isFalse);
        expect(recipeService.getAllRecipes(), isEmpty);
      });

      test('Reject recipe with empty ID, empty imagePath, or empty ingredient details (ArgumentError)', () {
        expect(
          () => createRecipe(id: ''),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => createRecipe(id: '   '),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => createRecipe(imagePath: ''),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => createRecipe(imagePath: '   '),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => RecipeIngredient(
            ingredientName: '',
            requiredQuantity: 10.0,
            unit: 'grams',
          ),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => RecipeIngredient(
            ingredientName: 'Sugar',
            requiredQuantity: 10.0,
            unit: '',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Task 5.3: Boundary / Special Scenarios', () {
      test('Aggregate duplicate ingredient lines in a single recipe (_aggregateIngredients)', () {
        final recipeWithDuplicates = createRecipe(
          id: 'rec-agg',
          name: 'Garlic Lovers Pasta',
          ingredients: [
            RecipeIngredient(
              ingredientName: 'Garlic',
              requiredQuantity: 2.0,
              unit: 'cloves',
            ),
            RecipeIngredient(
              ingredientName: 'garlic', // case difference
              requiredQuantity: 3.0,
              unit: 'cloves',
            ),
            RecipeIngredient(
              ingredientName: 'GARLIC',
              requiredQuantity: 1.0,
              unit: 'cloves',
            ),
          ],
        );
        recipeService.addRecipe(recipeWithDuplicates);

        pantryService.addItem(
          createPantryItem(
            id: 'p-garlic',
            name: 'Garlic',
            quantity: 5.0,
            unit: 'cloves',
            category: IngredientCategory.vegetables,
          ),
        );

        expect(recipeService.isRecipeAvailable(recipeWithDuplicates, pantryService), isFalse);

        final missing = recipeService.getMissingIngredients(recipeWithDuplicates, pantryService);
        expect(missing.length, equals(1));
        expect(missing.first.ingredientName.toLowerCase(), equals('garlic'));
        expect(missing.first.requiredQuantity, equals(1.0)); // 6 - 5 = 1 clove missing

        pantryService.addItem(
          createPantryItem(
            id: 'p-garlic-2',
            name: 'Garlic',
            quantity: 1.0,
            unit: 'cloves',
            category: IngredientCategory.vegetables,
          ),
        );

        expect(recipeService.isRecipeAvailable(recipeWithDuplicates, pantryService), isTrue);
        expect(recipeService.getMissingIngredients(recipeWithDuplicates, pantryService), isEmpty);
      });

      test('Handle empty pantry (all ingredients reported as missing)', () {
        final recipe = createRecipe(
          id: 'rec-empty-pantry',
          ingredients: [
            RecipeIngredient(
              ingredientName: 'Rice',
              requiredQuantity: 300.0,
              unit: 'grams',
            ),
            RecipeIngredient(
              ingredientName: 'Chicken',
              requiredQuantity: 200.0,
              unit: 'grams',
            ),
          ],
        );
        recipeService.addRecipe(recipe);

        // Empty pantry
        expect(pantryService.getAllItems(), isEmpty);
        expect(recipeService.isRecipeAvailable(recipe, pantryService), isFalse);

        final missing = recipeService.getMissingIngredients(recipe, pantryService);
        expect(missing.length, equals(2));
        expect(missing[0].ingredientName, equals('Rice'));
        expect(missing[0].requiredQuantity, equals(300.0));
        expect(missing[1].ingredientName, equals('Chicken'));
        expect(missing[1].requiredQuantity, equals(200.0));
      });

      test('Exact quantity availability (pantry has exactly what recipe needs)', () {
        pantryService.addItem(
          createPantryItem(
            id: 'p-pasta-exact',
            name: 'Pasta',
            quantity: 200.0,
            unit: 'grams',
          ),
        );
        pantryService.addItem(
          createPantryItem(
            id: 'p-sauce-exact',
            name: 'Tomato Sauce',
            quantity: 100.0,
            unit: 'ml',
            category: IngredientCategory.other,
          ),
        );

        final recipe = createRecipe(
          id: 'rec-exact',
          ingredients: [
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
        recipeService.addRecipe(recipe);

        expect(recipeService.isRecipeAvailable(recipe, pantryService), isTrue);
        final missing = recipeService.getMissingIngredients(recipe, pantryService);
        expect(missing, isEmpty);
      });

      test('Case-insensitive matching of ingredient names', () {
        final recipe = createRecipe(
          id: 'rec-case',
          ingredients: [
            RecipeIngredient(
              ingredientName: 'pAsTa',
              requiredQuantity: 200.0,
              unit: 'grams',
            ),
            RecipeIngredient(
              ingredientName: 'TOMATO SAUCE',
              requiredQuantity: 100.0,
              unit: 'ml',
            ),
          ],
        );
        recipeService.addRecipe(recipe);

        pantryService.addItem(
          createPantryItem(
            id: 'p-pasta-case',
            name: 'pasta',
            quantity: 200.0,
            unit: 'grams',
          ),
        );
        pantryService.addItem(
          createPantryItem(
            id: 'p-sauce-case',
            name: 'Tomato Sauce',
            quantity: 100.0,
            unit: 'ml',
            category: IngredientCategory.other,
          ),
        );

        expect(recipeService.isRecipeAvailable(recipe, pantryService), isTrue);
        expect(recipeService.getMissingIngredients(recipe, pantryService), isEmpty);
      });
    });
  });
}
