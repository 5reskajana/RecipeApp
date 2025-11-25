import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/meal_summary.dart';
import '../models/meal_detail.dart';

class ApiService {
  ApiService._();
  static const _base = 'https://www.themealdb.com/api/json/v1/1';

  static Future<List<Category>> fetchCategories() async {
    final url = Uri.parse('$_base/categories.php');
    final res = await http.get(url);
    if (res.statusCode != 200) throw Exception('Failed to load categories');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (data['categories'] as List<dynamic>).cast<Map<String, dynamic>>();
    return list.map((e) => Category.fromJson(e)).toList();
  }

  static Future<List<MealSummary>> fetchMealsByCategory(String category) async {
    final url = Uri.parse('$_base/filter.php?c=$category');
    final res = await http.get(url);
    if (res.statusCode != 200) throw Exception('Failed to load meals');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (data['meals'] == null) return [];
    final list = (data['meals'] as List<dynamic>).cast<Map<String, dynamic>>();
    return list.map((e) => MealSummary.fromJson(e)).toList();
  }

  static Future<List<MealDetail>> searchMeals(String query) async {
    final url = Uri.parse('$_base/search.php?s=$query');
    final res = await http.get(url);
    if (res.statusCode != 200) throw Exception('Search failed');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (data['meals'] == null) return [];
    final list = (data['meals'] as List<dynamic>).cast<Map<String, dynamic>>();
    return list.map((e) => MealDetail.fromJson(e)).toList();
  }

  static Future<MealDetail?> lookupMeal(String id) async {
    final url = Uri.parse('$_base/lookup.php?i=$id');
    final res = await http.get(url);
    if (res.statusCode != 200) throw Exception('Lookup failed');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (data['meals'] == null) return null;
    return MealDetail.fromJson((data['meals'] as List).first as Map<String, dynamic>);
  }

  static Future<MealDetail?> randomMeal() async {
    final url = Uri.parse('$_base/random.php');
    final res = await http.get(url);
    if (res.statusCode != 200) throw Exception('Random failed');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (data['meals'] == null) return null;
    return MealDetail.fromJson((data['meals'] as List).first as Map<String, dynamic>);
  }
  static Future<MealDetail?> fetchRandomMeal() async {
    final url = Uri.parse('https://www.themealdb.com/api/json/v1/1/random.php');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final meals = data['meals'];
      if (meals != null && meals.isNotEmpty) {
        return MealDetail.fromJson(meals[0]);
      }
    }
    return null;
  }

}
