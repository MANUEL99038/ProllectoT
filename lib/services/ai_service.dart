import '../models/loss_alert.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../models/expense.dart';

class AiService {
  List<LossAlert> explain({
    required List<Product> products,
    required List<Sale> sales,
    required List<Expense> expenses,
  }) {
    final alerts = <LossAlert>[];
    for (final product in products) {
      if (product.margin < 20 && product.salesCount > 0) {
        alerts.add(
          LossAlert(
            kind: AlertKind.lowMargin,
            title: 'Ganancia baja',
            message:
                '${product.name} tiene un margen de ${product.margin.toStringAsFixed(1)}%.',
            recommendation: 'Considera revisar el costo con tu proveedor o analizar el precio de venta.',
          ),
        );
      }
      final lastSale = product.lastSaleAt;
      if (lastSale != null) {
        final days = DateTime.now().difference(lastSale).inDays;
        if (days >= 15) {
          alerts.add(
            LossAlert(
              kind: AlertKind.noMovement,
              title: days >= 25 ? 'Producto sin movimiento' : 'Baja rotación',
              message: '${product.name} lleva $days días sin venderse.',
              recommendation:
                  'Podrías considerar una promoción para aumentar la rotación.',
              critical: days >= 25,
            ),
          );
        }
      }
      if (product.stock <= product.minimumStock) {
        alerts.add(
          LossAlert(
            kind: AlertKind.lowStock,
            title: 'Stock bajo',
            message:
                '${product.name} tiene ${product.stock} unidades disponibles.',
            recommendation: 'Revisa si necesitas programar una compra.',
          ),
        );
      }
      if (product.salesCount == 0 && product.stock > product.minimumStock * 2) {
        alerts.add(
          LossAlert(
            kind: AlertKind.excessStock,
            title: 'Inventario inmovilizado',
            message:
                '${product.name} aún no registra ventas y tiene ${product.stock} unidades.',
            recommendation: 'Considera una promoción, sin asumir que garantizará recuperar la inversión.',
          ),
        );
      }
    }
    if (expenses.length >= 3) {
      alerts.add(
        const LossAlert(
          kind: AlertKind.highExpenses,
          title: 'Revisa tus gastos',
          message:
              'Hay varios gastos registrados. Conviene comparar su evolución.',
          recommendation:
              'Analiza los gastos por categoría antes de tomar decisiones.',
        ),
      );
    }
    return alerts;
  }

  List<PromotionSuggestion> promotions(List<Product> products) {
    final suggestions = <PromotionSuggestion>[];
    for (final product in products) {
      final daysWithoutSale = product.lastSaleAt == null
          ? null
          : DateTime.now().difference(product.lastSaleAt!).inDays;
      if (product.stock > product.minimumStock * 2 &&
          (product.salesCount == 0 || (daysWithoutSale ?? 0) >= 15)) {
        suggestions.add(
          PromotionSuggestion(
            productName: product.name,
            title: 'Oferta para recuperar rotación',
            description: 'Hay inventario disponible y pocas ventas recientes.',
            offer: '15% de descuento por tiempo limitado',
            reason: 'Podría ayudar a mover parte del stock inmovilizado; mide el resultado antes de repetirla.',
            color: 0xFFB76E00,
          ),
        );
      } else if (product.margin >= 35 && product.stock > product.minimumStock) {
        suggestions.add(
          PromotionSuggestion(
            productName: product.name,
            title: 'Promoción de volumen',
            description: 'Este producto conserva margen suficiente para incentivar más unidades.',
            offer: '2 unidades con 8% de descuento',
            reason: 'Conviene revisar que el precio final mantenga la ganancia esperada.',
            color: 0xFF087A6E,
          ),
        );
      } else if (product.margin < 20 && product.salesCount > 0) {
        suggestions.add(
          PromotionSuggestion(
            productName: product.name,
            title: 'Oferta con producto complementario',
            description: 'El margen actual es reducido; bajar más el precio podría afectar la ganancia.',
            offer: 'Combínalo con un producto de margen alto',
            reason: 'Analiza el costo del combo y evita aplicar descuentos directos sin calcular el margen.',
            color: 0xFF9A3D2E,
          ),
        );
      }
    }
    return suggestions;
  }
}
