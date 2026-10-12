import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class LocalCacheService {
  static const String recipesBoxName = 'cached_recipes';
  static const String cartBoxName = 'cart_items';
  static const String firstPageKey = 'first_page_recipes';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(recipesBoxName);
    await Hive.openBox<String>(cartBoxName);
  }

  // Recipes Caching
  static Future<void> cacheFirstPageRecipes(String jsonString) async {
    final box = Hive.box<String>(recipesBoxName);
    await box.put(firstPageKey, jsonString);
  }

  static String? getFirstPageRecipes() {
    final box = Hive.box<String>(recipesBoxName);
    return box.get(firstPageKey);
  }

  // Cart Persistence
  static Future<void> saveCartItems(List<Map<String, dynamic>> items) async {
    final box = Hive.box<String>(cartBoxName);
    await box.put('items', jsonEncode(items));
  }

  static List<Map<String, dynamic>> getCartItems() {
    try {
      final box = Hive.box<String>(cartBoxName);
      final raw = box.get('items');
      if (raw == null || raw.isEmpty) return [];
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> clearCart() async {
    final box = Hive.box<String>(cartBoxName);
    await box.delete('items');
  }
}
