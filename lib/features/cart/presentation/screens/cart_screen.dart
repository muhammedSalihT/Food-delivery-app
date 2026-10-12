import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/price_calculator.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../providers/cart_providers.dart';

/// Primary brand orange matching the exact design screenshot
const Color kCartDrawerColor = Color(0xFFDE4A20);

/// Accent yellow for the checkout pill button
const Color kCartCheckoutButtonColor = Color(0xFFF7CA65);

// ─────────────────────────────────────────────────────────────────────────────
// Public helper — displays the cart drawer sliding in from the right
// ─────────────────────────────────────────────────────────────────────────────
void showCartDrawer(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Cart',
    barrierColor: Colors.black45,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (ctx, anim, secAnim) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, secAnim, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0),
          end: Offset.zero,
        ).animate(curved),
        child: Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: MediaQuery.of(ctx).size.width * 0.84,
            height: double.infinity,
            child: const CartDrawerView(),
          ),
        ),
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// CartScreen — keeps /cart route functional with the identical drawer UI
// ─────────────────────────────────────────────────────────────────────────────
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black45,
      body: Stack(
        children: [
          // Dismiss on tapping left area
          GestureDetector(
            onTap: () => context.pop(),
            child: const SizedBox.expand(),
          ),
          // Drawer on the right side
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.84,
              height: double.infinity,
              child: const CartDrawerView(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CartDrawerView — the complete drawer matching the exact reference design
// ─────────────────────────────────────────────────────────────────────────────
class CartDrawerView extends ConsumerWidget {
  const CartDrawerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartNotifierProvider);
    final notifier = ref.read(cartNotifierProvider.notifier);

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        // Allow horizontal swipe to the right to dismiss
        onHorizontalDragUpdate: (details) {
          if (details.primaryDelta != null && details.primaryDelta! > 12) {
            Navigator.of(context).maybePop();
          }
        },
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(44),
            bottomLeft: Radius.circular(44),
          ),
          child: Container(
            color: kCartDrawerColor,
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 18),

                  // ── Header: White circle badge with orange cart + "Cart" ───
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.shopping_cart,
                            color: kCartDrawerColor,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Cart',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),

                  // ── Divider line below header ─────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                    child: Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),

                  // ── Subtitle: "Your cart is empty" or "You have X items..." ─
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      cartState.items.isEmpty
                          ? 'Your cart is empty'
                          : cartState.items.length == 1
                              ? 'You have 1 item in the cart'
                              : 'You have ${cartState.items.length} items in the cart',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── Main Content: Empty State or Filled State ─────────────
                  Expanded(
                    child: cartState.items.isEmpty
                        ? _EmptyCartContent()
                        : _FilledCartContent(
                            cartState: cartState,
                            notifier: notifier,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty Cart State — Large circular border with + and "Want To Add Something?"
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyCartContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).maybePop();
                context.go('/menu');
              },
              child: Container(
                width: 116,
                height: 116,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3.5,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.add,
                    size: 58,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Want To Add\nSomething?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.25,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filled Cart State — Items list, Subtotal/Tax/Delivery, Dashed Divider, Total, Checkout
// ─────────────────────────────────────────────────────────────────────────────
class _FilledCartContent extends StatelessWidget {
  final CartState cartState;
  final CartNotifier notifier;

  const _FilledCartContent({
    required this.cartState,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Scrollable Items list ───────────────────────────────────────────
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            itemCount: cartState.items.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 16),
            itemBuilder: (ctx, index) {
              final item = cartState.items[index];
              return _CartItemTile(
                item: item,
                onIncrement: () =>
                    notifier.updateQuantity(item.recipeId, item.quantity + 1),
                onDecrement: () =>
                    notifier.updateQuantity(item.recipeId, item.quantity - 1),
              );
            },
          ),
        ),

        // ── Divider below items ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.35),
          ),
        ),

        const SizedBox(height: 14),

        // ── Price Summary Section ───────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _SummaryRow(
                label: 'Subtotal',
                value: PriceCalculator.format(cartState.subtotal),
              ),
              const SizedBox(height: 10),
              _SummaryRow(
                label: 'Tax and Fees',
                value: PriceCalculator.format(
                  cartState.tax + cartState.serviceFee,
                ),
              ),
              const SizedBox(height: 10),
              _SummaryRow(
                label: 'Delivery',
                value: PriceCalculator.format(cartState.deliveryFee),
              ),
              const SizedBox(height: 14),

              // Dashed divider
              const _WhiteDashedDivider(),

              const SizedBox(height: 14),
              _SummaryRow(
                label: 'Total',
                value: PriceCalculator.format(cartState.grandTotal),
                isBold: true,
              ),
            ],
          ),
        ),

        // ── Checkout Button ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                context.push('/confirm_order');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 46,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: kCartCheckoutButtonColor,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Text(
                  'Checkout',
                  style: TextStyle(
                    color: kCartDrawerColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CartItemTile — Single item row matching the reference image
// ─────────────────────────────────────────────────────────────────────────────
class _CartItemTile extends StatelessWidget {
  final CartItemEntity item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _CartItemTile({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    // 20% higher price shown with strikethrough like reference image
    final originalPrice = item.unitPrice * 1.25;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Rounded square food image
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CachedNetworkImage(
            imageUrl: item.image,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
            errorWidget: (c, url, err) => Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.fastfood,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Food Title + Current Price
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                PriceCalculator.format(item.unitPrice),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Trailing: strikethrough price on top, quantity stepper on bottom
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              PriceCalculator.format(originalPrice),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
                decoration: TextDecoration.lineThrough,
                decorationColor: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Minus circular button
                GestureDetector(
                  onTap: onDecrement,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.remove,
                        size: 14,
                        color: kCartDrawerColor,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                // Plus circular button
                GestureDetector(
                  onTap: onIncrement,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add,
                        size: 14,
                        color: kCartDrawerColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SummaryRow — Left and right aligned white text
// ─────────────────────────────────────────────────────────────────────────────
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            color: Colors.white,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _WhiteDashedDivider — White dashed line divider
// ─────────────────────────────────────────────────────────────────────────────
class _WhiteDashedDivider extends StatelessWidget {
  const _WhiteDashedDivider();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 1),
      painter: _WhiteDashedLinePainter(),
    );
  }
}

class _WhiteDashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 1.2;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
