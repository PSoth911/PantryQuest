import 'dart:nativewrappers/_internal/vm/lib/math_patch.dart';

import 'package:pantry_quest/model/ingredient_category.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../../lib/service/cooking_record_service.dart';
import '../../lib/service/pantry_service.dart';

import '../../lib/model/cookingRecord.dart';
import '../../lib/model/pantryItem.dart';
import '../../lib/model/recipe.dart';
import '../../lib/model/recipeIngredient.dart';

void main() {
  group('Cooking Record Service', () {
    late PantryService pantryService;
    late CookingRecordService cookingRecordService;
    final uuid = Uuid();

    setUp(() {
      pantryService = PantryService();

      cookingRecordService = CookingRecordService(pantryService);
    });

    test('Should record meal and deduct inventory successfull', () {
      final today = DateTime.now();

      final riceItem = PantryItem(
        id: uuid.v4(),
        name: "Rice",
        quantity: 1.0,
        unit: "kg",
        expiryDate: today.add(const Duration(days: 10)),
        category: IngredientCategory.grains,
      );

      final chickenItem = PantryItem(
        id: uuid.v4(),
        name: "Chicken",
        quantity: 3.0,
        unit: "kg",
        expiryDate: today.add(const Duration(days: 10)),
        category: IngredientCategory.meat,
      );

      pantryService.addItem(riceItem);
      pantryService.addItem(chickenItem);

      final recipe = Recipe(
        id: uuid.v4(),
        name: 'Chicken Rice',
        description: 'A simple meal',
        imagePath: '',
        ingredients: [
          RecipeIngredient(
            ingredientName: 'Rice',
            requiredQuantity: 1.0,
            unit: 'kg',
          ),
          RecipeIngredient(
            ingredientName: 'Chicken',
            requiredQuantity: 1.0,
            unit: 'kg',
          ),
        ],
      );

      final record = cookingRecordService.recordCookedMeal(
        recipe,
        note: 'Chnganh',
      );

      expect(record, isA<CookingRecord>);
      expect(record.recipeName, equals('Chicken Rice'));
      expect(cookingRecordService.getAllCookingRecords().length, equals(1));

      final pantry = pantryService.getAllItems();
      expect(pantry.firstWhere((i) => i.name == 'Rice').quantity, equals(4.0));
      expect(
        pantry.firstWhere((i) => i.name == 'Chicken').quantity,
        equals(2.0),
      );
    });

    test('Invalid: Reject cooking and keep inventory unchange', () {
      final today = DateTime.now();

      final riceItem = PantryItem(
        id: uuid.v4(),
        name: "Rice",
        quantity: 1.0,
        unit: "kg",
        expiryDate: today.add(const Duration(days: 10)),
        category: IngredientCategory.grains,
      );

      pantryService.addItem(riceItem);

      final recipe = Recipe(
        id: uuid.v4(),
        name: 'Chicken Rice',
        description: 'a delicous',
        imagePath: '',
        ingredients: [
          RecipeIngredient(
            ingredientName: 'Rice',
            requiredQuantity: 1.0,
            unit: 'kg',
          ),
          RecipeIngredient(
            ingredientName: 'Chicken',
            requiredQuantity: 1.0,
            unit: 'kg',
          ),
        ],
      );

      expect(
        () => CookingRecordService().recordCookedMeal(recipe),
        throwsA(isA<StateError>),
      );

      expect(pantryService.getAllItems().length, equals(1));
      expect(pantryService.getAllItems().first.quantity, equals(1));
      expect(cookingRecordService.getAllCookingRecords().isEmpty, true);
    });

    test('BOUNDARY: Should successfully cook and exhaust batch when quantity is exactly met', () {
      final today = DateTime.now();

      final eggsItem = PantryItem(
        id: uuid.v4(),
        name: 'Eggs',
        quantity: 2.0,
        unit: 'pcs',
        expiryDate: today.add(const Duration(days: 3)),
        category: IngredientCategory.dairy,
      );
      pantryService.addItem(eggsItem);

      final recipe = Recipe(
        id: uuid.v4(),
        name: 'Boiled Eggs',
        description: 'Simple',
        imagePath: '',
        // cookingTime removed!
        ingredients: [
          RecipeIngredient(
            ingredientName: 'Eggs',
            requiredQuantity: 2.0,
            unit: 'pcs',
          ),
        ],
      );

      cookingRecordService.recordCookedMeal(recipe);

      final pantry = pantryService.getAllItems();
      expect(pantry.first.quantity, equals(0.0));
      expect(cookingRecordService.getAllCookingRecords().length, equals(1));
    });

    test('Invalid: Should reject adding a cooking record with empty ID or repice info', () {
      final badRecord = CookingRecord(
        id: '',
        recipeId: uuid.v4(),
        recipeName: 'Test meal',
        cookedAt: DateTime.now(),
      );

      expect(
        () => cookingRecordService.addCookingRecord(badRecord),
        throwsA(isA<ArgumentError>),
      );
    });

    test('Boundary: Duplicate record', () {
      final record = CookingRecord(
        id: 'unique-id-123',
        recipeId: uuid.v4(),
        recipeName: 'Pasta',
        cookedAt: DateTime.now(),
      );

      expect(
        () => cookingRecordService.addCookingRecord(record),
        throwsA(isA<StateError>),
      );

      expect(cookingRecordService.getAllCookingRecords().length, equals(1));
    });
  });
}
