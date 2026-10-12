class RecipeEntity {
  final int id;
  final String name;
  final String image;
  final List<String> ingredients;
  final List<String> instructions;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final double rating;
  final int reviewCount;
  final List<String> mealType;
  final List<String> tags;
  final String cuisine;
  final String difficulty;
  final int servings;
  final int? caloriesPerServing;
  final double price; // Stable mock price calculated deterministically

  const RecipeEntity({
    required this.id,
    required this.name,
    required this.image,
    required this.ingredients,
    required this.instructions,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.rating,
    required this.reviewCount,
    required this.mealType,
    required this.tags,
    required this.cuisine,
    required this.difficulty,
    required this.servings,
    this.caloriesPerServing,
    required this.price,
  });

  int get totalTimeMinutes => prepTimeMinutes + cookTimeMinutes;
}

class RecipePaginationEntity {
  final List<RecipeEntity> recipes;
  final int total;
  final int skip;
  final int limit;

  const RecipePaginationEntity({
    required this.recipes,
    required this.total,
    required this.skip,
    required this.limit,
  });

  bool get hasMore => (skip + recipes.length) < total;
}
