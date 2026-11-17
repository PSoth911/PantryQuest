import 'package:flutter_test/flutter_test.dart';
import 'package:pantry_quest/model/cookingRecord.dart';
import 'package:pantry_quest/model/ingredient_category.dart';
import 'package:pantry_quest/model/pantryItem.dart';
import 'package:pantry_quest/model/recipe.dart';
import 'package:pantry_quest/model/recipeIngredient.dart';
import 'package:pantry_quest/service/cooking_record_service.dart';
import 'package:pantry_quest/service/cooking_service.dart';
import 'package:pantry_quest/service/pantry_service.dart';
import 'package:pantry_quest/service/recipe_service.dart';

void main() {
  group('CookingService Tests', () {
    late PantryService pantryService;
    late RecipeService recipeService;
    late CookingRecordService recordService;
    late CookingService cookingService;

    setUp(() {
      pantryService = PantryService();
      recipeService = RecipeService();
      recordService = CookingRecordService();
      cookingService = CookingService(
        pantryService: pantryService,
        recipeService: recipeService,
        recordService: recordService,
      );
    });

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
        expiryDate: expiryDate ?? DateTime.now().add(const Duration(days: 7)),
        category: category,
      );
    }

    Recipe createRecipe({
      String id = 'recipe-1',
      String name = 'Pasta Bolognese',
      String imagePath = 'assets/images/pasta.png',
      List<RecipeIngredient>? ingredients,
    }) {
      return Recipe(
        id: id,
        name: name,
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

    group('Task 3.1: Normal Scenarios', () {
      test('Successfully record meal when recipe exists and pantry stock is sufficient (recordMeal)', () {
        pantryService.addItem(
          createPantryItem(
            id: 'p-1',
            name: 'Pasta',
            quantity: 500.0,
            unit: 'grams',
          ),
        );
        pantryService.addItem(
          createPantryItem(
            id: 'p-2',
            name: 'Tomato Sauce',
            quantity: 300.0,
            unit: 'ml',
            category: IngredientCategory.other,
          ),
        );

        final recipe = createRecipe(id: 'recipe-101', name: 'Pasta Bolognese');
        recipeService.addRecipe(recipe);

        final record = cookingService.recordMeal(
          recipeId: 'recipe-101',
          recordId: 'record-1',
        );

        expect(record, isNotNull);
        expect(record.id, equals('record-1'));
        expect(record.recipeId, equals('recipe-101'));
        expect(record.recipeName, equals('Pasta Bolognese'));
      });

      test('Verify pantry quantities are deducted properly', () {
        pantryService.addItem(
          createPantryItem(
            id: 'p-1',
            name: 'Pasta',
            quantity: 500.0,
            unit: 'grams',
          ),
        );
        pantryService.addItem(
          createPantryItem(
            id: 'p-2',
            name: 'Tomato Sauce',
            quantity: 300.0,
            unit: 'ml',
            category: IngredientCategory.other,
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

        cookingService.recordMeal(
          recipeId: 'recipe-1',
          recordId: 'record-1',
        );

        expect(
          pantryService.getAvailableQuantity('Pasta', 'grams'),
          equals(300.0),
        );
        expect(
          pantryService.getAvailableQuantity('Tomato Sauce', 'ml'),
          equals(200.0),
        );
      });

      test('Verify cooking record is stored in CookingRecordService', () {
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
            quantity: 200.0,
            unit: 'ml',
            category: IngredientCategory.other,
          ),
        );

        final recipe = createRecipe(id: 'recipe-1');
        recipeService.addRecipe(recipe);

        cookingService.recordMeal(
          recipeId: 'recipe-1',
          recordId: 'rec-test-store',
        );

        final allRecords = recordService.getAllCookingRecords();
        expect(allRecords.length, equals(1));
        expect(allRecords.first.id, equals('rec-test-store'));

        final retrieved = recordService.getCookingRecordById('rec-test-store');
        expect(retrieved, isNotNull);
        expect(retrieved!.recipeId, equals('recipe-1'));
        expect(retrieved.recipeName, equals(recipe.name));
      });

      test('Verify returned CookingRecord properties (id, recipeId, recipeName, cookedAt)', () {
        pantryService.addItem(
          createPantryItem(
            id: 'p-1',
            name: 'Pasta',
            quantity: 500.0,
            unit: 'grams',
          ),
        );
        pantryService.addItem(
          createPantryItem(
            id: 'p-2',
            name: 'Tomato Sauce',
            quantity: 300.0,
            unit: 'ml',
            category: IngredientCategory.other,
          ),
        );

        final recipe = createRecipe(
          id: 'recipe-custom',
          name: 'Classic Spaghetti',
        );
        recipeService.addRecipe(recipe);

        final explicitTime = DateTime(2026, 11, 17, 19, 45);
        final recordWithTime = cookingService.recordMeal(
          recipeId: 'recipe-custom',
          recordId: 'rec-custom-time',
          cookedAt: explicitTime,
        );

        expect(recordWithTime.id, equals('rec-custom-time'));
        expect(recordWithTime.recipeId, equals('recipe-custom'));
        expect(recordWithTime.recipeName, equals('Classic Spaghetti'));
        expect(recordWithTime.cookedAt, equals(explicitTime));

        // When cookedAt is omitted, should default to roughly DateTime.now()
        final beforeTime = DateTime.now().subtract(const Duration(seconds: 1));
        final recordDefaultTime = cookingService.recordMeal(
          recipeId: 'recipe-custom',
          recordId: 'rec-default-time',
        );
        final afterTime = DateTime.now().add(const Duration(seconds: 1));

        expect(recordDefaultTime.id, equals('rec-default-time'));
        expect(recordDefaultTime.recipeId, equals('recipe-custom'));
        expect(recordDefaultTime.recipeName, equals('Classic Spaghetti'));
        expect(
          recordDefaultTime.cookedAt.isAfter(beforeTime) ||
              recordDefaultTime.cookedAt.isAtSameMomentAs(beforeTime),
          isTrue,
        );
        expect(
          recordDefaultTime.cookedAt.isBefore(afterTime) ||
              recordDefaultTime.cookedAt.isAtSameMomentAs(afterTime),
          isTrue,
        );
      });
    });

    group('Task 3.2: Invalid Scenarios', () {
      test('Reject empty or whitespace record ID (ArgumentError)', () {
        pantryService.addItem(
          createPantryItem(
            id: 'p-1',
            name: 'Pasta',
            quantity: 500.0,
            unit: 'grams',
          ),
        );
        pantryService.addItem(
          createPantryItem(
            id: 'p-2',
            name: 'Tomato Sauce',
            quantity: 300.0,
            unit: 'ml',
            category: IngredientCategory.other,
          ),
        );

        final recipe = createRecipe(id: 'recipe-1');
        recipeService.addRecipe(recipe);

        expect(
          () => cookingService.recordMeal(
            recipeId: 'recipe-1',
            recordId: '',
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Record ID cannot be empty'),
            ),
          ),
        );

        expect(
          () => cookingService.recordMeal(
            recipeId: 'recipe-1',
            recordId: '   ',
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Record ID cannot be empty'),
            ),
          ),
        );

        // Verify state is clean
        expect(recordService.getAllCookingRecords(), isEmpty);
        expect(
          pantryService.getAvailableQuantity('Pasta', 'grams'),
          equals(500.0),
        );
      });

      test('Reject non-existing recipe ID (StateError)', () {
        pantryService.addItem(
          createPantryItem(
            id: 'p-1',
            name: 'Pasta',
            quantity: 500.0,
            unit: 'grams',
          ),
        );

        expect(
          () => cookingService.recordMeal(
            recipeId: 'non-existing-recipe-id',
            recordId: 'record-1',
          ),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('Recipe not found'),
            ),
          ),
        );

        expect(recordService.getAllCookingRecords(), isEmpty);
        expect(
          pantryService.getAvailableQuantity('Pasta', 'grams'),
          equals(500.0),
        );
      });

      test('Reject duplicate cooking record ID (StateError)', () {
        pantryService.addItem(
          createPantryItem(
            id: 'p-1',
            name: 'Pasta',
            quantity: 500.0,
            unit: 'grams',
          ),
        );
        pantryService.addItem(
          createPantryItem(
            id: 'p-2',
            name: 'Tomato Sauce',
            quantity: 300.0,
            unit: 'ml',
            category: IngredientCategory.other,
          ),
        );

        final recipe = createRecipe(id: 'recipe-1');
        recipeService.addRecipe(recipe);

        // Pre-insert a cooking record with the same ID
        recordService.addCookingRecord(
          CookingRecord(
            id: 'dup-rec-id',
            recipeId: 'recipe-1',
            recipeName: 'Pasta Bolognese',
            cookedAt: DateTime.now(),
          ),
        );

        expect(
          () => cookingService.recordMeal(
            recipeId: 'recipe-1',
            recordId: 'dup-rec-id',
          ),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('Cooking record already exists'),
            ),
          ),
        );

        // Verify pantry stock was not deducted
        expect(
          pantryService.getAvailableQuantity('Pasta', 'grams'),
          equals(500.0),
        );
        expect(
          pantryService.getAvailableQuantity('Tomato Sauce', 'ml'),
          equals(300.0),
        );
        expect(recordService.getAllCookingRecords().length, equals(1));
      });

      test('Reject meal recording when pantry stock is insufficient (StateError)', () {
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

        // Case 1: Ingredient completely missing from pantry
        expect(
          () => cookingService.recordMeal(
            recipeId: 'recipe-1',
            recordId: 'rec-missing',
          ),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('Insufficient ingredients'),
            ),
          ),
        );

        // Case 2: Ingredient exists but quantity is insufficient
        pantryService.addItem(
          createPantryItem(
            id: 'p-1',
            name: 'Pasta',
            quantity: 100.0, // Needs 200.0
            unit: 'grams',
          ),
        );
        pantryService.addItem(
          createPantryItem(
            id: 'p-2',
            name: 'Tomato Sauce',
            quantity: 100.0, // Needs 100.0
            unit: 'ml',
            category: IngredientCategory.other,
          ),
        );

        expect(
          () => cookingService.recordMeal(
            recipeId: 'recipe-1',
            recordId: 'rec-not-enough',
          ),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('Insufficient ingredients'),
            ),
          ),
        );

        // Case 3: Ingredient exists in quantity but is expired
        final freshPantry = PantryService();
        final localCookingService = CookingService(
          pantryService: freshPantry,
          recipeService: recipeService,
          recordService: recordService,
        );

        freshPantry.addItem(
          createPantryItem(
            id: 'p-expired',
            name: 'Pasta',
            quantity: 500.0,
            unit: 'grams',
            expiryDate: DateTime.now().subtract(const Duration(days: 2)),
          ),
        );
        freshPantry.addItem(
          createPantryItem(
            id: 'p-fresh-sauce',
            name: 'Tomato Sauce',
            quantity: 200.0,
            unit: 'ml',
            category: IngredientCategory.other,
          ),
        );

        expect(
          () => localCookingService.recordMeal(
            recipeId: 'recipe-1',
            recordId: 'rec-expired',
          ),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('Insufficient ingredients'),
            ),
          ),
        );
      });
    });

    group('Task 3.3: Boundary / Special Scenarios', () {
      test('Support exact quantity availability (pantry stock matches recipe requirement exactly)', () {
        pantryService.addItem(
          createPantryItem(
            id: 'p-1',
            name: 'Pasta',
            quantity: 200.0, // Exactly what recipe needs
            unit: 'grams',
          ),
        );
        pantryService.addItem(
          createPantryItem(
            id: 'p-2',
            name: 'Tomato Sauce',
            quantity: 100.0, // Exactly what recipe needs
            unit: 'ml',
            category: IngredientCategory.other,
          ),
        );

        final recipe = createRecipe(
          id: 'recipe-exact',
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

        final record = cookingService.recordMeal(
          recipeId: 'recipe-exact',
          recordId: 'rec-exact-1',
        );

        expect(record.id, equals('rec-exact-1'));
        // Pantry stock should be fully exhausted (0.0 available)
        expect(
          pantryService.getAvailableQuantity('Pasta', 'grams'),
          equals(0.0),
        );
        expect(
          pantryService.getAvailableQuantity('Tomato Sauce', 'ml'),
          equals(0.0),
        );
        expect(recordService.getAllCookingRecords().length, equals(1));
      });

      test('Atomicity: Leave pantry stock unchanged when recording fails due to insufficient ingredients', () {
        // Recipe needs 200g Pasta and 100ml Tomato Sauce
        // Pantry has plenty of Pasta (500g), but only 50ml Sauce (insufficient)
        pantryService.addItem(
          createPantryItem(
            id: 'p-pasta',
            name: 'Pasta',
            quantity: 500.0,
            unit: 'grams',
          ),
        );
        pantryService.addItem(
          createPantryItem(
            id: 'p-sauce',
            name: 'Tomato Sauce',
            quantity: 50.0,
            unit: 'ml',
            category: IngredientCategory.other,
          ),
        );

        final recipe = createRecipe(
          id: 'recipe-atomic',
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

        expect(
          () => cookingService.recordMeal(
            recipeId: 'recipe-atomic',
            recordId: 'rec-fail-atomic',
          ),
          throwsA(isA<StateError>()),
        );

        // Verification: Pasta must NOT have been deducted partially!
        expect(
          pantryService.getAvailableQuantity('Pasta', 'grams'),
          equals(500.0),
        );
        // Sauce must remain untouched
        expect(
          pantryService.getAvailableQuantity('Tomato Sauce', 'ml'),
          equals(500.0 > 0 ? 50.0 : 0.0),
        );
      });

      test('Atomicity: Leave pantry stock unchanged when recording fails due to recipe or record validation', () {
        pantryService.addItem(
          createPantryItem(
            id: 'p-pasta',
            name: 'Pasta',
            quantity: 500.0,
            unit: 'grams',
          ),
        );
        pantryService.addItem(
          createPantryItem(
            id: 'p-sauce',
            name: 'Tomato Sauce',
            quantity: 300.0,
            unit: 'ml',
            category: IngredientCategory.other,
          ),
        );

        final recipe = createRecipe(id: 'recipe-valid');
        recipeService.addRecipe(recipe);

        // Case A: invalid record ID
        expect(
          () => cookingService.recordMeal(
            recipeId: 'recipe-valid',
            recordId: '',
          ),
          throwsA(isA<ArgumentError>()),
        );
        expect(
          pantryService.getAvailableQuantity('Pasta', 'grams'),
          equals(500.0),
        );
        expect(
          pantryService.getAvailableQuantity('Tomato Sauce', 'ml'),
          equals(300.0),
        );

        // Case B: non-existent recipe ID
        expect(
          () => cookingService.recordMeal(
            recipeId: 'recipe-does-not-exist',
            recordId: 'rec-any',
          ),
          throwsA(isA<StateError>()),
        );
        expect(
          pantryService.getAvailableQuantity('Pasta', 'grams'),
          equals(500.0),
        );
        expect(
          pantryService.getAvailableQuantity('Tomato Sauce', 'ml'),
          equals(300.0),
        );
      });

      test('Atomicity: Create no cooking record when deduction or recipe validation fails', () {
        pantryService.addItem(
          createPantryItem(
            id: 'p-pasta',
            name: 'Pasta',
            quantity: 50.0, // Insufficient (needs 200.0)
            unit: 'grams',
          ),
        );

        final recipe = createRecipe(id: 'recipe-atomic-rec');
        recipeService.addRecipe(recipe);

        expect(
          () => cookingService.recordMeal(
            recipeId: 'recipe-atomic-rec',
            recordId: 'rec-never-created',
          ),
          throwsA(isA<StateError>()),
        );

        expect(recordService.getAllCookingRecords(), isEmpty);
        expect(recordService.getCookingRecordById('rec-never-created'), isNull);
      });

      test('Deduct across multiple pantry batches following expiry ordering (FEFO)', () {
        final now = DateTime.now();
        // Batch 1 expires in 2 days (100g)
        pantryService.addItem(
          createPantryItem(
            id: 'p-batch-earlier',
            name: 'Pasta',
            quantity: 100.0,
            unit: 'grams',
            expiryDate: now.add(const Duration(days: 2)),
          ),
        );
        // Batch 2 expires in 10 days (200g)
        pantryService.addItem(
          createPantryItem(
            id: 'p-batch-later',
            name: 'Pasta',
            quantity: 200.0,
            unit: 'grams',
            expiryDate: now.add(const Duration(days: 10)),
          ),
        );

        final singleIngredientRecipe = createRecipe(
          id: 'recipe-pasta-only',
          ingredients: [
            RecipeIngredient(
              ingredientName: 'Pasta',
              requiredQuantity: 150.0,
              unit: 'grams',
            ),
          ],
        );
        recipeService.addRecipe(singleIngredientRecipe);

        cookingService.recordMeal(
          recipeId: 'recipe-pasta-only',
          recordId: 'rec-multi-batch',
        );

        // 100g from earlier batch was exhausted, 50g deducted from later batch
        // Total remaining: 150g
        expect(
          pantryService.getAvailableQuantity('Pasta', 'grams'),
          equals(150.0),
        );

        // Batch 1 item should be removed
        expect(pantryService.getItemById('p-batch-earlier'), isNull);

        // Batch 2 item should have 150g remaining
        final laterBatch = pantryService.getItemById('p-batch-later');
        expect(laterBatch, isNotNull);
        expect(laterBatch!.quantity, equals(150.0));
      });
    });
  });
}
