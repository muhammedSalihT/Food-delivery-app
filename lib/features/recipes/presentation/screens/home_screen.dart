import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/widgets/bottom_nav_bar.dart';
import '../../../../core/utils/price_calculator.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../recipes/domain/services/category_mapping_service.dart';
import '../providers/recipe_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Home Screen
// ─────────────────────────────────────────────────────────────────────────────
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Main scroll controller (drives recommend-grid infinite scroll)
  final ScrollController _mainScroll = ScrollController();

  // Best-sellers carousel scroll controller
  final ScrollController _bestSellersScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _mainScroll.addListener(_onMainScroll);
    _bestSellersScroll.addListener(_onBestSellersScroll);
  }

  // Trigger "load more" when near end of the main list (Recommend section)
  void _onMainScroll() {
    final pos = _mainScroll.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) {
      ref.read(recipeListNotifierProvider.notifier).fetchMoreRecommendations();
    }
  }

  // Trigger "load more" when near end of the horizontal Best Sellers list
  void _onBestSellersScroll() {
    final pos = _bestSellersScroll.position;
    if (pos.pixels >= pos.maxScrollExtent - 80) {
      ref.read(recipeListNotifierProvider.notifier).fetchMoreBestSellers();
    }
  }

  @override
  void dispose() {
    _mainScroll.dispose();
    _bestSellersScroll.dispose();
    super.dispose();
  }

  // ─── Greeting helpers ──────────────────────────────────────────────────────
  String _getGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getGreetingSubtitle() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Rise And Shine! It\'s Breakfast Time';
    if (h < 17) return 'Time For A Midday Treat!';
    return 'Craving Something Delicious Tonight?';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recipeListNotifierProvider);
    final cartCount = ref.watch(cartNotifierProvider).totalItemCount;
    final user = ref.watch(authNotifierProvider).user;

    return Scaffold(
      backgroundColor: const Color(0xFFF5C842),
      extendBody: true,
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Offline banner
            if (state.isOffline) const OfflineBanner(),

            // ── Amber header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search + icons row
                  Row(
                    children: [
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

                      // Cart
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
                                  color: Color(0xFFE85324),
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
                      const SizedBox(width: 8),

                      // Bell
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

                      // Avatar
                      GestureDetector(
                        onTap: () async {
                          await ref
                              .read(authNotifierProvider.notifier)
                              .logout();
                          if (context.mounted) context.go('/login');
                        },
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primaryLight,
                          backgroundImage:
                              user?.image.isNotEmpty == true
                                  ? NetworkImage(user!.image)
                                  : null,
                          child:
                              user?.image.isEmpty ?? true
                                  ? const Icon(
                                    Icons.person,
                                    size: 18,
                                    color: AppColors.primary,
                                  )
                                  : null,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  Text(
                    _getGreeting(),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getGreetingSubtitle(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFE85324),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // ── White rounded body ────────────────────────────────────────
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF6F6F9),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  child: state.isLoading && state.recipes.isEmpty
                      ? _buildSkeletonLoading()
                      : state.errorMessage != null && state.recipes.isEmpty
                      ? ErrorView(
                        message: state.errorMessage!,
                        onRetry: () => ref
                            .read(recipeListNotifierProvider.notifier)
                            .refresh(),
                      )
                      : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () => ref
                            .read(recipeListNotifierProvider.notifier)
                            .refresh(),
                        child: CustomScrollView(
                          controller: _mainScroll,
                          slivers: [
                            // ── Category pills ───────────────────────────
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 22),
                                child: _buildCategoryRow(
                                  state.selectedCategory,
                                ),
                              ),
                            ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 24),
                            ),

                            // ── Best Seller header ───────────────────────
                            SliverToBoxAdapter(
                              child: _buildSectionHeader(
                                'Best Seller',
                                onViewAll: () => context.push('/menu'),
                              ),
                            ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 12),
                            ),

                            // ── Best Sellers horizontal carousel ─────────
                            SliverToBoxAdapter(
                              child: _buildBestSellersRow(
                                state.bestSellers,
                                state.isLoadingMoreBestSellers,
                                state.canShowMoreBestSellers,
                              ),
                            ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 24),
                            ),

                            // ── Promo Banner ─────────────────────────────
                            SliverToBoxAdapter(
                              child: _buildPromoBanner(state.bestSellers),
                            ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 24),
                            ),

                            // ── Recommend header ─────────────────────────
                            SliverToBoxAdapter(
                              child: _buildSectionHeader('Recommend'),
                            ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 12),
                            ),

                            // ── Recommend 2-column grid ──────────────────
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              sliver: SliverGrid(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 14,
                                      mainAxisSpacing: 14,
                                      childAspectRatio: 0.78,
                                    ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final recs = state.recommendations;
                                    if (index >= recs.length) {
                                      return null;
                                    }
                                    return _RecommendCard(
                                      recipe: recs[index],
                                      onTap: () => context.push(
                                        '/recipe/${recs[index].id}',
                                      ),
                                    );
                                  },
                                  childCount: state.recommendations.length,
                                ),
                              ),
                            ),

                            // ── Recommend load-more footer ───────────────
                            SliverToBoxAdapter(
                              child: _buildRecommendFooter(state),
                            ),

                            // Bottom padding for nav bar
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 110),
                            ),
                          ],
                        ),
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Category pills row ─────────────────────────────────────────────────────
  Widget _buildCategoryRow(RecipeCategory selectedCategory) {
    final categories =
        RecipeCategory.values.where((c) => c != RecipeCategory.all).toList();
    return SizedBox(
      height: 90,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == selectedCategory;
          return GestureDetector(
            onTap: () => ref
                .read(recipeListNotifierProvider.notifier)
                .selectCategory(cat),
            child: Padding(
              padding: EdgeInsets.only(
                right: index < categories.length - 1 ? 16 : 0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFF3EC)
                          : const Color(0xFFFFF8F0),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFE85324)
                            : const Color(0xFFEEE0CC),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFFE85324,
                                ).withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Icon(
                        _getCategoryIcon(cat),
                        size: 26,
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
                      color: isSelected
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

  // ─── Section header ─────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTypography.titleLarge.copyWith(fontSize: 19)),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: Row(
                children: [
                  Text(
                    'View All',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ─── Best Sellers horizontal carousel with infinite scroll ──────────────────
  Widget _buildBestSellersRow(
    List recipes,
    bool isLoadingMore,
    bool hasMore,
  ) {
    if (recipes.isEmpty) return const SizedBox.shrink();

    // +1 for the loading indicator slot at the end
    final itemCount = recipes.length + (isLoadingMore || hasMore ? 1 : 0);

    return SizedBox(
      height: 170,
      child: ListView.builder(
        controller: _bestSellersScroll,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          // Loading indicator card at the end
          if (index == recipes.length) {
            return _BestSellerLoadingCard(isLoading: isLoadingMore);
          }

          final recipe = recipes[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => context.push('/recipe/${recipe.id}'),
              child: Container(
                width: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: CachedNetworkImage(
                        imageUrl: recipe.image,
                        fit: BoxFit.cover,
                        placeholder: (c, url) => const LoadingShimmer(
                          width: 130,
                          height: 170,
                          borderRadius: 18,
                        ),
                        errorWidget: (c, url, err) => Container(
                          color: AppColors.border,
                          child: const Icon(Icons.fastfood, color: Colors.grey),
                        ),
                      ),
                    ),
                    // Gradient overlay
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.65),
                            ],
                            stops: const [0.45, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Price badge
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          PriceCalculator.format(recipe.price),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE85324),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Promo Banner ────────────────────────────────────────────────────────────
  Widget _buildPromoBanner(List recipes) {
    final promoImage = recipes.isNotEmpty ? recipes.first.image : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE85324).withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Container(
                color: const Color(0xFFE85324),
                padding: const EdgeInsets.all(18),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Experience our\ndelicious new dish',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '30% OFF',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: promoImage != null
                  ? CachedNetworkImage(
                      imageUrl: promoImage,
                      fit: BoxFit.cover,
                      height: 140,
                      placeholder: (c, url) => Container(
                        color: const Color(0xFFFF7A55),
                        child: const Icon(
                          Icons.fastfood,
                          size: 50,
                          color: Colors.white54,
                        ),
                      ),
                      errorWidget: (c, url, err) => Container(
                        color: const Color(0xFFFF7A55),
                        child: const Icon(
                          Icons.fastfood,
                          size: 50,
                          color: Colors.white54,
                        ),
                      ),
                    )
                  : Container(
                      color: const Color(0xFFFF7A55),
                      child: const Icon(
                        Icons.fastfood_rounded,
                        size: 60,
                        color: Colors.white54,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Recommend footer (load more / spinner / end) ────────────────────────────
  Widget _buildRecommendFooter(RecipeListState state) {
    if (state.isLoadingMoreRecommendations) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    if (state.canShowMoreRecommendations) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: GestureDetector(
          onTap: () => ref
              .read(recipeListNotifierProvider.notifier)
              .fetchMoreRecommendations(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  'Load more dishes',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    // All recommendations shown
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(
          '✓ All dishes loaded',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
        ),
      ),
    );
  }

  // ─── Skeleton loading ────────────────────────────────────────────────────────
  Widget _buildSkeletonLoading() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      children: [
        // Category row
        Row(
          children: List.generate(
            5,
            (i) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: const Column(
                children: [
                  LoadingShimmer(width: 58, height: 58, borderRadius: 29),
                  SizedBox(height: 6),
                  LoadingShimmer(width: 40, height: 10, borderRadius: 4),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const LoadingShimmer(width: 120, height: 20, borderRadius: 6),
        const SizedBox(height: 12),
        // Best sellers skeleton
        SizedBox(
          height: 170,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: const LoadingShimmer(
                width: 130,
                height: 170,
                borderRadius: 18,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const LoadingShimmer(
          width: double.infinity,
          height: 140,
          borderRadius: 22,
        ),
        const SizedBox(height: 24),
        const LoadingShimmer(width: 120, height: 20, borderRadius: 6),
        const SizedBox(height: 12),
        // Recommend grid skeleton
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 4,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.78,
          ),
          itemBuilder: (context, index) => const LoadingShimmer(
            width: double.infinity,
            height: double.infinity,
            borderRadius: 18,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _RecommendCard — grid card for Recommend section
// ─────────────────────────────────────────────────────────────────────────────
class _RecommendCard extends StatelessWidget {
  final dynamic recipe;
  final VoidCallback onTap;

  const _RecommendCard({required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: recipe.image,
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (c, url) => const LoadingShimmer(
                      width: double.infinity,
                      height: 130,
                      borderRadius: 0,
                    ),
                    errorWidget: (c, url, err) => Container(
                      height: 130,
                      color: AppColors.border,
                      child: const Icon(Icons.fastfood, color: Colors.grey),
                    ),
                  ),
                ),
                // Rating
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 12,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          recipe.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Price
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE85324),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      PriceCalculator.format(recipe.price),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleMedium.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    recipe.cuisine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall,
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
// _BestSellerLoadingCard — shimmer / spinner at the end of the carousel
// ─────────────────────────────────────────────────────────────────────────────
class _BestSellerLoadingCard extends StatelessWidget {
  final bool isLoading;

  const _BestSellerLoadingCard({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isLoading ? 130 : 44,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.border.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              )
            : const Icon(
                Icons.keyboard_arrow_right_rounded,
                color: AppColors.textMuted,
                size: 24,
              ),
      ),
    );
  }
}
