import 'dart:convert';
import '../../../../core/storage/local_cache_service.dart';
import '../models/recipe_model.dart';

class RecipeLocalDataSource {
  Future<void> cacheFirstPageRecipes(RecipePaginationModel model) async {
    final jsonStr = jsonEncode(model.toJson());
    await LocalCacheService.cacheFirstPageRecipes(jsonStr);
  }

  List<RecipeModel> getCachedFirstPageRecipes() {
    final raw = LocalCacheService.getFirstPageRecipes();
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final model = RecipePaginationModel.fromJson(decoded);
      return model.recipes.cast<RecipeModel>();
    } catch (_) {
      return [];
    }
  }
}
