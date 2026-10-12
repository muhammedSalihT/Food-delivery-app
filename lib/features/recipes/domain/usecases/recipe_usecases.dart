import '../entities/recipe_entity.dart';
import '../repositories/recipe_repository.dart';

class GetRecipesUseCase {
  final RecipeRepository _repository;

  GetRecipesUseCase(this._repository);

  Future<RecipePaginationEntity> call({int limit = 20, int skip = 0}) {
    return _repository.getRecipes(limit: limit, skip: skip);
  }
}

class SearchRecipesUseCase {
  final RecipeRepository _repository;

  SearchRecipesUseCase(this._repository);

  Future<RecipePaginationEntity> call({
    required String query,
    int limit = 20,
    int skip = 0,
  }) {
    return _repository.searchRecipes(query: query, limit: limit, skip: skip);
  }
}

class GetRecipeByIdUseCase {
  final RecipeRepository _repository;

  GetRecipeByIdUseCase(this._repository);

  Future<RecipeEntity> call(int id) {
    return _repository.getRecipeById(id);
  }
}

class GetCachedRecipesUseCase {
  final RecipeRepository _repository;

  GetCachedRecipesUseCase(this._repository);

  Future<List<RecipeEntity>> call() {
    return _repository.getCachedFirstPage();
  }
}
