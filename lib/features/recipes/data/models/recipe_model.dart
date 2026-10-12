import '../../../../core/utils/price_calculator.dart';
import '../../domain/entities/recipe_entity.dart';

class RecipeModel extends RecipeEntity {
  const RecipeModel({
    required super.id,
    required super.name,
    required super.image,
    required super.ingredients,
    required super.instructions,
    required super.prepTimeMinutes,
    required super.cookTimeMinutes,
    required super.rating,
    required super.reviewCount,
    required super.mealType,
    required super.tags,
    required super.cuisine,
    required super.difficulty,
    required super.servings,
    super.caloriesPerServing,
    required super.price,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? 0) as int;
    final ratingNum = json['rating'];
    final rating = (ratingNum is num) ? ratingNum.toDouble() : 4.5;

    return RecipeModel(
      id: id,
      name: (json['name'] ?? 'Delicious Dish') as String,
      image: (json['image'] ?? '') as String,
      ingredients:
          (json['ingredients'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      instructions:
          (json['instructions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      prepTimeMinutes: (json['prepTimeMinutes'] ?? 15) as int,
      cookTimeMinutes: (json['cookTimeMinutes'] ?? 20) as int,
      rating: rating,
      reviewCount: (json['reviewCount'] ?? 10) as int,
      mealType:
          (json['mealType'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      cuisine: (json['cuisine'] ?? 'International') as String,
      difficulty: (json['difficulty'] ?? 'Easy') as String,
      servings: (json['servings'] ?? 2) as int,
      caloriesPerServing: json['caloriesPerServing'] as int?,
      price: PriceCalculator.calculatePrice(id),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'ingredients': ingredients,
      'instructions': instructions,
      'prepTimeMinutes': prepTimeMinutes,
      'cookTimeMinutes': cookTimeMinutes,
      'rating': rating,
      'reviewCount': reviewCount,
      'mealType': mealType,
      'tags': tags,
      'cuisine': cuisine,
      'difficulty': difficulty,
      'servings': servings,
      'caloriesPerServing': caloriesPerServing,
      'price': price,
    };
  }
}

class RecipePaginationModel extends RecipePaginationEntity {
  const RecipePaginationModel({
    required super.recipes,
    required super.total,
    required super.skip,
    required super.limit,
  });

  factory RecipePaginationModel.fromJson(Map<String, dynamic> json) {
    final rawRecipes = (json['recipes'] as List<dynamic>?) ?? [];
    final recipes = rawRecipes
        .map((e) => RecipeModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return RecipePaginationModel(
      recipes: recipes,
      total: (json['total'] ?? recipes.length) as int,
      skip: (json['skip'] ?? 0) as int,
      limit: (json['limit'] ?? 20) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipes': recipes.map((e) {
        if (e is RecipeModel) return e.toJson();
        return {
          'id': e.id,
          'name': e.name,
          'image': e.image,
          'ingredients': e.ingredients,
          'instructions': e.instructions,
          'prepTimeMinutes': e.prepTimeMinutes,
          'cookTimeMinutes': e.cookTimeMinutes,
          'rating': e.rating,
          'reviewCount': e.reviewCount,
          'mealType': e.mealType,
          'tags': e.tags,
          'cuisine': e.cuisine,
          'difficulty': e.difficulty,
          'servings': e.servings,
          'caloriesPerServing': e.caloriesPerServing,
          'price': e.price,
        };
      }).toList(),
      'total': total,
      'skip': skip,
      'limit': limit,
    };
  }
}
