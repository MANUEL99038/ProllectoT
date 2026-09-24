class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.code,
    required this.cost,
    required this.price,
    required this.stock,
    required this.minimumStock,
    this.description = '',
    this.createdAt,
    this.lastSaleAt,
    this.salesCount = 0,
  });

  final String id;
  final String name;
  final String category;
  final String code;
  final double cost;
  final double price;
  final int stock;
  final int minimumStock;
  final String description;
  final DateTime? createdAt;
  final DateTime? lastSaleAt;
  final int salesCount;

  double get profit => price - cost;
  double get margin => price == 0 ? 0 : profit / price * 100;
  double get invested => cost * stock;

  Product copyWith({int? stock, DateTime? lastSaleAt, int? salesCount}) =>
      Product(
        id: id,
        name: name,
        category: category,
        code: code,
        cost: cost,
        price: price,
        stock: stock ?? this.stock,
        minimumStock: minimumStock,
        description: description,
        createdAt: createdAt,
        lastSaleAt: lastSaleAt ?? this.lastSaleAt,
        salesCount: salesCount ?? this.salesCount,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'code': code,
    'cost': cost,
    'price': price,
    'stock': stock,
    'minimumStock': minimumStock,
    'description': description,
    'createdAt': createdAt?.toIso8601String(),
    'lastSaleAt': lastSaleAt?.toIso8601String(),
    'salesCount': salesCount,
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    category: json['category'] as String? ?? 'Otros',
    code: json['code'] as String? ?? '',
    cost: (json['cost'] as num?)?.toDouble() ?? 0,
    price: (json['price'] as num?)?.toDouble() ?? 0,
    stock: (json['stock'] as num?)?.toInt() ?? 0,
    minimumStock: (json['minimumStock'] as num?)?.toInt() ?? 0,
    description: json['description'] as String? ?? '',
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    lastSaleAt: DateTime.tryParse(json['lastSaleAt'] as String? ?? ''),
    salesCount: (json['salesCount'] as num?)?.toInt() ?? 0,
  );
}
