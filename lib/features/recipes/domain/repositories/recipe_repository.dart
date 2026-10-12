import '../entities/recipe_entity.dart';

abstract class RecipeRepository {
  Future<RecipePaginationEntity> getRecipes({int limit = 20, int skip = 0});
  Future<RecipePaginationEntity> searchRecipes({
    required String query,
    int limit = 20,
    int skip = 0,
  });
  Future<RecipeEntity> getRecipeById(int id);
  Future<List<RecipeEntity>> getCachedFirstPage();
}
