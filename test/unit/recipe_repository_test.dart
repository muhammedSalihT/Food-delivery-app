import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/recipes/data/models/recipe_model.dart';
import 'package:food_delivery_app/features/recipes/domain/entities/recipe_entity.dart';
import 'package:food_delivery_app/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:food_delivery_app/features/recipes/domain/services/category_mapping_service.dart';

class FakeRecipeRepository implements RecipeRepository {
  final List<RecipeEntity> _recipes;

  FakeRecipeRepository(this._recipes);

  @override
  Future<RecipePaginationEntity> getRecipes({
    int limit = 20,
    int skip = 0,
  }) async {
    final sub = _recipes.skip(skip).take(limit).toList();
    return RecipePaginationEntity(
      recipes: sub,
      total: _recipes.length,
      skip: skip,
      limit: limit,
    );
  }

  @override
  Future<RecipeEntity> getRecipeById(int id) async {
    return _recipes.firstWhere((r) => r.id == id);
  }

  @override
  Future<List<RecipeEntity>> getCachedFirstPage() async {
    return _recipes.take(20).toList();
  }

  @override
  Future<RecipePaginationEntity> searchRecipes({
    required String query,
    int limit = 20,
    int skip = 0,
  }) async {
    final matches = _recipes
        .where((r) => r.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return RecipePaginationEntity(
      recipes: matches,
      total: matches.length,
      skip: skip,
      limit: limit,
    );
  }
}

void main() {
  group('Recipe Model and Category Mapping Tests', () {
    test('RecipeModel JSON parsing and deterministic price mapping', () {
      final json = {
        'id': 1,
        'name': 'Classic Margherita Pizza',
        'image': 'https://example.com/pizza.jpg',
        'ingredients': ['Flour', 'Tomato Sauce', 'Mozzarella', 'Basil'],
        'instructions': ['Knead dough', 'Add toppings', 'Bake at 450F'],
        'prepTimeMinutes': 20,
        'cookTimeMinutes': 15,
        'rating': 4.8,
        'reviewCount': 95,
        'mealType': ['Dinner', 'Lunch'],
        'tags': ['Italian', 'Vegetarian', 'Pizza'],
        'cuisine': 'Italian',
        'difficulty': 'Easy',
        'servings': 4,
        'caloriesPerServing': 300,
      };

      final model = RecipeModel.fromJson(json);

      expect(model.id, equals(1));
      expect(model.name, equals('Classic Margherita Pizza'));
      expect(model.rating, equals(4.8));
      expect(model.totalTimeMinutes, equals(35));
      expect(model.price, equals(6.36)); // calculated deterministically
      expect(model.ingredients.length, equals(4));
    });

    test('CategoryMappingService classifies recipes accurately', () {
      final mealRecipe = RecipeEntity(
        id: 1,
        name: 'Spaghetti Bolognese',
        image: '',
        ingredients: [],
        instructions: [],
        prepTimeMinutes: 10,
        cookTimeMinutes: 20,
        rating: 4.5,
        reviewCount: 20,
        mealType: ['Dinner', 'Lunch'],
        tags: ['Pasta'],
        cuisine: 'Italian',
        difficulty: 'Easy',
        servings: 2,
        price: 8.5,
      );

      final veganRecipe = RecipeEntity(
        id: 2,
        name: 'Avocado Green Salad',
        image: '',
        ingredients: ['Lettuce', 'Avocado', 'Olive Oil'],
        instructions: [],
        prepTimeMinutes: 5,
        cookTimeMinutes: 0,
        rating: 4.7,
        reviewCount: 30,
        mealType: ['Snack'],
        tags: ['Vegan', 'Plant-based', 'Healthy'],
        cuisine: 'Healthy',
        difficulty: 'Easy',
        servings: 1,
        price: 6.5,
      );

      final dessertRecipe = RecipeEntity(
        id: 3,
        name: 'Chocolate Lava Cake',
        image: '',
        ingredients: [],
        instructions: [],
        prepTimeMinutes: 15,
        cookTimeMinutes: 20,
        rating: 4.9,
        reviewCount: 120,
        mealType: ['Dessert'],
        tags: ['Sweet', 'Cake'],
        cuisine: 'French',
        difficulty: 'Medium',
        servings: 2,
        price: 9.0,
      );

      // Verify category rules
      expect(
        CategoryMappingService.matchesCategory(mealRecipe, RecipeCategory.meal),
        isTrue,
      );
      expect(
        CategoryMappingService.matchesCategory(
          mealRecipe,
          RecipeCategory.dessert,
        ),
        isFalse,
      );

      expect(
        CategoryMappingService.matchesCategory(
          veganRecipe,
          RecipeCategory.vegan,
        ),
        isTrue,
      );
      expect(
        CategoryMappingService.matchesCategory(
          dessertRecipe,
          RecipeCategory.dessert,
        ),
        isTrue,
      );
    });

    test('FakeRecipeRepository returns expected paginated results', () async {
      final mockList = List.generate(
        25,
        (i) => RecipeEntity(
          id: i + 1,
          name: 'Recipe #${i + 1}',
          image: '',
          ingredients: [],
          instructions: [],
          prepTimeMinutes: 10,
          cookTimeMinutes: 15,
          rating: 4.5,
          reviewCount: 10,
          mealType: ['Dinner'],
          tags: [],
          cuisine: 'General',
          difficulty: 'Easy',
          servings: 2,
          price: 10.0,
        ),
      );

      final repo = FakeRecipeRepository(mockList);
      final page1 = await repo.getRecipes(limit: 20, skip: 0);

      expect(page1.recipes.length, equals(20));
      expect(page1.total, equals(25));
      expect(page1.hasMore, isTrue);

      final page2 = await repo.getRecipes(limit: 20, skip: 20);
      expect(page2.recipes.length, equals(5));
      expect(page2.hasMore, isFalse);
    });
  });
}
