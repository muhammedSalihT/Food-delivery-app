/// Stable mock pricing utility for recipes.
/// Uses the formula required by the specification:
/// price = 4.99 + ((recipeId * 137) % 1800) / 100
/// Prices are deterministic and survive application restarts.
class PriceCalculator {
  PriceCalculator._();

  static const String currencySymbol = '\$';
  static const String currencyCode = 'USD';

  /// Calculate unit price for a given recipe ID.
  static double calculatePrice(int recipeId) {
    // formula: 4.99 + ((recipeId * 137) % 1800) / 100
    final raw = 4.99 + ((recipeId * 137) % 1800) / 100.0;
    // Round to 2 decimal places using cents representation to avoid floating point drift
    return (raw * 100).round() / 100.0;
  }

  /// Formats price as currency string, e.g. "$12.49"
  static String format(double price) {
    return '$currencySymbol${price.toStringAsFixed(2)}';
  }

  /// Fixed fee calculations as specified:
  /// Tax: 5% of subtotal
  /// Service fee: $1.50 (for non-empty cart)
  /// Delivery fee: $2.00 (for non-empty cart, $0.00 if empty)
  static double calculateTax(double subtotal) {
    if (subtotal <= 0) return 0.0;
    return ((subtotal * 0.05) * 100).round() / 100.0;
  }

  static double calculateServiceFee(bool hasItems) {
    return hasItems ? 1.50 : 0.00;
  }

  static double calculateDeliveryFee(bool hasItems) {
    return hasItems ? 2.00 : 0.00;
  }

  static double calculateGrandTotal({
    required double subtotal,
    required double tax,
    required double serviceFee,
    required double deliveryFee,
  }) {
    if (subtotal <= 0) return 0.0;
    final totalCents =
        (subtotal * 100).round() +
        (tax * 100).round() +
        (serviceFee * 100).round() +
        (deliveryFee * 100).round();
    return totalCents / 100.0;
  }
}
