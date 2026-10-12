import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/price_calculator.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/usecases/cart_usecases.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl();
});

final getCartItemsUseCaseProvider = Provider<GetCartItemsUseCase>((ref) {
  return GetCartItemsUseCase(ref.watch(cartRepositoryProvider));
});

final saveCartItemsUseCaseProvider = Provider<SaveCartItemsUseCase>((ref) {
  return SaveCartItemsUseCase(ref.watch(cartRepositoryProvider));
});

final clearCartUseCaseProvider = Provider<ClearCartUseCase>((ref) {
  return ClearCartUseCase(ref.watch(cartRepositoryProvider));
});

class CartState {
  final List<CartItemEntity> items;
  final bool isLoading;

  const CartState({this.items = const [], this.isLoading = false});

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal {
    final sub = items.fold(
      0.0,
      (sum, item) => sum + (item.unitPrice * item.quantity),
    );
    return ((sub * 100).round()) / 100.0;
  }

  double get tax => PriceCalculator.calculateTax(subtotal);

  double get serviceFee =>
      PriceCalculator.calculateServiceFee(items.isNotEmpty);

  double get deliveryFee =>
      PriceCalculator.calculateDeliveryFee(items.isNotEmpty);

  double get grandTotal => PriceCalculator.calculateGrandTotal(
    subtotal: subtotal,
    tax: tax,
    serviceFee: serviceFee,
    deliveryFee: deliveryFee,
  );

  CartState copyWith({List<CartItemEntity>? items, bool? isLoading}) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  final GetCartItemsUseCase _getCartItemsUseCase;
  final SaveCartItemsUseCase _saveCartItemsUseCase;
  final ClearCartUseCase _clearCartUseCase;

  CartNotifier({
    required GetCartItemsUseCase getCartItemsUseCase,
    required SaveCartItemsUseCase saveCartItemsUseCase,
    required ClearCartUseCase clearCartUseCase,
  }) : _getCartItemsUseCase = getCartItemsUseCase,
       _saveCartItemsUseCase = saveCartItemsUseCase,
       _clearCartUseCase = clearCartUseCase,
       super(const CartState()) {
    loadCart();
  }

  Future<void> loadCart() async {
    state = state.copyWith(isLoading: true);
    final items = await _getCartItemsUseCase();
    state = CartState(items: items, isLoading: false);
  }

  Future<void> addItem({
    required int recipeId,
    required String name,
    required String image,
    required double unitPrice,
    int quantity = 1,
  }) async {
    if (quantity <= 0) return;

    final existingIndex = state.items.indexWhere((i) => i.recipeId == recipeId);
    List<CartItemEntity> updatedItems;

    if (existingIndex >= 0) {
      final existing = state.items[existingIndex];
      final updated = existing.copyWith(quantity: existing.quantity + quantity);
      updatedItems = List<CartItemEntity>.from(state.items);
      updatedItems[existingIndex] = updated;
    } else {
      updatedItems = [
        ...state.items,
        CartItemEntity(
          recipeId: recipeId,
          name: name,
          image: image,
          unitPrice: unitPrice,
          quantity: quantity,
        ),
      ];
    }

    state = state.copyWith(items: updatedItems);
    await _saveCartItemsUseCase(updatedItems);
  }

  Future<void> updateQuantity(int recipeId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeItem(recipeId);
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.recipeId == recipeId) {
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
    await _saveCartItemsUseCase(updatedItems);
  }

  Future<void> removeItem(int recipeId) async {
    final updatedItems = state.items
        .where((i) => i.recipeId != recipeId)
        .toList();
    state = state.copyWith(items: updatedItems);
    await _saveCartItemsUseCase(updatedItems);
  }

  Future<void> restoreItem(CartItemEntity item, int index) async {
    final updated = List<CartItemEntity>.from(state.items);
    if (index >= 0 && index <= updated.length) {
      updated.insert(index, item);
    } else {
      updated.add(item);
    }
    state = state.copyWith(items: updated);
    await _saveCartItemsUseCase(updated);
  }

  Future<void> clearCart() async {
    state = const CartState(items: []);
    await _clearCartUseCase();
  }
}

final cartNotifierProvider = StateNotifierProvider<CartNotifier, CartState>((
  ref,
) {
  return CartNotifier(
    getCartItemsUseCase: ref.watch(getCartItemsUseCaseProvider),
    saveCartItemsUseCase: ref.watch(saveCartItemsUseCaseProvider),
    clearCartUseCase: ref.watch(clearCartUseCaseProvider),
  );
});
