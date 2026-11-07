import '../model/pantryItem.dart';

class PantryService {
  final List<PantryItem> _items = [];

  void _validateItem(PantryItem item) {
    if (item.id.trim().isEmpty ||
        item.name.trim().isEmpty ||
        item.unit.trim().isEmpty) {
      throw ArgumentError('Item information cannot be empty.');
    }

    if (item.quantity <= 0) {
      throw ArgumentError('Quantity must be greater than zero.');
    }

    _validateExpiryDate(item);
  }

  void _validateExpiryDate(PantryItem item) {
    if (item.expiryDate == null) return;

    final today = DateTime.now();
    final expiry = item.expiryDate!;

    final todayDate = DateTime(today.year, today.month, today.day);

    final expiryDay = DateTime(expiry.year, expiry.month, expiry.day);

    if (expiryDay.isBefore(todayDate)) {
      throw ArgumentError('Expiry date cannot be in the past.');
    }
  }

  void addItem(PantryItem item) {
    _validateItem(item);

    if (getItemById(item.id) != null) {
      throw StateError('Item with this ID already exists.');
    }

    _items.add(item);
  }

  List<PantryItem> getAllItems() {
    return List.unmodifiable(_items);
  }

  PantryItem? getItemById(String id) {
    for (final item in _items) {
      if (item.id == id) {
        return item;
      }
    }

    return null;
  }

  bool updateItem(PantryItem updatedItem) {
    final index = _items.indexWhere((item) => item.id == updatedItem.id);

    if (index == -1) {
      return false;
    }

    _validateItem(updatedItem);

    _items[index] = updatedItem;

    return true;
  }

  bool deleteItem(String id) {
    final index = _items.indexWhere((item) => item.id == id);

    if (index == -1) {
      return false;
    }

    _items.removeAt(index);

    return true;
  }
}
