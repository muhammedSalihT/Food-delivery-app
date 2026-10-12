class CartItemEntity {
  final int recipeId;
  final String name;
  final String image;
  final double unitPrice;
  final int quantity;

  const CartItemEntity({
    required this.recipeId,
    required this.name,
    required this.image,
    required this.unitPrice,
    required this.quantity,
  });

  double get lineSubtotal => ((unitPrice * quantity) * 100).round() / 100.0;

  CartItemEntity copyWith({
    int? recipeId,
    String? name,
    String? image,
    double? unitPrice,
    int? quantity,
  }) {
    return CartItemEntity(
      recipeId: recipeId ?? this.recipeId,
      name: name ?? this.name,
      image: image ?? this.image,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
    );
  }
}
