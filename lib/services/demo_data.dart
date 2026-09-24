import '../models/business.dart';
import '../models/expense.dart';
import '../models/product.dart';
import '../models/sale.dart';

class DemoData {
  static Business business() => const Business(
    name: 'Mi Tienda',
    type: 'Abarrotes',
    owner: 'Propietario',
    currency: 'MXN',
    productCount: 6,
  );

  static List<Product> products() {
    final now = DateTime.now();
    return [
      Product(
        id: 'coke',
        name: 'Coca-Cola 600 ml',
        category: 'Bebidas',
        code: '750001',
        cost: 12,
        price: 18,
        stock: 25,
        minimumStock: 8,
        createdAt: now.subtract(const Duration(days: 50)),
        lastSaleAt: now.subtract(const Duration(days: 2)),
        salesCount: 45,
      ),
      Product(
        id: 'chips',
        name: 'Sabritas clásicas',
        category: 'Botanas',
        code: '750002',
        cost: 10,
        price: 16,
        stock: 18,
        minimumStock: 6,
        createdAt: now.subtract(const Duration(days: 40)),
        lastSaleAt: now.subtract(const Duration(days: 4)),
        salesCount: 28,
      ),
      Product(
        id: 'milk',
        name: 'Leche entera 1L',
        category: 'Lácteos',
        code: '750003',
        cost: 19,
        price: 28,
        stock: 3,
        minimumStock: 6,
        createdAt: now.subtract(const Duration(days: 30)),
        lastSaleAt: now.subtract(const Duration(days: 1)),
        salesCount: 34,
      ),
      Product(
        id: 'bread',
        name: 'Pan dulce',
        category: 'Panadería',
        code: '750004',
        cost: 8,
        price: 10,
        stock: 32,
        minimumStock: 5,
        createdAt: now.subtract(const Duration(days: 35)),
        lastSaleAt: now.subtract(const Duration(days: 20)),
        salesCount: 12,
      ),
      Product(
        id: 'cereal',
        name: 'Cereal familiar',
        category: 'Abarrotes',
        code: '750005',
        cost: 42,
        price: 50,
        stock: 20,
        minimumStock: 4,
        createdAt: now.subtract(const Duration(days: 45)),
        salesCount: 0,
      ),
      Product(
        id: 'water',
        name: 'Agua 1L',
        category: 'Bebidas',
        code: '750006',
        cost: 7,
        price: 12,
        stock: 40,
        minimumStock: 10,
        createdAt: now.subtract(const Duration(days: 60)),
        lastSaleAt: now.subtract(const Duration(days: 30)),
        salesCount: 9,
      ),
    ];
  }

  static List<Sale> sales() => [
    Sale(
      id: 'sale-1',
      productId: 'coke',
      quantity: 4,
      unitPrice: 18,
      unitCost: 12,
      date: DateTime.now(),
    ),
    Sale(
      id: 'sale-2',
      productId: 'milk',
      quantity: 2,
      unitPrice: 28,
      unitCost: 19,
      date: DateTime.now(),
    ),
  ];

  static List<Expense> expenses() => [
    Expense(
      id: 'expense-1',
      name: 'Luz del local',
      category: 'Luz',
      amount: 350,
      date: DateTime.now(),
    ),
    Expense(
      id: 'expense-2',
      name: 'Compra a proveedor',
      category: 'Proveedores',
      amount: 800,
      date: DateTime.now(),
    ),
  ];
}
