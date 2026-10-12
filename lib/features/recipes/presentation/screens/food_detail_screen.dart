import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/price_calculator.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../domain/entities/recipe_entity.dart';
import '../providers/recipe_providers.dart';

final recipeDetailFutureProvider = FutureProvider.family<RecipeEntity, int>((
  ref,
  recipeId,
) async {
  // First check in the loaded recipe list for instant display
  final listState = ref.watch(recipeListNotifierProvider);
  final found = listState.recipes.where((r) => r.id == recipeId);
  if (found.isNotEmpty) return found.first;

  // Otherwise fetch via repository / usecase
  final usecase = ref.watch(getRecipeByIdUseCaseProvider);
  return await usecase(recipeId);
});

class FoodDetailScreen extends ConsumerStatefulWidget {
  final int recipeId;

  const FoodDetailScreen({super.key, required this.recipeId});

  @override
  ConsumerState<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends ConsumerState<FoodDetailScreen> {
  int _quantity = 1;
  bool _isAdding = false;

  void _increment() {
    setState(() => _quantity++);
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  Future<void> _addToCart(RecipeEntity recipe) async {
    if (_isAdding) return;
    setState(() => _isAdding = true);

    await ref
        .read(cartNotifierProvider.notifier)
        .addItem(
          recipeId: recipe.id,
          name: recipe.name,
          image: recipe.image,
          unitPrice: recipe.price,
          quantity: _quantity,
        );

    if (mounted) {
      setState(() => _isAdding = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added $_quantity × ${recipe.name} to cart!'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'VIEW CART',
            textColor: Colors.white,
            onPressed: () => context.push('/cart'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(recipeDetailFutureProvider(widget.recipeId));
    final cartState = ref.watch(cartNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: detailAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Scaffold(
          appBar: AppBar(title: const Text('Food Details')),
          body: ErrorView(
            message: err.toString(),
            onRetry: () =>
                ref.refresh(recipeDetailFutureProvider(widget.recipeId)),
          ),
        ),
        data: (recipe) {
          final totalPrice = recipe.price * _quantity;

          return Stack(
            children: [
              // Scrollable Details
              CustomScrollView(
                slivers: [
                  // App Bar with Hero Image
                  SliverAppBar(
                    expandedHeight: 320,
                    pinned: true,
                    backgroundColor: Colors.white,
                    leading: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    actions: [
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.shopping_bag_outlined,
                                color: AppColors.textPrimary,
                              ),
                              onPressed: () => context.push('/cart'),
                            ),
                            if (cartState.totalItemCount > 0)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${cartState.totalItemCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Hero(
                        tag: 'recipe_image_${recipe.id}',
                        child: CachedNetworkImage(
                          imageUrl: recipe.image,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => const LoadingShimmer(
                            width: double.infinity,
                            height: 320,
                            borderRadius: 0,
                          ),
                          errorWidget: (_, _, _) => Container(
                            color: AppColors.border,
                            child: const Icon(
                              Icons.fastfood,
                              size: 64,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Body Content
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title & Cuisine Tag
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  recipe.name,
                                  style: AppTypography.displayMedium.copyWith(
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  recipe.cuisine,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Rating, Prep & Cook Time Info Row
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 16,
                                      color: AppColors.secondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${recipe.rating.toStringAsFixed(1)} (${recipe.reviewCount} reviews)',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.timer_outlined,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${recipe.totalTimeMinutes} mins total',
                                style: AppTypography.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Metadata Badges (Difficulty, Servings, Calories)
                          Row(
                            children: [
                              _buildMetaItem(
                                icon: Icons.local_fire_department_outlined,
                                label: 'Difficulty',
                                value: recipe.difficulty,
                              ),
                              const SizedBox(width: 16),
                              _buildMetaItem(
                                icon: Icons.people_outline_rounded,
                                label: 'Servings',
                                value: '${recipe.servings} People',
                              ),
                              if (recipe.caloriesPerServing != null) ...[
                                const SizedBox(width: 16),
                                _buildMetaItem(
                                  icon: Icons.electric_bolt_outlined,
                                  label: 'Calories',
                                  value: '${recipe.caloriesPerServing} kcal',
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Divider(color: AppColors.divider),
                          const SizedBox(height: 16),

                          // Ingredients Section
                          Text('Ingredients', style: AppTypography.titleLarge),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: recipe.ingredients.map((ing) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      size: 16,
                                      color: AppColors.accentGreen,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(ing, style: AppTypography.bodyMedium),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                          const Divider(color: AppColors.divider),
                          const SizedBox(height: 16),

                          // Instructions / Preparation
                          Text(
                            'Preparation Steps',
                            style: AppTypography.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: recipe.instructions.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, idx) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: AppColors.primaryLight,
                                    child: Text(
                                      '${idx + 1}',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      recipe.instructions[idx],
                                      style: AppTypography.bodyMedium,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 100), // Bottom sheet spacing
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Bottom Sticky Add to Cart Action Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        // Quantity Selector
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 18),
                                onPressed: _decrement,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Text(
                                  '$_quantity',
                                  style: AppTypography.titleMedium,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 18),
                                onPressed: _increment,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Add to Cart Button with Calculated Total
                        Expanded(
                          child: PrimaryButton(
                            text: 'Add • ${PriceCalculator.format(totalPrice)}',
                            isLoading: _isAdding,
                            icon: Icons.add_shopping_cart_rounded,
                            onPressed: () => _addToCart(recipe),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetaItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(label, style: AppTypography.bodySmall),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
