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
  }) : _id = _validateId(id),
       _name = _validateName(name),
       _quantity = _validateQuantity(quantity),
       _unit = _validateUnit(unit),
       _expiryDate = expiryDate,
       _category = category;

  String get id => _id;
  String get name => _name;
  double get quantity => _quantity;
  String get unit => _unit;
  DateTime? get expiryDate => _expiryDate;
  IngredientCategory get category => _category;

  static String _validateId(String value) {
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      throw ArgumentError('ID cannot be empty.');
    }
    return trimmedValue;
  }

  static String _validateName(String value) {
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      throw ArgumentError('Name cannot be empty');
    }
    return trimmedValue;
  }

  static double _validateQuantity(double value) {
    if (value <= 0 || !value.isFinite) {
      throw ArgumentError(
        'Quantity must be a finite number greater than zero.',
      );
    }
    return value;
  }

  static String _validateUnit(String value) {
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      throw ArgumentError('Unit cannot be empty.');
    }
    return trimmedValue;
  }

  set name(String value) {
    _name = _validateName(value);
  }

  set quantity(double value) {
    _quantity = _validateQuantity(value);
  }

  set unit(String value) {
    _unit = _validateUnit(value);
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

  PantryItem copy() {
    return PantryItem(
      id: id,
      name: name,
      quantity: quantity,
      unit: unit,
      expiryDate: expiryDate,
      category: category,
    );
  }
}
