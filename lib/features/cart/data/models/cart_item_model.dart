import '../../domain/entities/cart_item_entity.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.recipeId,
    required super.name,
    required super.image,
    required super.unitPrice,
    required super.quantity,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      recipeId: (json['recipeId'] ?? 0) as int,
      name: (json['name'] ?? '') as String,
      image: (json['image'] ?? '') as String,
      unitPrice: ((json['unitPrice'] ?? 0.0) as num).toDouble(),
      quantity: (json['quantity'] ?? 1) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipeId': recipeId,
      'name': name,
      'image': image,
      'unitPrice': unitPrice,
      'quantity': quantity,
    };
  }
}
