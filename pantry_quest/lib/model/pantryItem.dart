
import 'ingredient_category.dart';

class PantryItem {
  final String _id;
  String _name;
  double _quantity;
  String _unit;
  DateTime? _expiryDate;
  IngredientCategory _category;

  PantryItem({
    required String id,
    required String name,
    required double quantity,
    required String unit,
    required DateTime? expiryDate,
    required IngredientCategory category,
  })  : _id = id,
        _name = name,
        _quantity = quantity,
        _unit = unit,
        _expiryDate = expiryDate,
        _category = category;

  String get id => _id;
  String get name => _name;
  double get quantity => _quantity;
  String get unit => _unit;
  DateTime? get expiryDate => _expiryDate;
  IngredientCategory get category => _category;

  set name(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError('Name cannot be empty.');
    }
    _name = value;
  }

  set quantity(double value) {
    if (value <= 0) {
      throw ArgumentError('Quantity must be greater than zero.');
    }
    _quantity = value;
  }

  set unit(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError('Unit cannot be empty.');
    }
    _unit = value;
  }

  set expiryDate(DateTime? value) {
    _expiryDate = value;
  }

  set category(IngredientCategory value) {
    _category = value;
  }

  bool get isExpired {
    if (_expiryDate == null) return false;

    final today = DateTime.now();
    final expiry = _expiryDate!;

    final todayDate = DateTime(today.year, today.month, today.day);
    final expiryDay = DateTime(expiry.year, expiry.month, expiry.day);

    return expiryDay.isBefore(todayDate);
  }

  bool get isExpiringSoon {
    if (_expiryDate == null || isExpired) return false;

    final today = DateTime.now();
    final expiry = _expiryDate!;

    final todayDate = DateTime(today.year, today.month, today.day);
    final expiryDay = DateTime(expiry.year, expiry.month, expiry.day);

    return expiryDay.difference(todayDate).inDays <= 3;
  }
}
