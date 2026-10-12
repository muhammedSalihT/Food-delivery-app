import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/core/utils/price_calculator.dart';
import 'package:food_delivery_app/features/cart/domain/entities/cart_item_entity.dart';
import 'package:food_delivery_app/features/cart/domain/repositories/cart_repository.dart';
import 'package:food_delivery_app/features/cart/domain/usecases/cart_usecases.dart';
import 'package:food_delivery_app/features/cart/presentation/providers/cart_providers.dart';

class FakeCartRepository implements CartRepository {
  List<CartItemEntity> items = [];

  @override
  Future<void> clearCart() async {
    items.clear();
  }

  @override
  Future<List<CartItemEntity>> getCartItems() async {
    return List.from(items);
  }

  @override
  Future<void> saveCartItems(List<CartItemEntity> newItems) async {
    items = List.from(newItems);
  }
}

void main() {
  group('PriceCalculator Tests', () {
    test(
      'calculatePrice is deterministic and matches specification formula',
      () {
        // formula: 4.99 + ((recipeId * 137) % 1800) / 100
        final price1 = PriceCalculator.calculatePrice(1);
        expect(price1, equals(6.36));

        // Same ID always produces same price
        expect(PriceCalculator.calculatePrice(1), equals(price1));
        expect(PriceCalculator.calculatePrice(2), equals(7.73));
      },
    );

    test('Tax, Service fee and Delivery fee rules', () {
      // Empty cart rules
      expect(PriceCalculator.calculateTax(0), equals(0.0));
      expect(PriceCalculator.calculateServiceFee(false), equals(0.0));
      expect(PriceCalculator.calculateDeliveryFee(false), equals(0.0));
      expect(
        PriceCalculator.calculateGrandTotal(
          subtotal: 0,
          tax: 0,
          serviceFee: 0,
          deliveryFee: 0,
        ),
        equals(0.0),
      );

      // Non-empty cart rules (e.g., subtotal = $10.00)
      const subtotal = 10.00;
      final tax = PriceCalculator.calculateTax(subtotal); // 5% -> 0.50
      final serviceFee = PriceCalculator.calculateServiceFee(true); // $1.50
      final deliveryFee = PriceCalculator.calculateDeliveryFee(true); // $2.00
      final grandTotal = PriceCalculator.calculateGrandTotal(
        subtotal: subtotal,
        tax: tax,
        serviceFee: serviceFee,
        deliveryFee: deliveryFee,
      );

      expect(tax, equals(0.50));
      expect(serviceFee, equals(1.50));
      expect(deliveryFee, equals(2.00));
      expect(grandTotal, equals(14.00));
    });
  });

  group('CartNotifier Unit Tests', () {
    late FakeCartRepository fakeRepo;
    late CartNotifier notifier;

    setUp(() {
      fakeRepo = FakeCartRepository();
      notifier = CartNotifier(
        getCartItemsUseCase: GetCartItemsUseCase(fakeRepo),
        saveCartItemsUseCase: SaveCartItemsUseCase(fakeRepo),
        clearCartUseCase: ClearCartUseCase(fakeRepo),
      );
    });

    test('Initial cart is empty', () {
      expect(notifier.state.items, isEmpty);
      expect(notifier.state.totalItemCount, equals(0));
      expect(notifier.state.subtotal, equals(0.0));
      expect(notifier.state.grandTotal, equals(0.0));
    });

    test('Add a new item to cart', () async {
      await notifier.addItem(
        recipeId: 1,
        name: 'Classic Burger',
        image: 'https://example.com/burger.jpg',
        unitPrice: 10.00,
        quantity: 2,
      );

      expect(notifier.state.items.length, equals(1));
      expect(notifier.state.items.first.quantity, equals(2));
      expect(notifier.state.totalItemCount, equals(2));
      expect(notifier.state.subtotal, equals(20.00));
    });

    test(
      'Add an existing item increments quantity rather than creating duplicate line',
      () async {
        await notifier.addItem(
          recipeId: 1,
          name: 'Classic Burger',
          image: 'https://example.com/burger.jpg',
          unitPrice: 10.00,
          quantity: 1,
        );

        await notifier.addItem(
          recipeId: 1,
          name: 'Classic Burger',
          image: 'https://example.com/burger.jpg',
          unitPrice: 10.00,
          quantity: 2,
        );

        expect(notifier.state.items.length, equals(1));
        expect(notifier.state.items.first.quantity, equals(3));
        expect(notifier.state.totalItemCount, equals(3));
        expect(notifier.state.subtotal, equals(30.00));
      },
    );

    test('Update quantity and remove item', () async {
      await notifier.addItem(
        recipeId: 1,
        name: 'Classic Burger',
        image: 'https://example.com/burger.jpg',
        unitPrice: 10.00,
        quantity: 2,
      );

      await notifier.updateQuantity(1, 4);
      expect(notifier.state.items.first.quantity, equals(4));

      // Decrementing to zero removes item
      await notifier.updateQuantity(1, 0);
      expect(notifier.state.items, isEmpty);
      expect(notifier.state.subtotal, equals(0.0));
    });

    test('Clear cart empties all items and resets totals', () async {
      await notifier.addItem(
        recipeId: 1,
        name: 'Burger',
        image: 'img.jpg',
        unitPrice: 5.0,
      );
      await notifier.addItem(
        recipeId: 2,
        name: 'Pizza',
        image: 'img2.jpg',
        unitPrice: 8.0,
      );

      expect(notifier.state.items.length, equals(2));

      await notifier.clearCart();
      expect(notifier.state.items, isEmpty);
      expect(notifier.state.grandTotal, equals(0.0));
    });
  });
}
