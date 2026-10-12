import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/price_calculator.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  @override
  Future<List<CartItemEntity>> getCartItems() async {
    final rawList = LocalCacheService.getCartItems();
    return rawList.map((map) {
      final model = CartItemModel.fromJson(map);
      // Ensure unit price is deterministically checked/recalculated from recipeId
      final price = PriceCalculator.calculatePrice(model.recipeId);
      return model.copyWith(unitPrice: price);
    }).toList();
  }

  @override
  Future<void> saveCartItems(List<CartItemEntity> items) async {
    final list = items.map((e) {
      return CartItemModel(
        recipeId: e.recipeId,
        name: e.name,
        image: e.image,
        unitPrice: e.unitPrice,
        quantity: e.quantity,
      ).toJson();
    }).toList();
    await LocalCacheService.saveCartItems(list);
  }

  @override
  Future<void> clearCart() async {
    await LocalCacheService.clearCart();
  }
}
