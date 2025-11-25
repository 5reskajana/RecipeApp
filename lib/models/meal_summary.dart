class MealSummary {
  final String idMeal;
  final String strMeal;
  final String strMealThumb;

  MealSummary({
    required this.idMeal,
    required this.strMeal,
    required this.strMealThumb,
  });

  factory MealSummary.fromJson(Map<String, dynamic> json) => MealSummary(
    idMeal: json['idMeal'] as String,
    strMeal: json['strMeal'] as String,
    strMealThumb: json['strMealThumb'] as String,
  );
}
