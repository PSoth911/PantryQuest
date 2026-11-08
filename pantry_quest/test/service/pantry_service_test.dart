import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../../lib/model/pantryItem.dart';
import '../../lib/service/pantry_service.dart';

void main() {
  group('PantryService Tests', () {
    late PantryService pantryService;
    final uuid = Uuid();

    setUp(() {
      pantryService = PantryService();
    });

    PantryItem createValidItem({
      String? id,
      String name = 'Rice',
      double quantity = 5.0,
      String unit = 'kg',
      DateTime? expiryDate,
    }) {
      return PantryItem(
        id: id ?? uuid.v4(),
        name: name,
        quantity: quantity,
        unit: unit,
        expiryDate: expiryDate ?? DateTime.now().add(const Duration(days: 10)),
        category: 'Grains',
      );
    }

    test('NORMAL: Should add a valid pantry item successfully', () {
      final item = createValidItem();

      pantryService.addItem(item);

      final items = pantryService.getAllItems();
      expect(items.length, equals(1));
      expect(items.first.name, equals('Rice'));
      expect(items.first.quantity, equals(5.0));
    });

    test('INVALID: Should reject item with empty name', () {
      final item = createValidItem(name: ''); // Empty name

      expect(() => pantryService.addItem(item), throwsA(isA<ArgumentError>()));

      expect(pantryService.getAllItems().isEmpty, isTrue);
    });

    test('INVALID: Should reject item with zero or negative quantity', () {
      final itemZero = createValidItem(quantity: 0);
      final itemNegative = createValidItem(quantity: -5);

      expect(
        () => pantryService.addItem(itemZero),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => pantryService.addItem(itemNegative),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('BOUNDARY: Should accept item expiring today but reject item expired yesterday', () {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      final itemToday = createValidItem(expiryDate: today);
      expect(() => pantryService.addItem(itemToday), returnsNormally);

      final itemYesterday = createValidItem(
        id: uuid.v4(),
        expiryDate: yesterday,
      );
      expect(
        () => pantryService.addItem(itemYesterday),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('INVALID: Should reject adding an item with a duplicate ID', () {
      final id = 'duplicate-id-123';
      final item1 = createValidItem(id: id);
      final item2 = createValidItem(
        id: id,
        name: 'Wheat',
      ); // Same ID, different name

      pantryService.addItem(item1);

      expect(() => pantryService.addItem(item2), throwsA(isA<StateError>()));

      expect(pantryService.getAllItems().length, equals(1));
      expect(pantryService.getAllItems().first.name, equals('Rice'));
    });
  });
}
