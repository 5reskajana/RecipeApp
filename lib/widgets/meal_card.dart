import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meal_summary.dart';
import '../services/favorites_service.dart';

class MealCard extends StatefulWidget {
  final MealSummary meal;
  final VoidCallback onTap;

  const MealCard({Key? key, required this.meal, required this.onTap}) : super(key: key);

  @override
  State<MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<MealCard> {
  final FavoritesService favoritesService = FavoritesService();

  void toggleFavorite(bool currentIsFavorite) {
    if (currentIsFavorite) {
      favoritesService.removeFavorite(widget.meal.idMeal);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.meal.strMeal} removed from favorites!')),
      );
    } else {
      favoritesService.addFavorite(
        widget.meal.idMeal,
        widget.meal.strMeal,
        widget.meal.strMealThumb,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.meal.strMeal} added to favorites!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: widget.meal.strMealThumb,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.meal.strMeal,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  StreamBuilder<DocumentSnapshot>(
                    stream: favoritesService.isFavoriteStream(widget.meal.idMeal),
                    builder: (context, snapshot) {
                      final isFavorite = snapshot.hasData && snapshot.data!.exists;

                      return IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                        ),
                        onPressed: () => toggleFavorite(isFavorite),
                      );
                    },
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