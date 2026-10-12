import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/debounce.dart';
import '../../domain/entities/recipe_entity.dart';
import '../../domain/services/category_mapping_service.dart';
import '../../domain/usecases/recipe_usecases.dart';
import 'recipe_providers.dart';

enum MenuSortOption {
  defaultSort('Default'),
  ratingHighest('Rating: High to Low'),
  priceLowToHigh('Price: Low to High'),
  priceHighToLow('Price: High to Low'),
  cookTimeShortest('Cook Time: Shortest');

  final String title;
  const MenuSortOption(this.title);
}

class SearchFilterState {
  final String query;
  final RecipeCategory selectedCategory;
  final double minRating;
  final double maxPrice;
  final MenuSortOption sortOption;
  final List<RecipeEntity> searchResults;
  final bool isLoading;
  final String? errorMessage;

  const SearchFilterState({
    this.query = '',
    this.selectedCategory = RecipeCategory.all,
    this.minRating = 0.0,
    this.maxPrice = 30.0,
    this.sortOption = MenuSortOption.defaultSort,
    this.searchResults = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  List<RecipeEntity> get filteredAndSortedResults {
    var list = CategoryMappingService.filterByCategory(
      searchResults,
      selectedCategory,
    );

    // Filter by minRating
    if (minRating > 0) {
      list = list.where((r) => r.rating >= minRating).toList();
    }

    // Filter by maxPrice
    list = list.where((r) => r.price <= maxPrice).toList();

    // Sort
    final sorted = List<RecipeEntity>.from(list);
    switch (sortOption) {
      case MenuSortOption.ratingHighest:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case MenuSortOption.priceLowToHigh:
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case MenuSortOption.priceHighToLow:
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case MenuSortOption.cookTimeShortest:
        sorted.sort((a, b) => a.cookTimeMinutes.compareTo(b.cookTimeMinutes));
        break;
      case MenuSortOption.defaultSort:
        break;
    }

    return sorted;
  }

  SearchFilterState copyWith({
    String? query,
    RecipeCategory? selectedCategory,
    double? minRating,
    double? maxPrice,
    MenuSortOption? sortOption,
    List<RecipeEntity>? searchResults,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SearchFilterState(
      query: query ?? this.query,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      minRating: minRating ?? this.minRating,
      maxPrice: maxPrice ?? this.maxPrice,
      sortOption: sortOption ?? this.sortOption,
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class SearchFilterNotifier extends StateNotifier<SearchFilterState> {
  final SearchRecipesUseCase _searchRecipesUseCase;
  final GetRecipesUseCase _getRecipesUseCase;
  final Debouncer _debouncer = Debouncer(
    delay: const Duration(milliseconds: 350),
  );
  int _searchRequestId = 0;

  SearchFilterNotifier({
    required SearchRecipesUseCase searchRecipesUseCase,
    required GetRecipesUseCase getRecipesUseCase,
  }) : _searchRecipesUseCase = searchRecipesUseCase,
       _getRecipesUseCase = getRecipesUseCase,
       super(const SearchFilterState()) {
    // Initial popular items for search screen
    loadInitial();
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true);
    try {
      final res = await _getRecipesUseCase(limit: 30, skip: 0);
      state = state.copyWith(searchResults: res.recipes, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void onQueryChanged(String query) {
    state = state.copyWith(query: query);
    _debouncer.run(() {
      executeSearch(query);
    });
  }

  Future<void> executeSearch(String query) async {
    final currentId = ++_searchRequestId;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final results = query.trim().isEmpty
          ? await _getRecipesUseCase(limit: 30, skip: 0)
          : await _searchRecipesUseCase(query: query);

      // Handle race condition: prevent older responses from overwriting newer search results
      if (currentId == _searchRequestId) {
        state = state.copyWith(
          searchResults: results.recipes,
          isLoading: false,
        );
      }
    } catch (e) {
      if (currentId == _searchRequestId) {
        state = state.copyWith(isLoading: false, errorMessage: e.toString());
      }
    }
  }

  void setCategory(RecipeCategory category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setMinRating(double rating) {
    state = state.copyWith(minRating: rating);
  }

  void setMaxPrice(double price) {
    state = state.copyWith(maxPrice: price);
  }

  void setSortOption(MenuSortOption sort) {
    state = state.copyWith(sortOption: sort);
  }

  void resetFilters() {
    state = state.copyWith(
      selectedCategory: RecipeCategory.all,
      minRating: 0.0,
      maxPrice: 30.0,
      sortOption: MenuSortOption.defaultSort,
    );
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }
}

final searchFilterNotifierProvider =
    StateNotifierProvider<SearchFilterNotifier, SearchFilterState>((ref) {
      return SearchFilterNotifier(
        searchRecipesUseCase: ref.watch(searchRecipesUseCaseProvider),
        getRecipesUseCase: ref.watch(getRecipesUseCaseProvider),
      );
    });
