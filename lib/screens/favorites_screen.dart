import 'package:flutter/material.dart';

import '../services/favorites_service.dart';

import '../screens/meal_detail_screen.dart';

import '../services/api_service.dart';

import '../models/meal_summary.dart';

import '../widgets/meal_card.dart';

class FavoritesScreen extends StatelessWidget {
  final FavoritesService favService = FavoritesService();

  FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Favorite Recipes")),

      body: StreamBuilder(
        stream: favService.getFavorites(),

        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty)
            return const Center(child: Text("No favorite recipes yet."));

          // Map to MealSummary

          final favorites = docs
              .map(
                (doc) => MealSummary(
                  idMeal: doc['id'],

                  strMeal: doc['title'],

                  strMealThumb: doc['image'],
                ),
              )
              .toList();

          return GridView.builder(
            padding: const EdgeInsets.all(8),

            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,

              mainAxisSpacing: 8,

              crossAxisSpacing: 8,

              childAspectRatio: 0.75,
            ),

            itemCount: favorites.length,

            itemBuilder: (context, index) {
              final meal = favorites[index];

              return MealCard(
                meal: meal,

                onTap: () async {
                  final detail = await ApiService.lookupMeal(meal.idMeal);

                  if (detail != null && context.mounted) {
                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) => MealDetailScreen(mealDetail: detail),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
