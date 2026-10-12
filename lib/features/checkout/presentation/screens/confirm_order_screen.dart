import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/providers/cart_providers.dart';

/// Confirm Order Screen matching the exact reference design image
class ConfirmOrderScreen extends ConsumerStatefulWidget {
  const ConfirmOrderScreen({super.key});

  @override
  ConsumerState<ConfirmOrderScreen> createState() => _ConfirmOrderScreenState();
}

class _ConfirmOrderScreenState extends ConsumerState<ConfirmOrderScreen> {
  bool _isPlacingOrder = false;
  bool _orderConfirmed = false;
  String _shippingAddress = '778 Locust View Drive Oaklanda, CA';

  // Demo fallback items matching the screenshot when cart is empty
  late List<CartItemEntity> _sampleItems;

  @override
  void initState() {
    super.initState();
    _sampleItems = [
      const CartItemEntity(
        recipeId: 901,
        name: 'Strawberry Shake',
        image:
            'https://images.unsplash.com/photo-1579954115545-a95591f28bfc?w=400&q=80',
        unitPrice: 10.00,
        quantity: 2,
      ),
      const CartItemEntity(
        recipeId: 902,
        name: 'Broccoli Lasagna',
        image:
            'https://images.unsplash.com/photo-1574894709920-11b28e7367e3?w=400&q=80',
        unitPrice: 12.99,
        quantity: 1,
      ),
    ];
  }

  Future<void> _handlePlaceOrder() async {
    if (_isPlacingOrder) return;
    setState(() => _isPlacingOrder = true);

    // Simulate order placement
    await Future.delayed(const Duration(milliseconds: 900));

    // Clear cart upon successful order
    await ref.read(cartNotifierProvider.notifier).clearCart();

    if (mounted) {
      setState(() {
        _isPlacingOrder = false;
        _orderConfirmed = true;
      });
    }
  }

  void _showEditAddressDialog() {
    final controller = TextEditingController(text: _shippingAddress);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Edit Shipping Address',
          style: TextStyle(
            color: Color(0xFF2E1C12),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: TextField(
          controller: controller,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Enter new address',
            filled: true,
            fillColor: const Color(0xFFF7EABF).withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE85324),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() => _shippingAddress = controller.text.trim());
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartNotifierProvider);
    final notifier = ref.read(cartNotifierProvider.notifier);

