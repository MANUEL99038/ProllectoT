import 'package:flutter/foundation.dart';

import 'models/business.dart';
import 'models/expense.dart';
import 'models/loss_alert.dart';
import 'models/product.dart';
import 'models/sale.dart';
import 'services/ai_service.dart';
import 'services/demo_data.dart';
import 'services/local_store.dart';

class AppState extends ChangeNotifier {
  AppState(this.store);
  final LocalStore store;
  final analyzer = AiService();
  Business? business;
  List<Product> products = [];
  List<Sale> sales = [];
  List<Expense> expenses = [];
  bool ready = false;

  Future<void> load() async {
    business = store.business;
    products = store.products;
    sales = store.sales;
    expenses = store.expenses;
    ready = true;
    notifyListeners();
  }

  List<LossAlert> get alerts =>
      analyzer.explain(products: products, sales: sales, expenses: expenses);
  double get salesTotal => sales.fold(0, (sum, sale) => sum + sale.total);
  double get profitTotal => sales.fold(0, (sum, sale) => sum + sale.profit);
  double get expensesTotal =>
      expenses.fold(0, (sum, item) => sum + item.amount);
  double get inventoryValue =>
      products.fold(0, (sum, product) => sum + product.invested);

  Future<void> setup(Business value, {bool demo = false}) async {
    business = value;
    products = demo ? DemoData.products() : [];
    sales = demo ? DemoData.sales() : [];
    expenses = demo ? DemoData.expenses() : [];
    await store.saveBusiness(value);
    await store.saveProducts(products);
    await store.saveSales(sales);
    await store.saveExpenses(expenses);
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    products = [...products, product];
    await store.saveProducts(products);
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    products = products
        .map((item) => item.id == product.id ? product : item)
        .toList();
    await store.saveProducts(products);
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    products = products.where((item) => item.id != id).toList();
    await store.saveProducts(products);
    notifyListeners();
  }

  Future<String?> addSale(String productId, int quantity) async {
    final index = products.indexWhere((item) => item.id == productId);
    if (index < 0) return 'Producto no encontrado';
    final product = products[index];
    if (quantity <= 0 || quantity > product.stock) {
      return 'La cantidad supera el stock disponible';
    }
    final now = DateTime.now();
    products[index] = product.copyWith(
      stock: product.stock - quantity,
      lastSaleAt: now,
      salesCount: product.salesCount + quantity,
    );
    sales = [
      ...sales,
      Sale(
        id: now.microsecondsSinceEpoch.toString(),
        productId: productId,
        quantity: quantity,
        unitPrice: product.price,
        unitCost: product.cost,
        date: now,
      ),
    ];
    await store.saveProducts(products);
    await store.saveSales(sales);
    notifyListeners();
    return null;
  }

  Future<void> addExpense(Expense expense) async {
    expenses = [...expenses, expense];
    await store.saveExpenses(expenses);
    notifyListeners();
  }
}
