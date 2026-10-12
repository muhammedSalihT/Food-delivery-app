import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../features/recipes/domain/services/category_mapping_service.dart';

class CategoryChipsRow extends StatelessWidget {
  final RecipeCategory selectedCategory;
  final ValueChanged<RecipeCategory> onSelected;

  const CategoryChipsRow({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  IconData _getCategoryIcon(RecipeCategory category) {
    switch (category) {
      case RecipeCategory.all:
        return Icons.restaurant_menu_rounded;
      case RecipeCategory.snacks:
        return Icons.fastfood_rounded;
      case RecipeCategory.meal:
        return Icons.dinner_dining_rounded;
      case RecipeCategory.vegan:
        return Icons.eco_rounded;
      case RecipeCategory.dessert:
        return Icons.cake_rounded;
      case RecipeCategory.drinks:
        return Icons.local_bar_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = RecipeCategory.values;

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == selectedCategory;

          return GestureDetector(
            onTap: () => onSelected(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    _getCategoryIcon(cat),
                    size: 18,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    cat.title,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
