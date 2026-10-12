class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://dummyjson.com';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  // Endpoints
  static const String login = '/auth/login';
  static const String recipes = '/recipes';
  static const String searchRecipes = '/recipes/search';
  static String recipeDetail(int id) => '/recipes/$id';

  // Demo Credentials
  static const String demoUsername = 'emilys';
  static const String demoPassword = 'emilyspass';
}
