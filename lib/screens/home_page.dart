import 'package:flutter/material.dart';

import '../main.dart';
import '../models/expense.dart';
import '../models/loss_alert.dart';
import '../models/product.dart';
import '../services/demo_data.dart';
import 'auth_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;
  final titles = const [
    'Inicio',
    'Productos',
    'Ventas',
    'Análisis',
    'Configuración',
  ];

  Future<void> logout() async {
    await AppScope.of(context).store.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const AuthPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardView(onNavigate: (value) => setState(() => tab = value)),
      ProductsView(),
      SalesView(),
      AnalysisView(),
      SettingsView(
        onAddExpense: () => showExpenseForm(context),
        onLogout: logout,
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'img/logo.jpg',
              fit: BoxFit.cover,
              semanticLabel: 'Logo de LossTrack',
            ),
          ),
        ),
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: Text(
            titles[tab],
            key: ValueKey(tab),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.03, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: KeyedSubtree(key: ValueKey(tab), child: pages[tab]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (value) => setState(() => tab = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2_rounded),
            label: 'Productos',
          ),
          NavigationDestination(
            icon: Icon(Icons.point_of_sale_outlined),
            selectedIcon: Icon(Icons.point_of_sale_rounded),
            label: 'Ventas',
          ),
          NavigationDestination(
            icon: Icon(Icons.query_stats_outlined),
            selectedIcon: Icon(Icons.query_stats_rounded),
            label: 'Análisis',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Ajustes',
          ),
        ],
      ),
      floatingActionButton: tab == 1
          ? FloatingActionButton.extended(
              onPressed: () => showProductForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Producto'),
            )
          : tab == 2
          ? FloatingActionButton.extended(
              onPressed: () => showSaleForm(context),
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Registrar venta'),
            )
          : null,
    );
  }

  Future<void> showProductForm(BuildContext context, {Product? product}) async {
    final name = TextEditingController(text: product?.name);
    final category = TextEditingController(text: product?.category);
    final cost = TextEditingController(text: product?.cost.toString());
    final price = TextEditingController(text: product?.price.toString());
    final stock = TextEditingController(text: product?.stock.toString());
    final minimum = TextEditingController(
      text: product?.minimumStock.toString(),
    );
    final key = GlobalKey<FormState>();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(product == null ? 'Nuevo producto' : 'Editar producto'),
        content: SizedBox(
          width: 420,
          child: Form(
            key: key,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _dialogField(name, 'Nombre'),
                  _dialogField(category, 'Categoría'),
                  Row(
                    children: [
                      Expanded(
                        child: _dialogField(cost, 'Costo', number: true),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _dialogField(price, 'Precio', number: true),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _dialogField(stock, 'Existencia', number: true),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _dialogField(
                          minimum,
                          'Stock mínimo',
                          number: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (!key.currentState!.validate()) return;
              final state = AppScope.of(context);
              final item = Product(
                id:
                    product?.id ??
                    DateTime.now().microsecondsSinceEpoch.toString(),
                name: name.text.trim(),
                category: category.text.trim(),
                code: product?.code ?? '',
                cost: double.parse(cost.text),
                price: double.parse(price.text),
                stock: int.parse(stock.text),
                minimumStock: int.parse(minimum.text),
                createdAt: product?.createdAt ?? DateTime.now(),
                lastSaleAt: product?.lastSaleAt,
                salesCount: product?.salesCount ?? 0,
              );
              if (product == null) {
                await state.addProduct(item);
              } else {
                await state.updateProduct(item);
              }
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> showSaleForm(BuildContext context) async {
    final state = AppScope.of(context);
    if (state.products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agrega un producto antes de registrar ventas.'),
        ),
      );
      return;
    }
    String id = state.products.first.id;
    final quantity = TextEditingController(text: '1');
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Registrar venta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: id,
              decoration: const InputDecoration(labelText: 'Producto'),
              items: state.products
                  .map(
                    (product) => DropdownMenuItem(
                      value: product.id,
                      child: Text(product.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) => id = value!,
            ),
            const SizedBox(height: 12),
            _dialogField(quantity, 'Cantidad', number: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final error = await state.addSale(
                id,
                int.tryParse(quantity.text) ?? 0,
              );
              if (!dialogContext.mounted) return;
              if (error != null) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(error)));
              } else {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Venta registrada correctamente.'),
                  ),
                );
              }
            },
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
  }

  Future<void> showExpenseForm(BuildContext context) async {
    final name = TextEditingController();
    final amount = TextEditingController();
    final category = TextEditingController(text: 'Otros');
    final key = GlobalKey<FormState>();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Registrar gasto'),
        content: Form(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(name, 'Nombre del gasto'),
              _dialogField(category, 'Categoría'),
              _dialogField(amount, 'Cantidad', number: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (!key.currentState!.validate()) return;
              await AppScope.of(context).addExpense(
                Expense(
                  id: DateTime.now().microsecondsSinceEpoch.toString(),
                  name: name.text.trim(),
                  category: category.text.trim(),
                  amount: double.parse(amount.text),
                  date: DateTime.now(),
                ),
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(
    TextEditingController controller,
    String label, {
    bool number = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextFormField(
      controller: controller,
      keyboardType: number
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Obligatorio';
        if (number && double.tryParse(value) == null) return 'Número inválido';
        if (number && double.parse(value) < 0) return 'No puede ser negativo';
        return null;
      },
    ),
  );
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key, required this.onNavigate});
  final ValueChanged<int> onNavigate;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      children: [
        Text(
          'Hola, ${state.business?.owner ?? 'propietario'}',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            StatCard(
              label: 'Ventas de hoy',
              value: money(state.salesTotal),
              icon: Icons.trending_up_rounded,
              color: const Color(0xFFE3F4EE),
            ),
            StatCard(
              label: 'Ganancia estimada',
              value: money(state.profitTotal),
              icon: Icons.attach_money_rounded,
              color: const Color(0xFFEAF4DD),
            ),
            StatCard(
              label: 'Gastos',
              value: money(state.expensesTotal),
              icon: Icons.receipt_long_outlined,
              color: const Color(0xFFFFF0D8),
            ),
            StatCard(
              label: 'Alertas',
              value: '${state.alerts.length}',
              icon: Icons.warning_amber_rounded,
              color: const Color(0xFFFFE6E2),
            ),
          ],
        ),
        const SizedBox(height: 22),
        SectionTitle(title: 'Acciones rápidas'),
        Row(
          children: [
            QuickAction(
              label: 'Producto',
              icon: Icons.add_box_outlined,
              onTap: () => onNavigate(1),
            ),
            QuickAction(
              label: 'Venta',
              icon: Icons.point_of_sale_outlined,
              onTap: () => onNavigate(2),
            ),
            QuickAction(
              label: 'Pérdidas',
              icon: Icons.warning_amber_rounded,
              onTap: () => onNavigate(3),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SectionTitle(
          title: 'Alertas importantes',
          action: 'Ver análisis',
          onAction: () => onNavigate(3),
        ),
        if (state.alerts.isEmpty)
          const EmptyState(
            text: 'Aún no hay alertas. Registra productos y movimientos para analizar tu negocio.',
          )
        else
          ...state.alerts.take(4).map((alert) => AlertTile(alert: alert)),
        const SizedBox(height: 18),
        SectionTitle(title: 'Inventario'),
        InfoRow(label: 'Valor invertido', value: money(state.inventoryValue)),
        InfoRow(
          label: 'Productos registrados',
          value: '${state.products.length}',
        ),
        InfoRow(
          label: 'Productos con stock bajo',
          value:
              '${state.products.where((item) => item.stock <= item.minimumStock).length}',
        ),
      ],
    );
  }
}

class ProductsView extends StatefulWidget {
  const ProductsView({super.key});
  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final items = state.products
        .where(
          (product) => product.name.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      children: [
        TextField(
          onChanged: (value) => setState(() => query = value),
          decoration: const InputDecoration(
            hintText: 'Buscar producto',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 14),
        ...items.map(
          (product) => ProductCard(
            product: product,
            onEdit: () => context
                .findAncestorStateOfType<_HomePageState>()
                ?.showProductForm(context, product: product),
            onDelete: () => state.deleteProduct(product.id),
          ),
        ),
      ],
    );
  }
}

class SalesView extends StatelessWidget {
  const SalesView({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Ventas acumuladas: ${money(state.salesTotal)}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 18),
        ...state.sales.reversed.map((sale) {
          Product? product;
          for (final item in state.products) {
            if (item.id == sale.productId) product = item;
          }
          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFE3F4EE),
              child: Icon(Icons.shopping_cart_outlined, color: teal),
            ),
            title: Text(product?.name ?? 'Producto eliminado'),
            subtitle: Text(
              '${sale.quantity} unidades · ${sale.date.day}/${sale.date.month}/${sale.date.year}',
            ),
            trailing: Text(
              money(sale.total),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          );
        }),
      ],
    );
  }
}

