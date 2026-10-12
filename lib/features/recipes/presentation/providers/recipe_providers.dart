import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/network_info.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/recipe_local_data_source.dart';
import '../../data/datasources/recipe_remote_data_source.dart';
import '../../data/repositories/recipe_repository_impl.dart';
import '../../domain/entities/recipe_entity.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../domain/services/category_mapping_service.dart';
import '../../domain/usecases/recipe_usecases.dart';

// ─── Infrastructure Providers ─────────────────────────────────────────────────
final recipeRemoteDataSourceProvider = Provider<RecipeRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return RecipeRemoteDataSource(dio);
});

final recipeLocalDataSourceProvider = Provider<RecipeLocalDataSource>((ref) {
  return RecipeLocalDataSource();
});

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepositoryImpl(
    remoteDataSource: ref.watch(recipeRemoteDataSourceProvider),
    localDataSource: ref.watch(recipeLocalDataSourceProvider),
  );
});

final getRecipesUseCaseProvider = Provider<GetRecipesUseCase>((ref) {
  return GetRecipesUseCase(ref.watch(recipeRepositoryProvider));
});

final searchRecipesUseCaseProvider = Provider<SearchRecipesUseCase>((ref) {
  return SearchRecipesUseCase(ref.watch(recipeRepositoryProvider));
});

final getRecipeByIdUseCaseProvider = Provider<GetRecipeByIdUseCase>((ref) {
  return GetRecipeByIdUseCase(ref.watch(recipeRepositoryProvider));
});

final getCachedRecipesUseCaseProvider = Provider<GetCachedRecipesUseCase>((
  ref,
) {
  return GetCachedRecipesUseCase(ref.watch(recipeRepositoryProvider));
});

// ─── Network Connectivity ─────────────────────────────────────────────────────
final networkInfoProvider = Provider<NetworkInfo>((ref) => NetworkInfo());

