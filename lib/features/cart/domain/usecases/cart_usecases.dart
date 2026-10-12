import '../entities/cart_item_entity.dart';
import '../repositories/cart_repository.dart';

class GetCartItemsUseCase {
  final CartRepository _repository;

  GetCartItemsUseCase(this._repository);

  Future<List<CartItemEntity>> call() => _repository.getCartItems();
}

class SaveCartItemsUseCase {
  final CartRepository _repository;

  SaveCartItemsUseCase(this._repository);

  Future<void> call(List<CartItemEntity> items) =>
      _repository.saveCartItems(items);
}

class ClearCartUseCase {
  final CartRepository _repository;

  ClearCartUseCase(this._repository);

  Future<void> call() => _repository.clearCart();
}
