import '../model/pantryItem.dart';

class PantryService {
  final List<PantryItem> _items = [];

  void _validateItem(PantryItem item) {
    if (item.id.trim().isEmpty ||
        item.name.trim().isEmpty ||
        item.unit.trim().isEmpty) {
      throw ArgumentError('Item information cannot be empty.');
    }

    if (item.quantity <= 0 || !item.quantity.isFinite) {
      throw ArgumentError('Quantity must be a finite number greater than zero.');
    }

  }

  void addItem(PantryItem item) {
    _validateItem(item);

    if (_items.any((existing) => existing.id == item.id)) {
      throw StateError('Item with this ID already exists.');
    }

    _items.add(item.copy());
  }

  List<PantryItem> getAllItems() {
    return List.unmodifiable(_items.map((item)=>item.copy()));
  }

  PantryItem? getItemById(String id) {
    for (final item in _items) {
      if (item.id == id) {
        return item.copy();
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

    _items[index] = updatedItem.copy();

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
