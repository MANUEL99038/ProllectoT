class Sale {
  const Sale({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.unitCost,
    required this.date,
  });

  final String id;
  final String productId;
  final int quantity;
  final double unitPrice;
  final double unitCost;
  final DateTime date;

  double get total => unitPrice * quantity;
  double get profit => (unitPrice - unitCost) * quantity;

  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'unitCost': unitCost,
    'date': date.toIso8601String(),
  };

  factory Sale.fromJson(Map<String, dynamic> json) => Sale(
    id: json['id'] as String,
    productId: json['productId'] as String,
    quantity: (json['quantity'] as num).toInt(),
    unitPrice: (json['unitPrice'] as num).toDouble(),
    unitCost: (json['unitCost'] as num).toDouble(),
    date: DateTime.parse(json['date'] as String),
  );
}
