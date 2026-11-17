import 'package:flutter_test/flutter_test.dart';
import 'package:pantry_quest/model/ingredient_category.dart';
import 'package:pantry_quest/model/pantryItem.dart';
import 'package:pantry_quest/model/recipeIngredient.dart';
import 'package:pantry_quest/service/pantry_service.dart';

void main() {
  group('PantryService Tests', () {
    late PantryService pantryService;

    setUp(() {
      pantryService = PantryService();
    });

    PantryItem createItem({
      String id = 'item-1',
      String name = 'Rice',
      double quantity = 5.0,
      String unit = 'kg',
      DateTime? expiryDate,
      IngredientCategory category = IngredientCategory.grains,
    }) {
      return PantryItem(
        id: id,
        name: name,
        quantity: quantity,
        unit: unit,
        expiryDate: expiryDate,
        category: category,
      );
    }

    group('Task 4.1: Normal Scenarios', () {
      test('Add a valid pantry item (addItem)', () {
        final item = createItem(
          id: 'rice-1',
          name: 'Jasmine Rice',
          quantity: 2.5,
          unit: 'kg',
          category: IngredientCategory.grains,
        );

        pantryService.addItem(item);

        final items = pantryService.getAllItems();
        expect(items.length, equals(1));
        expect(items.first.id, equals('rice-1'));
        expect(items.first.name, equals('Jasmine Rice'));
        expect(items.first.quantity, equals(2.5));
        expect(items.first.unit, equals('kg'));
        expect(items.first.category, equals(IngredientCategory.grains));

        final retrieved = pantryService.getItemById('rice-1');
        expect(retrieved, isNotNull);
        expect(retrieved!.name, equals('Jasmine Rice'));
      });

      test('Retrieve all pantry items (getAllItems)', () {
        final item1 = createItem(id: 'i-1', name: 'Rice', quantity: 3.0);
        final item2 = createItem(id: 'i-2', name: 'Salt', quantity: 1.0, unit: 'kg', category: IngredientCategory.spices);

        pantryService.addItem(item1);
        pantryService.addItem(item2);

        final items = pantryService.getAllItems();
        expect(items.length, equals(2));
        expect(items[0].id, equals('i-1'));
        expect(items[1].id, equals('i-2'));

        // Verify returned list is unmodifiable
        expect(
          () => items.add(createItem(id: 'i-3')),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('Update an existing pantry item (updateItem)', () {
        final item = createItem(
          id: 'item-update-1',
          name: 'Old Bread',
          quantity: 1.0,
          unit: 'loaf',
        );
        pantryService.addItem(item);

        final updated = createItem(
          id: 'item-update-1',
          name: 'Fresh Bread',
          quantity: 2.0,
          unit: 'loaf',
          category: IngredientCategory.grains,
        );

        final result = pantryService.updateItem(updated);
        expect(result, isTrue);

        final fetched = pantryService.getItemById('item-update-1');
        expect(fetched, isNotNull);
        expect(fetched!.name, equals('Fresh Bread'));
        expect(fetched.quantity, equals(2.0));
      });

      test('Delete an existing pantry item (deleteItem)', () {
        final item1 = createItem(id: 'del-1', name: 'Milk');
        final item2 = createItem(id: 'del-2', name: 'Butter');

        pantryService.addItem(item1);
        pantryService.addItem(item2);

        final deleted = pantryService.deleteItem('del-1');
        expect(deleted, isTrue);

        expect(pantryService.getItemById('del-1'), isNull);
        final remaining = pantryService.getAllItems();
        expect(remaining.length, equals(1));
        expect(remaining.first.id, equals('del-2'));

        // Deleting already deleted item returns false
        expect(pantryService.deleteItem('del-1'), isFalse);
      });

      test('Calculate available ingredient quantity (getAvailableQuantity)', () {
        final future = DateTime.now().add(const Duration(days: 10));

        pantryService.addItem(
          createItem(id: 'r-1', name: 'Rice', quantity: 2.0, unit: 'kg', expiryDate: future),
        );
        pantryService.addItem(
          createItem(id: 'r-2', name: 'Rice', quantity: 3.5, unit: 'kg', expiryDate: future),
        );

        expect(pantryService.getAvailableQuantity('Rice', 'kg'), equals(5.5));
        expect(pantryService.getAvailableQuantity('rice', 'kg'), equals(5.5));
        expect(pantryService.getAvailableQuantity('  RICE  ', 'kg'), equals(5.5));

        expect(pantryService.getAvailableQuantity('Rice', 'grams'), equals(0.0));

        expect(pantryService.getAvailableQuantity('Sugar', 'kg'), equals(0.0));
      });
    });

    group('Task 4.2: Invalid Scenarios', () {
      test('Reject duplicate item IDs (StateError)', () {
        final item1 = createItem(id: 'dup-id', name: 'Pasta', quantity: 500.0);
        final item2 = createItem(id: 'dup-id', name: 'Rice', quantity: 1000.0);

        pantryService.addItem(item1);

        expect(
          () => pantryService.addItem(item2),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('Item with this ID already exists'),
            ),
          ),
        );

        expect(pantryService.getAllItems().length, equals(1));
        expect(pantryService.getAllItems().first.name, equals('Pasta'));
      });

      test('Reject item with empty or whitespace name (ArgumentError)', () {
        expect(
          () => createItem(name: ''),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => createItem(name: '   '),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('Reject item with zero, negative, or non-finite quantity (ArgumentError)', () {
        expect(
          () => createItem(quantity: 0),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => createItem(quantity: -5.0),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => createItem(quantity: double.nan),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => createItem(quantity: double.infinity),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('Reject updating a non-existent item (returns false)', () {
        final nonExistent = createItem(id: 'ghost-item', name: 'Ghost Flour');

        final result = pantryService.updateItem(nonExistent);
        expect(result, isFalse);
        expect(pantryService.getAllItems(), isEmpty);
      });

      test('Reject updating with invalid quantity or data (ArgumentError)', () {
        final item = createItem(id: 'item-test-invalid', name: 'Sugar', quantity: 100.0);
        pantryService.addItem(item);

        expect(
          () => item.quantity = 0,
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => item.quantity = -10,
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => item.name = '',
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => item.unit = '   ',
          throwsA(isA<ArgumentError>()),
        );

        final stored = pantryService.getItemById('item-test-invalid');
        expect(stored!.quantity, equals(100.0));
        expect(stored.name, equals('Sugar'));
      });

      test('Reject item with empty ID or empty unit (ArgumentError)', () {
        expect(
          () => createItem(id: ''),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => createItem(id: '   '),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => createItem(unit: ''),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => createItem(unit: '   '),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Task 4.3: Boundary / Special Scenarios', () {
      test('Accept item expiring today but reject expired yesterday from availability', () {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final yesterday = today.subtract(const Duration(days: 1));

        final itemToday = createItem(
          id: 'item-today',
          name: 'Milk',
          quantity: 1.0,
          unit: 'liter',
          expiryDate: today,
          category: IngredientCategory.dairy,
        );

        final itemYesterday = createItem(
          id: 'item-yesterday',
          name: 'Milk',
          quantity: 1.0,
          unit: 'liter',
          expiryDate: yesterday,
          category: IngredientCategory.dairy,
        );

        expect(itemToday.isExpired, isFalse);

        expect(itemYesterday.isExpired, isTrue);

        pantryService.addItem(itemToday);
        pantryService.addItem(itemYesterday);

        expect(pantryService.getAvailableQuantity('Milk', 'liter'), equals(1.0));

        expect(pantryService.hasEnoughIngredient('Milk', 1.0, 'liter'), isTrue);
        expect(pantryService.hasEnoughIngredient('Milk', 1.5, 'liter'), isFalse);

        // Expired list should contain the yesterday item
        final expiredList = pantryService.getAllExpired();
        expect(expiredList.length, equals(1));
        expect(expiredList.first.id, equals('item-yesterday'));
      });

      test('Support null expiry dates (non-perishable items like salt or sugar)', () {
        final salt = createItem(
          id: 'salt-1',
          name: 'Sea Salt',
          quantity: 500.0,
          unit: 'grams',
          expiryDate: null,
          category: IngredientCategory.spices,
        );

        pantryService.addItem(salt);

        expect(salt.isExpired, isFalse);
        expect(salt.isExpiringSoon, isFalse);

        expect(pantryService.getAvailableQuantity('Sea Salt', 'grams'), equals(500.0));
        expect(pantryService.getAllExpired(), isEmpty);
        expect(pantryService.getAllExpiredSoon(), isEmpty);

        // Deduction of non-perishable items works normally
        pantryService.deductIngredients([
          RecipeIngredient(
            ingredientName: 'Sea Salt',
            requiredQuantity: 100.0,
            unit: 'grams',
          ),
        ]);

        expect(pantryService.getAvailableQuantity('Sea Salt', 'grams'), equals(400.0));
      });

      test('Identify items expiring within 3 days (getAllExpiredSoon / isExpiringSoon)', () {
        final now = DateTime.now();
        final in1Day = now.add(const Duration(days: 1));
        final in3Days = now.add(const Duration(days: 3));
        final in5Days = now.add(const Duration(days: 5));
        final yesterday = now.subtract(const Duration(days: 1));

        final item1Day = createItem(id: 'soon-1', name: 'Yogurt', expiryDate: in1Day);
        final item3Days = createItem(id: 'soon-2', name: 'Bread', expiryDate: in3Days);
        final item5Days = createItem(id: 'fresh-1', name: 'Eggs', expiryDate: in5Days);
        final itemExpired = createItem(id: 'exp-1', name: 'Old Cheese', expiryDate: yesterday);
        final itemNoExpiry = createItem(id: 'no-exp', name: 'Salt', expiryDate: null);

        expect(item1Day.isExpiringSoon, isTrue);
        expect(item3Days.isExpiringSoon, isTrue);
        expect(item5Days.isExpiringSoon, isFalse);
        expect(itemExpired.isExpiringSoon, isFalse); // Already expired, not expiring soon
        expect(itemNoExpiry.isExpiringSoon, isFalse);

        pantryService.addItem(item1Day);
        pantryService.addItem(item3Days);
        pantryService.addItem(item5Days);
        pantryService.addItem(itemExpired);
        pantryService.addItem(itemNoExpiry);

        final expiringSoon = pantryService.getAllExpiredSoon();
        expect(expiringSoon.length, equals(2));
        final expiringIds = expiringSoon.map((e) => e.id).toSet();
        expect(expiringIds, containsAll(['soon-1', 'soon-2']));

        final expired = pantryService.getAllExpired();
        expect(expired.length, equals(1));
        expect(expired.first.id, equals('exp-1'));
      });

      test('Exclude expired ingredients from available quantities (getAvailableQuantity)', () {
        final now = DateTime.now();
        final freshDate = now.add(const Duration(days: 7));
        final expiredDate = now.subtract(const Duration(days: 3));

        pantryService.addItem(
          createItem(id: 'fresh-rice', name: 'Rice', quantity: 5.0, unit: 'kg', expiryDate: freshDate),
        );
        pantryService.addItem(
          createItem(id: 'expired-rice', name: 'Rice', quantity: 10.0, unit: 'kg', expiryDate: expiredDate),
        );

        // Only the fresh 5.0 kg should be available
        expect(pantryService.getAvailableQuantity('Rice', 'kg'), equals(5.0));

        // hasEnoughIngredient correctly checks only non-expired stock
        expect(pantryService.hasEnoughIngredient('Rice', 5.0, 'kg'), isTrue);
        expect(pantryService.hasEnoughIngredient('Rice', 6.0, 'kg'), isFalse);
      });

      test('FEFO deduction: Deduct from batches closest to expiration first (deductIngredients)', () {
        final now = DateTime.now();
        // Batch 1: Expires in 2 days (Earliest) - 50g
        pantryService.addItem(
          createItem(
            id: 'batch-earliest',
            name: 'Butter',
            quantity: 50.0,
            unit: 'grams',
            expiryDate: now.add(const Duration(days: 2)),
          ),
        );
        // Batch 2: Expires in 10 days - 100g
        pantryService.addItem(
          createItem(
            id: 'batch-later',
            name: 'Butter',
            quantity: 100.0,
            unit: 'grams',
            expiryDate: now.add(const Duration(days: 10)),
          ),
        );
        // Batch 3: Non-perishable (Null expiry) - 200g
        pantryService.addItem(
          createItem(
            id: 'batch-no-expiry',
            name: 'Butter',
            quantity: 200.0,
            unit: 'grams',
            expiryDate: null,
          ),
        );

        // Deduct 80g: 50g from batch-earliest, 30g from batch-later
        pantryService.deductIngredients([
          RecipeIngredient(ingredientName: 'Butter', requiredQuantity: 80.0, unit: 'grams'),
        ]);

        // Total remaining: 350 - 80 = 270g
        expect(pantryService.getAvailableQuantity('Butter', 'grams'), equals(270.0));

        // batch-earliest should be exhausted and removed
        expect(pantryService.getItemById('batch-earliest'), isNull);

        // batch-later should have 70g remaining
        final laterBatch = pantryService.getItemById('batch-later');
        expect(laterBatch, isNotNull);
        expect(laterBatch!.quantity, equals(70.0));

        // batch-no-expiry should still have full 200g
        final noExpiryBatch = pantryService.getItemById('batch-no-expiry');
        expect(noExpiryBatch, isNotNull);
        expect(noExpiryBatch!.quantity, equals(200.0));
      });

      test('Atomic deduction: Avoid partial deduction when any ingredient stock is insufficient', () {
        pantryService.addItem(
          createItem(id: 'stock-flour', name: 'Flour', quantity: 500.0, unit: 'grams'),
        );
        pantryService.addItem(
          createItem(id: 'stock-sugar', name: 'Sugar', quantity: 20.0, unit: 'grams'),
        );

        final ingredients = [
          RecipeIngredient(ingredientName: 'Flour', requiredQuantity: 200.0, unit: 'grams'),
          RecipeIngredient(ingredientName: 'Sugar', requiredQuantity: 50.0, unit: 'grams'), // Insufficient!
        ];

        expect(
          () => pantryService.deductIngredients(ingredients),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('Insufficient Sugar in pantry'),
            ),
          ),
        );

        // Flour must NOT have been partially deducted!
        expect(pantryService.getAvailableQuantity('Flour', 'grams'), equals(500.0));
        expect(pantryService.getAvailableQuantity('Sugar', 'grams'), equals(20.0));
      });
    });
  });
}
