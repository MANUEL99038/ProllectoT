class Expense {
  const Expense({
    required this.id,
    required this.name,
    required this.category,
    required this.amount,
    required this.date,
    this.description = '',
  });

  final String id;
  final String name;
  final String category;
  final double amount;
  final DateTime date;
  final String description;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'amount': amount,
    'date': date.toIso8601String(),
    'description': description,
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    category: json['category'] as String? ?? 'Otros',
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
    date: DateTime.parse(json['date'] as String),
    description: json['description'] as String? ?? '',
  );
}
