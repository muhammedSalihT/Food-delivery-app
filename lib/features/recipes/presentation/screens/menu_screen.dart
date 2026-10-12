import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/widgets/bottom_nav_bar.dart';
import '../../../../core/utils/price_calculator.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/services/category_mapping_service.dart';
import '../providers/recipe_providers.dart';
import '../providers/search_filter_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Menu Screen  –  matches reference image 2 exactly
// ─────────────────────────────────────────────────────────────────────────────
class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  final ScrollController _scrollController = ScrollController();
  MenuSortOption _currentSort = MenuSortOption.defaultSort;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(recipeListNotifierProvider.notifier).fetchNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ─── Sort helper ──────────────────────────────────────────────────────────
  List _sorted(List recipes) {
    final list = List.of(recipes);
    switch (_currentSort) {
      case MenuSortOption.ratingHighest:
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case MenuSortOption.priceLowToHigh:
        list.sort((a, b) => a.price.compareTo(b.price));
      case MenuSortOption.priceHighToLow:
        list.sort((a, b) => b.price.compareTo(a.price));
      case MenuSortOption.cookTimeShortest:
        list.sort((a, b) => a.cookTimeMinutes.compareTo(b.cookTimeMinutes));
      case MenuSortOption.defaultSort:
        break;
    }
    return list;
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final recipeState = ref.watch(recipeListNotifierProvider);
    final cartState = ref.watch(cartNotifierProvider);
    final user = ref.watch(authNotifierProvider).user;
    final cartCount = cartState.totalItemCount;
    final displayedRecipes = _sorted(recipeState.filteredRecipes);

    return Scaffold(
      // Orange background colour bleeds behind the status-bar SafeArea
      backgroundColor: const Color(0xFFE85324),
      extendBody: true,
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
      body: Column(
        children: [
          // ── ORANGE HEADER (search bar + icon buttons) ───────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: [
                  // ── Search bar ──────────────────────────────────────────
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.push('/search'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Search',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                            const Spacer(),
                            // Orange filter button inside search bar
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE85324),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.tune_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // ── Cart icon with badge ────────────────────────────────
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        onTap: () => context.push('/cart'),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            size: 20,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (cartCount > 0)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF5C842),
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Center(
                              child: Text(
                                '$cartCount',
                                style: const TextStyle(
                                  color: Color(0xFFE85324),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),

                  // ── Bell icon ───────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // ── Avatar / Profile ────────────────────────────────────
                  GestureDetector(
                    onTap: () async {
                      await ref.read(authNotifierProvider.notifier).logout();
                      if (context.mounted) context.go('/login');
                    },
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          user?.image.isNotEmpty == true
                              ? NetworkImage(user!.image)
                              : null,
                      child:
                          user?.image.isEmpty ?? true
                              ? const Icon(
                                Icons.person,
                                size: 18,
                                color: Color(0xFFE85324),
                              )
                              : null,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── WHITE ROUNDED BODY (categories + filter + list) ─────────────
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF6F6F9),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                child: Column(
                  children: [
                    // ── Category pills row (same style as Home screen) ──────
                    Padding(
                      padding: const EdgeInsets.only(top: 22, bottom: 4),
                      child: _buildCategoryRow(recipeState.selectedCategory),
                    ),

                    // ── Sort / Filter bar ──────────────────────────────────
                    Container(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Sort By',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _showSortSheet(context),
                            child: Text(
                              _currentSort == MenuSortOption.defaultSort
                                  ? 'Popular'
                                  : _currentSort.title,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => _showSortSheet(context),
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.tune_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Recipe list ─────────────────────────────────────────
                    Expanded(
                      child:
                          recipeState.isLoading && recipeState.recipes.isEmpty
                              ? ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                itemCount: 4,
                                itemBuilder:
                                    (context, index) => const _MenuItemShimmer(),
                              )
                              : recipeState.errorMessage != null &&
                                  recipeState.recipes.isEmpty
                              ? ErrorView(
                                message: recipeState.errorMessage!,
                                onRetry:
                                    () => ref
                                        .read(recipeListNotifierProvider.notifier)
                                        .refresh(),
                              )
                              : displayedRecipes.isEmpty
                              ? EmptyView(
                                title: 'No Dishes Found',
                                message:
                                    'No recipes match "${recipeState.selectedCategory.title}". Try another category.',
                                buttonText: 'Show All Menu',
                                onAction: () {
                                  ref
                                      .read(recipeListNotifierProvider.notifier)
                                      .selectCategory(RecipeCategory.all);
                                },
                              )
                              : RefreshIndicator(
                                color: AppColors.primary,
                                onRefresh:
                                    () => ref
                                        .read(recipeListNotifierProvider.notifier)
                                        .refresh(),
                                child: ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                    bottom: 110,
                                  ),
                                  itemCount:
                                      displayedRecipes.length +
                                      (recipeState.isLoadingMore ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == displayedRecipes.length) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 20,
                                        ),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      );
                                    }
                                    final recipe = displayedRecipes[index];
                                    return _MenuItemCard(
                                      recipe: recipe,
                                      onTap: () =>
                                          context.push('/recipe/${recipe.id}'),
                                      onAddToCart: () {
                                        ref
                                            .read(cartNotifierProvider.notifier)
                                            .addItem(
                                              recipeId: recipe.id,
                                              name: recipe.name,
                                              image: recipe.image,
                                              unitPrice: recipe.price,
                                            );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '${recipe.name} added to cart!',
                                            ),
                                            duration:
                                                const Duration(seconds: 1),
                                            backgroundColor: AppColors.primary,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Category pills row — IDENTICAL style to Home screen ────────────────────
  Widget _buildCategoryRow(RecipeCategory selectedCategory) {
    // Show all categories including "All"
    final categories = RecipeCategory.values.toList();
    return SizedBox(
      height: 92,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == selectedCategory;

          return GestureDetector(
            onTap: () {
              ref
                  .read(recipeListNotifierProvider.notifier)
                  .selectCategory(cat);
            },
            child: Padding(
              padding: EdgeInsets.only(right: index < categories.length - 1 ? 18 : 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Circle icon container — same as Home screen
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(0xFFFFF3EC)
                              : const Color(0xFFFFF8F0),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            isSelected
                                ? const Color(0xFFE85324)
                                : const Color(0xFFEEE0CC),
                        width: isSelected ? 2.0 : 1.0,
                      ),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFFE85324,
                                  ).withValues(alpha: 0.22),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                              : null,
                    ),
                    child: Center(
                      child: Icon(
                        _getCategoryIcon(cat),
                        size: 26,
                        // Icon always orange — same as home
                        color: const Color(0xFFE85324),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.normal,
                      color:
                          isSelected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(RecipeCategory category) {
    switch (category) {
      case RecipeCategory.all:
        return Icons.restaurant_menu_rounded;
      case RecipeCategory.snacks:
        return Icons.fastfood_rounded;
      case RecipeCategory.meal:
        return Icons.dinner_dining_rounded;
      case RecipeCategory.vegan:
        return Icons.eco_rounded;
      case RecipeCategory.dessert:
        return Icons.cake_rounded;
      case RecipeCategory.drinks:
        return Icons.local_bar_rounded;
    }
  }

  // ─── Sort bottom sheet ────────────────────────────────────────────────────
  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Text(
                    'Sort By',
                    style: AppTypography.titleLarge.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  ...MenuSortOption.values.map((sort) {
                    final isChosen = sort == _currentSort;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        isChosen
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color:
                            isChosen
                                ? AppColors.primary
                                : AppColors.textSecondary,
                      ),
                      title: Text(
                        sort == MenuSortOption.defaultSort
                            ? 'Popular'
                            : sort.title,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight:
                              isChosen ? FontWeight.w600 : FontWeight.normal,
                          color:
                              isChosen
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                        ),
                      ),
                      onTap: () {
                        setState(() => _currentSort = sort);
                        Navigator.pop(sheetCtx);
                      },
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MenuItemCard — large card matching reference image 2
// ─────────────────────────────────────────────────────────────────────────────
class _MenuItemCard extends StatelessWidget {
  final dynamic recipe;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;

  const _MenuItemCard({
    required this.recipe,
    required this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Full-width food image ──────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
              child: CachedNetworkImage(
                imageUrl: recipe.image,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (c, url) => const LoadingShimmer(
                  width: double.infinity,
                  height: 200,
                  borderRadius: 0,
                ),
                errorWidget:
                    (c, url, err) => Container(
                      height: 200,
                      color: AppColors.border,
                      child: const Center(
                        child: Icon(Icons.fastfood, size: 50, color: Colors.grey),
                      ),
                    ),
              ),
            ),

            // ── Info section ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name • rating badge • price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Item name
                      Expanded(
                        child: Text(
                          recipe.name,
                          style: AppTypography.titleMedium.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Bullet separator
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: AppColors.textMuted,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Rating badge — orange pill with star icon
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3EC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFFD4B5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              recipe.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFE85324),
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Icon(
                              Icons.star_rounded,
                              size: 13,
                              color: AppColors.secondary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Price in orange
                      Text(
                        PriceCalculator.format(recipe.price),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFE85324),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Description / tags
                  Text(
                    recipe.tags.isNotEmpty
                        ? recipe.tags.take(4).join(', ')
                        : '${recipe.cuisine} • ${recipe.difficulty}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MenuItemShimmer — skeleton placeholder card
// ─────────────────────────────────────────────────────────────────────────────
class _MenuItemShimmer extends StatelessWidget {
  const _MenuItemShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LoadingShimmer(
            width: double.infinity,
            height: 200,
            borderRadius: 22,
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    LoadingShimmer(width: 160, height: 18, borderRadius: 6),
                    Spacer(),
                    LoadingShimmer(width: 60, height: 18, borderRadius: 8),
                  ],
                ),
                SizedBox(height: 8),
                LoadingShimmer(width: 240, height: 13, borderRadius: 4),
                SizedBox(height: 4),
                LoadingShimmer(width: 180, height: 13, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
