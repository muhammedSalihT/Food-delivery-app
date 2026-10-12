import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/price_calculator.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../cart/presentation/providers/cart_providers.dart';

class ConfirmOrderScreen extends ConsumerStatefulWidget {
  const ConfirmOrderScreen({super.key});

  @override
  ConsumerState<ConfirmOrderScreen> createState() => _ConfirmOrderScreenState();
}

class _ConfirmOrderScreenState extends ConsumerState<ConfirmOrderScreen> {
  bool _isPlacingOrder = false;
  bool _orderConfirmed = false;

  Future<void> _handlePlaceOrder() async {
    if (_isPlacingOrder) return;
    setState(() => _isPlacingOrder = true);

    // Simulate local order processing
    await Future.delayed(const Duration(milliseconds: 900));

    // Clear cart upon successful local order
    await ref.read(cartNotifierProvider.notifier).clearCart();

    if (mounted) {
      setState(() {
        _isPlacingOrder = false;
        _orderConfirmed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartNotifierProvider);

    if (_orderConfirmed) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
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
                Text(
                  'Order Confirmed!',
                  style: AppTypography.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Your delicious meal has been booked locally. (This is a local demonstration confirmation — no payment was charged).',
                  style: AppTypography.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                PrimaryButton(
                  text: 'Back to Home',
                  onPressed: () => context.go('/home'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (cartState.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No items in order to confirm.'),
              const SizedBox(height: 16),
              PrimaryButton(
                text: 'Go to Menu',
                width: 160,
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Confirm Order')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Address card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery Address',
                          style: AppTypography.titleMedium.copyWith(
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '742 Evergreen Terrace, New York, NY 10001',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Order Items Review Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Items in Order (${cartState.items.length})',
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cartState.items.length,
                    separatorBuilder: (_, _) =>
                        const Divider(color: AppColors.divider),
                    itemBuilder: (context, index) {
                      final item = cartState.items[index];
                      return Row(
                        children: [
                          Text(
                            '${item.quantity}x',
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.primary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.name,
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            PriceCalculator.format(item.lineSubtotal),
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Payment method note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.payment_rounded,
                    color: AppColors.accentGreen,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Method',
                          style: AppTypography.titleMedium.copyWith(
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Cash on Delivery / Local Demo (No charge)',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Cost Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildSummaryLine(
                    'Subtotal',
                    PriceCalculator.format(cartState.subtotal),
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryLine(
                    'Tax (5%)',
                    PriceCalculator.format(cartState.tax),
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryLine(
                    'Service Fee',
                    PriceCalculator.format(cartState.serviceFee),
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryLine(
                    'Delivery Fee',
                    PriceCalculator.format(cartState.deliveryFee),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Final Total', style: AppTypography.titleLarge),
                      Text(
                        PriceCalculator.format(cartState.grandTotal),
                        style: AppTypography.titleLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Place Order Button
            PrimaryButton(
              text: 'Place Order Now',
              isLoading: _isPlacingOrder,
              icon: Icons.check_circle_outline,
              onPressed: _handlePlaceOrder,
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Demo checkout • No real funds will be transferred',
                style: AppTypography.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryLine(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTypography.bodyMedium),
        Text(
          value,
          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
