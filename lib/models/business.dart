class Business {
  const Business({
    required this.name,
    required this.type,
    required this.owner,
    required this.currency,
    required this.productCount,
  });

  final String name;
  final String type;
  final String owner;
  final String currency;
  final int productCount;

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'owner': owner,
    'currency': currency,
    'productCount': productCount,
  };

  factory Business.fromJson(Map<String, dynamic> json) => Business(
    name: json['name'] as String? ?? '',
    type: json['type'] as String? ?? '',
    owner: json['owner'] as String? ?? '',
    currency: json['currency'] as String? ?? 'MXN',
    productCount: (json['productCount'] as num?)?.toInt() ?? 0,
  );
}
