import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/failure_mapper.dart';
import '../models/recipe_model.dart';

class RecipeRemoteDataSource {
  final Dio _dio;

  RecipeRemoteDataSource(this._dio);

  Future<RecipePaginationModel> getRecipes({
    int limit = 20,
    int skip = 0,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.recipes,
        queryParameters: {'limit': limit, 'skip': skip},
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200 && response.data != null) {
        return RecipePaginationModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw FailureMapper.fromException('Failed to fetch recipes');
    } on DioException catch (e) {
      throw FailureMapper.fromDioException(e);
    } catch (e) {
      throw FailureMapper.fromException(e);
    }
  }

  Future<RecipePaginationModel> searchRecipes({
    required String query,
    int limit = 20,
    int skip = 0,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.searchRecipes,
        queryParameters: {'q': query.trim(), 'limit': limit, 'skip': skip},
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200 && response.data != null) {
        return RecipePaginationModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw FailureMapper.fromException('Failed to search recipes');
    } on DioException catch (e) {
      throw FailureMapper.fromDioException(e);
    } catch (e) {
      throw FailureMapper.fromException(e);
    }
  }

  Future<RecipeModel> getRecipeById(int id, {CancelToken? cancelToken}) async {
    try {
      final response = await _dio.get(
        ApiConstants.recipeDetail(id),
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200 && response.data != null) {
        return RecipeModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw FailureMapper.fromException('Recipe not found');
    } on DioException catch (e) {
      throw FailureMapper.fromDioException(e);
    } catch (e) {
      throw FailureMapper.fromException(e);
    }
  }
}
