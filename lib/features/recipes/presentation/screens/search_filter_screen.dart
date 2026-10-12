import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/widgets/category_chips_row.dart';
import '../../../../app/widgets/recipe_card.dart';
import '../../../../core/utils/price_calculator.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../providers/search_filter_providers.dart';

class SearchFilterScreen extends ConsumerStatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  ConsumerState<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends ConsumerState<SearchFilterScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final filterState = ref.watch(searchFilterNotifierProvider);
            final notifier = ref.read(searchFilterNotifierProvider.notifier);

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filter Dishes', style: AppTypography.titleLarge),
                      TextButton(
                        onPressed: () {
                          notifier.resetFilters();
                        },
                        child: const Text(
                          'Reset All',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 12),

                  // Minimum Rating Filter
                  Text(
                    'Minimum Rating: ${filterState.minRating == 0 ? "Any" : "${filterState.minRating.toStringAsFixed(1)} ★"}',
                    style: AppTypography.titleMedium.copyWith(fontSize: 15),
                  ),
                  Slider(
                    value: filterState.minRating,
                    min: 0.0,
                    max: 5.0,
                    divisions: 10,
                    activeColor: AppColors.secondary,
                    label: '${filterState.minRating} ★',
                    onChanged: (val) => notifier.setMinRating(val),
                  ),
                  const SizedBox(height: 12),

                  // Max Price Filter
                  Text(
                    'Max Price: ${PriceCalculator.format(filterState.maxPrice)}',
                    style: AppTypography.titleMedium.copyWith(fontSize: 15),
                  ),
                  Slider(
                    value: filterState.maxPrice,
                    min: 5.0,
                    max: 30.0,
                    divisions: 25,
                    activeColor: AppColors.primary,
                    label: PriceCalculator.format(filterState.maxPrice),
                    onChanged: (val) => notifier.setMaxPrice(val),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(searchFilterNotifierProvider);
    final results = filterState.filteredAndSortedResults;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Search & Filter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppColors.primary),
            onPressed: _showFilterModal,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Input Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'Search pizza, burger, pasta...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(searchFilterNotifierProvider.notifier)
                              .onQueryChanged('');
                        },
                      )
                    : null,
              ),
              onChanged: (val) {
                ref
                    .read(searchFilterNotifierProvider.notifier)
                    .onQueryChanged(val);
              },
            ),
          ),
          const SizedBox(height: 10),

          // Categories chips
          CategoryChipsRow(
            selectedCategory: filterState.selectedCategory,
            onSelected: (cat) {
              ref.read(searchFilterNotifierProvider.notifier).setCategory(cat);
            },
          ),
          const SizedBox(height: 14),

          // Result Count & Active Filter Tags
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  '${results.length} results found',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                if (filterState.minRating > 0 || filterState.maxPrice < 30.0)
                  GestureDetector(
                    onTap: () => ref
                        .read(searchFilterNotifierProvider.notifier)
                        .resetFilters(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Clear Filters',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Search Results List
          Expanded(
            child: filterState.isLoading
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: 4,
                    itemBuilder: (_, _) => const RecipeCardShimmer(),
                  )
                : filterState.errorMessage != null
                ? ErrorView(
                    message: filterState.errorMessage!,
                    onRetry: () => ref
                        .read(searchFilterNotifierProvider.notifier)
                        .executeSearch(_searchController.text),
                  )
                : results.isEmpty
                ? EmptyView(
                    title: 'No Matches Found',
                    message:
                        'Try adjusting your search or filters to find what you crave.',
                    buttonText: 'Reset Filters',
                    onAction: () {
                      _searchController.clear();
                      ref
                          .read(searchFilterNotifierProvider.notifier)
                          .onQueryChanged('');
                      ref
                          .read(searchFilterNotifierProvider.notifier)
                          .resetFilters();
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final recipe = results[index];
                      return RecipeCard(
                        recipe: recipe,
                        onTap: () => context.push('/recipe/${recipe.id}'),
                        onAddToCart: () {
                          ref
                              .read(cartNotifierProvider.notifier)
                              .addItem(
                                recipeId: recipe.id,
                                name: recipe.name,
                                image: recipe.image,
                                unitPrice: recipe.price,
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${recipe.name} added to cart!'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
