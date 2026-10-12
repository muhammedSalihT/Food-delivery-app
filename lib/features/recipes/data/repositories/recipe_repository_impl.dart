import '../../domain/entities/recipe_entity.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/recipe_local_data_source.dart';
import '../datasources/recipe_remote_data_source.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeRemoteDataSource _remoteDataSource;
  final RecipeLocalDataSource _localDataSource;

  RecipeRepositoryImpl({
    required RecipeRemoteDataSource remoteDataSource,
    required RecipeLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  @override
  Future<RecipePaginationEntity> getRecipes({
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      final result = await _remoteDataSource.getRecipes(
        limit: limit,
        skip: skip,
      );
      // Cache the first page locally
      if (skip == 0) {
        await _localDataSource.cacheFirstPageRecipes(result);
      }
      return result;
    } catch (e) {
      // If first page fails due to network or offline, check cache
      if (skip == 0) {
        final cached = _localDataSource.getCachedFirstPageRecipes();
        if (cached.isNotEmpty) {
          return RecipePaginationEntity(
            recipes: cached,
            total: cached.length,
            skip: 0,
            limit: limit,
          );
        }
      }
      rethrow;
    }
  }

  @override
  Future<RecipePaginationEntity> searchRecipes({
    required String query,
    int limit = 20,
    int skip = 0,
  }) async {
    return await _remoteDataSource.searchRecipes(
      query: query,
      limit: limit,
      skip: skip,
    );
  }

  @override
  Future<RecipeEntity> getRecipeById(int id) async {
    try {
      return await _remoteDataSource.getRecipeById(id);
    } catch (e) {
      // Check cached recipes first
      final cached = _localDataSource.getCachedFirstPageRecipes();
      final match = cached.where((r) => r.id == id);
      if (match.isNotEmpty) {
        return match.first;
      }
      rethrow;
    }
  }

  @override
  Future<List<RecipeEntity>> getCachedFirstPage() async {
    return _localDataSource.getCachedFirstPageRecipes();
  }
}
