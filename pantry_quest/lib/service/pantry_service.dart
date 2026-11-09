import 'package:pantry_quest/model/recipeIngredient.dart';

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
      throw ArgumentError(
        'Quantity must be a finite number greater than zero.',
      );
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
    return List.unmodifiable(_items.map((item) => item.copy()));
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

  List<PantryItem> getAllExpired() {
    return List.unmodifiable(
      _items
          .where((item) => item.isExpired == true)
          .map((itm) => itm.copy())
          .toList(),
    );
  }

  List<PantryItem> getAllExpiredSoon() {
    return List.unmodifiable(
      _items
          .where((item) => item.isExpiringSoon == true)
          .map((itm) => itm.copy())
          .toList(),
    );
  }

  double getAvailableQuantity(String ingredientName, String unit) {
    return _items
        .where(
          (item) =>
              item.name.toLowerCase() == ingredientName.trim().toLowerCase() &&
              item.unit == unit.trim() &&
              !item.isExpired,
        )
        .fold(0.0, (total, item) => total + item.quantity);
  }

  bool hasEnoughIngredient(
    String ingredientName,
    double requiredQuantity,
    String unit,
  ) {
    if (ingredientName.trim().isEmpty ||
        unit.trim().isEmpty ||
        requiredQuantity <= 0 ||
        !requiredQuantity.isFinite) {
      throw ArgumentError('Invalid ingredient requirements.');
    }

    final available = getAvailableQuantity(ingredientName, unit);

    return available + 0.000000001 >= requiredQuantity;
  }

  void deductIngredients(List<RecipeIngredient> ingredients) {

  

    for (final ingredient in ingredients) {
      if (!hasEnoughIngredient(
        ingredient.ingredientName,
        ingredient.requiredQuantity,
        ingredient.unit,
      )) {
        throw StateError(
          'Insufficient ${ingredient.ingredientName} in pantry.',
        );
      }
    }

   

    for (final ingredient in ingredients) {
      double remaining = ingredient.requiredQuantity;

      final matchingItems = _items.where(
        (item) =>
            item.name.toLowerCase() ==
                ingredient.ingredientName.toLowerCase() &&
            item.unit == ingredient.unit &&
            !item.isExpired,
      ).toList();

      matchingItems.sort((a, b) {
        if (a.expiryDate == null && b.expiryDate == null) {
          return 0;
        }

        if (a.expiryDate == null) return 1;
        if (b.expiryDate == null) return -1;

        return a.expiryDate!.compareTo(b.expiryDate!);
      });

      for (final item in matchingItems) {
        if (remaining <= 0) break;

        if (item.quantity <= remaining) {
          remaining -= item.quantity;
          _items.remove(item);
        } else {
          item.quantity = item.quantity - remaining;
          remaining = 0;
        }
      }
    }
  }
}
