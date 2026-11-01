class PantryItem {
  final String id;
  final String name;
  double quantity;
  final String unit;
  final DateTime expiryDate;
  final String category;

  PantryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.expiryDate,
    required this.category,
  });

  bool get isExpired {
    return expiryDate.isBefore(DateTime.now());
  }

  bool get isExpiringSoon {
    final today = DateTime.now();

    return !isExpired &&
        expiryDate.difference(today).inDays <= 3;
  }
}