final connectivityStatusProvider = StreamProvider<bool>((ref) async* {
  final networkInfo = ref.watch(networkInfoProvider);
  yield await networkInfo.isConnected;
  await for (final results in networkInfo.onConnectivityChanged) {
    yield !results.contains(ConnectivityResult.none);
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// RecipeListState — shared state for all recipe listing screens
// ─────────────────────────────────────────────────────────────────────────────
class RecipeListState {
  final List<RecipeEntity> recipes;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final bool hasMore;
  final int total;
  final int skip;
  final RecipeCategory selectedCategory;
  final bool isOffline;

  // Best sellers pagination
  final bool isLoadingMoreBestSellers;
  final bool hasMoreBestSellers;
  final int bestSellersCount; // how many best-seller slots are shown

  // Recommendations pagination
  final bool isLoadingMoreRecommendations;
  final bool hasMoreRecommendations;
  final int recommendationsCount; // how many recommend slots are shown

  static const int _bestSellersPageSize = 6;
  static const int _recommendationsPageSize = 6;

  const RecipeListState({
    this.recipes = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.hasMore = true,
    this.total = 0,
    this.skip = 0,
    this.selectedCategory = RecipeCategory.all,
    this.isOffline = false,
    this.isLoadingMoreBestSellers = false,
    this.hasMoreBestSellers = true,
    this.bestSellersCount = _bestSellersPageSize,
    this.isLoadingMoreRecommendations = false,
    this.hasMoreRecommendations = true,
    this.recommendationsCount = _recommendationsPageSize,
  });

  // ── Filtered list by selected category ──────────────────────────────────────
  List<RecipeEntity> get filteredRecipes {
    return CategoryMappingService.filterByCategory(recipes, selectedCategory);
  }

  // ── All best-seller candidates (sorted by rating × review-count) ─────────────
  List<RecipeEntity> get _allBestSellersRanked {
    final sorted = List<RecipeEntity>.from(recipes)
      ..sort((a, b) {
        final scoreA = a.rating * a.reviewCount.clamp(1, 100);
        final scoreB = b.rating * b.reviewCount.clamp(1, 100);
        return scoreB.compareTo(scoreA);
      });
    return sorted;
  }

  // ── Visible best sellers (respects bestSellersCount) ─────────────────────────
  List<RecipeEntity> get bestSellers {
    final all = _allBestSellersRanked;
    return all.take(bestSellersCount).toList();
  }

  // ── Whether we can show more best sellers ─────────────────────────────────────
  bool get canShowMoreBestSellers {
    return bestSellersCount < _allBestSellersRanked.length || hasMore;
  }

  // ── All recommendation candidates (sorted by rating, skipping top-2 best-sellers) ──
  List<RecipeEntity> get _allRecommendationsRanked {
    final sorted = List<RecipeEntity>.from(recipes)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    // Skip the first 2 (they're already in Best Sellers)
    return sorted.skip(2).toList();
  }

  // ── Visible recommendations (respects recommendationsCount) ──────────────────
  List<RecipeEntity> get recommendations {
    final all = _allRecommendationsRanked;
    return all.take(recommendationsCount).toList();
  }

  // ── Whether we can show more recommendations ──────────────────────────────────
  bool get canShowMoreRecommendations {
    return recommendationsCount < _allRecommendationsRanked.length || hasMore;
  }

  RecipeListState copyWith({
    List<RecipeEntity>? recipes,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool? hasMore,
    int? total,
    int? skip,
    RecipeCategory? selectedCategory,
    bool? isOffline,
    bool? isLoadingMoreBestSellers,
    bool? hasMoreBestSellers,
    int? bestSellersCount,
    bool? isLoadingMoreRecommendations,
    bool? hasMoreRecommendations,
    int? recommendationsCount,
    bool clearError = false,
  }) {
    return RecipeListState(
      recipes: recipes ?? this.recipes,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasMore: hasMore ?? this.hasMore,
      total: total ?? this.total,
      skip: skip ?? this.skip,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isOffline: isOffline ?? this.isOffline,
      isLoadingMoreBestSellers:
          isLoadingMoreBestSellers ?? this.isLoadingMoreBestSellers,
      hasMoreBestSellers: hasMoreBestSellers ?? this.hasMoreBestSellers,
      bestSellersCount: bestSellersCount ?? this.bestSellersCount,
      isLoadingMoreRecommendations:
          isLoadingMoreRecommendations ?? this.isLoadingMoreRecommendations,
      hasMoreRecommendations:
          hasMoreRecommendations ?? this.hasMoreRecommendations,
      recommendationsCount: recommendationsCount ?? this.recommendationsCount,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RecipeListNotifier — manages all recipe pagination
// ─────────────────────────────────────────────────────────────────────────────
class RecipeListNotifier extends StateNotifier<RecipeListState> {
  final GetRecipesUseCase _getRecipesUseCase;
  final NetworkInfo _networkInfo;

  /// Fetch 30 items per API page for richer section content
  static const int _pageSize = 30;
  static const int _bestSellersStep = 6;
  static const int _recommendationsStep = 6;

  RecipeListNotifier({
    required GetRecipesUseCase getRecipesUseCase,
    required NetworkInfo networkInfo,
  }) : _getRecipesUseCase = getRecipesUseCase,
       _networkInfo = networkInfo,
       super(const RecipeListState()) {
    fetchInitialRecipes();
  }

  // ── Initial load ────────────────────────────────────────────────────────────
  Future<void> fetchInitialRecipes() async {
    final connected = await _networkInfo.isConnected;
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      isOffline: !connected,
      bestSellersCount: RecipeListState._bestSellersPageSize,
      recommendationsCount: RecipeListState._recommendationsPageSize,
    );

    try {
      final result = await _getRecipesUseCase(limit: _pageSize, skip: 0);
      final newSkip = result.skip + result.recipes.length;
      state = state.copyWith(
        recipes: result.recipes,
        isLoading: false,
        total: result.total,
        skip: newSkip,
        hasMore: newSkip < result.total,
        isOffline: !connected,
        hasMoreBestSellers: true,
        hasMoreRecommendations: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        isOffline: !connected,
      );
    }
  }

  // ── General next page (used by Menu screen & Home recommended scroll) ────────
  Future<void> fetchNextPage() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _getRecipesUseCase(
        limit: _pageSize,
        skip: state.skip,
      );
      final combined = [...state.recipes, ...result.recipes];
      final newSkip = state.skip + result.recipes.length;
      state = state.copyWith(
        recipes: combined,
        isLoadingMore: false,
        skip: newSkip,
        hasMore: newSkip < result.total,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  // ── Best Sellers "load more" ─────────────────────────────────────────────────
  /// Called when the horizontal Best Sellers carousel reaches its end.
  /// First tries to show more from already-fetched recipes. If exhausted,
  /// fetches the next API page.
  Future<void> fetchMoreBestSellers() async {
    if (state.isLoadingMoreBestSellers) return;

    final currentRanked = state._allBestSellersRanked;
    final nextCount = state.bestSellersCount + _bestSellersStep;

    // Enough data already loaded — just show more
    if (state.bestSellersCount < currentRanked.length) {
      state = state.copyWith(
        bestSellersCount: nextCount.clamp(0, currentRanked.length),
        hasMoreBestSellers: nextCount < currentRanked.length || state.hasMore,
      );
      return;
    }

    // Need to fetch more from API
    if (!state.hasMore) {
      state = state.copyWith(hasMoreBestSellers: false);
      return;
    }

    state = state.copyWith(isLoadingMoreBestSellers: true);
    try {
      final result = await _getRecipesUseCase(
        limit: _pageSize,
        skip: state.skip,
      );
      final combined = [...state.recipes, ...result.recipes];
      final newSkip = state.skip + result.recipes.length;
      state = state.copyWith(
        recipes: combined,
        isLoadingMoreBestSellers: false,
        skip: newSkip,
        hasMore: newSkip < result.total,
        bestSellersCount: nextCount,
        hasMoreBestSellers: nextCount < combined.length || newSkip < result.total,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMoreBestSellers: false);
    }
  }

  // ── Recommendations "load more" ──────────────────────────────────────────────
  /// Called when user scrolls to the bottom of the Recommend grid.
  Future<void> fetchMoreRecommendations() async {
    if (state.isLoadingMoreRecommendations) return;

    final currentRanked = state._allRecommendationsRanked;
    final nextCount = state.recommendationsCount + _recommendationsStep;

    // Enough data already loaded — just reveal more
    if (state.recommendationsCount < currentRanked.length) {
      state = state.copyWith(
        recommendationsCount: nextCount.clamp(0, currentRanked.length),
        hasMoreRecommendations:
            nextCount < currentRanked.length || state.hasMore,
      );
      return;
    }

    // Need to fetch more from API
    if (!state.hasMore) {
      state = state.copyWith(hasMoreRecommendations: false);
      return;
    }

    state = state.copyWith(isLoadingMoreRecommendations: true);
    try {
      final result = await _getRecipesUseCase(
        limit: _pageSize,
        skip: state.skip,
      );
      final combined = [...state.recipes, ...result.recipes];
      final newSkip = state.skip + result.recipes.length;
      state = state.copyWith(
        recipes: combined,
        isLoadingMoreRecommendations: false,
        skip: newSkip,
        hasMore: newSkip < result.total,
        recommendationsCount: nextCount,
        hasMoreRecommendations:
            nextCount < combined.length || newSkip < result.total,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMoreRecommendations: false);
    }
  }

  // ── Category selection ───────────────────────────────────────────────────────
  void selectCategory(RecipeCategory category) {
    state = state.copyWith(selectedCategory: category);
  }

  // ── Refresh ──────────────────────────────────────────────────────────────────
  Future<void> refresh() async {
    await fetchInitialRecipes();
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────
final recipeListNotifierProvider =
    StateNotifierProvider<RecipeListNotifier, RecipeListState>((ref) {
      return RecipeListNotifier(
        getRecipesUseCase: ref.watch(getRecipesUseCaseProvider),
        networkInfo: ref.watch(networkInfoProvider),
      );
    });
