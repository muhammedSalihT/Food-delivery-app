import '../../domain/entities/recipe_entity.dart';

enum RecipeCategory {
  all('All'),
  snacks('Snacks'),
  meal('Meal'),
  vegan('Vegan'),
  dessert('Dessert'),
  drinks('Drinks');

  final String title;
  const RecipeCategory(this.title);
}

class CategoryMappingService {
  CategoryMappingService._();

  /// Centralized mapping rule according to specification:
  /// - Meal: mealType contains 'Lunch' or 'Dinner'
  /// - Vegan: tags explicitly contain 'vegan' or 'plant-based' (not just vegetable)
  /// - Dessert: mealType contains 'Dessert' or tags contains 'dessert' / 'sweet'
  /// - Snacks: mealType contains 'Snack' or 'Appetizer' or tags contain 'snack'
  /// - Drinks: tags/mealType contains 'beverage', 'drink', 'smoothie', or fallback check
  static bool matchesCategory(RecipeEntity recipe, RecipeCategory category) {
    if (category == RecipeCategory.all) return true;

    final lowerMealTypes = recipe.mealType.map((e) => e.toLowerCase()).toList();
    final lowerTags = recipe.tags.map((e) => e.toLowerCase()).toList();
    final lowerName = recipe.name.toLowerCase();

    switch (category) {
      case RecipeCategory.meal:
        return lowerMealTypes.any(
          (m) =>
              m.contains('lunch') ||
              m.contains('dinner') ||
              m.contains('main') ||
              m.contains('meal'),
        );

      case RecipeCategory.vegan:
        return lowerTags.any(
              (t) =>
                  t.contains('vegan') ||
                  t.contains('plant-based') ||
                  t.contains('vegetarian'),
            ) ||
            lowerName.contains('vegan') ||
            lowerName.contains('salad');

      case RecipeCategory.dessert:
        return lowerMealTypes.any((m) => m.contains('dessert')) ||
            lowerTags.any(
              (t) =>
                  t.contains('dessert') ||
                  t.contains('sweet') ||
                  t.contains('cake') ||
                  t.contains('cookie') ||
                  t.contains('pie'),
            ) ||
            lowerName.contains('dessert') ||
            lowerName.contains('cookie') ||
            lowerName.contains('cake');

      case RecipeCategory.snacks:
        return lowerMealTypes.any(
              (m) =>
                  m.contains('snack') ||
                  m.contains('appetizer') ||
                  m.contains('breakfast'),
            ) ||
            lowerTags.any(
              (t) =>
                  t.contains('snack') ||
                  t.contains('appetizer') ||
                  t.contains('side dish'),
            ) ||
            lowerName.contains('snack') ||
            lowerName.contains('toast');

      case RecipeCategory.drinks:
        // Beverage fallback check
        return lowerMealTypes.any(
              (m) =>
                  m.contains('beverage') ||
                  m.contains('drink') ||
                  m.contains('cocktail'),
            ) ||
            lowerTags.any(
              (t) =>
                  t.contains('drink') ||
                  t.contains('beverage') ||
                  t.contains('smoothie') ||
                  t.contains('shake') ||
                  t.contains('cocktail'),
            ) ||
            lowerName.contains('drink') ||
            lowerName.contains('smoothie') ||
            lowerName.contains('shake') ||
            lowerName.contains('juice') ||
            lowerName.contains('tea');

      case RecipeCategory.all:
        return true;
    }
  }

  static List<RecipeEntity> filterByCategory(
    List<RecipeEntity> recipes,
    RecipeCategory category,
  ) {
    if (category == RecipeCategory.all) return recipes;
    return recipes.where((r) => matchesCategory(r, category)).toList();
  }
}
