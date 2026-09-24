import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/business.dart';
import '../models/expense.dart';
import '../models/product.dart';
import '../models/sale.dart';

class LocalStore {
  LocalStore(this.preferences);
  final SharedPreferences preferences;

  Business? get business {
    final value = preferences.getString('business');
    return value == null
        ? null
        : Business.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }

  List<Product> get products => _readList('products', Product.fromJson);
  List<Sale> get sales => _readList('sales', Sale.fromJson);
  List<Expense> get expenses => _readList('expenses', Expense.fromJson);
  String? get accountEmail => preferences.getString('account_email');
  bool get hasAccount => accountEmail != null;
  bool get isLoggedIn => preferences.getBool('session_active') ?? false;

  Future<void> registerAccount(String email, String password) async {
    await preferences.setString('account_email', email.trim().toLowerCase());
    await preferences.setString('account_password', password);
    await preferences.setBool('session_active', true);
  }

  Future<bool> login(String email, String password) async {
    final valid =
        accountEmail == email.trim().toLowerCase() &&
        preferences.getString('account_password') == password;
    if (valid) await preferences.setBool('session_active', true);
    return valid;
  }

  Future<void> logout() => preferences.setBool('session_active', false);

  List<T> _readList<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final raw = preferences.getStringList(key) ?? [];
    return raw
        .map((item) => fromJson(jsonDecode(item) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveBusiness(Business value) =>
      preferences.setString('business', jsonEncode(value.toJson()));
  Future<void> saveProducts(List<Product> values) =>
      _saveList('products', values.map((value) => value.toJson()));
  Future<void> saveSales(List<Sale> values) =>
      _saveList('sales', values.map((value) => value.toJson()));
  Future<void> saveExpenses(List<Expense> values) =>
      _saveList('expenses', values.map((value) => value.toJson()));

  Future<void> _saveList(String key, Iterable<Map<String, dynamic>> values) =>
      preferences.setStringList(key, values.map(jsonEncode).toList());
  Future<void> clear() => preferences.clear();
}
