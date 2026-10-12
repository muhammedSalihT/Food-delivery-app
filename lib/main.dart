import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/storage/local_cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive storage for offline caching & persistent cart
  await LocalCacheService.init();

  runApp(const ProviderScope(child: FoodDeliveryApp()));
}
