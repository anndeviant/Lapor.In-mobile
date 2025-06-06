import 'package:logger/logger.dart';
import '../models/report_category.dart';
import 'base_network.dart';

class CategoryService {
  static final Logger _logger = Logger();

  static Future<List<ReportCategory>> getCategories() async {
    _logger.i('Fetching report categories');

    try {
      final response = await BaseNetwork.get('/public/categories');
      _logger.d('Categories response: $response');

      // Handle both array and object responses
      List<dynamic> categoriesData;

      if (response is List) {
        categoriesData = response;
      } else if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          final data = response['data'];
          if (data is List) {
            categoriesData = data;
          } else if (data is Map) {
            categoriesData = [data];
          } else {
            throw Exception('Unexpected data format');
          }
        } else if (response.containsKey('categories')) {
          final cats = response['categories'];
          if (cats is List) {
            categoriesData = cats;
          } else if (cats is Map) {
            categoriesData = [cats];
          } else {
            throw Exception('Unexpected categories format');
          }
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Unexpected response format');
      }

      return categoriesData
          .map((json) => ReportCategory.fromJson(json))
          .toList();
    } catch (e) {
      _logger.e('Error fetching categories: $e');
      rethrow;
    }
  }
}