class AnalysisView extends StatelessWidget {
  const AnalysisView({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final promotions = state.analyzer.promotions(state.products);
    final lowMarginProducts = state.products
        .where((product) => product.margin < 20 && product.salesCount > 0)
        .length;
    final inactiveProducts = state.products
        .where(
          (product) =>
              product.lastSaleAt != null &&
              DateTime.now().difference(product.lastSaleAt!).inDays >= 15,
        )
        .length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      children: [
        Text(
          'Decisiones basadas en tus datos',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'Estas sugerencias no garantizan resultados: pruébalas, registra el cambio y compara.',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            AnalysisMetric(
              value: '${state.alerts.length}',
              label: 'alertas',
              color: const Color(0xFFFFE7E2),
              icon: Icons.warning_amber_rounded,
            ),
            const SizedBox(width: 10),
            AnalysisMetric(
              value: '$lowMarginProducts',
              label: 'margen bajo',
              color: const Color(0xFFFFF0D8),
              icon: Icons.percent_rounded,
            ),
            const SizedBox(width: 10),
            AnalysisMetric(
              value: '$inactiveProducts',
              label: 'sin rotación',
              color: const Color(0xFFE3F4EE),
              icon: Icons.hourglass_empty_rounded,
            ),
          ],
        ),
        const SizedBox(height: 26),
        const SectionTitle(title: 'Recomendaciones prioritarias'),
        if (state.alerts.isEmpty)
          const EmptyState(
            text: 'Todavía no hay suficientes datos para detectar pérdidas.',
          )
        else
          ...state.alerts.map(
            (alert) => AlertTile(alert: alert, expanded: true),
          ),
        const SizedBox(height: 18),
        const SectionTitle(title: 'Promociones posibles'),
        if (promotions.isEmpty)
          const EmptyState(
            text: 'Registra más ventas e inventario para calcular ofertas con contexto.',
          )
        else
          ...promotions.map((promotion) => PromotionCard(promotion: promotion)),
      ],
    );
  }
}

