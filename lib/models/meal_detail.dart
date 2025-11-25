class MealDetail {
  final String idMeal;
  final String strMeal;
  final String strCategory;
  final String? strArea;
  final String? strInstructions;
  final String? strMealThumb;
  final String? strYoutube;
  final Map<String, String> ingredients;

  MealDetail({
    required this.idMeal,
    required this.strMeal,
    required this.strCategory,
    this.strArea,
    this.strInstructions,
    this.strMealThumb,
    this.strYoutube,
    required this.ingredients,
  });

  factory MealDetail.fromJson(Map<String, dynamic> json) {
    // Extract up to 20 ingredients/measures
    final Map<String, String> ingredients = {};
    for (int i = 1; i <= 20; i++) {
      final ing = json['strIngredient$i'] as String?;
      final meas = json['strMeasure$i'] as String?;
      if (ing != null && ing.trim().isNotEmpty) {
        ingredients[ing.trim()] = (meas ?? '').trim();
      }
    }

    return MealDetail(
      idMeal: json['idMeal'] as String,
      strMeal: json['strMeal'] as String,
      strCategory: json['strCategory'] as String,
      strArea: json['strArea'] as String?,
      strInstructions: json['strInstructions'] as String?,
      strMealThumb: json['strMealThumb'] as String?,
      strYoutube: json['strYoutube'] as String?,
      ingredients: ingredients,
    );
  }
}
