enum AlertKind { lowMargin, noMovement, lowStock, excessStock, highExpenses }

class LossAlert {
  const LossAlert({
    required this.kind,
    required this.title,
    required this.message,
    required this.recommendation,
    this.critical = false,
  });

  final AlertKind kind;
  final String title;
  final String message;
  final String recommendation;
  final bool critical;
}

class PromotionSuggestion {
  const PromotionSuggestion({
    required this.productName,
    required this.title,
    required this.description,
    required this.offer,
    required this.reason,
    required this.color,
  });

  final String productName;
  final String title;
  final String description;
  final String offer;
  final String reason;
  final int color;
}
