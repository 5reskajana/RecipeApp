import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/meal_detail.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MealDetailScreen extends StatelessWidget {
  final MealDetail mealDetail;

  const MealDetailScreen({Key? key, required this.mealDetail}) : super(key: key);

  Future<void> _openYoutube(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Cannot launch URL: $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    final ingredients = mealDetail.ingredients.entries.toList();

    final bool hasYoutubeLink = mealDetail.strYoutube != null && mealDetail.strYoutube!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(mealDetail.strMeal)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mealDetail.strMealThumb != null)
              CachedNetworkImage(
                imageUrl: mealDetail.strMealThumb!,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mealDetail.strMeal,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (mealDetail.strArea != null)
                    Text('Cuisine: ${mealDetail.strArea}'),
                  const SizedBox(height: 8),


                  const Text('Ingredients:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...ingredients.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text('- ${e.key} — ${e.value}'),
                  )),
                  const SizedBox(height: 12),

                  const Text('Instructions:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(mealDetail.strInstructions ?? 'No instructions available'),
                  const SizedBox(height: 12),

                  if (hasYoutubeLink)
                    ElevatedButton.icon(
                      onPressed: () => _openYoutube(mealDetail.strYoutube!),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text("Watch on YouTube"),
                    ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}