import 'package:flutter_test/flutter_test.dart';
import 'package:pantry_quest/model/cookingRecord.dart';
import 'package:pantry_quest/service/cooking_record_service.dart';

void main() {
  group('CookingRecordService Tests', () {
    late CookingRecordService service;

    setUp(() {
      service = CookingRecordService();
    });

    CookingRecord createRecord({
      String id = 'record-1',
      String recipeId = 'recipe-101',
      String recipeName = 'Spaghetti Bolognese',
      DateTime? cookedAt,
    }) {
      return CookingRecord(
        id: id,
        recipeId: recipeId,
        recipeName: recipeName,
        cookedAt: cookedAt ?? DateTime(2026, 11, 17, 12, 0),
      );
    }

    group('Task 2.1: Normal Scenarios', () {
      test('Should add a valid cooking record (addCookingRecord)', () {
        final record = createRecord(
          id: 'rec-1',
          recipeId: 'recipe-1',
          recipeName: 'Spaghetti',
        );

        service.addCookingRecord(record);

        final allRecords = service.getAllCookingRecords();
        expect(allRecords.length, equals(1));
        expect(allRecords.first.id, equals('rec-1'));
        expect(allRecords.first.recipeId, equals('recipe-1'));
        expect(allRecords.first.recipeName, equals('Spaghetti'));
        expect(allRecords.first.cookedAt, equals(record.cookedAt));
      });

      test('Should retrieve all cooking records (getAllCookingRecords)', () {
        final record1 = createRecord(id: 'rec-1', recipeName: 'Spaghetti');
        final record2 = createRecord(id: 'rec-2', recipeName: 'Fried Rice');

        service.addCookingRecord(record1);
        service.addCookingRecord(record2);

        final records = service.getAllCookingRecords();
        expect(records.length, equals(2));
        expect(records[0].id, equals('rec-1'));
        expect(records[1].id, equals('rec-2'));
      });

      test('Should retrieve a cooking record by ID (getCookingRecordById)', () {
        final record1 = createRecord(id: 'rec-1', recipeName: 'Spaghetti');
        final record2 = createRecord(id: 'rec-2', recipeName: 'Fried Rice');

        service.addCookingRecord(record1);
        service.addCookingRecord(record2);

        final found1 = service.getCookingRecordById('rec-1');
        expect(found1, isNotNull);
        expect(found1!.id, equals('rec-1'));
        expect(found1.recipeName, equals('Spaghetti'));

        final found2 = service.getCookingRecordById('rec-2');
        expect(found2, isNotNull);
        expect(found2!.id, equals('rec-2'));
        expect(found2.recipeName, equals('Fried Rice'));
      });

      test('Should delete a cooking record by ID (deleteCookingRecord)', () {
        final record1 = createRecord(id: 'rec-1', recipeName: 'Spaghetti');
        final record2 = createRecord(id: 'rec-2', recipeName: 'Fried Rice');

        service.addCookingRecord(record1);
        service.addCookingRecord(record2);

        final deleted = service.deleteCookingRecord('rec-1');
        expect(deleted, isTrue);

        expect(service.getCookingRecordById('rec-1'), isNull);
        expect(service.getAllCookingRecords().length, equals(1));
        expect(service.getAllCookingRecords().first.id, equals('rec-2'));
      });
    });

    group('Task 2.2: Invalid Scenarios', () {
      test('Should reject duplicate record IDs with StateError', () {
        final record1 = createRecord(id: 'dup-id', recipeName: 'Spaghetti');
        final record2 = createRecord(id: 'dup-id', recipeName: 'Fried Rice');

        service.addCookingRecord(record1);

        expect(
          () => service.addCookingRecord(record2),
          throwsA(isA<StateError>()),
        );

        expect(service.getAllCookingRecords().length, equals(1));
        expect(service.getAllCookingRecords().first.recipeName, equals('Spaghetti'));
      });

      test('Should reject record with empty or whitespace id (ArgumentError)', () {
        final emptyIdRecord = createRecord(id: '');
        final whitespaceIdRecord = createRecord(id: '   ');

        expect(
          () => service.addCookingRecord(emptyIdRecord),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => service.addCookingRecord(whitespaceIdRecord),
          throwsA(isA<ArgumentError>()),
        );

        expect(service.getAllCookingRecords().isEmpty, isTrue);
      });

      test('Should reject record with empty or whitespace recipeId (ArgumentError)', () {
        final emptyRecipeIdRecord = createRecord(recipeId: '');
        final whitespaceRecipeIdRecord = createRecord(recipeId: '   ');

        expect(
          () => service.addCookingRecord(emptyRecipeIdRecord),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => service.addCookingRecord(whitespaceRecipeIdRecord),
          throwsA(isA<ArgumentError>()),
        );

        expect(service.getAllCookingRecords().isEmpty, isTrue);
      });

      test('Should reject record with empty or whitespace recipeName (ArgumentError)', () {
        final emptyNameRecord = createRecord(recipeName: '');
        final whitespaceNameRecord = createRecord(recipeName: '   ');

        expect(
          () => service.addCookingRecord(emptyNameRecord),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => service.addCookingRecord(whitespaceNameRecord),
          throwsA(isA<ArgumentError>()),
        );

        expect(service.getAllCookingRecords().isEmpty, isTrue);
      });
    });

    group('Task 2.3: Boundary / Special Scenarios', () {
      test('Should return null when querying a non-existent ID', () {
        expect(service.getCookingRecordById('non-existent'), isNull);

        service.addCookingRecord(createRecord(id: 'rec-1'));
        expect(service.getCookingRecordById('non-existent'), isNull);
      });

      test('Should return false when deleting a non-existent ID', () {
        expect(service.deleteCookingRecord('non-existent'), isFalse);

        service.addCookingRecord(createRecord(id: 'rec-1'));
        expect(service.deleteCookingRecord('non-existent'), isFalse);
        expect(service.getAllCookingRecords().length, equals(1));
      });

      test('Should return an empty unmodifiable list when no records exist', () {
        final records = service.getAllCookingRecords();

        expect(records, isEmpty);
        expect(records.length, equals(0));

        // Attempting to modify unmodifiable list must throw UnsupportedError
        expect(
          () => records.add(createRecord(id: 'bad')),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('Should return an unmodifiable list after records are added', () {
        service.addCookingRecord(createRecord(id: 'rec-1'));
        final records = service.getAllCookingRecords();

        expect(records.length, equals(1));
        expect(
          () => records.clear(),
          throwsA(isA<UnsupportedError>()),
        );
      });
    });
  });
}
