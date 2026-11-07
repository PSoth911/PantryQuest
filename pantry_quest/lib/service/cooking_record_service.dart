import '../model/cookingRecord.dart';

class CookingRecordService {
  final List<CookingRecord> _cookingRecords = [];

  void addCookingRecord(CookingRecord record) {
    if (record.id.trim().isEmpty ||
        record.recipeId.trim().isEmpty ||
        record.recipeName.trim().isEmpty) {
      throw ArgumentError('Cooking record information cannot be empty.');
    }

    if (getCookingRecordById(record.id) != null) {
      throw StateError('Cooking record already exists.');
    }

    _cookingRecords.add(record);
  }

  List<CookingRecord> getAllCookingRecords() {
    return List.unmodifiable(_cookingRecords);
  }

  CookingRecord? getCookingRecordById(String id) {
    for (final record in _cookingRecords) {
      if (record.id == id) {
        return record;
      }
    }

    return null;
  }

  bool deleteCookingRecord(String id) {
    final index = _cookingRecords.indexWhere((record) => record.id == id);

    if (index == -1) {
      return false;
    }

    _cookingRecords.removeAt(index);

    return true;
  }
}