    // If order confirmed, show confirmation view
    if (_orderConfirmed) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 80,
                    color: AppColors.accentGreen,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Order Confirmed!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2E1C12),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your order has been booked successfully! Thank you for ordering with us.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF8C7B74),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                GestureDetector(
                  onTap: () => context.go('/home'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE85324),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final usingSample = cartState.items.isEmpty;
    final items = usingSample ? _sampleItems : cartState.items;

    // Financial calculations
    final double subtotal;
    final double taxAndFees;
    final double deliveryFee;
    final double total;

    if (usingSample) {
      // Numbers exactly matching reference design image
      subtotal = 32.00;
      taxAndFees = 5.00;
      deliveryFee = 3.00;
      total = 40.00;
    } else {
      subtotal = cartState.subtotal;
      taxAndFees = cartState.tax + cartState.serviceFee;
      deliveryFee = cartState.deliveryFee;
      total = cartState.grandTotal;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7CA65),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Top Header Bar (Yellow) ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFFE85324),
                        size: 22,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Confirm Order',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 34), // balance back arrow for centering
                ],
              ),
            ),

            // ── White Card Content (Scrollable) ─────────────────────────────
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFFCFBF9),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Shipping Address Section ──────────────────────────
                      Row(
                        children: [
                          const Text(
                            'Shipping Address',
                            style: TextStyle(
                              color: Color(0xFF2E1C12),
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _showEditAddressDialog,
                            behavior: HitTestBehavior.opaque,
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.edit_outlined,
                                color: Color(0xFFE85324),
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Address Pill Container
                      GestureDetector(
                        onTap: _showEditAddressDialog,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7EABF),
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: Text(
                            _shippingAddress,
                            style: const TextStyle(
                              color: Color(0xFF332014),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Order Summary Header ──────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Order Summary',
                            style: TextStyle(
                              color: Color(0xFF2E1C12),
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push('/cart'),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFECE5),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text(
                                'Edit',
                                style: TextStyle(
                                  color: Color(0xFFE85324),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Subtle divider under Order Summary
                      Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 12),
                        height: 0.8,
                        color: const Color(0xFFFFE5DC),
                      ),

                      // ── Order Items List ──────────────────────────────────
                      ...items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final dateStr = index == 0
                            ? '29 Nov, 15:20 pm'
                            : '29 Nov, 12:00 pm';

                        final linePrice = usingSample
                            ? (index == 0 ? 20.00 : 12.99)
                            : (item.unitPrice * item.quantity);

                        return Column(
                          children: [
                            _buildOrderItem(
                              context: context,
                              name: item.name,
                              image: item.image,
                              date: dateStr,
                              totalPrice: linePrice,
                              quantity: item.quantity,
                              onCancel: () {
                                if (usingSample) {
                                  setState(() => _sampleItems.removeAt(index));
                                } else {
                                  notifier.removeItem(item.recipeId);
                                }
                              },
                              onDelete: () {
                                if (usingSample) {
                                  setState(() => _sampleItems.removeAt(index));
                                } else {
                                  notifier.removeItem(item.recipeId);
                                }
                              },
                              onIncrement: () {
                                if (usingSample) {
                                  setState(() {
                                    _sampleItems[index] = item.copyWith(
                                      quantity: item.quantity + 1,
                                    );
                                  });
                                } else {
                                  notifier.updateQuantity(
                                    item.recipeId,
                                    item.quantity + 1,
                                  );
                                }
                              },
                              onDecrement: () {
                                if (item.quantity > 1) {
                                  if (usingSample) {
                                    setState(() {
                                      _sampleItems[index] = item.copyWith(
                                        quantity: item.quantity - 1,
                                      );
                                    });
                                  } else {
                                    notifier.updateQuantity(
                                      item.recipeId,
                                      item.quantity - 1,
                                    );
                                  }
                                }
                              },
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 14),
                              height: 0.8,
                              color: const Color(0xFFFFE5DC),
                            ),
                          ],
                        );
                      }),

                      const SizedBox(height: 4),

                      // ── Price Breakdown ───────────────────────────────────
                      _buildSummaryRow(
                        label: 'Subtotal',
                        value: '\$${subtotal.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow(
                        label: 'Tax and Fees',
                        value: '\$${taxAndFees.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow(
                        label: 'Delivery',
                        value: '\$${deliveryFee.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 16),

                      // Dotted divider
                      const _DottedDivider(color: Color(0xFFFFCBB8)),
                      const SizedBox(height: 16),

                      // Total Row
                      _buildSummaryRow(
                        label: 'Total',
                        value: '\$${total.toStringAsFixed(2)}',
                        isTotal: true,
                      ),

                      const SizedBox(height: 28),

                      // ── Place Order Button ────────────────────────────────
                      Center(
                        child: GestureDetector(
                          onTap: _handlePlaceOrder,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 52,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFDDCF),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: _isPlacingOrder
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Color(0xFFE85324),
                                    ),
                                  )
                                : const Text(
                                    'Place Order',
                                    style: TextStyle(
                                      color: Color(0xFFDE4A20),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Docked Orange Bottom Navigation Bar ───────────────────────────────
      bottomNavigationBar: Container(
        height: 64,
        decoration: const BoxDecoration(
          color: Color(0xFFE85324),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(
                Icons.home_outlined,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () => context.go('/home'),
            ),
            IconButton(
              icon: const Icon(
                Icons.room_service_outlined,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () => context.go('/menu'),
            ),
            IconButton(
              icon: const Icon(
                Icons.favorite_border_rounded,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(
                Icons.assignment_outlined,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () => context.push('/cart'),
            ),
            IconButton(
              icon: const Icon(
                Icons.support_agent_outlined,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  // ── Single Order Item Card Widget ──────────────────────────────────────────
  Widget _buildOrderItem({
    required BuildContext context,
    required String name,
    required String image,
    required String date,
    required double totalPrice,
    required int quantity,
    required VoidCallback onCancel,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required VoidCallback onDelete,
  }) {
    final isOne = quantity <= 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rounded Food Image
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: CachedNetworkImage(
            imageUrl: image,
            width: 82,
            height: 82,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 82,
              height: 82,
              color: const Color(0xFFFFECE5),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFE85324),
                  ),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              width: 82,
              height: 82,
              color: const Color(0xFFFFECE5),
              child: const Icon(
                Icons.fastfood_rounded,
                color: Color(0xFFE85324),
                size: 36,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Food Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Trash Icon Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        color: Color(0xFF2E1C12),
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: onDelete,
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 2),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFE85324),
                        size: 19,
                      ),
                    ),
                  ),
                ],
              ),

              // Date and Total Price Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                      color: Color(0xFF8C7B74),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '\$${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFFE85324),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),

              // Items count label
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$quantity items',
                  style: const TextStyle(
                    color: Color(0xFF8C7B74),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Bottom Actions: "Cancel Order" button & Counter controls
              Row(
                children: [
                  GestureDetector(
                    onTap: onCancel,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFECE5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Cancel Order',
                        style: TextStyle(
                          color: Color(0xFFE85324),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),

                  // Pencil edit icon
                  const Icon(
                    Icons.edit_outlined,
                    color: Color(0xFFE85324),
                    size: 16,
                  ),
                  const SizedBox(width: 8),

                  // Minus button (peach if 1, coral if > 1)
                  GestureDetector(
                    onTap: onDecrement,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: isOne
                            ? const Color(0xFFFFECE5)
                            : const Color(0xFFE85324),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.remove,
                          size: 14,
                          color: isOne
                              ? const Color(0xFFE85324)
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '$quantity',
                      style: const TextStyle(
                        color: Color(0xFF2E1C12),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  // Plus button (coral)
                  GestureDetector(
                    onTap: onIncrement,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE85324),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Summary Row Widget ─────────────────────────────────────────────────────
  Widget _buildSummaryRow({
    required String label,
    required String value,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF2E1C12),
            fontSize: isTotal ? 18.5 : 17,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFF2E1C12),
            fontSize: isTotal ? 19 : 17,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ── Horizontal Dotted Divider ───────────────────────────────────────────────
class _DottedDivider extends StatelessWidget {
  final Color color;
  const _DottedDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashSpace = 4.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: 1.2,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}