class AnalysisMetric extends StatelessWidget {
  const AnalysisMetric({
    super.key,
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: teal, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class PromotionCard extends StatelessWidget {
  const PromotionCard({super.key, required this.promotion});
  final PromotionSuggestion promotion;

  @override
  Widget build(BuildContext context) {
    final accent = Color(promotion.color);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: accent.withAlpha(70)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: accent.withAlpha(28),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.local_offer_rounded, color: accent),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    promotion.productName,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  'OFERTA',
                  style: TextStyle(
                    color: accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              promotion.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 5),
            Text(
              promotion.description,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accent.withAlpha(18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline_rounded, size: 19),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      promotion.offer,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Por qué: ${promotion.reason}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({
    super.key,
    required this.onAddExpense,
    required this.onLogout,
  });
  final VoidCallback onAddExpense;
  final VoidCallback onLogout;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ListTile(
          leading: const Icon(Icons.store_outlined, color: teal),
          title: Text(state.business?.name ?? ''),
          subtitle: Text(
            '${state.business?.type ?? ''} · ${state.business?.currency ?? ''}',
          ),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.receipt_long_outlined, color: teal),
          title: const Text('Registrar gasto'),
          subtitle: const Text('Renta, servicios, proveedores y otros'),
          onTap: onAddExpense,
        ),
        ListTile(
          leading: const Icon(Icons.auto_awesome_outlined, color: teal),
          title: const Text('Datos de demostración'),
          subtitle: const Text('Prueba el detector con un negocio de ejemplo'),
          onTap: () async {
            await state.setup(DemoData.business(), demo: true);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Datos demo cargados.')),
              );
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
          title: const Text(
            'Eliminar datos',
            style: TextStyle(color: Colors.red),
          ),
          onTap: () async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('¿Eliminar todos los datos?'),
                content: const Text('Esta acción no se puede deshacer.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Cancelar'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text('Eliminar'),
                  ),
                ],
              ),
            );
            if (ok == true) {
              await state.store.clear();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Datos eliminados. Reinicia la aplicación para configurar un negocio nuevo.',
                    ),
                  ),
                );
              }
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout_rounded, color: Colors.red),
          title: const Text(
            'Cerrar sesión',
            style: TextStyle(color: Colors.red),
          ),
          onTap: onLogout,
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label, value;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: (MediaQuery.sizeOf(context).width - 52) / 2,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: teal),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
        ],
      ),
    ),
  );
}

class QuickAction extends StatelessWidget {
  const QuickAction({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Padding(
      padding: const EdgeInsets.only(right: 8),
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
      ),
    ),
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });
  final String title;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
      ],
    ),
  );
}

class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(text),
  );
}

class AlertTile extends StatelessWidget {
  const AlertTile({super.key, required this.alert, this.expanded = false});
  final dynamic alert;
  final bool expanded;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      leading: Icon(
        alert.critical ? Icons.error_outline : Icons.warning_amber_rounded,
        color: alert.critical ? Colors.red : Colors.orange,
      ),
      title: Text(
        alert.title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        expanded ? '${alert.message}\n${alert.recommendation}' : alert.message,
      ),
    ),
  );
}

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });
  final Product product;
  final VoidCallback onEdit, onDelete;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFE3F4EE),
        child: const Icon(Icons.inventory_2_outlined, color: teal),
      ),
      title: Text(
        product.name,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        '${product.category} · Stock: ${product.stock} · Margen: ${product.margin.toStringAsFixed(1)}%',
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') onEdit();
          if (value == 'delete') onDelete();
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'edit', child: Text('Editar')),
          PopupMenuItem(value: 'delete', child: Text('Eliminar')),
        ],
      ),
    ),
  );
}

String money(double value) => '\$${value.toStringAsFixed(2)}';
